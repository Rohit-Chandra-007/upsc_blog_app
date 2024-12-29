part of 'blog_bloc.dart';

sealed class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object> get props => [];
}

final class BlogUpload extends BlogEvent {
  final File image;
  final String title;
  final String content;
  final String userId;
  final List<String> topics;

  const BlogUpload({
    required this.image,
    required this.title,
    required this.content,
    required this.userId,
    required this.topics,
  });
}

final class FetchBlogs extends BlogEvent {}

final class RefreshBlogs extends BlogEvent {}


