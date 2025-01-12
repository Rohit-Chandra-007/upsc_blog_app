import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:upsc_blog_app/core/themes/app_color_pallete.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.twistingDots(
        leftDotColor: AppPallete.gradient1,
        rightDotColor: AppPallete.gradient2,
        size: 200,
      ),
    );
  }
}
