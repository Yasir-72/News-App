import 'package:flutter/material.dart';
import 'package:news_app/modal/newsmodal.dart';
import 'package:news_app/res/response.dart';
import 'package:news_app/view/screens/fullnewspage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsArticle>> _newsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _fetchRandomNews();
  }

  /// Fetch random news articles.
  void _fetchRandomNews() {
    setState(() {
      _newsFuture = _newsService.fetchRandomNews();
    });
  }

  /// Refresh the data by fetching random news.
  Future<void> _refreshData() async {
    setState(() {
      _fetchRandomNews();
    });
  }

  /// Search for news articles.
  /// If the query is empty, random news is fetched.
  void _searchNews(String query) {
    setState(() {
      _newsFuture = query.isNotEmpty
          ? _newsService.searchNews(query)
          : _newsService.fetchRandomNews();
    });
  }

  /// When a category chip is clicked, update the selected category and fetch
  /// news for that category. If the category is "all" or no articles are found,
  /// fall back to random news.
  void _onCategoryChipClick(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "all") {
        _newsFuture = _newsService.fetchRandomNews();
      } else {
        _newsFuture =
            _newsService.fetchNewsWithCategory(category).then((articles) {
          // If no articles are returned for the selected category,
          // fallback to random news.
          if (articles.isEmpty) {
            return _newsService.fetchRandomNews();
          }
          return articles;
        });
      }
    });
  }

  /// Build a horizontal list of category chips.
  Widget _buildCategoryChips() {
    List<String> categories = [
      "all",
      "business",
      "technology",
      "sports",
      "general",
      "health",
      "science",
      "entertainment"
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return GestureDetector(
            onTap: () => _onCategoryChipClick(category),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Chip(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                label: Text(category == "all" ? "All Categories" : category),
                backgroundColor: _selectedCategory == category
                    ? Colors.blue
                    : Colors.grey[300],
                labelStyle: TextStyle(
                  color: _selectedCategory == category
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build the header section with title, subtitle, and category chips.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Discover",
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          "News from all around the world",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildCategoryChips(),
      ],
    );
  }

  /// Build the search bar with a clear button.
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onSubmitted: _searchNews,
      onChanged: (value) {
        // When the search text is cleared, show random news.
        if (value.isEmpty) {
          _searchNews('');
        }
      },
      decoration: InputDecoration(
        hintText: "Search",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            _searchNews('');
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    );
  }

  /// Build the list of news articles using a FutureBuilder.
  Widget _buildNewsList() {
    return FutureBuilder<List<NewsArticle>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No articles found for this query."),
          );
        } else if (snapshot.hasData) {
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final article = snapshot.data![index];
              return _buildArticleItem(article);
            },
          );
        } else {
          return const Center(
            child: Text("Unexpected error occurred."),
          );
        }
      },
    );
  }

  /// Build an individual news article item.
  Widget _buildArticleItem(NewsArticle article) {
    return GestureDetector(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: article.imageUrl.isNotEmpty
                  ? Image.network(
                      article.imageUrl,
                      width: 150,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 150,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.sourceName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person,
                            size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.author.isNotEmpty
                              ? article.author
                              : "Unknown",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.publishedAt?.toString() ?? "N/A",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the overall UI layout.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uncomment the following lines if you want to use an AppBar.
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   iconTheme: const IconThemeData(color: Colors.black),
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(child: _buildNewsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
