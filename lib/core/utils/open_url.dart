import 'package:url_launcher/url_launcher.dart';

import '../../data/services/logger_service.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.e('Could not launch $url');
    }
  } catch (e) {
    AppLogger.e('Error launching $url', e);
  }
}
