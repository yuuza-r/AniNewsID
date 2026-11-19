import 'article_model.dart';

/// Model pembungkus response dari endpoint GNews API.
class NewsResponseModel {
  final int totalArticles;
  final List<ArticleModel> articles;

  const NewsResponseModel({
    required this.totalArticles,
    required this.articles,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      totalArticles: json['totalArticles'] as int? ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
