import 'package:civilshots/core/constant/constant.dart';
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

class _BlogScreenState extends State<BlogScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    context.read<BlogBloc>().add(const BlogFetchAllEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBlogList(List<dynamic> blogs) {
    return ListView.builder(
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.pushNamed(RouteNames.blogReader, extra: blogs[index]);
          },
          child: BlogCard(
            blog: blogs[index],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constant.appName),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouteNames.addNewBlog);
            },
            icon: const Icon(CupertinoIcons.add_circled),
          ),
        ],
        bottom: TabBar(
          physics: const BouncingScrollPhysics(),
          isScrollable: true,
          controller: _tabController,
          tabs: Constant.tabBarName.map((e) {
            return Tab(
              text: e,
            );
          }).toList(),
        ),
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
            return TabBarView(
              controller: _tabController,
              children: [
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
                _buildBlogList(state.blogs),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
