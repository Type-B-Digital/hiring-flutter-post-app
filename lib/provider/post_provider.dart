import 'package:flutter/foundation.dart';
import 'package:post_app/app_config.dart';
import 'package:post_app/models/post.dart';
import 'package:post_app/repository/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;
  final int _pageSize;

  PostProvider(this._repository, {int pageSize = AppConfig.paginationLimit}) : _pageSize = pageSize;

  List<Post> _posts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> onInit() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPosts = await _fetchPage(skip: 0);
      _posts = newPosts;
      
      _hasMore = newPosts.length == _pageSize;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final newPosts = await _fetchPage(skip: _posts.length);
      _posts = [..._posts, ...newPosts];
      _hasMore = newPosts.length == _pageSize;
    } catch (_) {
      
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    await onInit();
  }

  Post? getById(int id) {
    for (final post in _posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  Future<List<Post>> _fetchPage({required int skip}) {
    return _searchQuery.isEmpty
        ? _repository.getPosts(skip: skip, limit: _pageSize)
        : _repository.searchPosts(query: _searchQuery, skip: skip, limit: _pageSize);
  }
}
