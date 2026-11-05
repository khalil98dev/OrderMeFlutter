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
  });

  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String Function(AppStrings strings) label;
  final String Function(AppStrings strings) section;
}

String _operations(AppStrings s) => s.sectionOperations;
String _finance(AppStrings s) => s.sectionFinance;
String _system(AppStrings s) => s.sectionSystem;

const adminDestinations = <AdminDestination>[
  // Operations
  AdminDestination(
    path: '/dashboard',
    icon: CupertinoIcons.square_grid_2x2,
    activeIcon: CupertinoIcons.square_grid_2x2_fill,
    label: _dashboard,
    section: _operations,
  ),
  AdminDestination(
    path: '/orders',
    icon: CupertinoIcons.cart,
    activeIcon: CupertinoIcons.cart_fill,
    label: _orders,
    section: _operations,
  ),
  AdminDestination(
    path: '/products',
    icon: CupertinoIcons.book,
    activeIcon: CupertinoIcons.book_fill,
    label: _products,
    section: _operations,
  ),
  AdminDestination(
    path: '/teachers',
    icon: CupertinoIcons.person_2,
    activeIcon: CupertinoIcons.person_2_fill,
    label: _teachers,
    section: _operations,
  ),
  AdminDestination(
    path: '/schools',
    icon: CupertinoIcons.building_2_fill,
    activeIcon: CupertinoIcons.building_2_fill,
    label: _schools,
    section: _operations,
  ),
  // Finance
  AdminDestination(
    path: '/invoices',
    icon: CupertinoIcons.doc_text,
    activeIcon: CupertinoIcons.doc_text_fill,
    label: _invoices,
    section: _finance,
  ),
  AdminDestination(
    path: '/wallet',
    icon: CupertinoIcons.money_dollar_circle,
    activeIcon: CupertinoIcons.money_dollar_circle_fill,
    label: _wallet,
    section: _finance,
  ),
  AdminDestination(
    path: '/debts',
    icon: CupertinoIcons.exclamationmark_triangle,
    activeIcon: CupertinoIcons.exclamationmark_triangle_fill,
    label: _debts,
    section: _finance,
  ),
  AdminDestination(
    path: '/reports',
    icon: CupertinoIcons.chart_bar,
    activeIcon: CupertinoIcons.chart_bar_fill,
    label: _reports,
    section: _finance,
  ),
  // System
  AdminDestination(
    path: '/notifications',
    icon: CupertinoIcons.bell,
    activeIcon: CupertinoIcons.bell_fill,
    label: _notifications,
    section: _system,
  ),
  AdminDestination(
    path: '/security',
    icon: CupertinoIcons.lock_shield,
    activeIcon: CupertinoIcons.lock_shield_fill,
    label: _security,
    section: _system,
  ),
  AdminDestination(
    path: '/settings',
    icon: CupertinoIcons.gear,
    activeIcon: CupertinoIcons.gear_solid,
    label: _settings,
    section: _system,
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
