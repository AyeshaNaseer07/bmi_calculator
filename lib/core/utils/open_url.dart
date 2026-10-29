import 'package:url_launcher/url_launcher.dart';

import '../../data/services/logger_service.dart';
import '../../views/widgets/ads/app_open_ad_manager.dart';

/// Opens [url] outside the app (browser, mail, ...). Coming back from it
/// doesn't trigger an app open ad.
Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      AppOpenAdManager.instance.skipNextResume();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.e('Could not launch $url');
    }
  } catch (e) {
    AppLogger.e('Error launching $url', e);
  }
}
