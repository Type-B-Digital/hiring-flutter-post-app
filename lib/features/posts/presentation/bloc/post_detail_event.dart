import 'package:equatable/equatable.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

class PostDetailFetched extends PostDetailEvent {
  final int id;

  const PostDetailFetched(this.id);

  @override
  List<Object> get props => [id];
}
