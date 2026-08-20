import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class PostsFetched extends PostsEvent {}

class PostsRefreshed extends PostsEvent {}

class PostsSearchQueryChanged extends PostsEvent {
  final String query;

  const PostsSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}
