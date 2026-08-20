import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/models/post.dart';
import 'package:post_app/provider/post_provider.dart';
import 'package:post_app/repository/post_repository.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepo;
  late PostProvider provider;

  setUp(() {
    mockRepo = MockPostRepository();
    provider = PostProvider(mockRepo, pageSize: 20);
  });

  Post makePost(int id) {
    return Post(
      id: id,
      title: 'Post $id',
      body: 'Body $id',
      tags: ['flutter'],
      likes: 1,
      dislikes: 0,
      views: 10,
      userId: 1,
    );
  }

  test('onInit loads posts', () async {
    // a full page (20 posts) means the provider should assume there's more
    final fullPage = List.generate(20, (i) => makePost(i));
    when(() => mockRepo.getPosts(skip: 0, limit: 20)).thenAnswer((_) async => fullPage);

    await provider.onInit();

    expect(provider.posts.length, 20);
    expect(provider.hasMore, true);
  });

  test('search updates the post list', () async {
    when(
      () => mockRepo.getPosts(skip: 0, limit: 20),
    ).thenAnswer((_) async => [makePost(1)]);
    await provider.onInit();

    when(
      () => mockRepo.searchPosts(query: 'flutter', skip: 0, limit: 20),
    ).thenAnswer((_) async => [makePost(9)]);

    await provider.search('flutter');

    expect(provider.posts.first.id, 9);
  });

  test('shows an error if fetching fails', () async {
    when(
      () => mockRepo.getPosts(skip: 0, limit: 20),
    ).thenThrow(Exception('Failed to load posts. Please try again.'));

    await provider.onInit();

    expect(provider.error, 'Failed to load posts. Please try again.');
  });
}
