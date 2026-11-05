import 'package:flutter/cupertino.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Shown while the stored session is checked at start-up.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 112),
            SizedBox(height: AppSpacing.lg),
            CupertinoActivityIndicator(),
          ],
        ),
      ),
    );
  }
}
