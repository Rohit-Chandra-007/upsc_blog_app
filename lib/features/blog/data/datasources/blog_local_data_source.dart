import 'package:hive/hive.dart';
import 'package:upsc_blog_app/features/blog/data/models/blog_model.dart';

abstract interface class BlogLocalDataSource {
  List<BlogModel> getBlogs();
  void uploadLocalBlog({required List<BlogModel> blogs});
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box box;

  BlogLocalDataSourceImpl(this.box);

  /// This class is responsible for caching the blogs locally means in the device.
  /// It will take the list of blogs and store them in the local storage.
  @override
  void uploadLocalBlog({required List<BlogModel> blogs}) {
    box.clear();
    box.write(
      () {
        for (int i = 0; i < blogs.length; i++) {
          box.put(
            i.toString(),
            blogs[i].toJson(),
          );
        }
      },
    );
  }

  /// This class is responsible for getting the blogs from the local storage.
  /// It will return the list of blogs.
  @override
  List<BlogModel> getBlogs() {
    List<BlogModel> blogs = [];
    box.read(
      () {
        for (int i = 0; i < box.length; i++) {
          blogs.add(
            BlogModel.fromJson(
              box.get(
                i.toString(),
              ),
            ),
          );
        }
      },
    );
    return blogs;
  }
}
