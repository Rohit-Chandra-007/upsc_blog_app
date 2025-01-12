import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/features/blog/domain/entities/blog.dart';

abstract interface class BlogRepository {
  Future<Either<Failure,Blog >> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String userId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Blog>>> getAllBlogs();

}