import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../features/debts/domain/debts.dart';
import '../../features/invoices/domain/invoice.dart';
import '../../features/reports/domain/reports.dart';
import '../../features/schools/domain/school.dart';
import '../../features/security/domain/security.dart';
import '../../features/wallets/domain/wallet.dart';

// The words and tones of the domain's values, in one place so every screen says them the same way.
// The design system knows nothing about orders or invoices: the meaning → tone mapping lives here.

String orderStatusText(AppStrings s, OrderStatus status) => switch (status) {
  OrderStatus.pending => s.orderStatusPending,
  OrderStatus.inPreparation => s.orderStatusInPreparation,
  OrderStatus.ready => s.orderStatusReady,
  OrderStatus.delivered => s.orderStatusDelivered,
  OrderStatus.cancelled => s.orderStatusCancelled,
};

AppTone orderStatusTone(OrderStatus status) => switch (status) {
  OrderStatus.pending => AppTone.warning,
  OrderStatus.inPreparation => AppTone.info,
  OrderStatus.ready => AppTone.brand,
  OrderStatus.delivered => AppTone.success,
  OrderStatus.cancelled => AppTone.neutral,
};

/// The button that moves an order to [status].
String orderMoveText(AppStrings s, OrderStatus status) => switch (status) {
  OrderStatus.inPreparation => s.actionStartPreparation,
  OrderStatus.ready => s.actionMarkReady,
  OrderStatus.delivered => s.actionMarkDelivered,
  OrderStatus.cancelled => s.actionCancelOrder,
  OrderStatus.pending => s.orderStatusPending,
};

String actorText(AppStrings s, OrderActor actor) => switch (actor) {
  OrderActor.client => s.actorClient,
  OrderActor.staff => s.actorStaff,
};

String paymentTermsText(AppStrings s, PaymentTerms terms) => switch (terms) {
  PaymentTerms.immediate => s.paymentTermsImmediate,
  PaymentTerms.endOfMonth => s.paymentTermsEndOfMonth,
  PaymentTerms.endOfYear => s.paymentTermsEndOfYear,
};

Map<PaymentTerms, String> paymentTermsOptions(AppStrings s) => {
  for (final terms in PaymentTerms.values) terms: paymentTermsText(s, terms),
};

String schoolLevelText(AppStrings s, SchoolLevel level) => switch (level) {
  SchoolLevel.primary => s.schoolLevelPrimary,
  SchoolLevel.middle => s.schoolLevelMiddle,
  SchoolLevel.secondary => s.schoolLevelSecondary,
  SchoolLevel.university => s.schoolLevelUniversity,
  SchoolLevel.other => s.schoolLevelOther,
};

String schoolTypeText(AppStrings s, SchoolType type) => switch (type) {
  SchoolType.public => s.schoolTypePublic,
  SchoolType.private => s.schoolTypePrivate,
};

String transactionTypeText(AppStrings s, WalletTransactionType type) => switch (type) {
  WalletTransactionType.deposit => s.txDeposit,
  WalletTransactionType.withdrawal => s.txWithdrawal,
  WalletTransactionType.reversal => s.txReversal,
  WalletTransactionType.invoicePayment => s.txInvoicePayment,
  WalletTransactionType.otherPayment => s.txOtherPayment,
};

/// Money in is a success, money out is neutral.
AppTone amountTone(num amount) => amount >= 0 ? AppTone.success : AppTone.neutral;

String paymentMethodText(AppStrings s, PaymentMethod method) => switch (method) {
  PaymentMethod.cash => s.paymentMethodCash,
  PaymentMethod.bankTransfer => s.paymentMethodBankTransfer,
  PaymentMethod.other => s.paymentMethodOther,
};

String paymentStatusText(AppStrings s, InvoicePaymentStatus status) => switch (status) {
  InvoicePaymentStatus.unpaid => s.paymentStatusUnpaid,
  InvoicePaymentStatus.partiallyPaid => s.paymentStatusPartiallyPaid,
  InvoicePaymentStatus.paid => s.paymentStatusPaid,
};

AppTone paymentStatusTone(InvoicePaymentStatus status) => switch (status) {
  InvoicePaymentStatus.unpaid => AppTone.warning,
  InvoicePaymentStatus.partiallyPaid => AppTone.info,
  InvoicePaymentStatus.paid => AppTone.success,
};

String debtKindText(AppStrings s, DebtItemKind kind) => switch (kind) {
  DebtItemKind.invoice => s.debtKindInvoice,
  DebtItemKind.debt => s.debtKindDebt,
};

String groupByText(AppStrings s, SalesGroupBy group) => switch (group) {
  SalesGroupBy.product => s.groupByProduct,
  SalesGroupBy.client => s.groupByClient,
  SalesGroupBy.school => s.groupBySchool,
  SalesGroupBy.wilaya => s.groupByWilaya,
  SalesGroupBy.month => s.groupByMonth,
};

String resourceActionText(AppStrings s, ResourceAction action) => switch (action) {
  ResourceAction.create => s.permCreate,
  ResourceAction.read => s.permRead,
  ResourceAction.set => s.permSet,
  ResourceAction.delete => s.permDelete,
};

String fieldActionText(AppStrings s, FieldAction action) => switch (action) {
  FieldAction.read => s.permRead,
  FieldAction.set => s.permSet,
};
