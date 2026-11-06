import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// One sidebar entry and its route. The order here is the sidebar's order and the shell's branch index.
class AdminDestination {
  const AdminDestination({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.section,
    required this.color,
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String Function(AppStrings strings) label;
  final String Function(AppStrings strings) section;

  /// The sidebar tile's color: one of Apple's system colors, so each section is found at a glance.
  final Color color;
}

String _operations(AppStrings s) => s.sectionOperations;
String _finance(AppStrings s) => s.sectionFinance;
String _system(AppStrings s) => s.sectionSystem;

const adminDestinations = <AdminDestination>[
  // Operations
  AdminDestination(
    path: '/dashboard',
    icon: AppIcons.dashboard,
    activeIcon: AppIcons.dashboard,
    label: _dashboard,
    section: _operations,
    color: CupertinoColors.systemBlue,
  ),
  AdminDestination(
    path: '/orders',
    icon: AppIcons.cart,
    activeIcon: AppIcons.cart,
    label: _orders,
    section: _operations,
    color: CupertinoColors.systemOrange,
  ),
  AdminDestination(
    path: '/products',
    icon: AppIcons.products,
    activeIcon: AppIcons.products,
    label: _products,
    section: _operations,
    color: CupertinoColors.systemIndigo,
  ),
  AdminDestination(
    path: '/teachers',
    icon: AppIcons.teachers,
    activeIcon: AppIcons.teachers,
    label: _teachers,
    section: _operations,
    color: CupertinoColors.systemTeal,
  ),
  AdminDestination(
    path: '/schools',
    icon: AppIcons.schools,
    activeIcon: AppIcons.schools,
    label: _schools,
    section: _operations,
    color: CupertinoColors.systemBrown,
  ),
  // Finance
  AdminDestination(
    path: '/invoices',
    icon: AppIcons.invoices,
    activeIcon: AppIcons.invoices,
    label: _invoices,
    section: _finance,
    color: CupertinoColors.systemGreen,
  ),
  AdminDestination(
    path: '/wallet',
    icon: AppIcons.wallet,
    activeIcon: AppIcons.wallet,
    label: _wallet,
    section: _finance,
    color: CupertinoColors.systemMint,
  ),
  AdminDestination(
    path: '/debts',
    icon: AppIcons.warning,
    activeIcon: AppIcons.warning,
    label: _debts,
    section: _finance,
    color: CupertinoColors.systemPink,
  ),
  AdminDestination(
    path: '/reports',
    icon: AppIcons.reports,
    activeIcon: AppIcons.reports,
    label: _reports,
    section: _finance,
    color: CupertinoColors.systemPurple,
  ),
  // System
  AdminDestination(
    path: '/notifications',
    icon: AppIcons.notifications,
    activeIcon: AppIcons.notifications,
    label: _notifications,
    section: _system,
    color: CupertinoColors.systemRed,
  ),
  AdminDestination(
    path: '/security',
    icon: AppIcons.security,
    activeIcon: AppIcons.security,
    label: _security,
    section: _system,
    color: CupertinoColors.systemGrey,
  ),
  AdminDestination(
    path: '/settings',
    icon: AppIcons.settings,
    activeIcon: AppIcons.settings,
    label: _settings,
    section: _system,
    color: CupertinoColors.systemGrey,
  ),
];

String _dashboard(AppStrings s) => s.navDashboard;
String _orders(AppStrings s) => s.navOrders;
String _products(AppStrings s) => s.navProducts;
String _teachers(AppStrings s) => s.navTeachers;
String _schools(AppStrings s) => s.navSchools;
String _invoices(AppStrings s) => s.navInvoices;
String _wallet(AppStrings s) => s.navWallet;
String _debts(AppStrings s) => s.navDebts;
String _reports(AppStrings s) => s.navReports;
String _security(AppStrings s) => s.navSecurity;
String _notifications(AppStrings s) => s.navNotifications;
String _settings(AppStrings s) => s.navSettings;
