import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

/// Downloads a PDF through [download] (an authenticated API call), asks where to save it, writes it,
/// and tells the user where it went. A failed download or write shows the reason.
///
/// ```dart
/// AppButton(label: strings.downloadPdf, onPressed: () => savePdf(context, 'INV-000042.pdf', () => invoicePdf(id)))
/// ```
Future<void> savePdf(
  BuildContext context,
  String fileName,
  Future<Result<Uint8List>> Function() download,
) async {
  final strings = AppStrings.of(context);
  final result = await download();
  if (!context.mounted) return;
  switch (result) {
    case Err(:final failure):
      showAppToast(context, failureText(strings, failure), tone: AppTone.danger);
    case Ok(value: final bytes):
      final location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (location == null || !context.mounted) return;
      try {
        await File(location.path).writeAsBytes(bytes, flush: true);
        if (context.mounted) showAppToast(context, strings.fileSaved(location.path), tone: AppTone.success);
      } on FileSystemException catch (e) {
        if (context.mounted) showAppToast(context, e.message, tone: AppTone.danger);
      }
  }
}
