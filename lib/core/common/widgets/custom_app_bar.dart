import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:civilshots/core/routes/route_name.dart';

class CustomAppBar extends StatelessWidget {
  
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withAlpha(230),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.goNamed(RouteNames.blog),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
