import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsc_blog_app/core/routes/route_name.dart';
import 'package:upsc_blog_app/core/themes/app_color_pallete.dart';
import 'package:upsc_blog_app/core/utils/pick_image.dart';
import 'package:upsc_blog_app/features/blog/presentation/widgets/blog_editor.dart';

class AddNewBlogScreen extends StatefulWidget {
  const AddNewBlogScreen({super.key});

  @override
  State<AddNewBlogScreen> createState() => _AddNewBlogScreenState();
}

class _AddNewBlogScreenState extends State<AddNewBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<String> selectedCategories = [];
  File? image;

  void selectImage(File? image) async {
    final pickedImage = await pickImageFromGallery();
    if (pickedImage != null) {
      setState(() {
        this.image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Blog'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            context.goNamed(RouteNames.blog);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to Blog Screen
              context.goNamed(RouteNames.blog);
            },
            icon: const Icon(
              Icons.done_rounded,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    selectImage(image);
                  },
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : DottedBorder(
                          color: AppPallete.borderColor,
                          strokeWidth: 2,
                          borderType: BorderType.RRect,
                          strokeCap: StrokeCap.round,
                          radius: const Radius.circular(12),
                          padding: const EdgeInsets.all(6),
                          dashPattern: const [12, 4],
                          child: const SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: Center(
                              child: Column(
                                spacing: 15,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 40,
                                  ),
                                  Text('Select Your Image'),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 16,
                    children: [
                      'General Studies 1',
                      'General Studies 2',
                      'General Studies 3',
                      'General Studies 4',
                    ]
                        .map(
                          (e) => GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedCategories.contains(e)) {
                                  selectedCategories.remove(e);
                                } else {
                                  selectedCategories.add(e);
                                }
                              });
                            },
                            child: Chip(
                              label: Text(e),
                              backgroundColor: selectedCategories.contains(e)
                                  ? AppPallete.gradient1
                                  : null,
                              side: !selectedCategories.contains(e)
                                  ? const BorderSide(
                                      color: AppPallete.borderColor,
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                BlogEditor(
                  // Update the content
                  initialText: 'Blog Title',
                  controller: _titleController,
                ),
                const SizedBox(height: 16),
                BlogEditor(
                  // Update the content
                  controller: _contentController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
