import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/modal/newsmodal.dart';

class NewsService {
  final String baseUrl = 'https://saurav.tech/NewsAPI/';

  // General method to fetch data from API
  Future<List<NewsArticle>> _fetchNews(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      // Check the response status
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;

        if (articles.isEmpty) {
          throw Exception('No articles found for the selected criteria.');
        }

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

  // Fetch breaking news with optional country filter
  Future<List<NewsArticle>> fetchBreakingNews(
      String category, String countryCode) async {
    final endpoint = 'top-headlines/category/$category/$countryCode.json';
    return _fetchNews(endpoint);
  }

  // Fetch recommendations based on category and country
  Future<List<NewsArticle>> fetchRecommendations(
      String category, String countryCode) async {
    final endpoint = 'top-headlines/category/$category/$countryCode.json';
    return _fetchNews(endpoint);
  }

  // Fetch top headlines for a specific category and country
  Future<List<NewsArticle>> fetchTopHeadlines(
      String category, String countryCode) async {
    final endpoint = 'top-headlines/category/$category/$countryCode.json';
    return _fetchNews(endpoint);
  }

  // Search for news with a specific source
  Future<List<NewsArticle>> searchNews(String sourceId) async {
    final endpoint = 'everything/$sourceId.json';
    return _fetchNews(endpoint);
  }

  // Fetch random news based on random category and country
  Future<List<NewsArticle>> fetchRandomNews() async {
    // Categories and countries for random selection
    List<String> categories = [
      "business",
      "technology",
      "sports",
      "general",
      "health",
      "science",
      "entertainment"
    ];
    List<String> countries = ["us", "in", "fr", "au"];

    // Select a random category and country
    String randomCategory = (categories..shuffle()).first;
    String randomCountry = (countries..shuffle()).first;

    // Fetch the news with random category and country
    String endpoint =
        'top-headlines/category/$randomCategory/$randomCountry.json';
    return _fetchNews(endpoint);
  }
} 