import 'package:url_launcher/url_launcher.dart';

/// Utilidades para realizar llamadas telefónicas
class CallUtils {
  CallUtils._();

  /// Realiza una llamada telefónica al número especificado
  static Future<bool> makeCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }
}
