/// Open-RCE-Batt — run a GitHub update check and prompt the user.
///
/// Shared by the manual "檢查更新" button (Settings → 關於) and the silent
/// on-launch check. Never auto-installs: on a newer release it offers to open
/// the download page in the browser.
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/data.dart';
import '../../theme/app_theme.dart';

/// Checks GitHub for a newer release. [manual] true → also surfaces an
/// "already up to date / offline" SnackBar; false (on-launch) → silent unless
/// an update exists.
Future<void> runUpdateCheck(BuildContext context, {required bool manual}) async {
  final messenger = ScaffoldMessenger.of(context);
  final info = await PackageInfo.fromPlatform();
  final update = await const UpdateService().checkForUpdate(info.version);
  if (!context.mounted) return;

  if (update == null) {
    if (manual) {
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1600),
          content: Text('已是最新版本（或暫時無法連線）'),
        ),
      );
    }
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.panel,
      title: Text('有新版本 ${update.latestTag}',
          style: TextStyle(fontSize: 16, color: ctx.colors.text)),
      content: Text(
        '目前版本 v${info.version}。前往 GitHub 下載最新版 APK，'
        '安裝前請先解除安裝舊版（簽章不同無法直接覆蓋）。',
        style: TextStyle(fontSize: 12.5, height: 1.6, color: ctx.colors.muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('稍後', style: TextStyle(color: ctx.colors.muted)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            final url = update.apkUrl ?? update.htmlUrl;
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          },
          child: const Text('前往下載', style: TextStyle(color: AppColors.amber)),
        ),
      ],
    ),
  );
}
