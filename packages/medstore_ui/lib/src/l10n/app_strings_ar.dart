// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_strings.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppStringsAr extends AppStrings {
  AppStringsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MedStore';

  @override
  String get adminSubtitle => 'الإدارة';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitleAdmin => 'فضاء فريق MedStore';

  @override
  String get loginSubtitleTeacher => 'اطلب طباعة كتبك';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get signIn => 'دخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get wrongCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get failureNetwork => 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';

  @override
  String get failureUnauthorized => 'انتهت جلستك. يرجى تسجيل الدخول من جديد.';

  @override
  String get failureForbidden => 'ليست لديك صلاحية للقيام بهذا الإجراء.';

  @override
  String get failureNotFound => 'العنصر غير موجود.';

  @override
  String get failureConflict => 'تم تعديل هذا العنصر في الأثناء. حدّث الصفحة ثم أعد المحاولة.';

  @override
  String get failureValidation => 'يرجى تصحيح الحقول المشار إليها.';

  @override
  String get failureWrongApp => 'لا يمكن لهذا الحساب استخدام هذا التطبيق.';

  @override
  String get failureServer => 'حدث خطأ في الخادم. أعد المحاولة لاحقًا.';

  @override
  String get failureUnexpected => 'حدث خطأ غير متوقع.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorTitle => 'حدث خطأ';

  @override
  String get search => 'بحث';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get decreaseQuantity => 'إنقاص الكمية';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get offline => 'غير متصل';

  @override
  String get comingSoonTitle => 'قريبًا';

  @override
  String get comingSoonMessage => 'ستُضاف هذه الشاشة في مرحلة قادمة.';

  @override
  String get sectionOperations => 'العمليات';

  @override
  String get sectionFinance => 'المالية';

  @override
  String get sectionSystem => 'النظام';

  @override
  String get navDashboard => 'لوحة القيادة';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navTeachers => 'الأساتذة';

  @override
  String get navSchools => 'المؤسسات';

  @override
  String get navInvoices => 'الفواتير';

  @override
  String get navWallet => 'المحفظة';

  @override
  String get navDebts => 'الديون';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get collapseSidebar => 'طيّ الشريط الجانبي';

  @override
  String get expandSidebar => 'توسيع الشريط الجانبي';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get filterAll => 'الكل';

  @override
  String get noResultsTitle => 'لا توجد نتائج';

  @override
  String get noResultsMessage => 'جرّب كلمة أخرى أو أزل أحد المرشحات.';

  @override
  String tooLong(int max) {
    return '$max حرفًا على الأكثر.';
  }

  @override
  String get productTypeGuide => 'دليل';

  @override
  String get productTypePracticeBook => 'كرّاس تمارين';

  @override
  String get productTypeExamCollection => 'مجموعة امتحانات';

  @override
  String get productTypeOther => 'أخرى';

  @override
  String get productAvailable => 'متوفر';

  @override
  String get productUnavailable => 'غير متوفر';

  @override
  String get priceHidden => 'السعر مخفي';

  @override
  String pricePerCopy(String price) {
    return '$price للنسخة';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      many: '$count صفحة',
      few: '$count صفحات',
      two: 'صفحتان',
      one: 'صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتجًا',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
  }

  @override
  String get searchProducts => 'ابحث عن منتج';

  @override
  String get noProductsTitle => 'لا توجد منتجات';

  @override
  String get noProductsTeacherMessage => 'ستظهر كتبك هنا بمجرد أن يجهّزها فريق MedStore.';

  @override
  String get noProductsAdminMessage => 'أنشئ أول منتج لأحد الأساتذة.';

  @override
  String get productDetails => 'التفاصيل';

  @override
  String get productUnavailableNotice => 'لا يمكن طلب هذا المنتج حاليًا.';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldCode => 'الرمز';

  @override
  String get fieldDescription => 'الوصف';

  @override
  String get fieldSubject => 'المادة';

  @override
  String get fieldLevel => 'المستوى';

  @override
  String get fieldType => 'النوع';

  @override
  String get fieldPageCount => 'عدد الصفحات';

  @override
  String get fieldPrice => 'سعر النسخة (د.ج)';

  @override
  String get fieldTeacher => 'الأستاذ';

  @override
  String get fieldAvailable => 'متاح للطلب';

  @override
  String get fieldAvailableHint => 'عند إلغاء التحديد يبقى المنتج ظاهرًا لكن لا يمكن طلبه.';

  @override
  String get fieldCover => 'الغلاف';

  @override
  String get ownerCannotChange => 'لا يمكن تغيير صاحب المنتج.';

  @override
  String get chooseTeacher => 'اختيار أستاذ';

  @override
  String get chooseImage => 'اختيار صورة';

  @override
  String get replaceImage => 'استبدال';

  @override
  String get removeImage => 'إزالة';

  @override
  String get imageHint => 'JPEG أو PNG أو WebP، بحد أقصى 5 ميغابايت.';

  @override
  String get imageTooLarge => 'حجم الصورة يتجاوز 5 ميغابايت.';

  @override
  String get priceInvalid => 'أدخل سعرًا صحيحًا (0 أو أكثر).';

  @override
  String get pageCountInvalid => 'أدخل عدد صفحات أكبر من 0.';

  @override
  String deleteProductTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get deleteProductMessage => 'سيختفي المنتج من القائمة، وتبقى الطلبات السابقة مرتبطة به.';

  @override
  String get productSaved => 'تم حفظ المنتج';

  @override
  String get productDeleted => 'تم حذف المنتج';

  @override
  String get codeTaken => 'هذا الرمز مستخدم لمنتج آخر.';

  @override
  String get imageTypeInvalid => 'يجب أن تكون الصورة بصيغة JPEG أو PNG أو WebP.';

  @override
  String get teacherUnavailable => 'هذا الأستاذ غير موجود أو معطّل.';

  @override
  String get savedButCoverFailed => 'تم حفظ المنتج لكن لم يتم حفظ الغلاف. أعد المحاولة.';

  @override
  String get back => 'رجوع';

  @override
  String get clear => 'مسح';

  @override
  String get choose => 'اختيار';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get create => 'إنشاء';

  @override
  String get refresh => 'تحديث';

  @override
  String get downloadPdf => 'تنزيل PDF';

  @override
  String fileSaved(String path) {
    return 'تم حفظ الملف: $path';
  }

  @override
  String get none => 'لا شيء';

  @override
  String get periodFrom => 'من';

  @override
  String get periodTo => 'إلى';

  @override
  String get total => 'المجموع';

  @override
  String get details => 'التفاصيل';

  @override
  String get fieldNotes => 'ملاحظات';

  @override
  String get fieldNote => 'ملاحظة';

  @override
  String get fieldReason => 'السبب';

  @override
  String get fieldAmount => 'المبلغ (د.ج)';

  @override
  String get amountInvalid => 'أدخل مبلغًا أكبر من 0 وبرقمين عشريين على الأكثر.';

  @override
  String get voidedBadge => 'ملغى';

  @override
  String get voidAction => 'إلغاء نهائي';

  @override
  String byName(String name) {
    return 'بواسطة $name';
  }

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'معطّل';

  @override
  String get deactivate => 'تعطيل';

  @override
  String get validationUserNameTaken => 'اسم المستخدم هذا مستعمل.';

  @override
  String get validationPassword => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get validationPhone => 'رقم الهاتف غير صالح.';

  @override
  String get validationEmail => 'البريد الإلكتروني غير صالح.';

  @override
  String get colNumber => 'الرقم';

  @override
  String get colTeacher => 'الأستاذ';

  @override
  String get colDate => 'التاريخ';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colTotal => 'المجموع';

  @override
  String get colQuantity => 'الكمية';

  @override
  String get colProduct => 'المنتج';

  @override
  String get colUnitPrice => 'سعر الوحدة';

  @override
  String get colLines => 'الأسطر';

  @override
  String get colAmount => 'المبلغ';

  @override
  String get colBalance => 'الرصيد';

  @override
  String get colBalanceAfter => 'الرصيد بعد';

  @override
  String get colType => 'النوع';

  @override
  String get colDueDate => 'تاريخ الاستحقاق';

  @override
  String get colPaid => 'المدفوع';

  @override
  String get colDue => 'المتبقي';

  @override
  String get colOrders => 'الطلبات';

  @override
  String get colCopies => 'النسخ';

  @override
  String get colPhone => 'الهاتف';

  @override
  String get colSchool => 'المؤسسة';

  @override
  String get colReceipt => 'الوصل';

  @override
  String get colLabel => 'البيان';

  @override
  String get account => 'الحساب';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور. ستحتاج الأجهزة الأخرى إلى تسجيل الدخول من جديد.';

  @override
  String get currentPasswordWrong => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get changePasswordHint => 'تغيير كلمة المرور ينهي كل الجلسات المفتوحة.';

  @override
  String get fieldRoles => 'الأدوار';

  @override
  String get billingSettings => 'الفوترة';

  @override
  String get autoSettle => 'التسوية التلقائية';

  @override
  String get autoSettleHint => 'بعد كل فاتورة أو دين أو إيداع، يدفع رصيد المحفظة المستحقات بدءًا بالأقدم.';

  @override
  String get defaultPaymentTerms => 'أجل الدفع الافتراضي للأساتذة الجدد';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String lastChanged(String date, String name) {
    return 'عُدّل في $date بواسطة $name';
  }

  @override
  String get fieldPaymentTerms => 'أجل الدفع';

  @override
  String get paymentTermsImmediate => 'فوري';

  @override
  String get paymentTermsEndOfMonth => 'نهاية الشهر';

  @override
  String get paymentTermsEndOfYear => 'نهاية السنة';

  @override
  String get paymentTermsDefault => 'الافتراضي (الإعدادات)';

  @override
  String teachersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أستاذ',
      many: '$count أستاذًا',
      few: '$count أساتذة',
      two: 'أستاذان',
      one: 'أستاذ واحد',
      zero: 'لا يوجد أساتذة',
    );
    return '$_temp0';
  }

  @override
  String get searchTeachers => 'البحث عن أستاذ';

  @override
  String get newTeacher => 'أستاذ جديد';

  @override
  String get editTeacher => 'تعديل الأستاذ';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldEmail => 'البريد الإلكتروني';

  @override
  String get fieldSchool => 'المؤسسة';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get signInAccount => 'حساب الدخول';

  @override
  String get signInAccountHint => 'يدخل الأستاذ إلى تطبيق الهاتف بهذا الاسم وكلمة المرور.';

  @override
  String deactivateTeacherTitle(String name) {
    return 'تعطيل $name؟';
  }

  @override
  String get deactivateTeacherMessage => 'يُغلق حسابه وتنتهي جلساته. تبقى طلباته وفواتيره.';

  @override
  String get teacherDeactivated => 'تم تعطيل الأستاذ';

  @override
  String get teacherSaved => 'تم حفظ الأستاذ';

  @override
  String get noTeachersTitle => 'لا يوجد أساتذة';

  @override
  String get noTeachersMessage => 'أنشئ أول حساب أستاذ.';

  @override
  String get allTeachers => 'كل الأساتذة';

  @override
  String get chooseSchool => 'اختيار مؤسسة';

  @override
  String get statement => 'كشف الحساب';

  @override
  String get statementInvoices => 'فواتير الفترة';

  @override
  String get statementMovements => 'حركات المحفظة';

  @override
  String get statementOpenDebts => 'الديون المفتوحة';

  @override
  String get totalsInvoiced => 'المفوتر';

  @override
  String get totalsDeposited => 'المودع';

  @override
  String get totalsPaidFromWallet => 'المدفوع من المحفظة';

  @override
  String get owedNow => 'المستحق اليوم';

  @override
  String get overdueNow => 'المتأخر اليوم';

  @override
  String get walletBalanceNow => 'رصيد المحفظة';

  @override
  String get nothingInPeriod => 'لا شيء في هذه الفترة.';

  @override
  String get periodTooLong => 'اختر فترة لا تتجاوز 366 يومًا.';

  @override
  String schoolsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مؤسسة',
      many: '$count مؤسسة',
      few: '$count مؤسسات',
      two: 'مؤسستان',
      one: 'مؤسسة واحدة',
      zero: 'لا توجد مؤسسات',
    );
    return '$_temp0';
  }

  @override
  String get searchSchools => 'البحث عن مؤسسة';

  @override
  String get newSchool => 'مؤسسة جديدة';

  @override
  String get editSchool => 'تعديل المؤسسة';

  @override
  String get fieldWilaya => 'الولاية (الرمز)';

  @override
  String get fieldCity => 'المدينة';

  @override
  String get fieldSchoolLevel => 'الطور';

  @override
  String get fieldSchoolType => 'القطاع';

  @override
  String get schoolLevelPrimary => 'ابتدائي';

  @override
  String get schoolLevelMiddle => 'متوسط';

  @override
  String get schoolLevelSecondary => 'ثانوي';

  @override
  String get schoolLevelUniversity => 'جامعة';

  @override
  String get schoolLevelOther => 'آخر';

  @override
  String get schoolTypePublic => 'عمومي';

  @override
  String get schoolTypePrivate => 'خاص';

  @override
  String get schoolSaved => 'تم حفظ المؤسسة';

  @override
  String get noSchoolsTitle => 'لا توجد مؤسسات';

  @override
  String get noSchoolsMessage => 'أضف المؤسسات التي يدرّس فيها زبائنك.';

  @override
  String get wilayaInvalid => 'أدخل رمز ولاية بين 1 و58.';

  @override
  String wilayaLabel(int code) {
    return 'الولاية $code';
  }

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      many: '$count طلبًا',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String get newOrder => 'طلب جديد';

  @override
  String orderNumber(int number) {
    return 'الطلب رقم $number';
  }

  @override
  String get searchOrderNumber => 'رقم الطلب';

  @override
  String get orderStatusPending => 'في الانتظار';

  @override
  String get orderStatusInPreparation => 'قيد التحضير';

  @override
  String get orderStatusReady => 'جاهز';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusCancelled => 'ملغى';

  @override
  String get orderLines => 'الأسطر';

  @override
  String get orderHistory => 'السجل';

  @override
  String get actionStartPreparation => 'بدء التحضير';

  @override
  String get actionMarkReady => 'تعيين كجاهز';

  @override
  String get actionMarkDelivered => 'تعيين كمسلَّم';

  @override
  String get actionCancelOrder => 'إلغاء الطلب';

  @override
  String get statusNoteLabel => 'ملاحظة للأستاذ';

  @override
  String changeStatusTitle(String status) {
    return 'نقل الطلب إلى «$status»؟';
  }

  @override
  String get cancelOrderMessage => 'يُعرض السبب على الأستاذ، وهو إلزامي بعد بدء التحضير.';

  @override
  String get orderStatusChanged => 'تم تحديث الحالة';

  @override
  String get reviseOrder => 'تعديل الأسطر';

  @override
  String get orderSaved => 'تم حفظ الطلب';

  @override
  String orderPlaced(int number) {
    return 'تم إنشاء الطلب رقم $number';
  }

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get noLines => 'أضف منتجًا واحدًا على الأقل.';

  @override
  String get actorClient => 'الأستاذ';

  @override
  String get actorStaff => 'الفريق';

  @override
  String get noOrdersTitle => 'لا توجد طلبات';

  @override
  String get noOrdersMessage => 'ستظهر طلبات الأساتذة هنا.';

  @override
  String get chooseProduct => 'اختيار منتج';

  @override
  String get chooseTeacherFirst => 'اختر الأستاذ أولًا.';

  @override
  String get orderEditableHint => 'يمكن تعديل الأسطر ما دام الطلب في الانتظار أو قيد التحضير.';

  @override
  String get noProductsForTeacher => 'لا توجد منتجات متاحة لهذا الأستاذ.';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سطر',
      many: '$count سطرًا',
      few: '$count أسطر',
      two: 'سطران',
      one: 'سطر واحد',
    );
    return '$_temp0';
  }

  @override
  String walletsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محفظة',
      many: '$count محفظة',
      few: '$count محافظ',
      two: 'محفظتان',
      one: 'محفظة واحدة',
      zero: 'لا توجد محافظ',
    );
    return '$_temp0';
  }

  @override
  String get balance => 'الرصيد';

  @override
  String get totalDeposited => 'مجموع الإيداعات';

  @override
  String get lastMovement => 'آخر حركة';

  @override
  String get newDeposit => 'إيداع جديد';

  @override
  String get newWithdrawal => 'سحب جديد';

  @override
  String get settleNow => 'التسوية الآن';

  @override
  String get settleNowMessage => 'يدفع رصيد المحفظة الفواتير والديون المستحقة بدءًا بالأقدم.';

  @override
  String get fieldMethod => 'وسيلة الدفع';

  @override
  String get fieldReference => 'المرجع';

  @override
  String get referenceHint => 'رقم التحويل، صفحة الدفتر…';

  @override
  String get paymentMethodCash => 'نقدًا';

  @override
  String get paymentMethodBankTransfer => 'تحويل بنكي';

  @override
  String get paymentMethodOther => 'أخرى';

  @override
  String get txDeposit => 'إيداع';

  @override
  String get txWithdrawal => 'سحب';

  @override
  String get txReversal => 'إلغاء';

  @override
  String get txInvoicePayment => 'دفع فاتورة';

  @override
  String get txOtherPayment => 'دفع دين';

  @override
  String get allTypes => 'كل الأنواع';

  @override
  String get voidTransaction => 'إلغاء العملية';

  @override
  String get voidTransactionMessage => 'تُضاف قيد عكسي، وتبقى العملية ظاهرة بعلامة ملغاة.';

  @override
  String get downloadReceipt => 'تنزيل الوصل';

  @override
  String depositRecorded(String receipt) {
    return 'تم تسجيل الإيداع ($receipt)';
  }

  @override
  String get withdrawalRecorded => 'تم تسجيل السحب';

  @override
  String get transactionVoided => 'تم إلغاء العملية';

  @override
  String settledAmount(String amount) {
    return 'تمت تسوية $amount من المحفظة';
  }

  @override
  String get noWalletsTitle => 'لا توجد محافظ';

  @override
  String get noWalletsMessage => 'تظهر المحفظة عند أول إيداع.';

  @override
  String get noTransactionsTitle => 'لا توجد عمليات';

  @override
  String get withdrawalHint => 'لا يتجاوز الرصيد أبدًا.';

  @override
  String invoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فاتورة',
      many: '$count فاتورة',
      few: '$count فواتير',
      two: 'فاتورتان',
      one: 'فاتورة واحدة',
      zero: 'لا توجد فواتير',
    );
    return '$_temp0';
  }

  @override
  String get newInvoice => 'فاتورة جديدة';

  @override
  String get paymentStatusUnpaid => 'غير مدفوعة';

  @override
  String get paymentStatusPartiallyPaid => 'مدفوعة جزئيًا';

  @override
  String get paymentStatusPaid => 'مدفوعة';

  @override
  String get overdue => 'متأخر';

  @override
  String get onlyOverdue => 'المتأخرة فقط';

  @override
  String get includeVoided => 'إظهار الملغاة';

  @override
  String get fieldPaymentStatus => 'الدفع';

  @override
  String get issueDate => 'تاريخ الإصدار';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get amountPaid => 'المدفوع';

  @override
  String get amountDue => 'المتبقي';

  @override
  String get invoicePayments => 'المدفوعات';

  @override
  String refundedOn(String date) {
    return 'استُرجع في $date';
  }

  @override
  String get voidInvoice => 'إلغاء الفاتورة';

  @override
  String get voidInvoiceMessage => 'تعود نسخها إلى الطلبات ومدفوعاتها إلى المحفظة.';

  @override
  String get settleFromWallet => 'التسوية من المحفظة';

  @override
  String get settleAmountLabel => 'المبلغ (فارغ: أقصى ما يمكن)';

  @override
  String get uninvoicedTitle => 'نسخ للفوترة';

  @override
  String get noUninvoiced => 'لا شيء للفوترة لهذا الأستاذ.';

  @override
  String get toInvoice => 'للفوترة';

  @override
  String get available => 'المتاح';

  @override
  String get issueInvoice => 'إصدار الفاتورة';

  @override
  String invoiceIssued(String label) {
    return 'تم إصدار الفاتورة $label';
  }

  @override
  String get invoiceVoided => 'تم إلغاء الفاتورة';

  @override
  String get invoiceSettled => 'تمت تسوية الفاتورة';

  @override
  String fromOrders(String numbers) {
    return 'الطلبات: $numbers';
  }

  @override
  String get noInvoicesTitle => 'لا توجد فواتير';

  @override
  String get noInvoicesMessage => 'أصدر فاتورة من طلبات أستاذ.';

  @override
  String get nothingSelected => 'أدخل كمية واحدة على الأقل للفوترة.';

  @override
  String quantityTooHigh(int max) {
    return '$max على الأكثر.';
  }

  @override
  String get onlyOwing => 'المدينون فقط';

  @override
  String get totalOwed => 'مجموع المستحق';

  @override
  String get overdueInvoices => 'فواتير متأخرة';

  @override
  String get upcomingInvoices => 'فواتير قادمة';

  @override
  String get openDebts => 'الديون';

  @override
  String get oldestDue => 'أقدم استحقاق';

  @override
  String get newDebt => 'دين جديد';

  @override
  String get debtDueHint => 'فارغ: مستحق اليوم.';

  @override
  String get debtKindInvoice => 'فاتورة';

  @override
  String get debtKindDebt => 'دين';

  @override
  String get includeClosed => 'إظهار المسددة';

  @override
  String get writeOff => 'شطب';

  @override
  String get writeOffMessage => 'يُتنازل عن المتبقي من الدين.';

  @override
  String get debtCreated => 'تم تسجيل الدين';

  @override
  String get debtSettled => 'تمت تسوية الدين';

  @override
  String get debtWrittenOff => 'تم شطب الدين';

  @override
  String get writtenOff => 'المشطوب';

  @override
  String writtenOffOn(String date, String reason) {
    return 'شُطب في $date: $reason';
  }

  @override
  String get noDebtsTitle => 'لا أحد مدين';

  @override
  String get noDebtsMessage => 'ستظهر هنا الفواتير غير المدفوعة والديون المسجلة.';

  @override
  String get debtDescriptionHint => 'دين سابق للتطبيق، تسوية…';

  @override
  String get navReports => 'التقارير';

  @override
  String get navSecurity => 'الأمان';

  @override
  String get thePeriod => 'خلال الفترة';

  @override
  String get today => 'اليوم';

  @override
  String get ordersPlaced => 'الطلبات المقدمة';

  @override
  String get copiesOrdered => 'النسخ المطلوبة';

  @override
  String get amountOrdered => 'مبلغ الطلبات';

  @override
  String get invoicesIssued => 'الفواتير الصادرة';

  @override
  String get amountInvoiced => 'المبلغ المفوتر';

  @override
  String get depositsCount => 'الإيداعات';

  @override
  String get amountDeposited => 'المبلغ المودع';

  @override
  String get amountPaidFromWallets => 'المدفوع من المحافظ';

  @override
  String get newTeachers => 'أساتذة جدد';

  @override
  String get activeTeachers => 'أساتذة نشطون';

  @override
  String get heldInWallets => 'في المحافظ';

  @override
  String get ordersByStatus => 'الطلبات حسب الحالة';

  @override
  String get salesReport => 'المبيعات';

  @override
  String get groupBy => 'التجميع حسب';

  @override
  String get groupByProduct => 'المنتج';

  @override
  String get groupByClient => 'الأستاذ';

  @override
  String get groupBySchool => 'المؤسسة';

  @override
  String get groupByWilaya => 'الولاية';

  @override
  String get groupByMonth => 'الشهر';

  @override
  String get noSalesTitle => 'لا مبيعات في هذه الفترة';

  @override
  String get tabRoles => 'الأدوار';

  @override
  String get tabUsers => 'المستخدمون';

  @override
  String get tabResources => 'الموارد';

  @override
  String get newRole => 'دور جديد';

  @override
  String get fieldRoleName => 'اسم الدور';

  @override
  String get roleCreated => 'تم إنشاء الدور';

  @override
  String permissionsOf(String role) {
    return 'صلاحيات: $role';
  }

  @override
  String get permissionsSaved => 'تم حفظ الصلاحيات';

  @override
  String get editPermissions => 'تعديل الصلاحيات';

  @override
  String get permCreate => 'إنشاء';

  @override
  String get permRead => 'قراءة';

  @override
  String get permSet => 'تعديل';

  @override
  String get permDelete => 'حذف';

  @override
  String get securedFields => 'الحقول المحمية';

  @override
  String get resourceCol => 'المورد';

  @override
  String grantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد ممنوح',
      many: '$count موردًا ممنوحًا',
      few: '$count موارد ممنوحة',
      two: 'موردان ممنوحان',
      one: 'مورد واحد ممنوح',
      zero: 'لا صلاحيات',
    );
    return '$_temp0';
  }

  @override
  String get adminRoleNotice => 'يحصل دور Admin على كل الصلاحيات عند كل تشغيل للخادم.';

  @override
  String get newUser => 'مستخدم جديد';

  @override
  String get userCreated => 'تم إنشاء المستخدم';

  @override
  String get editRoles => 'الأدوار';

  @override
  String get rolesSaved => 'تم حفظ الأدوار. على المستخدم تسجيل الدخول من جديد.';

  @override
  String rolesOf(String name) {
    return 'أدوار $name';
  }

  @override
  String deactivateUserTitle(String name) {
    return 'تعطيل $name؟';
  }

  @override
  String get deactivateUserMessage => 'لن يتمكن الحساب من الدخول وتنتهي جلساته.';

  @override
  String get userDeactivated => 'تم تعطيل المستخدم';

  @override
  String get teacherAccountsHint => 'تُدار حسابات الأساتذة من قسم الأساتذة.';

  @override
  String get chooseRoles => 'اختر دورًا واحدًا على الأقل.';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get unreadOnly => 'غير المقروءة فقط';

  @override
  String get noNotificationsTitle => 'لا توجد إشعارات';

  @override
  String get noNotificationsMessage => 'ستظهر الإشعارات الجديدة هنا.';

  @override
  String get cart => 'السلة';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String inCart(int count) {
    return '$count في السلة';
  }

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptyMessage => 'أضف كتبًا من منتجاتك، ثم أكّد طلبك هنا.';

  @override
  String get browseProducts => 'تصفح منتجاتي';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String copiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نسخة',
      many: '$count نسخة',
      few: '$count نسخ',
      two: 'نسختان',
      one: 'نسخة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get orderNotesHint => 'ملاحظة للفريق (اختياري)';

  @override
  String get orderSentTitle => 'تم إرسال الطلب';

  @override
  String orderSentMessage(int number) {
    return 'الطلب رقم $number: سيُعلمك فريق ميدستور فور جاهزيته.';
  }

  @override
  String get viewOrder => 'عرض الطلب';

  @override
  String get confirmDelivery => 'استلمت طلبي';

  @override
  String get confirmDeliveryMessage => 'هل تؤكد أنك استلمت هذا الطلب؟';

  @override
  String get cancelMyOrderMessage => 'إلغاء هذا الطلب؟ لن يقوم الفريق بتحضيره.';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String get deliveryConfirmed => 'تم تأكيد الاستلام، شكرًا!';

  @override
  String greeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get greetingSubtitle => 'كتبك جاهزة للطلب.';

  @override
  String get noOrdersTeacherMessage => 'ستظهر طلباتك هنا مع متابعتها.';

  @override
  String get orderProgress => 'المتابعة';

  @override
  String get readyPickupHint => 'طلبك جاهز: يمكنك القدوم لاستلامه.';

  @override
  String get cartUnavailableHint => 'أزل المنتجات غير المتوفرة لإتمام الطلب.';

  @override
  String notifOrderPlacedForYouTitle(String number) {
    return 'تم تسجيل الطلب رقم $number';
  }

  @override
  String get notifOrderPlacedForYouMessage => 'سجّل فريق ميدستور طلبًا باسمك.';

  @override
  String notifOrderPreparingTitle(String number) {
    return 'الطلب رقم $number قيد التحضير';
  }

  @override
  String get notifOrderPreparingMessage => 'يقوم فريق ميدستور بتحضير طلبك.';

  @override
  String notifOrderReadyTitle(String number) {
    return 'الطلب رقم $number جاهز';
  }

  @override
  String notifOrderDeliveredTitle(String number) {
    return 'تم تسليم الطلب رقم $number';
  }

  @override
  String get notifOrderDeliveredMessage => 'تم تسليم طلبك.';

  @override
  String notifOrderCancelledTitle(String number) {
    return 'تم إلغاء الطلب رقم $number';
  }

  @override
  String get notifOrderCancelledMessage => 'ألغى فريق ميدستور طلبك.';

  @override
  String notifInvoiceTitle(String number) {
    return 'فاتورة جديدة $number';
  }

  @override
  String get notifInvoiceMessage => 'صدرت فاتورة جديدة باسمك.';

  @override
  String get notifDepositTitle => 'تم تسجيل الدفعة';

  @override
  String get notifDepositMessage => 'تم تسجيل دفعتك.';

  @override
  String get notifProductTitle => 'منتج جديد';

  @override
  String notifProductMessage(String name) {
    return '«$name» متوفر للطلب.';
  }

  @override
  String get byProductTitle => 'ملخص حسب المنتج';

  @override
  String get byProductSubtitle => 'كل فواتير الفترة، مجمّعة حسب المنتج';

  @override
  String get onlyUnpaid => 'غير المدفوعة فقط';

  @override
  String get colInvoices => 'الفواتير';

  @override
  String get totalQuantity => 'الكمية الإجمالية';

  @override
  String get noInvoicedProductsTitle => 'لا توجد فواتير في هذه الفترة';

  @override
  String get noInvoicedProductsMessage => 'غيّر الفترة أو الأستاذ أو مرشّح غير المدفوعة.';

  @override
  String invoicedProductSources(String product) {
    return 'مصدر هذا المجموع: $product';
  }

  @override
  String get collectPayment => 'تحصيل';

  @override
  String get collectPaymentTitle => 'تحصيل في المكتبة';

  @override
  String collectPaymentMessage(String amount) {
    return 'المبلغ المتبقي: $amount. يُسجَّل الدفع كإيداع (مع وصل) ويُسدِّد هذه الفاتورة أولاً.';
  }

  @override
  String get collectAmountLabel => 'المبلغ (فارغ: كل المبلغ المتبقي)';

  @override
  String get paymentCollected => 'تم تحصيل الدفع';

  @override
  String invoiceIssuedTitle(String label) {
    return 'تم إصدار الفاتورة $label';
  }

  @override
  String get invoiceIssuedMessage => 'الطلب جاهز: صدرت فاتورته تلقائياً. يمكن للأستاذ دفع الباقي في المكتبة.';

  @override
  String get paidFromWallet => 'مدفوع من المحفظة';

  @override
  String get leftAsDebt => 'المتبقي (دَين)';

  @override
  String get viewInvoice => 'عرض الفاتورة';

  @override
  String get fullyPaidFromWallet => 'سُدِّدت بالكامل من المحفظة.';

  @override
  String get setTeacherPassword => 'كلمة مرور جديدة';

  @override
  String setTeacherPasswordTitle(String name) {
    return 'كلمة مرور جديدة لـ $name';
  }

  @override
  String setTeacherPasswordHint(String name) {
    return 'لا حاجة إلى كلمة المرور الحالية. سيتم تسجيل خروج $name من كل أجهزته، ثم يسجّل الدخول بكلمة المرور الجديدة.';
  }

  @override
  String get teacherPasswordSet => 'تم تحديث كلمة المرور. أبلغها للأستاذ.';

  @override
  String get generatePassword => 'توليد';

  @override
  String get copyPassword => 'نسخ';

  @override
  String get passwordCopied => 'تم نسخ كلمة المرور.';
}
