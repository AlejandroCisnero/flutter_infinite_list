// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(milliseconds: 500);

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.dioClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched,
        transformer: throttleDroppable(throttleDuration));
  }
  final Dio dioClient;

  EventTransformer<E> throttleDroppable<E>(Duration duration) {
    return (events, mapper) {
      return droppable<E>().call(events.throttle(duration), mapper);
    };
  }

  Future<void> _onPostFetched(PostEvent event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.postStatus == PostStatus.initial) {
        final List<Post> posts = await _fetchPosts();
        return emit(state.copyWith(
            posts: posts,
            postStatus: PostStatus.success,
            hasReachedMax: false));
      }
      final List<Post> posts = await _fetchPosts(state.posts.length);
      emit(state.posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              posts: List.of(state.posts)..addAll(posts),
              postStatus: PostStatus.success,
              hasReachedMax: false));
    } catch (_) {
      emit(state.copyWith(postStatus: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([startIndex = 0]) async {
    String url =
        'https://jsonplaceholder.typicode.com/posts?$startIndex&_limit=20';
    Response response = await dioClient.get(url);
    await Future.delayed(const Duration(seconds: 2));
    if (response.statusCode == 200) {
      return (response.data as List).map((jsonPost) {
        return Post(
            userId: jsonPost['userId'],
            id: jsonPost['id'],
            title: jsonPost['title'],
            body: jsonPost['body']);
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}
