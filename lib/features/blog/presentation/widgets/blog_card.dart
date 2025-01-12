import 'package:flutter/material.dart';
import 'package:civilshots/core/utils/calculate_reading_time.dart';
import 'package:civilshots/features/blog/domain/entities/blog.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final Color color;
  const BlogCard({super.key, required this.blog, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(12).copyWith(bottom: 4),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16,
                  children: blog.topics
                      .map(
                        (e) => Chip(
                          label: Text(e),
                        ),
                      )
                      .toList(),
                ),
              ),
              Text(
                blog.title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${calCulateReadingTime(blog.content)} min',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                blog.userName ?? 'Anonymous',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
