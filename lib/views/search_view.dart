import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/search_dialog.dart';

/// Halaman hasil pencarian berita anime yang wajib menggunakan FutureBuilder
/// dan menangani 4 state: loading, error, empty, dan data.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NewsApiService _service = NewsApiService();
  late String _keyword;

  /// Future disimpan di State, BUKAN dibuat di dalam build()
  late Future<List<ArticleModel>> _futureSearch;

  @override
  void initState() {
    super.initState();
    // Mengambil kata kunci yang dikirim dari dialog pencarian
    _keyword = Get.arguments is String ? Get.arguments as String : 'anime';
    _futureSearch = _service.searchNews(_keyword);
  }

  /// Membuat Future baru saat menekan tombol coba lagi
  void _muatUlang() {
    setState(() {
      _futureSearch = _service.searchNews(_keyword);
    });
  }

  /// Pull-to-refresh pada halaman hasil pencarian
  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureSearch;
    } catch (_) {
      // Error ditangani secara visual oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Pencarian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '"$_keyword"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.secondary),
            tooltip: 'Cari Kata Kunci Lain',
            onPressed: () => SearchDialog.show(context),
          ),
        ],
      ),
      body: FutureBuilder<List<ArticleModel>>(
        future: _futureSearch,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Mencari berita anime...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _muatUlang,
            );
          }

          // 3. Empty State (Request sukses tapi list artikel kosong)
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return EmptyView(
              title: 'Tidak Ada Hasil',
              message: 'Tidak ditemukan berita anime dengan kata kunci "$_keyword". Coba gunakan kata kunci lainnya.',
              onRefresh: _onRefresh,
            );
          }

          // 4. Data State
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: articles.length + 1,
              itemBuilder: (context, index) {
                // Header jumlah artikel yang ditemukan
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.feed_outlined,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ditemukan ${articles.length} berita untuk "$_keyword"',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final article = articles[index - 1];
                return ArticleCard(
                  article: article,
                  onTap: () => Get.toNamed(AppRoutes.detail, arguments: article),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
