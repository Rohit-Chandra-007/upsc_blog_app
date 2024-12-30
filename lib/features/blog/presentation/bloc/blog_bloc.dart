import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/features/blog/domain/entities/blog.dart';
import 'package:upsc_blog_app/features/blog/domain/usecases/fetch_all_blog.dart';
import 'package:upsc_blog_app/features/blog/domain/usecases/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final FetchAllBlog _fetchAllBlog;
  BlogBloc({
    required UploadBlog uploadBlog,
    required FetchAllBlog fetchAllBlog,
  })  : _fetchAllBlog = fetchAllBlog,
        _uploadBlog = uploadBlog,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) {
      emit(BlogLoading());
    });

    on<BlogUploadEvent>(_onUploadBlogEvent);
    on<BlogFetchAllEvent>(_onFetchAllBlogEvent);
  }

  void _onUploadBlogEvent(
      BlogUploadEvent event, Emitter<BlogState> emit) async {
    final result = await _uploadBlog(
      UploadBlogParams(
        image: event.image,
        title: event.title,
        content: event.content,
        userId: event.userId,
        topics: event.topics,
      ),
    );
    result.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogUploadSuccess()),
    );
  }

  void _onFetchAllBlogEvent(
    BlogFetchAllEvent event,
    Emitter<BlogState> emit,
  ) async {
    final result = await _fetchAllBlog(NoParams());
    result.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogFetchAllSuccess(blogs: r)),
    );
  }
}
