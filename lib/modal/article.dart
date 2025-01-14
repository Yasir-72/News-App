import 'package:hive/hive.dart';

part 'article.g.dart'; // Run the build_runner to generate this file.

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String imageUrl;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String content;

  Article({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.content,
  });
}
