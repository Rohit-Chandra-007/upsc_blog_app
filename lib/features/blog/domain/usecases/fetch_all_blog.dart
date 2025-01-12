
import 'package:fpdart/fpdart.dart';
import 'package:civilshots/core/error/failures.dart';
import 'package:civilshots/core/usecase/usecase.dart';
import 'package:civilshots/features/blog/domain/entities/blog.dart';
import 'package:civilshots/features/blog/domain/repository/blog_repository.dart';

class FetchAllBlog implements UseCase<NoParams, List<Blog>> {
  BlogRepository blogRepository;
  FetchAllBlog(this.blogRepository);
  @override
  Future<Either<Failure, List<Blog>>> call(NoParams params) async {
    return await blogRepository.getAllBlogs();
  }
}
