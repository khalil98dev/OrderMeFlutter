import 'dart:async';

import 'package:flutter/foundation.dart';

/// Lets go_router's `refreshListenable` follow a Bloc/Cubit stream (re-runs `redirect` on each state).
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
