part of 'blog_bloc.dart';

sealed class BlogState extends Equatable {
  const BlogState();

  @override
  List<Object> get props => [];
}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogUploadSuccess extends BlogState {}

final class BlogFetchAllSuccess extends BlogState {
  final List<Blog> blogs;

  const BlogFetchAllSuccess({required this.blogs});

  @override
  List<Object> get props => [blogs];
}

final class BlogFailure extends BlogState {
  final String message;

  const BlogFailure(this.message);

  @override
  List<Object> get props => [message];
}
