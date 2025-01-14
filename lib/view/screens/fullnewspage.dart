import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FullNewsPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String content;

  const FullNewsPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  State<FullNewsPage> createState() => _FullNewsPageState();
}

class _FullNewsPageState extends State<FullNewsPage> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // Check if the article is already saved
  void _checkIfSaved() async {
    final savedArticles = await SavedArticles.getArticles();
    setState(() {
      isSaved = savedArticles.any((article) => article.title == widget.title);
    });
  }

  // Toggle the bookmark state
  void toggleBookmark() async {
    final article = Article(
      imageUrl: widget.imageUrl,
      title: widget.title,
      description: widget.description,
      content: widget.content,
    );

    if (isSaved) {
      await SavedArticles.removeArticle(widget.title);
      setState(() {});
    } else {
      await SavedArticles.addArticle(article);
      setState(() {});
    }

    _checkIfSaved(); // Refresh the saved state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
          ),

          // Back button and Bookmark button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    onPressed: toggleBookmark,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 14),

                        // Description
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.content,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Article {
  final String imageUrl;
  final String title;
  final String description;
  final String content;

  Article({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.content,
  });

  // Convert Article object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'content': content,
    };
  }

  // Convert JSON map to Article object
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
    );
  }
}

class SavedArticles {
  static const _key = 'saved_articles';

  // Save article to SharedPreferences
  static Future<void> addArticle(Article article) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedArticles = prefs.getStringList(_key) ?? [];

    // Add the article as a JSON string
    String articleJson = json.encode(article.toJson());
    savedArticles.add(articleJson);

    await prefs.setStringList(_key, savedArticles);
  }

  // Remove article from SharedPreferences
  static Future<void> removeArticle(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedArticles = prefs.getStringList(_key) ?? [];

    // Remove the article with the given title
    savedArticles.removeWhere((articleJson) {
      final article = json.decode(articleJson);
      return article['title'] == title;
    });

    await prefs.setStringList(_key, savedArticles);
  }

  // Get all saved articles
  static Future<List<Article>> getArticles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedArticles = prefs.getStringList(_key) ?? [];

    // Convert the stored JSON strings back to Article objects
    return savedArticles.map((articleJson) {
      final articleMap = json.decode(articleJson);
      return Article.fromJson(articleMap);
    }).toList();
  }
}
