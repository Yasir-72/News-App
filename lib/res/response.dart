import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/modal/newsmodal.dart';

class NewsService {
  final String baseUrl = 'https://newsapi.org/v2/';
  final String apiKey = 'af4f5113e2084cb1aaf69ff168f96d88';

  // General method to fetch data from API
  Future<List<NewsArticle>> _fetchNews(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint&apiKey=$apiKey'),
      );

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
  Future<List<NewsArticle>> fetchBreakingNews(String countryCode) async {
    final endpoint = 'top-headlines?country=$countryCode';
    return _fetchNews(endpoint);
  }

  // Fetch recommendations based on category and country
  Future<List<NewsArticle>> fetchRecommendations(
      String category, String countryCode,
      {int page = 1, int pageSize = 30}) async {
    final endpoint =
        'top-headlines?category=$category&country=$countryCode&page=$page&pageSize=$pageSize';
    return _fetchNews(endpoint);
  }

  Future<List<NewsArticle>> fetchTopHeadlines(
      String category, String countryCode) async {
    final endpoint = 'top-headlines?category=$category&country=$countryCode';
    return _fetchNews(endpoint);
  }

  // Search for news with advanced filters
  Future<List<NewsArticle>> searchNews(
    String query, {
    String? language,
    String? sortBy,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 10,
  }) async {
    String endpoint = 'everything?q=$query';

    // Add optional parameters to the query string
    if (language != null) endpoint += '&language=$language';
    if (sortBy != null) endpoint += '&sortBy=$sortBy';
    if (from != null) endpoint += '&from=$from';
    if (to != null) endpoint += '&to=$to';
    endpoint += '&page=$page&pageSize=$pageSize';

    return _fetchNews(endpoint);
  }

  // Fetch random news based on random category and country
  Future<List<NewsArticle>> fetchRandomNews() async {
    // Categories and countries for random selection
    List<String> categories = ["business", "technology", "sports", "general", "health", "science", "entertainment"];
    List<String> countries = ["us", "in", "fr", "au"];

    // Select a random category and country
    String randomCategory = (categories..shuffle()).first;
    String randomCountry = (countries..shuffle()).first;

    // Fetch the news with random category and country
    String endpoint = 'top-headlines?category=$randomCategory&country=$randomCountry';
    return _fetchNews(endpoint);
  }
}
