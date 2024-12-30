import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/core/error/failures.dart';
import 'package:upsc_blog_app/features/blog/data/datasources/supabase_blog_remote_datasource.dart';
import 'package:upsc_blog_app/features/blog/data/models/blog_model.dart';
import 'package:upsc_blog_app/features/blog/domain/entities/blog.dart';
import 'package:upsc_blog_app/features/blog/domain/repository/blog_repository.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  SupabaseBlogRemoteDatasource supabaseBlogRemoteDatasource;
  BlogRepositoryImpl({required this.supabaseBlogRemoteDatasource});
  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String userId,
    required List<String> topics,
  }) async {
    try {
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
  Future<Either<Failure, List<Blog>>> getAllBlogs() async{
    try {
      final blogs = await supabaseBlogRemoteDatasource.getAllBlogs();
      return Right(blogs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } 
  }
}
