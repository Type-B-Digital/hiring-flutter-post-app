part of 'post_bloc.dart';

@immutable
sealed class PostEvent {}

class PostsFetchRequestedEvent extends PostEvent {}

class PostsNextPageRequestedEvent extends PostEvent {}

class PostsSearchChangedEvent extends PostEvent {
  final String query;
  PostsSearchChangedEvent(this.query);
}

class PostsRefreshRequestedEvent extends PostEvent {}
