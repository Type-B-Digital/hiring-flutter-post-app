import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.tags,
    required super.reactions,
    required super.views,
    required super.userId,
    super.authorName,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      reactions: json['reactions'] is Map
          ? (json['reactions']['likes'] ?? 0)
          : (json['reactions'] ?? 0),
      views: json['views'] ?? 0,
      userId: json['userId'] as int,
      authorName: json['authorName'] as String?,
    );
  }

  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    List<String>? tags,
    int? reactions,
    int? views,
    int? userId,
    String? authorName,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      reactions: reactions ?? this.reactions,
      views: views ?? this.views,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
    );
  }
}
