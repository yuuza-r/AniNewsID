class Env {
  Env._();

  static const String baseUrl = String.fromEnvironment('GNEWS_BASE_URL');
  static const String apiKey = String.fromEnvironment('GNEWS_API_KEY');

  /// Konfigurasi dianggap lengkap bila baseUrl dan apiKey sudah terisi.
  static bool get lengkap => baseUrl.isNotEmpty && apiKey.isNotEmpty;

  /// Menyamarkan API key di teks log / pesan error agar aman dari kebocoran data.
  static String samarkan(String teks) {
    var hasil = teks.replaceAllMapped(
      RegExp(r'(apikey=)[^&\s"]+', caseSensitive: false),
      (m) => '${m[1]}***',
    );
    if (apiKey.isNotEmpty) {
      hasil = hasil.replaceAll(apiKey, '***');
    }
    return hasil;
  }
}
