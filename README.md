# MedStore Flutter apps

One Dart pub workspace: two apps and two shared packages. One `pubspec.lock` at this root.

```
medstore_flutter/
├─ pubspec.yaml              workspace root (not an app)
├─ analysis_options.yaml     shared lints + formatter (page width 110); members include it
├─ packages/
│  ├─ medstore_core/         logic both apps share: Result/Failure, network, cache, realtime, auth, settings
│  └─ medstore_ui/           design system: tokens, Cupertino theme, components, ar/fr strings (drawing only)
└─ apps/
   ├─ medstore_admin/        Windows desktop, the MedStore team   (accepts every role except Client)
   └─ medstore_teacher/      Android / iOS, teachers               (accepts the Client role only)
```

`medstore_ui` depends on `medstore_core` (to show a `Failure`), never the reverse.

## Commands (run from this folder)

```bash
flutter pub get                      # resolves the whole workspace
flutter analyze apps packages
dart format apps packages
```

```bash
cd apps/medstore_admin && flutter run -d windows --dart-define-from-file=env/dev.json
cd apps/medstore_teacher && flutter run --dart-define-from-file=env/dev.json
```

Tests run per package: `cd <package> && flutter test`. After editing an `.arb` file:
`cd packages/medstore_ui && flutter gen-l10n`.

`env/dev.json` holds `API_BASE_URL` (admin: `https://localhost:60612`; teacher: `http://10.0.2.2:60613`, the
PC as seen from the Android emulator). The API redirects plain http to https (307), and Dio does not follow a
redirect on a POST, so point an app at the https port wherever its certificate is trusted. Add `env/prod.json` with the https URL for releases. Nothing secret
goes in these files: anything compiled into an app can be read from it.

## Clean Architecture

Every feature has three layers. Dependencies point inward only: presentation → domain ← data.

```
features/<feature>/
├─ domain/         pure Dart: entities, repository interfaces, use cases. No Flutter, no HTTP, no JSON.
├─ data/           models (JSON ↔ entity), remote data sources, repository implementations
└─ presentation/   Cubits/Blocs (in core when shared); pages and widgets live in the app
```

- **Where a feature lives:** used by both apps → `packages/medstore_core/lib/src/features/`. Used by one app
  → that app's `lib/features/`. Admin-only features (debts, invoices, wallet, permissions) never go in core,
  so the teacher app never contains them.
- **Errors are values.** Repositories and use cases return `Result<T>` (`Ok` / `Err(Failure)`); nothing
  throws across a layer. `FailureMapper` turns HTTP into `Failure`: 400/422 → `ValidationFailure` (with the
  API's per-field errors), 401 → `UnauthorizedFailure`, 403 → `ForbiddenFailure` (with `deniedFields`),
  404, 409 → `ConflictFailure`, 5xx → `ServerFailure`, no connection → `NetworkFailure`. The UI shows
  `failureText(strings, failure)`: the *type* picks the sentence, in the user's language.
- **Presentation calls use cases**, never repositories or data sources.
- **State:** `flutter_bloc`. Prefer a `Cubit`; use a `Bloc` when events need transformers (debounced
  search, drop-while-busy submit). States are immutable and `Equatable`, or a `sealed` class.
- **DI:** `get_it`. `registerCoreModule(sl, appRole: …)` registers everything shared; each app's
  `lib/app/di/injection.dart` adds its own features after it. Data sources, repositories and use cases are
  lazy singletons; screen Cubits are factories handed to `BlocProvider`; `AuthCubit` and `LocaleCubit` are
  app-wide singletons. Only `main`, the app root and route builders call `sl`.
- **Each package's public API is its library file** (`medstore_core.dart`, `medstore_ui.dart`). The rest of
  `src/` stays private.
- **Sign-in is per app:** `SignIn` / `RestoreSession` refuse an account from the other app with
  `WrongAppFailure` (and sign it out). The server still enforces every permission.
- **Fields the user may not read arrive as `null`:** model them nullable in data models and entities.

## Connectivity (`medstore_core/lib/src/core/`)

| Piece | What it does |
| --- | --- |
| `network/api_client.dart` | `ApiClient.get/post/put/delete` → `Result<T>`. Dio with `X-Api-Version: 1`, timeouts, and `BackgroundTransformer` (large JSON is decoded off the UI thread). |
| `network/token_store.dart` | Access token **in memory only**; refresh token and last user in secure storage. |
| `network/auth_interceptor.dart` | Adds the Bearer token. Refreshes *before* a request when the token expires within 30 s; on a 401, refreshes once and retries once. |
| `network/token_refresher.dart` | **One refresh at a time** (refresh tokens are single use). Parallel callers share the same refresh. A refused refresh clears the session and fires `sessionExpired` → login screen. Offline keeps the session. |
| `cache/hybrid_cache.dart` | Memory LRU (200 entries) in front of a hive_ce box on disk. `fetch()` is stale-while-revalidate: cached data at once, then fresh data; offline it keeps showing the cache instead of an error. Keys are scoped to the user; everything is wiped on sign-out. |
| `realtime/realtime_client.dart` | SignalR to `/hubs/notifications` with the same token, automatic reconnect, and retries until the hub exists. Started on sign-in, stopped on sign-out. **The hub is not on the API yet.** |

A repository that reads a list:

```dart
Stream<Result<List<Product>>> watchProducts({bool refresh = false}) => _cache.fetch(
  key: 'products',
  maxAge: const Duration(minutes: 5),
  forceRefresh: refresh, // pull to refresh
  fetch: () => _api.get('/api/products', decode: ApiClient.rawJson),
  decode: ProductModel.listFromJson,
);
```

After a write, `await _cache.invalidate('products')` (a prefix: it drops every key that starts with it).

## Features

### Products (the template for the next features)

| Where | What |
| --- | --- |
| `medstore_core/.../features/products/` | **Reading, shared:** `Product`, `ProductQuery`, `ProductRepository` (`GET /api/products`, lists cached 5 min), `WatchProducts` / `GetProduct`, `ProductsCubit` (search, filters, endless scroll, pull to refresh), `ProductDetailCubit`, `ProductImages` (covers through the authenticated API). |
| `medstore_ui/.../features/products/` | Drawing only: `productTypeText`, `ProductAvailabilityBadge`, `ProductPrice` (shows "Price hidden" for a `null` price, never 0 DA). |
| `apps/medstore_teacher/.../features/products/` | The teacher's list (large title, search, pull to refresh) and the detail page. |
| `apps/medstore_admin/.../features/products/` | **Writing, admin only:** `ProductDraft` (form values + the server's rules), `AdminProductRepository` (`/api/admin/products`), `CreateProduct` / `UpdateProduct` / `ChangeProductCover` / `DeleteProduct`, `ProductFormCubit`, the list page, the form page, the cover editor and the teacher picker. Routes in `products_routes.dart`. |

- **Server errors land on their field:** `fieldProblemsFrom` maps the API's error codes (`Product.NameRequired`,
  `Product.CodeExists`, `Product.ImageTooLarge`, …) to form fields, shown in the user's language.
- **No duplicates on retry:** if a new product is saved but its cover upload fails, "Save" again updates that
  product instead of creating a second one.
- **After a change** the admin repository drops the cached product lists and the old cover image.
- **Permissions:** the `Client` role is not granted `Product` yet, so the teacher app gets 403 ("not allowed")
  on its products until permissions are seeded (planned for the end, with the other grants).

### Admin features (`apps/medstore_admin/lib/features/`)

Each is `domain/` (entities, drafts with the server's rules, repository interface and use cases), `data/`
(the `*_repository_impl.dart` talking to `/api/admin/...`) and `presentation/` (pages, dialogs, routes).

| Section | Endpoints | Screens |
| --- | --- | --- |
| Dashboard | `reports/summary` | the period and today's position |
| Orders | `orders` list/POST/PUT/`{id}/status`; one order via core `GetOrder` (`/api/orders/{id}`) | list with filters, detail with timeline and moves, editor (new for a teacher / revise) |
| Products | `products` (list by teacher through core `ProductRepositoryImpl(listPath:)`), POST/PUT/DELETE, image | list, form, cover |
| Teachers | `clients` list/GET/POST/PUT/deactivate, `{id}/statement[/pdf]` | list, form (with sign-in account), detail with statement and PDF |
| Schools | `schools` list (cached 10 min)/POST/PUT | list, form |
| Invoices | `invoices` list/`uninvoiced`/POST/`void`/`settle`; one invoice and PDF via `/api/invoices/{id}` | list, detail, new invoice from uninvoiced copies |
| Wallet | `wallets` list/`{clientId}`/transactions/deposits/withdrawals/settle/`transactions/{id}/void`; receipts via `/api/wallet/...` | balances, ledger with receipts and voids, deposit and withdrawal dialogs |
| Debts | `debts` overview/`clients/{id}`/`{id}`/POST/settle/write-off | overview, per teacher, debt dialog |
| Reports | `reports/sales?groupBy=` | sales table |
| Security | `security/resources`, `security/roles/{name}/matrix`, `roles`, `roles/{name}/permissions`, `users`, `users/{id}/roles`, `users/{id}/deactivate` | roles, users, resources, a role's permission grid |
| Settings | `settings/billing`, `auth/change-password` | billing, password, language |

- **Shared screen state** (core): `PagedListCubit<T, F>` for every filtered, endless list (an answer to an older
  filter is dropped), `LoadCubit<T>` for a detail or report, `SubmitCubit<T>` for one action at a time.
- **Admin glue** (`apps/medstore_admin/lib/app/`): `PagedTable` (an `AppTable` fed by a `PagedListCubit`),
  `SubmitDialog` (a form dialog that saves, shows the refusal, closes with the answer), `PeriodBar`,
  `savePdf` (download, ask where, write), `problemText` (an API rule code → its sentence) and `l10n/labels.dart`
  (every domain value → its words and `AppTone`).
- **Money is never cached**: wallets, invoices, debts and reports always come fresh.
- **Live check:** `test/live/live_api_test.dart` runs every admin feature against the running API through these
  repositories (it creates its own "Live …" data). Skipped unless `MEDSTORE_ADMIN_PASSWORD` is set; set
  `MEDSTORE_API_URL=https://localhost:60612`.

## UI (`medstore_ui`)

- **Cupertino, Apple-style**, after deptsManager: grouped canvas, white cards with hairlines, a translucent
  macOS-style sidebar on desktop, an iOS tab bar and large titles on mobile.
- **Colors** from the logo: garnet `#C4143F` for actions and selection, teal only for "done / paid /
  delivered", iOS red for destructive actions. All tokens are `CupertinoDynamicColor`, so light and dark
  follow the system with one theme. Use `AppColors.x.resolveFrom(context)` in widgets.
- **Languages:** Arabic and French (`lib/src/l10n/app_ar.arb`, `app_fr.arb`; French is the template).
  The device language is used when it is one of them, otherwise Arabic; the user can switch on the login
  screen and in settings/profile (saved on the device). **Arabic is right-to-left:** use
  `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `BorderDirectional` — never
  left/right.
- **Routing:** go_router. A guard follows `AuthCubit`: start-up → splash, signed out → login, signed in →
  the app. Sections are `StatefulShellRoute.indexedStack` branches, so each keeps its state.
- **Fonts:** none bundled; each platform's system font covers Arabic and French.

### Component catalog

See them all live, in both languages and both brightnesses:
`cd packages/medstore_ui/example && flutter run -d chrome` (the "ui-gallery" entry in `.claude/launch.json`
serves it on http://localhost:8099).

| Group | Components |
| --- | --- |
| Buttons | `AppButton` (filled / tinted / plain / destructive, regular / small, `isLoading`, `expand`), `AppIconButton` (tooltip + screen-reader label required) |
| Inputs | `AppTextField` (top label, error, password eye), `AppSearchField` (300 ms debounce), `AppSegmentedControl<T>`, `AppQuantityStepper`, `LanguageSwitch`, `AppFieldLabel`, `AppFieldBox` (a tappable field), `AppSelectField<T>` (action sheet, optional "All"), `AppDateField`, `AppSwitchRow`, `AppCheckbox` |
| Display | `AppBadge`, `AppMoney` (DZD, tabular digits), `AppAvatar` (initials), `AppMetricCard`, `AppLogo`, `AppInfoRow` (label · value, "—" when hidden) |
| Lists | `AppSection` (grouped iOS card), `AppListTile` (leading / title / subtitle / trailing, chevron when tappable), `AppTable` + `AppTableColumn` (desktop table, lazy rows, endless scroll, `shrinkWrap` for short lists) |
| Surfaces | `AppCard` (optional `onTap`), `Pressable` (the hover/press behaviour every tappable surface shares) |
| Feedback | `AppLoadView` (data → loading → error → empty, in that order), `AppEmptyState`, `AppErrorState`, `AppMessage`, `AppSkeleton` / `AppSkeletonPulse` / `AppSkeletonList`, `showAppConfirmDialog`, `showAppToast`, `AppDialog` / `showAppDialog`, `showAppTextPrompt` (a reason, a note) |
| Navigation | `AppSidebar`, `AppPageHeader` (optional back button) |
| Helpers | `AppTone`, `MoneyFormat.dzd`, `AppDateFormat`, `failureText`, `LoginForm` |

### Writing a component

- **One component per file**, in the folder of its group, exported from `lib/medstore_ui.dart`.
- **A doc comment with a usage example** on every public widget; say *when* to use it, not only what it is.
- **Meaning, not colors:** take an `AppTone` (neutral, brand, success, warning, danger, info), never a
  `Color`. Map domain values to tones in the feature (`OrderStatus.ready → AppTone.success`), so the design
  system knows nothing about orders or invoices.
- **No business logic, no Cubits, no API** in `medstore_ui`. Screens pass data and callbacks in.
- **Strings come in as parameters**; only generic words (Cancel, Retry, Search) come from `AppStrings`.
- **Accessible by default:** icon-only buttons require a label; tappable things are `Semantics(button:)`;
  messages that appear are `liveRegion`.
- **RTL by construction:** directional paddings/alignments only, and check the gallery in Arabic.
- **Motion through `AppDurations.of(context, …)`**, so reduced motion turns it off.
- **A behaviour gets a widget test** (`packages/medstore_ui/test/`): debounce, bounds, ordering, dialogs.
- Prefer plain `if`s and small private widgets over clever expressions: code is read far more than written.

## Performance rules

- `const` everywhere it compiles. Missing `const` is an analyzer **error** here, not a hint.
- Rebuild the smallest widget: `BlocSelector` or `buildWhen` instead of a `BlocBuilder` around a whole page;
  `context.select` for one field.
- Lists: always `ListView.builder` / `SliverList.builder` (lazy), give `itemExtent` or `prototypeItem` when
  rows share a height, paginate from the API instead of loading everything.
- Large JSON is already decoded off the UI thread (Dio's `BackgroundTransformer`; `HybridCache` uses
  `Isolate.run` above 50 KB). Do the same for any other heavy parsing.
- Images: set `cacheWidth`/`cacheHeight` to the size shown (see `AppLogo`), so a 4000 px cover is not
  decoded for a 64 px tile.
- Wrap independently animating or frequently repainting areas in `RepaintBoundary`.
- No work in `build()`: no sorting, filtering, formatting of big lists, or creating controllers there.
- Every animation duration goes through `AppDurations.of(context, …)`, which honours "reduce motion".
- Measure in profile mode (`flutter run --profile`) with DevTools, never in debug.
- Release builds: `--obfuscate --split-debug-info=build/symbols`.
