class Reactions {
  final int likes;
  final int dislikes;

  const Reactions({required this.likes, required this.dislikes});

  factory Reactions.fromJson(Map<String, dynamic> json) {
    return Reactions(
      likes: json['likes'] as int,
      dislikes: json['dislikes'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Reactions && likes == other.likes && dislikes == other.dislikes;

  @override
  int get hashCode => Object.hash(likes, dislikes);
}

class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final Reactions reactions;
  final int views;

  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
    required this.views,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
      reactions: Reactions.fromJson(json['reactions'] as Map<String, dynamic>),
      views: json['views'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PostModel &&
      id == other.id &&
      title == other.title &&
      body == other.body &&
      userId == other.userId &&
      views == other.views &&
      reactions == other.reactions;

  @override
  int get hashCode => Object.hash(id, title, body, userId, views, reactions);
}

class PostsResponseModel {
  final List<PostModel> posts;
  final int total;
  final int skip;
  final int limit;

  const PostsResponseModel({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PostsResponseModel.fromJson(Map<String, dynamic> json) {
    return PostsResponseModel(
      posts: (json['posts'] as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}
