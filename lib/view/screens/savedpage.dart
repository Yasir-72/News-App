import 'package:flutter/material.dart';
import 'package:news_app/view/screens/fullnewspage.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  late Future<List<Article>> _savedArticles;

  @override
  void initState() {
    super.initState();
    _savedArticles = SavedArticles.getArticles(); // Load saved articles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Articles"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Article>>(
        future: _savedArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No articles saved.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final savedArticles = snapshot.data!;

          return ListView.builder(
            itemCount: savedArticles.length,
            itemBuilder: (context, index) {
              final article = savedArticles[index];

              return Card(
                elevation: 10,
                color: Colors.grey[100],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    article.imageUrl,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                    ),
                  ),
                  title: Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await SavedArticles.removeArticle(article.title);
                      setState(() {
                        _savedArticles = SavedArticles.getArticles();
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullNewsPage(
                          imageUrl: article.imageUrl,
                          title: article.title,
                          description: article.description,
                          content: article.content,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
