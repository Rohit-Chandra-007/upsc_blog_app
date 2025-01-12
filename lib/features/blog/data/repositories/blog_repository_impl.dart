import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/core/network/connection_checker.dart';
import 'package:upsc_blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:upsc_blog_app/features/blog/data/datasources/supabase_blog_remote_datasource.dart';
import 'package:upsc_blog_app/features/blog/data/models/blog_model.dart';
import 'package:upsc_blog_app/features/blog/domain/entities/blog.dart';
import 'package:upsc_blog_app/features/blog/domain/repository/blog_repository.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final SupabaseBlogRemoteDatasource supabaseBlogRemoteDatasource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;
  BlogRepositoryImpl({
    required this.supabaseBlogRemoteDatasource,
    required this.blogLocalDataSource,
    required this.connectionChecker,
  });
  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String userId,
    required List<String> topics,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        imageUrl: '',
        title: title,
        content: content,
        userId: userId,
        topics: topics,
        createdAt: DateTime.now(),
      );
      final imgUrl = await supabaseBlogRemoteDatasource.uploadImage(
        image: image,
        blog: blogModel,
      );
      blogModel = blogModel.copyWith(imageUrl: imgUrl);
      final updateBlog =
          await supabaseBlogRemoteDatasource.uploadBlog(blog: blogModel);
      return Right(updateBlog);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await connectionChecker.isConnected) {
        final blogs = blogLocalDataSource.getBlogs();
        return Right(blogs);
      }
      final blogs = await supabaseBlogRemoteDatasource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlog(blogs: blogs);
      return Right(blogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
