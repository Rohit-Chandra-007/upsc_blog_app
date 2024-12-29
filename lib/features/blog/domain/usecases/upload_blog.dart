import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/core/usecase/usecase.dart';
import 'package:upsc_blog_app/features/blog/domain/entities/blog.dart';
import 'package:upsc_blog_app/features/blog/domain/repository/blog_repository.dart';

class UploadBlog implements UseCase<UploadBlogParams, Blog> {
  BlogRepository blogRepository;
  UploadBlog(this.blogRepository);
  @override
  Future<Either<Failure, Blog>> call(UploadBlogParams params) async {
    return await blogRepository.uploadBlog(
      image: params.image,
      title: params.title,
      content: params.content,
      userId: params.userId,
      topics: params.topics,
    );
  }
}

class UploadBlogParams {
  final File image;
  final String title;
  final String content;
  final String userId;
  final List<String> topics;

  UploadBlogParams({
    required this.image,
    required this.title,
    required this.content,
    required this.userId,
    required this.topics,
  });
}
