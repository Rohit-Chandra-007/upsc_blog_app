part of 'blog_bloc.dart';

sealed class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object> get props => [];
}

final class BlogUploadEvent extends BlogEvent {
  final File image;
  final String title;
  final String content;
  final String userId;
  final List<String> topics;

  const BlogUploadEvent({
    required this.image,
    required this.title,
    required this.content,
    required this.userId,
    required this.topics,
  });

  @override
  List<Object> get props => [image, title, content, userId, topics];
}
