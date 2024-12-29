import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsc_blog_app/features/blog/domain/usecases/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  UploadBlog uploadBlog;
  BlogBloc(this.uploadBlog) : super(BlogInitial()) {
    on<BlogEvent>((event, emit) {
      emit(BlogLoading());
    });

    on<BlogUploadEvent>(_onUploadBlogEvent);
  }

  void _onUploadBlogEvent(
      BlogUploadEvent event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final result = await uploadBlog(
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
      (r) => emit(BlogSuccess()),
    );
  }
}
