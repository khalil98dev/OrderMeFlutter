import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

import 'sections/buttons_section.dart';
import 'sections/display_section.dart';
import 'sections/feedback_section.dart';
import 'sections/forms_section.dart';
import 'sections/inputs_section.dart';
import 'sections/lists_section.dart';
import 'sections/motion_section.dart';
import 'sections/navigation_section.dart';
import 'sections/tables_section.dart';
import 'sections/tokens_section.dart';
import 'widgets/gallery_section.dart';

/// The whole catalog on one scrolling page, with the language and brightness switches on top.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.brightness,
    required this.onBrightnessChanged,
    required this.onLocaleChanged,
  });

  final Brightness brightness;
  final ValueChanged<Brightness> onBrightnessChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const Center(widthFactor: 1, child: AppLogo(size: 28)),
        middle: const Text('MedStore UI'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LanguageSwitch(current: Localizations.localeOf(context), onChanged: onLocaleChanged),
            const SizedBox(width: AppSpacing.xs),
            AppSegmentedControl<Brightness>(
              segments: {
                Brightness.light: tr(context, 'Clair', 'فاتح'),
                Brightness.dark: tr(context, 'Sombre', 'داكن'),
              },
              selected: brightness,
              onChanged: onBrightnessChanged,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            _Centered(child: TokensSection()),
            _Centered(child: ButtonsSection()),
            _Centered(child: InputsSection()),
            _Centered(child: FormsSection()),
            _Centered(child: DisplaySection()),
            _Centered(child: ListsSection()),
            _Centered(child: TablesSection()),
            _Centered(child: FeedbackSection()),
            _Centered(child: MotionSection()),
            _Centered(child: NavigationSection()),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1040), child: child),
    );
  }
}
