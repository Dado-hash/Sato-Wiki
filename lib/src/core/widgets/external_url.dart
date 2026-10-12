import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n/app_localizations.dart';

/// Opens [uri] in the external application (browser).
///
/// If the platform cannot open the URL, a snackbar tells the reader.
Future<void> openExternalUrl(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failureMessage = AppLocalizations.of(context).openLinkFailed;

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  } on PlatformException {
    messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
  }
}
