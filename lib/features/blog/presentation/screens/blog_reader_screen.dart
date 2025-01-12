import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:civilshots/core/routes/route_name.dart';
import 'package:civilshots/core/utils/calculate_reading_time.dart';
import 'package:civilshots/core/utils/datatime_converter.dart';

import 'package:civilshots/features/blog/domain/entities/blog.dart';

class BlogReaderScreen extends StatelessWidget {
  final Blog blog;
  const BlogReaderScreen({super.key, required this.blog});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Reader'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: blog.topics
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(tag),
                                  ))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          blog.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Author Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[800],
                                  radius: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  blog.userName ?? 'Anonymous',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatDateTime(blog.createdAt),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${calCulateReadingTime(blog.content)} min read',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            blog.imageUrl,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Content
                        Text(
                          blog.content,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Notes Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes and Highlights',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[700]!,
                                    style: BorderStyle.solid,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add your notes here...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Navigation
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[800]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: const Text('Previous Article'),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Next Article'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
