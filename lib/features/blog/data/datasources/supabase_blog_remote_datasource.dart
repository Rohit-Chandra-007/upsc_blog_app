import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upsc_blog_app/core/error/exception.dart';
import 'package:upsc_blog_app/features/blog/data/models/blog_model.dart';

abstract interface class SupabaseBlogRemoteDatasource {
  Future<BlogModel> uploadBlog({
    required BlogModel blog,
  });

  Future<String> uploadImage({
    required File image,
    required BlogModel blog,
  });
}

class SupabaseBlogRemoteDatasourceImpl implements SupabaseBlogRemoteDatasource {
  final SupabaseClient client;

  SupabaseBlogRemoteDatasourceImpl({
    required this.client,
  });

  @override
  Future<BlogModel> uploadBlog({
    required BlogModel blog,
  }) async {
    try {
      final response =
          await client.from('blogs').insert(blog.toJson()).select();

      return BlogModel.fromJson(response.first);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadImage(
      {required File image, required BlogModel blog}) async {
    try {
      await client.storage.from('blog_images').upload(
            blog.id,
            image,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return client.storage.from('blog_images').getPublicUrl(
            blog.id,
          );
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
