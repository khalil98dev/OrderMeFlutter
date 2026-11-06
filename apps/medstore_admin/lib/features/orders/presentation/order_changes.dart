import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tells every screen that shows orders that one changed on this device (its status moved, its lines
/// were revised), so the orders list is up to date however the order page was opened: from the list,
/// a notification or the dashboard. One for the app.
class OrderChanges {
  final _changes = StreamController<String>.broadcast();

  /// The id of each order that changed.
  Stream<String> get stream => _changes.stream;

  void changed(String orderId) => _changes.add(orderId);

  Future<void> dispose() => _changes.close();
}

/// Calls [onChange] with the order's id each time [OrderChanges] reports one, while [child] is on
/// screen. Expects [OrderChanges] above it.
class ReloadOnOrderChange extends StatefulWidget {
  const ReloadOnOrderChange({super.key, required this.onChange, required this.child});

  /// Receives a context below this widget, so it can read the page's Cubit.
  final void Function(BuildContext context, String orderId) onChange;
  final Widget child;

  @override
  State<ReloadOnOrderChange> createState() => _ReloadOnOrderChangeState();
}

class _ReloadOnOrderChangeState extends State<ReloadOnOrderChange> {
  StreamSubscription<String>? _changes;

  @override
  void initState() {
    super.initState();
    _changes = context.read<OrderChanges>().stream.listen((orderId) {
      if (mounted) widget.onChange(context, orderId);
    });
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
