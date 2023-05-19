part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

class PostState extends Equatable {
  const PostState({
    this.posts = const <Post>[],
    this.postStatus = PostStatus.initial,
    this.hasReachedMax = false,
  });

  final List<Post> posts;
  final PostStatus postStatus;
  final bool hasReachedMax;

  PostState copyWith({
    List<Post>? posts,
    PostStatus? postStatus,
    bool? hasReachedMax,
  }) {
    return PostState(
        posts: posts ?? this.posts,
        postStatus: postStatus ?? this.postStatus,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  String toString() =>
      'Post Status: $postStatus | Has Reached Max: $hasReachedMax | Posts: ${posts.length}';

  @override
  List<Object> get props => [posts, postStatus, hasReachedMax];
}

class PostInitial extends PostState {}
