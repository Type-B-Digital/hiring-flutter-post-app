import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int reactions;
  final int views;
  final int userId;
  final String? authorName;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.reactions,
    required this.views,
    required this.userId,
    this.authorName,
  });

  @override
  List<Object?> get props =>
      [id, title, body, tags, reactions, views, userId, authorName];
}
