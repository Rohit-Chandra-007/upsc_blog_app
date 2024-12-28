import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController controller;
  final String? initialText;

  const BlogEditor({
    super.key,
    this.initialText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: initialText ?? 'Write your blog post here...',
        border: InputBorder.none,
      ),
    );
  }
}
