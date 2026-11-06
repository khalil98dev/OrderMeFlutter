// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_strings.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppStringsFr extends AppStrings {
  AppStringsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MedStore';

  @override
  String get adminSubtitle => 'Administration';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitleAdmin => 'Espace de l\'équipe MedStore';

  @override
  String get loginSubtitleTeacher => 'Commandez vos impressions';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get fieldRequired => 'Ce champ est obligatoire.';

  @override
  String get wrongCredentials => 'Nom d\'utilisateur ou mot de passe incorrect.';

  @override
  String get failureNetwork => 'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get failureUnauthorized => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get failureForbidden => 'Vous n\'avez pas l\'autorisation de faire cela.';

  @override
  String get failureNotFound => 'Élément introuvable.';

  @override
  String get failureConflict => 'Cet élément a été modifié entre-temps. Actualisez puis réessayez.';

  @override
  String get failureValidation => 'Veuillez corriger les champs indiqués.';

  @override
  String get failureWrongApp => 'Ce compte ne peut pas utiliser cette application.';

  @override
  String get failureServer => 'Le serveur a rencontré une erreur. Réessayez plus tard.';

  @override
  String get failureUnexpected => 'Une erreur inattendue s\'est produite.';

  @override
  String get retry => 'Réessayer';

  @override
  String get errorTitle => 'Une erreur est survenue';

  @override
  String get search => 'Rechercher';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get loading => 'Chargement…';

  @override
  String get decreaseQuantity => 'Diminuer la quantité';

  @override
  String get increaseQuantity => 'Augmenter la quantité';

  @override
  String get offline => 'Hors ligne';

  @override
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonMessage => 'Cet écran sera construit dans une prochaine étape.';

  @override
  String get sectionOperations => 'Opérations';

  @override
  String get sectionFinance => 'Finance';

  @override
  String get sectionSystem => 'Système';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navProducts => 'Produits';

  @override
  String get navTeachers => 'Enseignants';

  @override
  String get navSchools => 'Établissements';

  @override
  String get navInvoices => 'Factures';

  @override
  String get navWallet => 'Portefeuille';

  @override
  String get navDebts => 'Créances';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navProfile => 'Profil';

  @override
  String get collapseSidebar => 'Réduire la barre latérale';

  @override
  String get expandSidebar => 'Déployer la barre latérale';

  @override
  String get language => 'Langue';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get filterAll => 'Tous';

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsMessage => 'Essayez un autre mot ou retirez un filtre.';

  @override
  String tooLong(int max) {
    return '$max caractères au plus.';
  }

  @override
  String get productTypeGuide => 'Guide';

  @override
  String get productTypePracticeBook => 'Cahier d\'exercices';

  @override
  String get productTypeExamCollection => 'Recueil d\'examens';

  @override
  String get productTypeOther => 'Autre';

  @override
  String get productAvailable => 'Disponible';

  @override
  String get productUnavailable => 'Indisponible';

  @override
  String get priceHidden => 'Prix masqué';

  @override
  String pricePerCopy(String price) {
    return '$price / exemplaire';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count pages', one: '1 page');
    return '$_temp0';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String get searchProducts => 'Rechercher un produit';

  @override
  String get noProductsTitle => 'Aucun produit';

  @override
  String get noProductsTeacherMessage =>
      'Vos livres apparaîtront ici dès que l\'équipe MedStore les aura préparés.';

  @override
  String get noProductsAdminMessage => 'Créez le premier produit d\'un enseignant.';

  @override
  String get productDetails => 'Détails';

  @override
  String get productUnavailableNotice => 'Ce produit ne peut pas être commandé pour le moment.';

  @override
  String get newProduct => 'Nouveau produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldCode => 'Code';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldSubject => 'Matière';

  @override
  String get fieldLevel => 'Niveau';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldPageCount => 'Nombre de pages';

  @override
  String get fieldPrice => 'Prix par exemplaire (DA)';

  @override
  String get fieldTeacher => 'Enseignant';

  @override
  String get fieldAvailable => 'Disponible à la commande';

  @override
  String get fieldAvailableHint => 'Décoché, le produit reste visible mais ne peut plus être commandé.';

  @override
  String get fieldCover => 'Couverture';

  @override
  String get ownerCannotChange => 'Le propriétaire d\'un produit ne change pas.';

  @override
  String get chooseTeacher => 'Choisir un enseignant';

  @override
  String get chooseImage => 'Choisir une image';

  @override
  String get replaceImage => 'Remplacer';

  @override
  String get removeImage => 'Retirer';

  @override
  String get imageHint => 'JPEG, PNG ou WebP, 5 Mo au plus.';

  @override
  String get imageTooLarge => 'L\'image dépasse 5 Mo.';

  @override
  String get priceInvalid => 'Saisissez un prix valide (0 ou plus).';

  @override
  String get pageCountInvalid => 'Saisissez un nombre de pages supérieur à 0.';

  @override
  String deleteProductTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteProductMessage => 'Le produit disparaît de la liste. Les commandes passées le gardent.';

  @override
  String get productSaved => 'Produit enregistré';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get codeTaken => 'Ce code est déjà utilisé par un autre produit.';

  @override
  String get imageTypeInvalid => 'L\'image doit être un fichier JPEG, PNG ou WebP.';

  @override
  String get teacherUnavailable => 'Cet enseignant n\'existe pas ou est désactivé.';

  @override
  String get savedButCoverFailed => 'Le produit est enregistré, mais pas la couverture. Réessayez.';

  @override
  String get back => 'Retour';

  @override
  String get clear => 'Effacer';

  @override
  String get choose => 'Choisir';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get create => 'Créer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get downloadPdf => 'Télécharger le PDF';

  @override
  String fileSaved(String path) {
    return 'Fichier enregistré : $path';
  }

  @override
  String get none => 'Aucun';

  @override
  String get periodFrom => 'Du';

  @override
  String get periodTo => 'Au';

  @override
  String get total => 'Total';

  @override
  String get details => 'Détails';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldReason => 'Motif';

  @override
  String get fieldAmount => 'Montant (DA)';

  @override
  String get amountInvalid => 'Saisissez un montant supérieur à 0, avec 2 décimales au plus.';

  @override
  String get voidedBadge => 'Annulé';

  @override
  String get voidAction => 'Annuler définitivement';

  @override
  String byName(String name) {
    return 'par $name';
  }

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Désactivé';

  @override
  String get deactivate => 'Désactiver';

  @override
  String get validationUserNameTaken => 'Ce nom d\'utilisateur est déjà pris.';

  @override
  String get validationPassword => 'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get validationPhone => 'Numéro de téléphone invalide.';

  @override
  String get validationEmail => 'Adresse e-mail invalide.';

  @override
  String get colNumber => 'N°';

  @override
  String get colTeacher => 'Enseignant';

  @override
  String get colDate => 'Date';

  @override
  String get colStatus => 'Statut';

  @override
  String get colTotal => 'Total';

  @override
  String get colQuantity => 'Qté';

  @override
  String get colProduct => 'Produit';

  @override
  String get colUnitPrice => 'Prix unitaire';

  @override
  String get colLines => 'Lignes';

  @override
  String get colAmount => 'Montant';

  @override
  String get colBalance => 'Solde';

  @override
  String get colBalanceAfter => 'Solde après';

  @override
  String get colType => 'Type';

  @override
  String get colDueDate => 'Échéance';

  @override
  String get colPaid => 'Payé';

  @override
  String get colDue => 'Reste dû';

  @override
  String get colOrders => 'Commandes';

  @override
  String get colCopies => 'Exemplaires';

  @override
  String get colPhone => 'Téléphone';

  @override
  String get colSchool => 'Établissement';

  @override
  String get colReceipt => 'Reçu';

  @override
  String get colLabel => 'Libellé';

  @override
  String get account => 'Compte';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les deux mots de passe ne sont pas identiques.';

  @override
  String get passwordChanged => 'Mot de passe changé. Les autres appareils devront se reconnecter.';

  @override
  String get currentPasswordWrong => 'Le mot de passe actuel est incorrect.';

  @override
  String get changePasswordHint => 'Changer le mot de passe termine toutes les sessions ouvertes.';

  @override
  String get fieldRoles => 'Rôles';

  @override
  String get billingSettings => 'Facturation';

  @override
  String get autoSettle => 'Régler automatiquement';

  @override
  String get autoSettleHint =>
      'Après chaque facture, créance ou dépôt, l\'argent du portefeuille paie ce qui est dû, le plus ancien d\'abord.';

  @override
  String get defaultPaymentTerms => 'Échéance par défaut des nouveaux enseignants';

  @override
  String get settingsSaved => 'Paramètres enregistrés';

  @override
  String lastChanged(String date, String name) {
    return 'Modifié le $date par $name';
  }

  @override
  String get fieldPaymentTerms => 'Échéance';

  @override
  String get paymentTermsImmediate => 'Comptant';

  @override
  String get paymentTermsEndOfMonth => 'Fin de mois';

  @override
  String get paymentTermsEndOfYear => 'Fin d\'année';

  @override
  String get paymentTermsDefault => 'Par défaut (paramètres)';

  @override
  String teachersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enseignants',
      one: '1 enseignant',
      zero: 'Aucun enseignant',
    );
    return '$_temp0';
  }

  @override
  String get searchTeachers => 'Rechercher un enseignant';

  @override
  String get newTeacher => 'Nouvel enseignant';

  @override
  String get editTeacher => 'Modifier l\'enseignant';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldSchool => 'Établissement';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get signInAccount => 'Compte de connexion';

  @override
  String get signInAccountHint =>
      'L\'enseignant se connecte à l\'application mobile avec ce nom et ce mot de passe.';

  @override
  String deactivateTeacherTitle(String name) {
    return 'Désactiver $name ?';
  }

  @override
  String get deactivateTeacherMessage =>
      'Son compte est fermé et ses sessions terminées. Ses commandes et factures restent.';

  @override
  String get teacherDeactivated => 'Enseignant désactivé';

  @override
  String get teacherSaved => 'Enseignant enregistré';

  @override
  String get noTeachersTitle => 'Aucun enseignant';

  @override
  String get noTeachersMessage => 'Créez le premier compte enseignant.';

  @override
  String get allTeachers => 'Tous les enseignants';

  @override
  String get chooseSchool => 'Choisir un établissement';

  @override
  String get statement => 'Relevé de compte';

  @override
  String get statementInvoices => 'Factures de la période';

  @override
  String get statementMovements => 'Mouvements du portefeuille';

  @override
  String get statementOpenDebts => 'Créances ouvertes';

  @override
  String get totalsInvoiced => 'Facturé';

  @override
  String get totalsDeposited => 'Déposé';

  @override
  String get totalsPaidFromWallet => 'Payé par le portefeuille';

  @override
  String get owedNow => 'Dû aujourd\'hui';

  @override
  String get overdueNow => 'En retard aujourd\'hui';

  @override
  String get walletBalanceNow => 'Solde du portefeuille';

  @override
  String get nothingInPeriod => 'Rien sur cette période.';

  @override
  String get periodTooLong => 'Choisissez une période de 366 jours au plus.';

  @override
  String schoolsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count établissements',
      one: '1 établissement',
      zero: 'Aucun établissement',
    );
    return '$_temp0';
  }

  @override
  String get searchSchools => 'Rechercher un établissement';

  @override
  String get newSchool => 'Nouvel établissement';

  @override
  String get editSchool => 'Modifier l\'établissement';

  @override
  String get fieldWilaya => 'Wilaya (code)';

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldSchoolLevel => 'Cycle';

  @override
  String get fieldSchoolType => 'Secteur';

  @override
  String get schoolLevelPrimary => 'Primaire';

  @override
  String get schoolLevelMiddle => 'Moyen';

  @override
  String get schoolLevelSecondary => 'Secondaire';

  @override
  String get schoolLevelUniversity => 'Université';

  @override
  String get schoolLevelOther => 'Autre';

  @override
  String get schoolTypePublic => 'Public';

  @override
  String get schoolTypePrivate => 'Privé';

  @override
  String get schoolSaved => 'Établissement enregistré';

  @override
  String get noSchoolsTitle => 'Aucun établissement';

  @override
  String get noSchoolsMessage => 'Ajoutez les établissements où enseignent vos clients.';

  @override
  String get wilayaInvalid => 'Saisissez un code de wilaya entre 1 et 58.';

  @override
  String wilayaLabel(int code) {
    return 'Wilaya $code';
  }

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: 'Aucune commande',
    );
    return '$_temp0';
  }

  @override
  String get newOrder => 'Nouvelle commande';

  @override
  String orderNumber(int number) {
    return 'Commande n° $number';
  }

  @override
  String get searchOrderNumber => 'N° de commande';

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusInPreparation => 'En préparation';

  @override
  String get orderStatusReady => 'Prête';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderLines => 'Lignes';

  @override
  String get orderHistory => 'Historique';

  @override
  String get actionStartPreparation => 'Commencer la préparation';

  @override
  String get actionMarkReady => 'Marquer prête';

  @override
  String get actionMarkDelivered => 'Marquer livrée';

  @override
  String get actionCancelOrder => 'Annuler la commande';

  @override
  String get statusNoteLabel => 'Note pour l\'enseignant';

  @override
  String changeStatusTitle(String status) {
    return 'Passer la commande à « $status » ?';
  }

  @override
  String get cancelOrderMessage =>
      'Le motif est montré à l\'enseignant. Il est obligatoire une fois la préparation commencée.';

  @override
  String get orderStatusChanged => 'Statut mis à jour';

  @override
  String get reviseOrder => 'Modifier les lignes';

  @override
  String get orderSaved => 'Commande enregistrée';

  @override
  String orderPlaced(int number) {
    return 'Commande n° $number créée';
  }

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get noLines => 'Ajoutez au moins un produit.';

  @override
  String get actorClient => 'Enseignant';

  @override
  String get actorStaff => 'Équipe';

  @override
  String get noOrdersTitle => 'Aucune commande';

  @override
  String get noOrdersMessage => 'Les commandes des enseignants apparaîtront ici.';

  @override
  String get chooseProduct => 'Choisir un produit';

  @override
  String get chooseTeacherFirst => 'Choisissez d\'abord l\'enseignant.';

  @override
  String get orderEditableHint =>
      'Les lignes se modifient tant que la commande est en attente ou en préparation.';

  @override
  String get noProductsForTeacher => 'Cet enseignant n\'a aucun produit disponible.';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lignes', one: '1 ligne');
    return '$_temp0';
  }

  @override
  String walletsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portefeuilles',
      one: '1 portefeuille',
      zero: 'Aucun portefeuille',
    );
    return '$_temp0';
  }

  @override
  String get balance => 'Solde';

  @override
  String get totalDeposited => 'Total déposé';

  @override
  String get lastMovement => 'Dernier mouvement';

  @override
  String get newDeposit => 'Nouveau dépôt';

  @override
  String get newWithdrawal => 'Nouveau retrait';

  @override
  String get settleNow => 'Régler maintenant';

  @override
  String get settleNowMessage =>
      'L\'argent du portefeuille paie les factures et créances dues, les plus anciennes d\'abord.';

  @override
  String get fieldMethod => 'Moyen de paiement';

  @override
  String get fieldReference => 'Référence';

  @override
  String get referenceHint => 'N° de virement, page du carnet…';

  @override
  String get paymentMethodCash => 'Espèces';

  @override
  String get paymentMethodBankTransfer => 'Virement';

  @override
  String get paymentMethodOther => 'Autre';

  @override
  String get txDeposit => 'Dépôt';

  @override
  String get txWithdrawal => 'Retrait';

  @override
  String get txReversal => 'Annulation';

  @override
  String get txInvoicePayment => 'Paiement de facture';

  @override
  String get txOtherPayment => 'Paiement de créance';

  @override
  String get allTypes => 'Tous les types';

  @override
  String get voidTransaction => 'Annuler l\'opération';

  @override
  String get voidTransactionMessage =>
      'Une écriture inverse est ajoutée. L\'opération reste visible, marquée annulée.';

  @override
  String get downloadReceipt => 'Télécharger le reçu';

  @override
  String depositRecorded(String receipt) {
    return 'Dépôt enregistré ($receipt)';
  }

  @override
  String get withdrawalRecorded => 'Retrait enregistré';

  @override
  String get transactionVoided => 'Opération annulée';

  @override
  String settledAmount(String amount) {
    return '$amount réglés depuis le portefeuille';
  }

  @override
  String get noWalletsTitle => 'Aucun portefeuille';

  @override
  String get noWalletsMessage => 'Un portefeuille apparaît au premier dépôt.';

  @override
  String get noTransactionsTitle => 'Aucune opération';

  @override
  String get withdrawalHint => 'Jamais plus que le solde.';

  @override
  String invoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count factures',
      one: '1 facture',
      zero: 'Aucune facture',
    );
    return '$_temp0';
  }

  @override
  String get newInvoice => 'Nouvelle facture';

  @override
  String get paymentStatusUnpaid => 'Non payée';

  @override
  String get paymentStatusPartiallyPaid => 'Payée en partie';

  @override
  String get paymentStatusPaid => 'Payée';

  @override
  String get overdue => 'En retard';

  @override
  String get onlyOverdue => 'En retard seulement';

  @override
  String get includeVoided => 'Inclure les annulées';

  @override
  String get fieldPaymentStatus => 'Paiement';

  @override
  String get issueDate => 'Date d\'émission';

  @override
  String get dueDate => 'Échéance';

  @override
  String get amountPaid => 'Payé';

  @override
  String get amountDue => 'Reste dû';

  @override
  String get invoicePayments => 'Paiements';

  @override
  String refundedOn(String date) {
    return 'Remboursé le $date';
  }

  @override
  String get voidInvoice => 'Annuler la facture';

  @override
  String get voidInvoiceMessage =>
      'Ses exemplaires retournent aux commandes et ses paiements au portefeuille.';

  @override
  String get settleFromWallet => 'Régler depuis le portefeuille';

  @override
  String get settleAmountLabel => 'Montant (vide : le maximum possible)';

  @override
  String get uninvoicedTitle => 'Exemplaires à facturer';

  @override
  String get noUninvoiced => 'Rien à facturer pour cet enseignant.';

  @override
  String get toInvoice => 'À facturer';

  @override
  String get available => 'Disponible';

  @override
  String get issueInvoice => 'Émettre la facture';

  @override
  String invoiceIssued(String label) {
    return 'Facture $label émise';
  }

  @override
  String get invoiceVoided => 'Facture annulée';

  @override
  String get invoiceSettled => 'Facture réglée';

  @override
  String fromOrders(String numbers) {
    return 'Commandes : $numbers';
  }

  @override
  String get noInvoicesTitle => 'Aucune facture';

  @override
  String get noInvoicesMessage => 'Émettez une facture à partir des commandes d\'un enseignant.';

  @override
  String get nothingSelected => 'Saisissez au moins une quantité à facturer.';

  @override
  String quantityTooHigh(int max) {
    return 'Au plus $max.';
  }

  @override
  String get onlyOwing => 'Seulement ceux qui doivent';

  @override
  String get totalOwed => 'Total dû';

  @override
  String get overdueInvoices => 'Factures en retard';

  @override
  String get upcomingInvoices => 'Factures à venir';

  @override
  String get openDebts => 'Créances';

  @override
  String get oldestDue => 'Plus ancienne échéance';

  @override
  String get newDebt => 'Nouvelle créance';

  @override
  String get debtDueHint => 'Vide : due aujourd\'hui.';

  @override
  String get debtKindInvoice => 'Facture';

  @override
  String get debtKindDebt => 'Créance';

  @override
  String get includeClosed => 'Inclure les soldées';

  @override
  String get writeOff => 'Passer en perte';

  @override
  String get writeOffMessage => 'Ce qui reste de la créance est abandonné.';

  @override
  String get debtCreated => 'Créance enregistrée';

  @override
  String get debtSettled => 'Créance réglée';

  @override
  String get debtWrittenOff => 'Créance passée en perte';

  @override
  String get writtenOff => 'Abandonné';

  @override
  String writtenOffOn(String date, String reason) {
    return 'Abandonné le $date : $reason';
  }

  @override
  String get noDebtsTitle => 'Personne ne doit rien';

  @override
  String get noDebtsMessage => 'Les factures impayées et les créances saisies apparaîtront ici.';

  @override
  String get debtDescriptionHint => 'Dû d\'avant l\'application, ajustement…';

  @override
  String get navReports => 'Rapports';

  @override
  String get navSecurity => 'Sécurité';

  @override
  String get thePeriod => 'Sur la période';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get ordersPlaced => 'Commandes passées';

  @override
  String get copiesOrdered => 'Exemplaires commandés';

  @override
  String get amountOrdered => 'Montant commandé';

  @override
  String get invoicesIssued => 'Factures émises';

  @override
  String get amountInvoiced => 'Montant facturé';

  @override
  String get depositsCount => 'Dépôts';

  @override
  String get amountDeposited => 'Montant déposé';

  @override
  String get amountPaidFromWallets => 'Payé par les portefeuilles';

  @override
  String get newTeachers => 'Nouveaux enseignants';

  @override
  String get activeTeachers => 'Enseignants actifs';

  @override
  String get heldInWallets => 'Dans les portefeuilles';

  @override
  String get ordersByStatus => 'Commandes par statut';

  @override
  String get salesReport => 'Ventes';

  @override
  String get groupBy => 'Regrouper par';

  @override
  String get groupByProduct => 'Produit';

  @override
  String get groupByClient => 'Enseignant';

  @override
  String get groupBySchool => 'Établissement';

  @override
  String get groupByWilaya => 'Wilaya';

  @override
  String get groupByMonth => 'Mois';

  @override
  String get noSalesTitle => 'Aucune vente sur la période';

  @override
  String get tabRoles => 'Rôles';

  @override
  String get tabUsers => 'Utilisateurs';

  @override
  String get tabResources => 'Ressources';

  @override
  String get newRole => 'Nouveau rôle';

  @override
  String get fieldRoleName => 'Nom du rôle';

  @override
  String get roleCreated => 'Rôle créé';

  @override
  String permissionsOf(String role) {
    return 'Permissions : $role';
  }

  @override
  String get permissionsSaved => 'Permissions enregistrées';

  @override
  String get editPermissions => 'Modifier les permissions';

  @override
  String get permCreate => 'Créer';

  @override
  String get permRead => 'Lire';

  @override
  String get permSet => 'Modifier';

  @override
  String get permDelete => 'Supprimer';

  @override
  String get securedFields => 'Champs protégés';

  @override
  String get resourceCol => 'Ressource';

  @override
  String grantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ressources accordées',
      one: '1 ressource accordée',
      zero: 'Aucune permission',
    );
    return '$_temp0';
  }

  @override
  String get adminRoleNotice => 'Le rôle Admin reçoit toutes les permissions à chaque démarrage du serveur.';

  @override
  String get newUser => 'Nouvel utilisateur';

  @override
  String get userCreated => 'Utilisateur créé';

  @override
  String get editRoles => 'Rôles';

  @override
  String get rolesSaved => 'Rôles enregistrés. L\'utilisateur doit se reconnecter.';

  @override
  String rolesOf(String name) {
    return 'Rôles de $name';
  }

  @override
  String deactivateUserTitle(String name) {
    return 'Désactiver $name ?';
  }

  @override
  String get deactivateUserMessage => 'Le compte ne peut plus se connecter et ses sessions sont terminées.';

  @override
  String get userDeactivated => 'Utilisateur désactivé';

  @override
  String get teacherAccountsHint => 'Les comptes enseignants se gèrent dans Enseignants.';

  @override
  String get chooseRoles => 'Choisissez au moins un rôle.';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get unreadOnly => 'Non lues seulement';

  @override
  String get noNotificationsTitle => 'Aucune notification';

  @override
  String get noNotificationsMessage => 'Les nouvelles notifications apparaîtront ici.';

  @override
  String get cart => 'Panier';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String inCart(int count) {
    return '$count dans le panier';
  }

  @override
  String get cartEmptyTitle => 'Votre panier est vide';

  @override
  String get cartEmptyMessage => 'Ajoutez des livres depuis vos produits, puis passez commande ici.';

  @override
  String get browseProducts => 'Voir mes produits';

  @override
  String get viewCart => 'Voir le panier';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String copiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exemplaires',
      one: '1 exemplaire',
    );
    return '$_temp0';
  }

  @override
  String get orderNotesHint => 'Une précision pour l\'équipe (facultatif)';

  @override
  String get orderSentTitle => 'Commande envoyée';

  @override
  String orderSentMessage(int number) {
    return 'Commande n° $number : l\'équipe MedStore vous préviendra dès qu\'elle sera prête.';
  }

  @override
  String get viewOrder => 'Voir la commande';

  @override
  String get confirmDelivery => 'J\'ai reçu ma commande';

  @override
  String get confirmDeliveryMessage => 'Confirmez-vous avoir reçu cette commande ?';

  @override
  String get cancelMyOrderMessage => 'Annuler cette commande ? L\'équipe ne la préparera pas.';

  @override
  String get orderCancelled => 'Commande annulée';

  @override
  String get deliveryConfirmed => 'Réception confirmée, merci !';

  @override
  String greeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get greetingSubtitle => 'Vos livres, prêts à être commandés.';

  @override
  String get noOrdersTeacherMessage => 'Vos commandes apparaîtront ici, avec leur suivi.';

  @override
  String get orderProgress => 'Suivi';

  @override
  String get readyPickupHint => 'Votre commande est prête : vous pouvez venir la récupérer.';

  @override
  String get cartUnavailableHint => 'Retirez les produits indisponibles pour commander.';

  @override
  String notifOrderPlacedForYouTitle(String number) {
    return 'Commande n° $number enregistrée';
  }

  @override
  String get notifOrderPlacedForYouMessage => 'L\'équipe MedStore a enregistré une commande pour vous.';

  @override
  String notifOrderPreparingTitle(String number) {
    return 'Commande n° $number en préparation';
  }

  @override
  String get notifOrderPreparingMessage => 'L\'équipe MedStore prépare votre commande.';

  @override
  String notifOrderReadyTitle(String number) {
    return 'Commande n° $number prête';
  }

  @override
  String notifOrderDeliveredTitle(String number) {
    return 'Commande n° $number livrée';
  }

  @override
  String get notifOrderDeliveredMessage => 'Votre commande a été remise.';

  @override
  String notifOrderCancelledTitle(String number) {
    return 'Commande n° $number annulée';
  }

  @override
  String get notifOrderCancelledMessage => 'L\'équipe MedStore a annulé votre commande.';

  @override
  String notifInvoiceTitle(String number) {
    return 'Nouvelle facture $number';
  }

  @override
  String get notifInvoiceMessage => 'Une nouvelle facture a été émise à votre nom.';

  @override
  String get notifDepositTitle => 'Versement enregistré';

  @override
  String get notifDepositMessage => 'Votre versement a été enregistré.';

  @override
  String get notifProductTitle => 'Nouveau produit';

  @override
  String notifProductMessage(String name) {
    return '« $name » est disponible à la commande.';
  }

  @override
  String get byProductTitle => 'Résumé par produit';

  @override
  String get byProductSubtitle => 'Toutes les factures de la période, regroupées par produit';

  @override
  String get onlyUnpaid => 'Seulement les impayées';

  @override
  String get colInvoices => 'Factures';

  @override
  String get totalQuantity => 'Quantité totale';

  @override
  String get noInvoicedProductsTitle => 'Aucune facture sur cette période';

  @override
  String get noInvoicedProductsMessage => 'Changez la période, l\'enseignant ou le filtre des impayées.';

  @override
  String invoicedProductSources(String product) {
    return 'D\'où vient ce total : $product';
  }

  @override
  String get collectPayment => 'Encaisser';

  @override
  String get collectPaymentTitle => 'Encaisser au comptoir';

  @override
  String collectPaymentMessage(String amount) {
    return 'Reste dû : $amount. Le paiement est enregistré comme un versement (avec reçu) et règle cette facture en premier.';
  }

  @override
  String get collectAmountLabel => 'Montant (vide : tout le reste dû)';

  @override
  String get paymentCollected => 'Paiement encaissé';

  @override
  String invoiceIssuedTitle(String label) {
    return 'Facture $label émise';
  }

  @override
  String get invoiceIssuedMessage =>
      'La commande est prête : sa facture a été émise automatiquement. L\'enseignant pourra payer le reste à la librairie.';

  @override
  String get paidFromWallet => 'Payé par le portefeuille';

  @override
  String get leftAsDebt => 'Reste dû (créance)';

  @override
  String get viewInvoice => 'Voir la facture';

  @override
  String get fullyPaidFromWallet => 'Entièrement réglée par le portefeuille.';
}
