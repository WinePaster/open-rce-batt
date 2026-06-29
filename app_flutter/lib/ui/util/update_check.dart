/// Open-RCE-Batt — run a GitHub update check and prompt the user.
///
/// Shared by the manual "檢查更新" button (Settings → 關於) and the silent
/// on-launch check. Never auto-installs: on a newer release it offers to open
/// the download page in the browser.
library;

import 'package:flutter/material.dart';
import 'package:open_rce_batt/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/data.dart';
import '../../theme/app_theme.dart';

/// Checks GitHub for a newer release. [manual] true → also surfaces an
/// "already up to date / offline" SnackBar; false (on-launch) → silent unless
/// an update exists.
Future<void> runUpdateCheck(BuildContext context, {required bool manual}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final info = await PackageInfo.fromPlatform();
  final update = await const UpdateService().checkForUpdate(info.version);
  if (!context.mounted) return;

  if (update == null) {
    if (manual) {
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1600),
          content: Text(l10n.updateAlreadyLatest),
        ),
      );
    }
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.panel,
      title: Text(l10n.updateAvailableTitle(update.latestTag),
          style: TextStyle(fontSize: 16, color: ctx.colors.text)),
      content: Text(
        l10n.updateAvailableBody(info.version),
        style: TextStyle(fontSize: 12.5, height: 1.6, color: ctx.colors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.updateLaterButton,
              style: TextStyle(color: ctx.colors.muted)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final url = update.apkUrl ?? update.htmlUrl;
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          },
          child: Text(l10n.updateDownloadButton,
              style: const TextStyle(color: AppColors.amber)),
        ),
      ],
    ),
  );
}
