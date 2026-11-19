import 'package:aninews_id/main.dart';
import 'package:aninews_id/models/article_model.dart';
import 'package:aninews_id/models/news_response_model.dart';
import 'package:aninews_id/services/api_exception.dart';
import 'package:aninews_id/config/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArticleModel & NewsResponseModel Tests', () {
    test('ArticleModel.fromJson parses fields correctly', () {
      final json = {
        'id': 'abc123',
        'title': 'Jujutsu Kaisen Season 3 Resmi Diumumkan',
        'description': 'Petualangan Yuji Itadori berlanjut ke Culling Game.',
        'content': 'Studio MAPPA telah merilis teaser visual perdana [450 chars]',
        'url': 'https://example.com/anime/jujutsu-kaisen-s3',
        'image': 'https://example.com/images/jjk3.jpg',
        'publishedAt': '2026-11-18T10:00:00Z',
        'source': {
          'id': 'animenews',
          'name': 'Anime News Network',
          'url': 'https://example.com',
        },
      };

      final article = ArticleModel.fromJson(json);

      expect(article.title, 'Jujutsu Kaisen Season 3 Resmi Diumumkan');
      expect(article.description, 'Petualangan Yuji Itadori berlanjut ke Culling Game.');
      expect(article.author, 'Anime News Network');
      expect(article.urlToImage, 'https://example.com/images/jjk3.jpg');
      expect(article.publishedAt, '2026-11-18T10:00:00Z');
      expect(article.content, 'Studio MAPPA telah merilis teaser visual perdana...');
    });

    test('ArticleModel handles null and fallback values gracefully', () {
      final json = <String, dynamic>{};
      final article = ArticleModel.fromJson(json);

      expect(article.title, 'Tanpa Judul');
      expect(article.author, isNull);
      expect(article.urlToImage, isNull);
      expect(article.content, isNull);
      expect(article.publishedAt, '');
    });

    test('NewsResponseModel parses article list and totalArticles', () {
      final json = {
        'totalArticles': 1,
        'articles': [
          {
            'title': 'Chainsaw Man Reze Arc Movie',
            'publishedAt': '2026-11-19T01:00:00Z',
          }
        ]
      };

      final response = NewsResponseModel.fromJson(json);
      expect(response.totalArticles, 1);
      expect(response.articles.length, 1);
      expect(response.articles.first.title, 'Chainsaw Man Reze Arc Movie');
    });
  });

  group('ApiException Tests (Topic 11 Scenarios)', () {
    test('Timeout error produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.receiveTimeout,
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'Koneksi lambat. Server tidak merespons tepat waktu.');
    });

    test('Connection error produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.connectionError,
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    });

    test('HTTP 401 Unauthorized produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/search'),
          statusCode: 401,
        ),
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'API key salah atau tidak terdaftar.');
      expect(apiException.statusCode, 401);
    });

    test('HTTP 403 Forbidden produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/search'),
          statusCode: 403,
        ),
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'Kuota harian habis atau email akun belum diverifikasi.');
      expect(apiException.statusCode, 403);
    });

    test('HTTP 429 Rate Limit produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/search'),
          statusCode: 429,
        ),
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'Terlalu cepat. Paket gratis hanya 1 request per detik.');
      expect(apiException.statusCode, 429);
    });

    test('HTTP 404 Endpoint Not Found produces correct message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/invalid-path'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/invalid-path'),
          statusCode: 404,
        ),
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, 'Alamat endpoint tidak ditemukan.');
    });

    test('HTTP 400 Bad Request with server error message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/search'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/search'),
          statusCode: 400,
          data: {
            'errors': ['Parameter query q tidak valid.']
          },
        ),
      );

      final apiException = ApiException.fromDio(dioException);
      expect(apiException.message, contains('Permintaan tidak valid. Parameter query q tidak valid.'));
    });

    test('Env.samarkan hides apiKey in logs and error messages', () {
      const sensitive = 'https://gnews.io/api/v4/search?q=anime&apikey=1234567890abcdef1234567890abcdef';
      final masked = Env.samarkan(sensitive);
      expect(masked, contains('apikey=***'));
      expect(masked, isNot(contains('1234567890abcdef1234567890abcdef')));
    });
  });

  group('Widget Smoke Test', () {
    testWidgets('AniNewsApp renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const AniNewsApp());
      // Check that the title AniNews ID appears
      expect(find.text('AniNews ID'), findsOneWidget);
      expect(find.text('Your Daily Dose of Anime News'), findsOneWidget);
    });
  });
}
