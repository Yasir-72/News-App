import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/modal/newsmodal.dart';

class NewsService {
  // Official NewsAPI base URL
  final String _baseUrl = 'https://newsapi.org/v2';
  // Replace with your actual API key. In production, store this securely.
  final String _apiKey = 'af4f5113e2084cb1aaf69ff168f96d88';

  /// General method to fetch news from a given [endpoint] with optional [queryParameters].
  Future<List<NewsArticle>> _fetchNews(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    // Build the complete URI including the API key
    final uri = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: {
      ...?queryParameters,
      'apiKey': _apiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'ok') {
          throw Exception('API error: ${data['message']}');
        }

        final articles = data['articles'] as List;
        return articles
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      } else {
        throw Exception(
            'Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('An error occurred while fetching news: $error');
    }
  }

  /// Fetch breaking news based on a specific [category] and [countryCode].
  Future<List<NewsArticle>> fetchBreakingNews(
      String category, String countryCode) async {
    return _fetchNews(
      'top-headlines',
      queryParameters: {
        'category': category,
        'country': countryCode,
      },
    );
  }

  /// Fetch recommendations based on [category] and [countryCode].
  Future<List<NewsArticle>> fetchRecommendations(
      String category, String countryCode) async {
    // Using the same endpoint as breaking news
    return _fetchNews(
      'top-headlines',
      queryParameters: {
        'category': category,
        'country': countryCode,
      },
    );
  }

  /// Fetch top headlines for a specific [category] and [countryCode].
  Future<List<NewsArticle>> fetchTopHeadlines(
      String category, String countryCode) async {
    return _fetchNews(
      'top-headlines',
      queryParameters: {
        'category': category,
        'country': countryCode,
      },
    );
  }

  /// Search for news articles using the provided [query] via the "everything" endpoint.
  /// If no articles are found, it falls back to fetching US general news.
  Future<List<NewsArticle>> searchNews(String query) async {
    List<NewsArticle> articles = await _fetchNews(
      'everything',
      queryParameters: {
        'q': query,
        'language': 'en',
        'sortBy': 'publishedAt',
        'pageSize': '20',
      },
    );

    // Fallback to US general news if the search returns empty results.
    if (articles.isEmpty) {
      articles = await fetchBreakingNews("general", "us");
    }

    return articles;
  }

  /// Fetch random news by selecting a random [category] and a random [country].
  /// If the returned list is empty, it falls back to US general news.
  Future<List<NewsArticle>> fetchRandomNews() async {
    List<String> categories = [
      "business",
      "technology",
      "sports",
      "general",
      "health",
      "science",
      "entertainment"
    ];
    List<String> countries = ["us", "gb", "au", "ca"];

    categories.shuffle();
    countries.shuffle();

    String randomCategory = categories.first;
    String randomCountry = countries.first;

    List<NewsArticle> articles = await _fetchNews(
      'top-headlines',
      queryParameters: {
        'category': randomCategory,
        'country': randomCountry,
      },
    );

    // Fallback if no articles are found with the random selection.
    if (articles.isEmpty) {
      articles = await fetchBreakingNews("general", "us");
    }

    return articles;
  }

  /// Fetch news articles for a specific [selectedCategory].
  /// Uses a fixed country code ('us') for reliable results.
  Future<List<NewsArticle>> fetchNewsWithCategory(
      String selectedCategory) async {
    return _fetchNews(
      'top-headlines',
      queryParameters: {
        'category': selectedCategory,
        'country': 'us',
      },
    );
  }
}
