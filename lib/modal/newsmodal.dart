class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final String imageUrl;
  final DateTime? publishedAt;
  final String content;
  final String author;
  final String language;
  final String country;
  final String urlToImage;
  final String sourceName;
  final String sourceUrl;
  final String sourceLogo;
  final String sourceLogoUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.content,
    required this.author,
    required this.language,
    required this.country,
    required this.urlToImage,
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceLogo,
    required this.sourceLogoUrl,
  });

  // Factory method to create a NewsArticle from JSON data
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? '',  
      imageUrl: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      language: json['language'] ?? '',
      country: json['country'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      sourceName: json['source']?['name'] ?? '', 
      sourceUrl: json['source']?['url'] ?? '',  
      sourceLogo: json['source']?['logo'] ?? '',  
      sourceLogoUrl: json['source']?['logoUrl'] ?? '',  
    );
  }
}
