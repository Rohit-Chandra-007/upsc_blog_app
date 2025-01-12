import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:civilshots/core/common/widgets/loader.dart';
import 'package:civilshots/core/routes/route_name.dart';
import 'package:civilshots/core/themes/app_color_pallete.dart';
import 'package:civilshots/core/utils/show_snackbar.dart';
import 'package:civilshots/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:civilshots/features/blog/presentation/widgets/blog_card.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all blog posts
    context.read<BlogBloc>().add(const BlogFetchAllEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPSC Blog'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to Add New Blog Screen
              context.pushNamed(RouteNames.addNewBlog);
            },
            icon: const Icon(
              CupertinoIcons.add_circled,
            ),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackbar(context, 'Failed to fetch blog posts');
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is BlogFetchAllSuccess) {
            return ListView.builder(
              itemCount:
                  state.blogs.length, // Replace with actual blog posts count
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to Blog Reader Screen
                    context.pushNamed(RouteNames.blogReader,
                        extra: state.blogs[index]);
                  },
                  child: BlogCard(
                    blog: state.blogs[index],
                    color: index % 3 == 0
                        ? AppPallete.gradient2
                        : index % 3 == 1
                            ? AppPallete.gradient3
                            : AppPallete.gradient1,
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
