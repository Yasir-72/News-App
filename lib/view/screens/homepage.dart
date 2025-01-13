import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:news_app/modal/newsmodal.dart';
import 'package:news_app/res/response.dart';
import 'package:news_app/view/screens/explorepage.dart';
import 'package:news_app/view/screens/fullnewspage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();

  late Future<List<NewsArticle>> _breakingNewsFuture;
  late Future<List<NewsArticle>> _recommendationsFuture;

  int _selectedIndex = 0;

  // Lists of available countries and categories
  final List<String> _categories = [
    "business",
    "technology",
    "sports",
    "general",
    "health",
    "science",
    "entertainment"
  ];
  final List<String> _countries = ["us", "in", "fr", "ru", "au", "gb"];

  String _selectedCategory = "";
  String _selectedCountry = "";

  @override
  void initState() {
    super.initState();

    // Randomly select a category and country
    final Random random = Random();
    _selectedCategory = _categories[random.nextInt(_categories.length)];
    _selectedCountry = _countries[random.nextInt(_countries.length)];

    // Fetch breaking news and recommendations based on the selected category and country
    _breakingNewsFuture =
        _newsService.fetchBreakingNews(_selectedCountry); // Updated method
    _recommendationsFuture = _newsService.fetchRecommendations(
        _selectedCategory, _selectedCountry); // Updated method
  }

  Future<void> _refreshData() async {
    setState(() {
      // Randomly select a category and country when refreshing data
      final Random random = Random();
      _selectedCategory = _categories[random.nextInt(_categories.length)];
      _selectedCountry = _countries[random.nextInt(_countries.length)];

      _breakingNewsFuture =
          _newsService.fetchBreakingNews(_selectedCountry); // Updated method
      _recommendationsFuture = _newsService.fetchRecommendations(
          _selectedCategory, _selectedCountry); // Updated method
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _recommendationsFuture = _newsService.fetchRecommendations(
          category.toLowerCase(), _selectedCountry); // Updated method
    });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Full-screen refresh
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: "Breaking News",
                  onViewAllPressed: () => debugPrint("View All pressed"),
                ),
                const SizedBox(height: 16),
                _buildFutureBuilder(
                  future: _breakingNewsFuture,
                  builder: (context, articles) =>
                      _buildCarouselSlider(articles),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader(
                  title: "Recommendation",
                  onViewAllPressed: () => debugPrint("View All pressed"),
                ),
                const SizedBox(height: 8),
                _buildFutureBuilder(
                  future: _recommendationsFuture,
                  builder: (context, articles) =>
                      _buildRecommendationList(articles),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // AppBar widget
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, size: 35),
        onPressed: () => debugPrint("Menu pressed"),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 35),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => ExplorePage())),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_active, size: 35),
          onPressed: () {},
        ),
      ],
    );
  }

  // FutureBuilder for loading data with optimized error handling
  Widget _buildFutureBuilder({
    required Future<List<NewsArticle>> future,
    required Widget Function(BuildContext context, List<NewsArticle> articles)
        builder,
  }) {
    return FutureBuilder<List<NewsArticle>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return builder(context, snapshot.data!);
        } else {
          return const Center(child: Text("No data available."));
        }
      },
    );
  }

  // Section header widget
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAllPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAllPressed,
          child: const Text("View All",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Carousel slider widget for breaking news
  Widget _buildCarouselSlider(List<NewsArticle> articles) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        enlargeCenterPage: true,
        autoPlay: true,
        viewportFraction: 0.9,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index, realIndex) {
        final article = articles[index];
        return _buildCarouselItem(article);
      },
    );
  }

  // Carousel item widget
  Widget _buildCarouselItem(NewsArticle article) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              article.urlToImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Image has finished loading
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color:
                      Colors.grey[200], // Background color for the error state
                  child: const Center(
                    child:
                        Icon(Icons.broken_image, size: 50, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildCarouselTextOverlay(article),
          ),
        ],
      ),
    );
  }

  // Text overlay widget for the carousel item
  Widget _buildCarouselTextOverlay(NewsArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8)),
          child: Text(
            article.sourceName,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.description,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4),
              ]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Recommendation list widget
  Widget _buildRecommendationList(List<NewsArticle> articles) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildRecommendationItem(article);
      },
    );
  }

  // Recommendation list item widget
  Widget _buildRecommendationItem(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullNewsPage(imageUrl: article.imageUrl, title: article.title, description: article.description, content: article.content),
          ),
        );
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: article.urlToImage.isNotEmpty
                    ? Image.network(
                        article.urlToImage,
                        width: 150,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 100,
                            color: Colors
                                .grey[200], // Placeholder background color
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
                        color: Colors.grey[200], // Placeholder background color
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
                            article.author.isNotEmpty == true
                                ? article.author
                                : "Unknown",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.publishedAt?.toString() ?? "N/A",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
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

  // Bottom navigation bar widget
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: "Bookmarks",
        ),
      ],
    );
  }
}
