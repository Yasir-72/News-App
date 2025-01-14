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

  late Future<Map<String, List<NewsArticle>>> _newsDataFuture;

  @override
  void initState() {
    super.initState();
    _initializeNewsData();
  }

  void _initializeNewsData() {
    // Call fetchRandomNews for both sections
    _newsDataFuture = Future.wait([
      _newsService.fetchRandomNews(), // For breaking news
      _newsService.fetchRandomNews(), // For recommendations
    ]).then((results) => {
          "breakingNews": results[0],
          "recommendations": results[1],
        });
  }

  Future<void> _refreshData() async {
    setState(() {
      _initializeNewsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, List<NewsArticle>>>(
              future: _newsDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  final breakingNews = snapshot.data?["breakingNews"] ?? [];
                  final recommendations =
                      snapshot.data?["recommendations"] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        title: "Breaking News",
                        onViewAllPressed: () => debugPrint("View All pressed"),
                      ),
                      const SizedBox(height: 16),
                      _buildCarouselSlider(breakingNews),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: "Recommendations",
                        onViewAllPressed: () => debugPrint("View All pressed"),
                      ),
                      const SizedBox(height: 8),
                      _buildRecommendationList(recommendations),
                    ],
                  );
                } else {
                  return const Center(child: Text("No data available."));
                }
              },
            ),
          ),
        ),
      ),
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
            context,
            MaterialPageRoute(builder: (context) => const ExplorePage()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_active, size: 35),
          onPressed: () {},
        ),
      ],
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
        IconButton(
            onPressed: onViewAllPressed, icon: const Icon(Icons.new_releases)),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullNewsPage(
                    imageUrl: article.imageUrl,
                    title: article.title,
                    description: article.description,
                    content: article.content)));
      },
      child: Container(
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
                    color: Colors
                        .grey[200], // Background color for the error state
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
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(),
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
            builder: (context) => FullNewsPage(
              imageUrl: article.urlToImage,
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
}
