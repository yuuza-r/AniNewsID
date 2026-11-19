import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import 'news_image.dart';

/// Kartu berita standar untuk menampilkan artikel dalam daftar berita.
class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const metaStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.primary.withValues(alpha: 0.15),
            highlightColor: AppColors.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Berita
                NewsImage(
                  url: article.urlToImage,
                  height: 180,
                  fit: BoxFit.cover,
                ),

                // Konten Kartu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Berita
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Ringkasan Deskripsi
                      if (article.description != null &&
                          article.description!.trim().isNotEmpty) ...[
                        Text(
                          article.description!.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Informasi Meta (Sumber Media & Tanggal)
                      Row(
                        children: [
                          if (article.author != null &&
                              article.author!.trim().isNotEmpty) ...[
                            const Icon(
                              Icons.newspaper_rounded,
                              size: 15,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                article.author!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: metaStyle,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatDate(article.publishedAt),
                            style: metaStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
