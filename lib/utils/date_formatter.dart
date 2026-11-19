import 'package:intl/intl.dart';

/// Formatter tanggal dengan lokalisasi Bahasa Indonesia (id_ID).
class DateFormatter {
  DateFormatter._();

  /// Memformat string ISO 8601 (mis. 2026-11-18T00:30:00Z) menjadi format Indonesia yang ramah pengguna.
  /// Contoh: "18 Nov 2026, 07:30 WIB" atau "18 November 2026"
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return 'Tanggal tidak tersedia';
    }

    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final formatter = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
      return formatter.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Format lengkap untuk halaman detail berita.
  /// Contoh: "Rabu, 18 November 2026 • 07:30 WIB"
  static String formatDetailDate(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) {
      return 'Tanggal tidak tersedia';
    }

    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final formatter = DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID');
      return '${formatter.format(dateTime)} WIB';
    } catch (_) {
      return isoString;
    }
  }
}
