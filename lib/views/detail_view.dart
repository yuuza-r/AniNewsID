import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/news_image.dart';

/// Halaman detail berita yang menampilkan informasi lengkap dari [ArticleModel]
/// yang dikirimkan melalui Get.arguments tanpa membuat request API baru.
class DetailView extends StatelessWidget {
  const DetailView({super.key});

  Future<void> _launchSourceUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan sumber berita tidak tersedia.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(urlString.trim());
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format tautan tidak valid.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka browser.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka tautan di browser.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data artikel yang dikirimkan via arguments
    final article = Get.arguments is ArticleModel ? Get.arguments as ArticleModel : null;

    if (article == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Detail Berita'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Text(
            'Data artikel tidak ditemukan.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (article.url != null && article.url!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.secondary),
              tooltip: 'Buka di Browser',
              onPressed: () => _launchSourceUrl(context, article.url),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama Berita
            NewsImage(
              url: article.urlToImage,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Konten Detail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sumber Media & Tanggal
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (article.author != null && article.author!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.newspaper_rounded,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                article.author!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatDate(article.publishedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul Berita
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Garis Pemisah Halus
                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: 14),

                  // Ringkasan / Deskripsi
                  if (article.description != null &&
                      article.description!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        article.description!.trim(),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.secondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Isi Konten Berita
                  if (article.content != null && article.content!.trim().isNotEmpty) ...[
                    Text(
                      article.content!.trim(),
                      style: const TextStyle(
                        fontSize: 15.5,
                        color: AppColors.textPrimary,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Kotak Info Kuota/Snippet GNews
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Konten di atas merupakan cuplikan berita dari API GNews. Untuk membaca artikel selengkapnya, silakan kunjungi website media aslinya melalui tombol di bawah.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Buka di Browser
                  if (article.url != null && article.url!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _launchSourceUrl(context, article.url),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.public_rounded, size: 20),
                        label: const Text(
                          'Baca Artikel Asli di Website',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
