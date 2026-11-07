import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every icon the apps use, from Lucide (lucide.dev): outline icons on one 24px grid with the same 2px
/// stroke, so a screen reads as one family.
///
/// Name icons by what they mean here, not by their drawing, and add new ones to this list rather than
/// reaching for `LucideIcons` in a feature: swapping a drawing then changes it everywhere at once.
///
/// Lucide has no filled variants. A selected sidebar entry or tab shows its state with color and a
/// tinted background instead, so `icon` and `activeIcon` may be the same.
///
/// Icons that point along the reading direction ([forward], [back], [signOut], [undo], [sidebar])
/// mirror in Arabic.
abstract final class AppIcons {
  // Navigation
  static const dashboard = LucideIcons.layoutDashboard;
  static const orders = LucideIcons.package;
  static const cart = LucideIcons.shoppingCart;
  static const bag = LucideIcons.shoppingBag;
  static const products = LucideIcons.bookOpen;
  static const teachers = LucideIcons.usersRound;
  static const schools = LucideIcons.school;
  static const invoices = LucideIcons.fileText;
  static const wallet = LucideIcons.wallet;
  static const deposit = LucideIcons.handCoins;
  static const debts = LucideIcons.triangleAlert;
  static const reports = LucideIcons.chartColumn;
  static const notifications = LucideIcons.bell;
  static const security = LucideIcons.shieldCheck;
  static const settings = LucideIcons.settings;
  static const profile = LucideIcons.circleUserRound;
  static const sidebar = LucideIcons.panelLeftDir;
  static const forward = LucideIcons.chevronRightDir;
  static const back = LucideIcons.chevronLeftDir;
  static const signOut = LucideIcons.logOutDir;

  // Actions
  static const add = LucideIcons.plus;
  static const remove = LucideIcons.minus;
  static const edit = LucideIcons.pencil;
  static const delete = LucideIcons.trash2;
  static const deleteBackward = LucideIcons.delete;
  static const close = LucideIcons.x;
  static const check = LucideIcons.check;
  static const checkAll = LucideIcons.checkCheck;
  static const search = LucideIcons.search;
  static const refresh = LucideIcons.refreshCw;
  static const retry = LucideIcons.rotateCw;
  static const undo = LucideIcons.undo2Dir;
  static const download = LucideIcons.fileDown;
  static const downloadCircle = LucideIcons.circleArrowDown;
  static const print = LucideIcons.printer;
  static const copy = LucideIcons.copy;
  static const password = LucideIcons.keyRound;
  static const send = LucideIcons.send;
  static const sort = LucideIcons.chevronsUpDown;
  static const show = LucideIcons.eye;
  static const hide = LucideIcons.eyeOff;
  static const addPerson = LucideIcons.userRoundPlus;
  static const removePerson = LucideIcons.userRoundX;

  // Things
  static const person = LucideIcons.userRound;
  static const calendar = LucideIcons.calendarDays;
  static const clock = LucideIcons.clock;
  static const language = LucideIcons.globe;
  static const image = LucideIcons.image;
  static const list = LucideIcons.list;
  static const verified = LucideIcons.badgeCheck;
  static const documentDone = LucideIcons.fileCheck;
  static const preparing = LucideIcons.hammer;
  static const lab = LucideIcons.flaskConical;
  static const offline = LucideIcons.wifiOff;

  // Feedback
  static const success = LucideIcons.circleCheck;
  static const error = LucideIcons.circleAlert;
  static const warning = LucideIcons.triangleAlert;
  static const info = LucideIcons.info;
  static const cancelled = LucideIcons.circleX;
  static const paused = LucideIcons.circlePause;
}
