class Post {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int likes;
  final int dislikes;
  final int views;
  final int userId;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'] as Map<String, dynamic>? ?? const {};
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      tags: (json['tags'] as List? ?? const []).map((t) => t.toString()).toList(),
      likes: (reactions['likes'] as num?)?.toInt() ?? 0,
      dislikes: (reactions['dislikes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as int,
    );
  }
}
