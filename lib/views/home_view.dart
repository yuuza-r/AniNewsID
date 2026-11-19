import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/article_model.dart';
import '../routes/app_routes.dart';
import '../services/news_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/search_dialog.dart';

/// Halaman utama AniNews ID.
/// Menggunakan FutureBuilder untuk manajemen data asynchronous dan sistem caching
/// kategori berbasis `Map<String, Future<List<ArticleModel>>>` untuk efisiensi kuota API.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NewsApiService _service = NewsApiService();

  /// Definisi Kategori Berita Anime (Query GNews -> Label Tampilan)
  static const Map<String, String> _categories = {
    'anime': 'Anime Terbaru',
    'manga': 'Manga',
    'anime Jepang': 'Anime Jepang',
    'industri anime': 'Industri Anime',
  };

  String _selectedCategory = 'anime';

  /// Cache Future berdasarkan query kategori untuk mencegah request API berulang
  final Map<String, Future<List<ArticleModel>>> _categoryCache = {};

  /// Future aktif yang disimpan di State, BUKAN dibuat langsung di dalam build()
  late Future<List<ArticleModel>> _futureNews;

  @override
  void initState() {
    super.initState();
    // Inisialisasi request pertama dan simpan ke cache
    _futureNews = _getNewsForCategory(_selectedCategory);
  }

  /// Mengambil Future dari cache jika sudah ada, atau membuat request baru jika belum
  Future<List<ArticleModel>> _getNewsForCategory(String category) {
    if (_categoryCache.containsKey(category)) {
      return _categoryCache[category]!;
    }
    final future = _service.getNewsByCategory(category);
    _categoryCache[category] = future;
    return future;
  }

  /// Memuat ulang data (dipanggil oleh tombol Coba Lagi pada ErrorView)
  /// Membuat Future baru dan memperbarui cache kategori aktif
  void _muatUlang() {
    setState(() {
      final newFuture = _service.getNewsByCategory(_selectedCategory);
      _categoryCache[_selectedCategory] = newFuture;
      _futureNews = newFuture;
    });
  }

  /// Berpindah kategori berita dengan memanfaatkan caching Future
  void _gantiKategori(String category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _futureNews = _getNewsForCategory(category);
    });
  }

  /// Pull-to-refresh: Memaksa pembuatan Future baru dan memperbarui cache kategori aktif
  Future<void> _onRefresh() async {
    _muatUlang();
    try {
      await _futureNews;
    } catch (_) {
      // Error akan otomatis ditangani secara visual oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AniNews ID',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Your Daily Dose of Anime News',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.secondary, size: 24),
            tooltip: 'Cari Berita Anime',
            onPressed: () => SearchDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori Bar (Horizontal ChoiceChips)
          _buildCategoryBar(),

          // Konten Berita Berbasis FutureBuilder
          Expanded(
            child: FutureBuilder<List<ArticleModel>>(
              future: _futureNews,
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
                          'Memuat berita anime terkini...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
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

                // 3. Empty State (Request berhasil tapi data kosong)
                final articles = snapshot.data ?? [];
                if (articles.isEmpty) {
                  return EmptyView(
                    title: 'Belum Ada Berita',
                    message: 'Tidak ada berita yang ditemukan untuk kategori "${_categories[_selectedCategory]}".',
                    onRefresh: _onRefresh,
                  );
                }

                // 4. Data State (Tampilkan berita dengan Featured News di posisi paling atas)
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: articles.length + 1, // +1 untuk header info
                    itemBuilder: (context, index) {
                      // Index 0: Header Sambutan / Tagline
                      if (index == 0) {
                        return _buildHeaderSection();
                      }

                      // Index 1: Berita Utama (Featured News Card)
                      if (index == 1) {
                        final featuredArticle = articles[0];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FeaturedNewsCard(
                              article: featuredArticle,
                              onTap: () => Get.toNamed(
                                AppRoutes.detail,
                                arguments: featuredArticle,
                              ),
                            ),
                            if (articles.length > 1)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Berita Terkini Lainnya',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }

                      // Index >= 2: Daftar Berita Standar (ArticleCard)
                      final article = articles[index - 1];
                      return ArticleCard(
                        article: article,
                        onTap: () => Get.toNamed(
                          AppRoutes.detail,
                          arguments: article,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget bar kategori yang dapat digeser secara horizontal
  Widget _buildCategoryBar() {
    return Container(
      height: 54,
      width: double.infinity,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = _categories.entries.elementAt(index);
          final isSelected = entry.key == _selectedCategory;

          return ChoiceChip(
            label: Text(
              entry.value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.chipBackground,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            showCheckmark: false,
            onSelected: (_) => _gantiKategori(entry.key),
          );
        },
      ),
    );
  }

  /// Header sambutan singkat dan tagline di bagian atas feed berita
  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kabar Populer Anime & Manga',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Update berkala dari media terpercaya Jepang dan global.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
