import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/core/models/paginated_response.dart';
import 'package:posts_app/features/posts/data/models/post_model.dart';

void main() {
  group('PostModel', () {
    test('fromJson_withMapReactions_extractsLikesCount', () {
      final json = {
        'id': 1,
        'title': 'Title',
        'body': 'Body',
        'tags': ['tag1', 'tag2'],
        'reactions': {'likes': 10, 'dislikes': 2},
        'views': 100,
        'userId': 5,
      };

      final result = PostModel.fromJson(json);

      expect(result.reactions, 10);
      expect(result.views, 100);
      expect(result.tags, ['tag1', 'tag2']);
      expect(result.authorName, isNull);
    });

    test('fromJson_withIntReactions_usesValueDirectly', () {
      final json = {
        'id': 1,
        'title': 'Title',
        'body': 'Body',
        'tags': ['tag1'],
        'reactions': 7,
        'views': 50,
        'userId': 5,
      };

      final result = PostModel.fromJson(json);

      expect(result.reactions, 7);
    });

    test('fromJson_withMissingTags_returnsEmptyList', () {
      final json = {
        'id': 1,
        'title': 'Title',
        'body': 'Body',
        'reactions': 0,
        'views': 0,
        'userId': 5,
      };

      final result = PostModel.fromJson(json);

      expect(result.tags, isEmpty);
    });

    test('copyWith_withAuthorName_returnsUpdatedModel', () {
      const post = PostModel(
        id: 1,
        title: 'Title',
        body: 'Body',
        tags: [],
        reactions: 0,
        views: 0,
        userId: 5,
      );

      final result = post.copyWith(authorName: 'johnd');

      expect(result.authorName, 'johnd');
      expect(result.id, post.id);
    });
  });

  group('PaginatedResponse', () {
    test('fromJson_withPostsEnvelope_parsesItemsAndMetadata', () {
      final json = {
        'posts': [
          {
            'id': 1,
            'title': 'Title',
            'body': 'Body',
            'tags': [],
            'reactions': 0,
            'views': 0,
            'userId': 5,
          }
        ],
        'total': 251,
        'skip': 0,
        'limit': 10,
      };

      final result = PaginatedResponse<PostModel>.fromJson(
        json,
        (j) => PostModel.fromJson(j),
        'posts',
      );

      expect(result.items.length, 1);
      expect(result.total, 251);
      expect(result.skip, 0);
      expect(result.limit, 10);
    });

    test('fromJson_withNoMatches_returnsEmptyItems', () {
      final json = {'posts': [], 'total': 0, 'skip': 0, 'limit': 10};

      final result = PaginatedResponse<PostModel>.fromJson(
        json,
        (j) => PostModel.fromJson(j),
        'posts',
      );

      expect(result.items, isEmpty);
      expect(result.total, 0);
    });
  });
}
