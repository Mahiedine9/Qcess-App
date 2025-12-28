import 'package:mobile/core/di/di.dart';


class AppConfig {
  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    return '$apiBaseUrl$relativePath';
  }
}