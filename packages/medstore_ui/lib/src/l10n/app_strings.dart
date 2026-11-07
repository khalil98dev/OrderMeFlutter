import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_strings_ar.dart';
import 'app_strings_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppStrings
/// returned by `AppStrings.of(context)`.
///
/// Applications need to include `AppStrings.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_strings.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppStrings.localizationsDelegates,
///   supportedLocales: AppStrings.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppStrings.supportedLocales
/// property.
abstract class AppStrings {
  AppStrings(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('fr')];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'MedStore'**
  String get appName;

  /// No description provided for @adminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSubtitleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Espace de l\'équipe MedStore'**
  String get loginSubtitleAdmin;

  /// No description provided for @loginSubtitleTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Commandez vos impressions'**
  String get loginSubtitleTeacher;

  /// No description provided for @userName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get userName;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get fieldRequired;

  /// No description provided for @wrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur ou mot de passe incorrect.'**
  String get wrongCredentials;

  /// No description provided for @failureNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion.'**
  String get failureNetwork;

  /// No description provided for @failureUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré. Reconnectez-vous.'**
  String get failureUnauthorized;

  /// No description provided for @failureForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas l\'autorisation de faire cela.'**
  String get failureForbidden;

  /// No description provided for @failureNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable.'**
  String get failureNotFound;

  /// No description provided for @failureConflict.
  ///
  /// In fr, this message translates to:
  /// **'Cet élément a été modifié entre-temps. Actualisez puis réessayez.'**
  String get failureConflict;

  /// No description provided for @failureValidation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez corriger les champs indiqués.'**
  String get failureValidation;

  /// No description provided for @failureWrongApp.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte ne peut pas utiliser cette application.'**
  String get failureWrongApp;

  /// No description provided for @failureServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a rencontré une erreur. Réessayez plus tard.'**
  String get failureServer;

  /// No description provided for @failureUnexpected.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite.'**
  String get failureUnexpected;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorTitle;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @decreaseQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Diminuer la quantité'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter la quantité'**
  String get increaseQuantity;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// No description provided for @comingSoonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cet écran sera construit dans une prochaine étape.'**
  String get comingSoonMessage;

  /// No description provided for @sectionOperations.
  ///
  /// In fr, this message translates to:
  /// **'Opérations'**
  String get sectionOperations;

  /// No description provided for @sectionFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finance'**
  String get sectionFinance;

  /// No description provided for @sectionSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get sectionSystem;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get navDashboard;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// No description provided for @navProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get navProducts;

  /// No description provided for @navTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Enseignants'**
  String get navTeachers;

  /// No description provided for @navSchools.
  ///
  /// In fr, this message translates to:
  /// **'Établissements'**
  String get navSchools;

  /// No description provided for @navInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get navInvoices;

  /// No description provided for @navWallet.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille'**
  String get navWallet;

  /// No description provided for @navDebts.
  ///
  /// In fr, this message translates to:
  /// **'Créances'**
  String get navDebts;

  /// No description provided for @navNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @collapseSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Réduire la barre latérale'**
  String get collapseSidebar;

  /// No description provided for @expandSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Déployer la barre latérale'**
  String get expandSidebar;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @noResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot ou retirez un filtre.'**
  String get noResultsMessage;

  /// No description provided for @tooLong.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères au plus.'**
  String tooLong(int max);

  /// No description provided for @productTypeGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide'**
  String get productTypeGuide;

  /// No description provided for @productTypePracticeBook.
  ///
  /// In fr, this message translates to:
  /// **'Cahier d\'exercices'**
  String get productTypePracticeBook;

  /// No description provided for @productTypeExamCollection.
  ///
  /// In fr, this message translates to:
  /// **'Recueil d\'examens'**
  String get productTypeExamCollection;

  /// No description provided for @productTypeOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get productTypeOther;

  /// No description provided for @productAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get productAvailable;

  /// No description provided for @productUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get productUnavailable;

  /// No description provided for @priceHidden.
  ///
  /// In fr, this message translates to:
  /// **'Prix masqué'**
  String get priceHidden;

  /// No description provided for @pricePerCopy.
  ///
  /// In fr, this message translates to:
  /// **'{price} / exemplaire'**
  String pricePerCopy(String price);

  /// No description provided for @pageCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(int count);

  /// No description provided for @productsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun produit} =1{1 produit} other{{count} produits}}'**
  String productsCount(int count);

  /// No description provided for @searchProducts.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit'**
  String get searchProducts;

  /// No description provided for @noProductsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get noProductsTitle;

  /// No description provided for @noProductsTeacherMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vos livres apparaîtront ici dès que l\'équipe MedStore les aura préparés.'**
  String get noProductsTeacherMessage;

  /// No description provided for @noProductsAdminMessage.
  ///
  /// In fr, this message translates to:
  /// **'Créez le premier produit d\'un enseignant.'**
  String get noProductsAdminMessage;

  /// No description provided for @productDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get productDetails;

  /// No description provided for @productUnavailableNotice.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit ne peut pas être commandé pour le moment.'**
  String get productUnavailableNotice;

  /// No description provided for @newProduct.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get newProduct;

  /// No description provided for @editProduct.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get editProduct;

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldName;

  /// No description provided for @fieldCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get fieldCode;

  /// No description provided for @fieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldSubject.
  ///
  /// In fr, this message translates to:
  /// **'Matière'**
  String get fieldSubject;

  /// No description provided for @fieldLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau'**
  String get fieldLevel;

  /// No description provided for @fieldType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get fieldType;

  /// No description provided for @fieldPageCount.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pages'**
  String get fieldPageCount;

  /// No description provided for @fieldPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix par exemplaire (DA)'**
  String get fieldPrice;

  /// No description provided for @fieldTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get fieldTeacher;

  /// No description provided for @fieldAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible à la commande'**
  String get fieldAvailable;

  /// No description provided for @fieldAvailableHint.
  ///
  /// In fr, this message translates to:
  /// **'Décoché, le produit reste visible mais ne peut plus être commandé.'**
  String get fieldAvailableHint;

  /// No description provided for @fieldCover.
  ///
  /// In fr, this message translates to:
  /// **'Couverture'**
  String get fieldCover;

  /// No description provided for @ownerCannotChange.
  ///
  /// In fr, this message translates to:
  /// **'Le propriétaire d\'un produit ne change pas.'**
  String get ownerCannotChange;

  /// No description provided for @chooseTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un enseignant'**
  String get chooseTeacher;

  /// No description provided for @chooseImage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image'**
  String get chooseImage;

  /// No description provided for @replaceImage.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get replaceImage;

  /// No description provided for @removeImage.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeImage;

  /// No description provided for @imageHint.
  ///
  /// In fr, this message translates to:
  /// **'JPEG, PNG ou WebP, 5 Mo au plus.'**
  String get imageHint;

  /// No description provided for @imageTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'L\'image dépasse 5 Mo.'**
  String get imageTooLarge;

  /// No description provided for @priceInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un prix valide (0 ou plus).'**
  String get priceInvalid;

  /// No description provided for @pageCountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nombre de pages supérieur à 0.'**
  String get pageCountInvalid;

  /// No description provided for @deleteProductTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String deleteProductTitle(String name);

  /// No description provided for @deleteProductMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le produit disparaît de la liste. Les commandes passées le gardent.'**
  String get deleteProductMessage;

  /// No description provided for @productSaved.
  ///
  /// In fr, this message translates to:
  /// **'Produit enregistré'**
  String get productSaved;

  /// No description provided for @productDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Produit supprimé'**
  String get productDeleted;

  /// No description provided for @codeTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce code est déjà utilisé par un autre produit.'**
  String get codeTaken;

  /// No description provided for @imageTypeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'L\'image doit être un fichier JPEG, PNG ou WebP.'**
  String get imageTypeInvalid;

  /// No description provided for @teacherUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cet enseignant n\'existe pas ou est désactivé.'**
  String get teacherUnavailable;

  /// No description provided for @savedButCoverFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le produit est enregistré, mais pas la couverture. Réessayez.'**
  String get savedButCoverFailed;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @choose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get choose;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get remove;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @downloadPdf.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le PDF'**
  String get downloadPdf;

  /// No description provided for @fileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré : {path}'**
  String fileSaved(String path);

  /// No description provided for @none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get none;

  /// No description provided for @periodFrom.
  ///
  /// In fr, this message translates to:
  /// **'Du'**
  String get periodFrom;

  /// No description provided for @periodTo.
  ///
  /// In fr, this message translates to:
  /// **'Au'**
  String get periodTo;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @fieldNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldNote.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @fieldReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get fieldReason;

  /// No description provided for @fieldAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant (DA)'**
  String get fieldAmount;

  /// No description provided for @amountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un montant supérieur à 0, avec 2 décimales au plus.'**
  String get amountInvalid;

  /// No description provided for @voidedBadge.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get voidedBadge;

  /// No description provided for @voidAction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler définitivement'**
  String get voidAction;

  /// No description provided for @byName.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String byName(String name);

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get inactive;

  /// No description provided for @deactivate.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get deactivate;

  /// No description provided for @validationUserNameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom d\'utilisateur est déjà pris.'**
  String get validationUserNameTaken;

  /// No description provided for @validationPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères.'**
  String get validationPassword;

  /// No description provided for @validationPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone invalide.'**
  String get validationPhone;

  /// No description provided for @validationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get validationEmail;

  /// No description provided for @colNumber.
  ///
  /// In fr, this message translates to:
  /// **'N°'**
  String get colNumber;

  /// No description provided for @colTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get colTeacher;

  /// No description provided for @colDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get colStatus;

  /// No description provided for @colTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get colTotal;

  /// No description provided for @colQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get colQuantity;

  /// No description provided for @colProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get colProduct;

  /// No description provided for @colUnitPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire'**
  String get colUnitPrice;

  /// No description provided for @colLines.
  ///
  /// In fr, this message translates to:
  /// **'Lignes'**
  String get colLines;

  /// No description provided for @colAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get colAmount;

  /// No description provided for @colBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get colBalance;

  /// No description provided for @colBalanceAfter.
  ///
  /// In fr, this message translates to:
  /// **'Solde après'**
  String get colBalanceAfter;

  /// No description provided for @colType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get colDueDate;

  /// No description provided for @colPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get colPaid;

  /// No description provided for @colDue.
  ///
  /// In fr, this message translates to:
  /// **'Reste dû'**
  String get colDue;

  /// No description provided for @colOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get colOrders;

  /// No description provided for @colCopies.
  ///
  /// In fr, this message translates to:
  /// **'Exemplaires'**
  String get colCopies;

  /// No description provided for @colPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get colPhone;

  /// No description provided for @colSchool.
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get colSchool;

  /// No description provided for @colReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get colReceipt;

  /// No description provided for @colLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get colLabel;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne sont pas identiques.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe changé. Les autres appareils devront se reconnecter.'**
  String get passwordChanged;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe actuel est incorrect.'**
  String get currentPasswordWrong;

  /// No description provided for @changePasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe termine toutes les sessions ouvertes.'**
  String get changePasswordHint;

  /// No description provided for @fieldRoles.
  ///
  /// In fr, this message translates to:
  /// **'Rôles'**
  String get fieldRoles;

  /// No description provided for @billingSettings.
  ///
  /// In fr, this message translates to:
  /// **'Facturation'**
  String get billingSettings;

  /// No description provided for @autoSettle.
  ///
  /// In fr, this message translates to:
  /// **'Régler automatiquement'**
  String get autoSettle;

  /// No description provided for @autoSettleHint.
  ///
  /// In fr, this message translates to:
  /// **'Après chaque facture, créance ou dépôt, l\'argent du portefeuille paie ce qui est dû, le plus ancien d\'abord.'**
  String get autoSettleHint;

  /// No description provided for @defaultPaymentTerms.
  ///
  /// In fr, this message translates to:
  /// **'Échéance par défaut des nouveaux enseignants'**
  String get defaultPaymentTerms;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés'**
  String get settingsSaved;

  /// No description provided for @lastChanged.
  ///
  /// In fr, this message translates to:
  /// **'Modifié le {date} par {name}'**
  String lastChanged(String date, String name);

  /// No description provided for @fieldPaymentTerms.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get fieldPaymentTerms;

  /// No description provided for @paymentTermsImmediate.
  ///
  /// In fr, this message translates to:
  /// **'Comptant'**
  String get paymentTermsImmediate;

  /// No description provided for @paymentTermsEndOfMonth.
  ///
  /// In fr, this message translates to:
  /// **'Fin de mois'**
  String get paymentTermsEndOfMonth;

  /// No description provided for @paymentTermsEndOfYear.
  ///
  /// In fr, this message translates to:
  /// **'Fin d\'année'**
  String get paymentTermsEndOfYear;

  /// No description provided for @paymentTermsDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut (paramètres)'**
  String get paymentTermsDefault;

  /// No description provided for @teachersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun enseignant} =1{1 enseignant} other{{count} enseignants}}'**
  String teachersCount(int count);

  /// No description provided for @searchTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un enseignant'**
  String get searchTeachers;

  /// No description provided for @newTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel enseignant'**
  String get newTeacher;

  /// No description provided for @editTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'enseignant'**
  String get editTeacher;

  /// No description provided for @fieldFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fieldFullName;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldSchool.
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get fieldSchool;

  /// No description provided for @fieldStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get fieldStatus;

  /// No description provided for @signInAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte de connexion'**
  String get signInAccount;

  /// No description provided for @signInAccountHint.
  ///
  /// In fr, this message translates to:
  /// **'L\'enseignant se connecte à l\'application mobile avec ce nom et ce mot de passe.'**
  String get signInAccountHint;

  /// No description provided for @deactivateTeacherTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver {name} ?'**
  String deactivateTeacherTitle(String name);

  /// No description provided for @deactivateTeacherMessage.
  ///
  /// In fr, this message translates to:
  /// **'Son compte est fermé et ses sessions terminées. Ses commandes et factures restent.'**
  String get deactivateTeacherMessage;

  /// No description provided for @teacherDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant désactivé'**
  String get teacherDeactivated;

  /// No description provided for @teacherSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant enregistré'**
  String get teacherSaved;

  /// No description provided for @noTeachersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enseignant'**
  String get noTeachersTitle;

  /// No description provided for @noTeachersMessage.
  ///
  /// In fr, this message translates to:
  /// **'Créez le premier compte enseignant.'**
  String get noTeachersMessage;

  /// No description provided for @allTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Tous les enseignants'**
  String get allTeachers;

  /// No description provided for @chooseSchool.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un établissement'**
  String get chooseSchool;

  /// No description provided for @statement.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de compte'**
  String get statement;

  /// No description provided for @statementInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures de la période'**
  String get statementInvoices;

  /// No description provided for @statementMovements.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements du portefeuille'**
  String get statementMovements;

  /// No description provided for @statementOpenDebts.
  ///
  /// In fr, this message translates to:
  /// **'Créances ouvertes'**
  String get statementOpenDebts;

  /// No description provided for @totalsInvoiced.
  ///
  /// In fr, this message translates to:
  /// **'Facturé'**
  String get totalsInvoiced;

  /// No description provided for @totalsDeposited.
  ///
  /// In fr, this message translates to:
  /// **'Déposé'**
  String get totalsDeposited;

  /// No description provided for @totalsPaidFromWallet.
  ///
  /// In fr, this message translates to:
  /// **'Payé par le portefeuille'**
  String get totalsPaidFromWallet;

  /// No description provided for @owedNow.
  ///
  /// In fr, this message translates to:
  /// **'Dû aujourd\'hui'**
  String get owedNow;

  /// No description provided for @overdueNow.
  ///
  /// In fr, this message translates to:
  /// **'En retard aujourd\'hui'**
  String get overdueNow;

  /// No description provided for @walletBalanceNow.
  ///
  /// In fr, this message translates to:
  /// **'Solde du portefeuille'**
  String get walletBalanceNow;

  /// No description provided for @nothingInPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Rien sur cette période.'**
  String get nothingInPeriod;

  /// No description provided for @periodTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une période de 366 jours au plus.'**
  String get periodTooLong;

  /// No description provided for @schoolsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun établissement} =1{1 établissement} other{{count} établissements}}'**
  String schoolsCount(int count);

  /// No description provided for @searchSchools.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un établissement'**
  String get searchSchools;

  /// No description provided for @newSchool.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel établissement'**
  String get newSchool;

  /// No description provided for @editSchool.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'établissement'**
  String get editSchool;

  /// No description provided for @fieldWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya (code)'**
  String get fieldWilaya;

  /// No description provided for @fieldCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get fieldCity;

  /// No description provided for @fieldSchoolLevel.
  ///
  /// In fr, this message translates to:
  /// **'Cycle'**
  String get fieldSchoolLevel;

  /// No description provided for @fieldSchoolType.
  ///
  /// In fr, this message translates to:
  /// **'Secteur'**
  String get fieldSchoolType;

  /// No description provided for @schoolLevelPrimary.
  ///
  /// In fr, this message translates to:
  /// **'Primaire'**
  String get schoolLevelPrimary;

  /// No description provided for @schoolLevelMiddle.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get schoolLevelMiddle;

  /// No description provided for @schoolLevelSecondary.
  ///
  /// In fr, this message translates to:
  /// **'Secondaire'**
  String get schoolLevelSecondary;

  /// No description provided for @schoolLevelUniversity.
  ///
  /// In fr, this message translates to:
  /// **'Université'**
  String get schoolLevelUniversity;

  /// No description provided for @schoolLevelOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get schoolLevelOther;

  /// No description provided for @schoolTypePublic.
  ///
  /// In fr, this message translates to:
  /// **'Public'**
  String get schoolTypePublic;

  /// No description provided for @schoolTypePrivate.
  ///
  /// In fr, this message translates to:
  /// **'Privé'**
  String get schoolTypePrivate;

  /// No description provided for @schoolSaved.
  ///
  /// In fr, this message translates to:
  /// **'Établissement enregistré'**
  String get schoolSaved;

  /// No description provided for @noSchoolsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun établissement'**
  String get noSchoolsTitle;

  /// No description provided for @noSchoolsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les établissements où enseignent vos clients.'**
  String get noSchoolsMessage;

  /// No description provided for @wilayaInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un code de wilaya entre 1 et 58.'**
  String get wilayaInvalid;

  /// No description provided for @wilayaLabel.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya {code}'**
  String wilayaLabel(int code);

  /// No description provided for @ordersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune commande} =1{1 commande} other{{count} commandes}}'**
  String ordersCount(int count);

  /// No description provided for @newOrder.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande'**
  String get newOrder;

  /// No description provided for @orderNumber.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number}'**
  String orderNumber(int number);

  /// No description provided for @searchOrderNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de commande'**
  String get searchOrderNumber;

  /// No description provided for @orderStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get orderStatusPending;

  /// No description provided for @orderStatusInPreparation.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get orderStatusInPreparation;

  /// No description provided for @orderStatusReady.
  ///
  /// In fr, this message translates to:
  /// **'Prête'**
  String get orderStatusReady;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get orderStatusCancelled;

  /// No description provided for @orderLines.
  ///
  /// In fr, this message translates to:
  /// **'Lignes'**
  String get orderLines;

  /// No description provided for @orderHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get orderHistory;

  /// No description provided for @actionStartPreparation.
  ///
  /// In fr, this message translates to:
  /// **'Commencer la préparation'**
  String get actionStartPreparation;

  /// No description provided for @actionMarkReady.
  ///
  /// In fr, this message translates to:
  /// **'Marquer prête'**
  String get actionMarkReady;

  /// No description provided for @actionMarkDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Marquer livrée'**
  String get actionMarkDelivered;

  /// No description provided for @actionCancelOrder.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la commande'**
  String get actionCancelOrder;

  /// No description provided for @statusNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note pour l\'enseignant'**
  String get statusNoteLabel;

  /// No description provided for @changeStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passer la commande à « {status} » ?'**
  String changeStatusTitle(String status);

  /// No description provided for @cancelOrderMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le motif est montré à l\'enseignant. Il est obligatoire une fois la préparation commencée.'**
  String get cancelOrderMessage;

  /// No description provided for @orderStatusChanged.
  ///
  /// In fr, this message translates to:
  /// **'Statut mis à jour'**
  String get orderStatusChanged;

  /// No description provided for @reviseOrder.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les lignes'**
  String get reviseOrder;

  /// No description provided for @orderSaved.
  ///
  /// In fr, this message translates to:
  /// **'Commande enregistrée'**
  String get orderSaved;

  /// No description provided for @orderPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} créée'**
  String orderPlaced(int number);

  /// No description provided for @addProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get addProduct;

  /// No description provided for @noLines.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un produit.'**
  String get noLines;

  /// No description provided for @actorClient.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get actorClient;

  /// No description provided for @actorStaff.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get actorStaff;

  /// No description provided for @noOrdersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande'**
  String get noOrdersTitle;

  /// No description provided for @noOrdersMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes des enseignants apparaîtront ici.'**
  String get noOrdersMessage;

  /// No description provided for @chooseProduct.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un produit'**
  String get chooseProduct;

  /// No description provided for @chooseTeacherFirst.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez d\'abord l\'enseignant.'**
  String get chooseTeacherFirst;

  /// No description provided for @orderEditableHint.
  ///
  /// In fr, this message translates to:
  /// **'Les lignes se modifient tant que la commande est en attente ou en préparation.'**
  String get orderEditableHint;

  /// No description provided for @noProductsForTeacher.
  ///
  /// In fr, this message translates to:
  /// **'Cet enseignant n\'a aucun produit disponible.'**
  String get noProductsForTeacher;

  /// No description provided for @linesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 ligne} other{{count} lignes}}'**
  String linesCount(int count);

  /// No description provided for @walletsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun portefeuille} =1{1 portefeuille} other{{count} portefeuilles}}'**
  String walletsCount(int count);

  /// No description provided for @balance.
  ///
  /// In fr, this message translates to:
  /// **'Solde'**
  String get balance;

  /// No description provided for @totalDeposited.
  ///
  /// In fr, this message translates to:
  /// **'Total déposé'**
  String get totalDeposited;

  /// No description provided for @lastMovement.
  ///
  /// In fr, this message translates to:
  /// **'Dernier mouvement'**
  String get lastMovement;

  /// No description provided for @newDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau dépôt'**
  String get newDeposit;

  /// No description provided for @newWithdrawal.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau retrait'**
  String get newWithdrawal;

  /// No description provided for @settleNow.
  ///
  /// In fr, this message translates to:
  /// **'Régler maintenant'**
  String get settleNow;

  /// No description provided for @settleNowMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'argent du portefeuille paie les factures et créances dues, les plus anciennes d\'abord.'**
  String get settleNowMessage;

  /// No description provided for @fieldMethod.
  ///
  /// In fr, this message translates to:
  /// **'Moyen de paiement'**
  String get fieldMethod;

  /// No description provided for @fieldReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get fieldReference;

  /// No description provided for @referenceHint.
  ///
  /// In fr, this message translates to:
  /// **'N° de virement, page du carnet…'**
  String get referenceHint;

  /// No description provided for @paymentMethodCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Virement'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentMethodOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get paymentMethodOther;

  /// No description provided for @txDeposit.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt'**
  String get txDeposit;

  /// No description provided for @txWithdrawal.
  ///
  /// In fr, this message translates to:
  /// **'Retrait'**
  String get txWithdrawal;

  /// No description provided for @txReversal.
  ///
  /// In fr, this message translates to:
  /// **'Annulation'**
  String get txReversal;

  /// No description provided for @txInvoicePayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement de facture'**
  String get txInvoicePayment;

  /// No description provided for @txOtherPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement de créance'**
  String get txOtherPayment;

  /// No description provided for @allTypes.
  ///
  /// In fr, this message translates to:
  /// **'Tous les types'**
  String get allTypes;

  /// No description provided for @voidTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l\'opération'**
  String get voidTransaction;

  /// No description provided for @voidTransactionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Une écriture inverse est ajoutée. L\'opération reste visible, marquée annulée.'**
  String get voidTransactionMessage;

  /// No description provided for @downloadReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le reçu'**
  String get downloadReceipt;

  /// No description provided for @depositRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt enregistré ({receipt})'**
  String depositRecorded(String receipt);

  /// No description provided for @withdrawalRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Retrait enregistré'**
  String get withdrawalRecorded;

  /// No description provided for @transactionVoided.
  ///
  /// In fr, this message translates to:
  /// **'Opération annulée'**
  String get transactionVoided;

  /// No description provided for @settledAmount.
  ///
  /// In fr, this message translates to:
  /// **'{amount} réglés depuis le portefeuille'**
  String settledAmount(String amount);

  /// No description provided for @noWalletsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun portefeuille'**
  String get noWalletsTitle;

  /// No description provided for @noWalletsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un portefeuille apparaît au premier dépôt.'**
  String get noWalletsMessage;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération'**
  String get noTransactionsTitle;

  /// No description provided for @withdrawalHint.
  ///
  /// In fr, this message translates to:
  /// **'Jamais plus que le solde.'**
  String get withdrawalHint;

  /// No description provided for @invoicesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune facture} =1{1 facture} other{{count} factures}}'**
  String invoicesCount(int count);

  /// No description provided for @newInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle facture'**
  String get newInvoice;

  /// No description provided for @paymentStatusUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Non payée'**
  String get paymentStatusUnpaid;

  /// No description provided for @paymentStatusPartiallyPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée en partie'**
  String get paymentStatusPartiallyPaid;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get paymentStatusPaid;

  /// No description provided for @overdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get overdue;

  /// No description provided for @onlyOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard seulement'**
  String get onlyOverdue;

  /// No description provided for @includeVoided.
  ///
  /// In fr, this message translates to:
  /// **'Inclure les annulées'**
  String get includeVoided;

  /// No description provided for @fieldPaymentStatus.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get fieldPaymentStatus;

  /// No description provided for @issueDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'émission'**
  String get issueDate;

  /// No description provided for @dueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get dueDate;

  /// No description provided for @amountPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get amountPaid;

  /// No description provided for @amountDue.
  ///
  /// In fr, this message translates to:
  /// **'Reste dû'**
  String get amountDue;

  /// No description provided for @invoicePayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get invoicePayments;

  /// No description provided for @refundedOn.
  ///
  /// In fr, this message translates to:
  /// **'Remboursé le {date}'**
  String refundedOn(String date);

  /// No description provided for @voidInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la facture'**
  String get voidInvoice;

  /// No description provided for @voidInvoiceMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ses exemplaires retournent aux commandes et ses paiements au portefeuille.'**
  String get voidInvoiceMessage;

  /// No description provided for @settleFromWallet.
  ///
  /// In fr, this message translates to:
  /// **'Régler depuis le portefeuille'**
  String get settleFromWallet;

  /// No description provided for @settleAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant (vide : le maximum possible)'**
  String get settleAmountLabel;

  /// No description provided for @uninvoicedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exemplaires à facturer'**
  String get uninvoicedTitle;

  /// No description provided for @noUninvoiced.
  ///
  /// In fr, this message translates to:
  /// **'Rien à facturer pour cet enseignant.'**
  String get noUninvoiced;

  /// No description provided for @toInvoice.
  ///
  /// In fr, this message translates to:
  /// **'À facturer'**
  String get toInvoice;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @issueInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Émettre la facture'**
  String get issueInvoice;

  /// No description provided for @invoiceIssued.
  ///
  /// In fr, this message translates to:
  /// **'Facture {label} émise'**
  String invoiceIssued(String label);

  /// No description provided for @invoiceVoided.
  ///
  /// In fr, this message translates to:
  /// **'Facture annulée'**
  String get invoiceVoided;

  /// No description provided for @invoiceSettled.
  ///
  /// In fr, this message translates to:
  /// **'Facture réglée'**
  String get invoiceSettled;

  /// No description provided for @fromOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes : {numbers}'**
  String fromOrders(String numbers);

  /// No description provided for @noInvoicesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture'**
  String get noInvoicesTitle;

  /// No description provided for @noInvoicesMessage.
  ///
  /// In fr, this message translates to:
  /// **'Émettez une facture à partir des commandes d\'un enseignant.'**
  String get noInvoicesMessage;

  /// No description provided for @nothingSelected.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez au moins une quantité à facturer.'**
  String get nothingSelected;

  /// No description provided for @quantityTooHigh.
  ///
  /// In fr, this message translates to:
  /// **'Au plus {max}.'**
  String quantityTooHigh(int max);

  /// No description provided for @onlyOwing.
  ///
  /// In fr, this message translates to:
  /// **'Seulement ceux qui doivent'**
  String get onlyOwing;

  /// No description provided for @totalOwed.
  ///
  /// In fr, this message translates to:
  /// **'Total dû'**
  String get totalOwed;

  /// No description provided for @overdueInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures en retard'**
  String get overdueInvoices;

  /// No description provided for @upcomingInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures à venir'**
  String get upcomingInvoices;

  /// No description provided for @openDebts.
  ///
  /// In fr, this message translates to:
  /// **'Créances'**
  String get openDebts;

  /// No description provided for @oldestDue.
  ///
  /// In fr, this message translates to:
  /// **'Plus ancienne échéance'**
  String get oldestDue;

  /// No description provided for @newDebt.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle créance'**
  String get newDebt;

  /// No description provided for @debtDueHint.
  ///
  /// In fr, this message translates to:
  /// **'Vide : due aujourd\'hui.'**
  String get debtDueHint;

  /// No description provided for @debtKindInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get debtKindInvoice;

  /// No description provided for @debtKindDebt.
  ///
  /// In fr, this message translates to:
  /// **'Créance'**
  String get debtKindDebt;

  /// No description provided for @includeClosed.
  ///
  /// In fr, this message translates to:
  /// **'Inclure les soldées'**
  String get includeClosed;

  /// No description provided for @writeOff.
  ///
  /// In fr, this message translates to:
  /// **'Passer en perte'**
  String get writeOff;

  /// No description provided for @writeOffMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui reste de la créance est abandonné.'**
  String get writeOffMessage;

  /// No description provided for @debtCreated.
  ///
  /// In fr, this message translates to:
  /// **'Créance enregistrée'**
  String get debtCreated;

  /// No description provided for @debtSettled.
  ///
  /// In fr, this message translates to:
  /// **'Créance réglée'**
  String get debtSettled;

  /// No description provided for @debtWrittenOff.
  ///
  /// In fr, this message translates to:
  /// **'Créance passée en perte'**
  String get debtWrittenOff;

  /// No description provided for @writtenOff.
  ///
  /// In fr, this message translates to:
  /// **'Abandonné'**
  String get writtenOff;

  /// No description provided for @writtenOffOn.
  ///
  /// In fr, this message translates to:
  /// **'Abandonné le {date} : {reason}'**
  String writtenOffOn(String date, String reason);

  /// No description provided for @noDebtsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Personne ne doit rien'**
  String get noDebtsTitle;

  /// No description provided for @noDebtsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les factures impayées et les créances saisies apparaîtront ici.'**
  String get noDebtsMessage;

  /// No description provided for @debtDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Dû d\'avant l\'application, ajustement…'**
  String get debtDescriptionHint;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get navSecurity;

  /// No description provided for @thePeriod.
  ///
  /// In fr, this message translates to:
  /// **'Sur la période'**
  String get thePeriod;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @ordersPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Commandes passées'**
  String get ordersPlaced;

  /// No description provided for @copiesOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Exemplaires commandés'**
  String get copiesOrdered;

  /// No description provided for @amountOrdered.
  ///
  /// In fr, this message translates to:
  /// **'Montant commandé'**
  String get amountOrdered;

  /// No description provided for @invoicesIssued.
  ///
  /// In fr, this message translates to:
  /// **'Factures émises'**
  String get invoicesIssued;

  /// No description provided for @amountInvoiced.
  ///
  /// In fr, this message translates to:
  /// **'Montant facturé'**
  String get amountInvoiced;

  /// No description provided for @depositsCount.
  ///
  /// In fr, this message translates to:
  /// **'Dépôts'**
  String get depositsCount;

  /// No description provided for @amountDeposited.
  ///
  /// In fr, this message translates to:
  /// **'Montant déposé'**
  String get amountDeposited;

  /// No description provided for @amountPaidFromWallets.
  ///
  /// In fr, this message translates to:
  /// **'Payé par les portefeuilles'**
  String get amountPaidFromWallets;

  /// No description provided for @newTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux enseignants'**
  String get newTeachers;

  /// No description provided for @activeTeachers.
  ///
  /// In fr, this message translates to:
  /// **'Enseignants actifs'**
  String get activeTeachers;

  /// No description provided for @heldInWallets.
  ///
  /// In fr, this message translates to:
  /// **'Dans les portefeuilles'**
  String get heldInWallets;

  /// No description provided for @ordersByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Commandes par statut'**
  String get ordersByStatus;

  /// No description provided for @salesReport.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get salesReport;

  /// No description provided for @groupBy.
  ///
  /// In fr, this message translates to:
  /// **'Regrouper par'**
  String get groupBy;

  /// No description provided for @groupByProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get groupByProduct;

  /// No description provided for @groupByClient.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant'**
  String get groupByClient;

  /// No description provided for @groupBySchool.
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get groupBySchool;

  /// No description provided for @groupByWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get groupByWilaya;

  /// No description provided for @groupByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get groupByMonth;

  /// No description provided for @noSalesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente sur la période'**
  String get noSalesTitle;

  /// No description provided for @tabRoles.
  ///
  /// In fr, this message translates to:
  /// **'Rôles'**
  String get tabRoles;

  /// No description provided for @tabUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get tabUsers;

  /// No description provided for @tabResources.
  ///
  /// In fr, this message translates to:
  /// **'Ressources'**
  String get tabResources;

  /// No description provided for @newRole.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau rôle'**
  String get newRole;

  /// No description provided for @fieldRoleName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du rôle'**
  String get fieldRoleName;

  /// No description provided for @roleCreated.
  ///
  /// In fr, this message translates to:
  /// **'Rôle créé'**
  String get roleCreated;

  /// No description provided for @permissionsOf.
  ///
  /// In fr, this message translates to:
  /// **'Permissions : {role}'**
  String permissionsOf(String role);

  /// No description provided for @permissionsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Permissions enregistrées'**
  String get permissionsSaved;

  /// No description provided for @editPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les permissions'**
  String get editPermissions;

  /// No description provided for @permCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get permCreate;

  /// No description provided for @permRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get permRead;

  /// No description provided for @permSet.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get permSet;

  /// No description provided for @permDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get permDelete;

  /// No description provided for @securedFields.
  ///
  /// In fr, this message translates to:
  /// **'Champs protégés'**
  String get securedFields;

  /// No description provided for @resourceCol.
  ///
  /// In fr, this message translates to:
  /// **'Ressource'**
  String get resourceCol;

  /// No description provided for @grantsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune permission} =1{1 ressource accordée} other{{count} ressources accordées}}'**
  String grantsCount(int count);

  /// No description provided for @adminRoleNotice.
  ///
  /// In fr, this message translates to:
  /// **'Le rôle Admin reçoit toutes les permissions à chaque démarrage du serveur.'**
  String get adminRoleNotice;

  /// No description provided for @newUser.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel utilisateur'**
  String get newUser;

  /// No description provided for @userCreated.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur créé'**
  String get userCreated;

  /// No description provided for @editRoles.
  ///
  /// In fr, this message translates to:
  /// **'Rôles'**
  String get editRoles;

  /// No description provided for @rolesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Rôles enregistrés. L\'utilisateur doit se reconnecter.'**
  String get rolesSaved;

  /// No description provided for @rolesOf.
  ///
  /// In fr, this message translates to:
  /// **'Rôles de {name}'**
  String rolesOf(String name);

  /// No description provided for @deactivateUserTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver {name} ?'**
  String deactivateUserTitle(String name);

  /// No description provided for @deactivateUserMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le compte ne peut plus se connecter et ses sessions sont terminées.'**
  String get deactivateUserMessage;

  /// No description provided for @userDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur désactivé'**
  String get userDeactivated;

  /// No description provided for @teacherAccountsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les comptes enseignants se gèrent dans Enseignants.'**
  String get teacherAccountsHint;

  /// No description provided for @chooseRoles.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un rôle.'**
  String get chooseRoles;

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllRead;

  /// No description provided for @unreadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Non lues seulement'**
  String get unreadOnly;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les nouvelles notifications apparaîtront ici.'**
  String get noNotificationsMessage;

  /// No description provided for @cart.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get cart;

  /// No description provided for @addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get addToCart;

  /// No description provided for @inCart.
  ///
  /// In fr, this message translates to:
  /// **'{count} dans le panier'**
  String inCart(int count);

  /// No description provided for @cartEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des livres depuis vos produits, puis passez commande ici.'**
  String get cartEmptyMessage;

  /// No description provided for @browseProducts.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes produits'**
  String get browseProducts;

  /// No description provided for @viewCart.
  ///
  /// In fr, this message translates to:
  /// **'Voir le panier'**
  String get viewCart;

  /// No description provided for @placeOrder.
  ///
  /// In fr, this message translates to:
  /// **'Passer la commande'**
  String get placeOrder;

  /// No description provided for @copiesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 exemplaire} other{{count} exemplaires}}'**
  String copiesCount(int count);

  /// No description provided for @orderNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Une précision pour l\'équipe (facultatif)'**
  String get orderNotesHint;

  /// No description provided for @orderSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyée'**
  String get orderSentTitle;

  /// No description provided for @orderSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} : l\'équipe MedStore vous préviendra dès qu\'elle sera prête.'**
  String orderSentMessage(int number);

  /// No description provided for @viewOrder.
  ///
  /// In fr, this message translates to:
  /// **'Voir la commande'**
  String get viewOrder;

  /// No description provided for @confirmDelivery.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu ma commande'**
  String get confirmDelivery;

  /// No description provided for @confirmDeliveryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez-vous avoir reçu cette commande ?'**
  String get confirmDeliveryMessage;

  /// No description provided for @cancelMyOrderMessage.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette commande ? L\'équipe ne la préparera pas.'**
  String get cancelMyOrderMessage;

  /// No description provided for @orderCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée'**
  String get orderCancelled;

  /// No description provided for @deliveryConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Réception confirmée, merci !'**
  String get deliveryConfirmed;

  /// No description provided for @greeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}'**
  String greeting(String name);

  /// No description provided for @greetingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos livres, prêts à être commandés.'**
  String get greetingSubtitle;

  /// No description provided for @noOrdersTeacherMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vos commandes apparaîtront ici, avec leur suivi.'**
  String get noOrdersTeacherMessage;

  /// No description provided for @orderProgress.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get orderProgress;

  /// No description provided for @readyPickupHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande est prête : vous pouvez venir la récupérer.'**
  String get readyPickupHint;

  /// No description provided for @cartUnavailableHint.
  ///
  /// In fr, this message translates to:
  /// **'Retirez les produits indisponibles pour commander.'**
  String get cartUnavailableHint;

  /// No description provided for @notifOrderPlacedForYouTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} enregistrée'**
  String notifOrderPlacedForYouTitle(String number);

  /// No description provided for @notifOrderPlacedForYouMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe MedStore a enregistré une commande pour vous.'**
  String get notifOrderPlacedForYouMessage;

  /// No description provided for @notifOrderPreparingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} en préparation'**
  String notifOrderPreparingTitle(String number);

  /// No description provided for @notifOrderPreparingMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe MedStore prépare votre commande.'**
  String get notifOrderPreparingMessage;

  /// No description provided for @notifOrderReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} prête'**
  String notifOrderReadyTitle(String number);

  /// No description provided for @notifOrderDeliveredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} livrée'**
  String notifOrderDeliveredTitle(String number);

  /// No description provided for @notifOrderDeliveredMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande a été remise.'**
  String get notifOrderDeliveredMessage;

  /// No description provided for @notifOrderCancelledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} annulée'**
  String notifOrderCancelledTitle(String number);

  /// No description provided for @notifOrderCancelledMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe MedStore a annulé votre commande.'**
  String get notifOrderCancelledMessage;

  /// No description provided for @notifInvoiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle facture {number}'**
  String notifInvoiceTitle(String number);

  /// No description provided for @notifInvoiceMessage.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle facture a été émise à votre nom.'**
  String get notifInvoiceMessage;

  /// No description provided for @notifDepositTitle.
  ///
  /// In fr, this message translates to:
  /// **'Versement enregistré'**
  String get notifDepositTitle;

  /// No description provided for @notifDepositMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre versement a été enregistré.'**
  String get notifDepositMessage;

  /// No description provided for @notifProductTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get notifProductTitle;

  /// No description provided for @notifProductMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » est disponible à la commande.'**
  String notifProductMessage(String name);

  /// No description provided for @byProductTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé par produit'**
  String get byProductTitle;

  /// No description provided for @byProductSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les factures de la période, regroupées par produit'**
  String get byProductSubtitle;

  /// No description provided for @onlyUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Seulement les impayées'**
  String get onlyUnpaid;

  /// No description provided for @colInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get colInvoices;

  /// No description provided for @totalQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité totale'**
  String get totalQuantity;

  /// No description provided for @noInvoicedProductsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture sur cette période'**
  String get noInvoicedProductsTitle;

  /// No description provided for @noInvoicedProductsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Changez la période, l\'enseignant ou le filtre des impayées.'**
  String get noInvoicedProductsMessage;

  /// No description provided for @invoicedProductSources.
  ///
  /// In fr, this message translates to:
  /// **'D\'où vient ce total : {product}'**
  String invoicedProductSources(String product);

  /// No description provided for @collectPayment.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collectPayment;

  /// No description provided for @collectPaymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser au comptoir'**
  String get collectPaymentTitle;

  /// No description provided for @collectPaymentMessage.
  ///
  /// In fr, this message translates to:
  /// **'Reste dû : {amount}. Le paiement est enregistré comme un versement (avec reçu) et règle cette facture en premier.'**
  String collectPaymentMessage(String amount);

  /// No description provided for @collectAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant (vide : tout le reste dû)'**
  String get collectAmountLabel;

  /// No description provided for @paymentCollected.
  ///
  /// In fr, this message translates to:
  /// **'Paiement encaissé'**
  String get paymentCollected;

  /// No description provided for @invoiceIssuedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Facture {label} émise'**
  String invoiceIssuedTitle(String label);

  /// No description provided for @invoiceIssuedMessage.
  ///
  /// In fr, this message translates to:
  /// **'La commande est prête : sa facture a été émise automatiquement. L\'enseignant pourra payer le reste à la librairie.'**
  String get invoiceIssuedMessage;

  /// No description provided for @paidFromWallet.
  ///
  /// In fr, this message translates to:
  /// **'Payé par le portefeuille'**
  String get paidFromWallet;

  /// No description provided for @leftAsDebt.
  ///
  /// In fr, this message translates to:
  /// **'Reste dû (créance)'**
  String get leftAsDebt;

  /// No description provided for @viewInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Voir la facture'**
  String get viewInvoice;

  /// No description provided for @fullyPaidFromWallet.
  ///
  /// In fr, this message translates to:
  /// **'Entièrement réglée par le portefeuille.'**
  String get fullyPaidFromWallet;

  /// No description provided for @setTeacherPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get setTeacherPassword;

  /// No description provided for @setTeacherPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe pour {name}'**
  String setTeacherPasswordTitle(String name);

  /// No description provided for @setTeacherPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe actuel n\'est pas demandé. {name} sera déconnecté de tous ses appareils et se connectera avec le nouveau.'**
  String setTeacherPasswordHint(String name);

  /// No description provided for @teacherPasswordSet.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe mis à jour. Communiquez-le à l\'enseignant.'**
  String get teacherPasswordSet;

  /// No description provided for @generatePassword.
  ///
  /// In fr, this message translates to:
  /// **'Générer'**
  String get generatePassword;

  /// No description provided for @copyPassword.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copyPassword;

  /// No description provided for @passwordCopied.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe copié.'**
  String get passwordCopied;
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(lookupAppStrings(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

AppStrings lookupAppStrings(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppStringsAr();
    case 'fr':
      return AppStringsFr();
  }

  throw FlutterError(
    'AppStrings.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
