import 'package:civilshots/features/blog/presentation/widgets/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:civilshots/core/themes/app_color_pallete.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Add this import

class AddNewBlogScreen extends StatefulWidget {
  const AddNewBlogScreen({super.key});

  @override
  State<AddNewBlogScreen> createState() => _AddNewBlogScreenState();
}

class _AddNewBlogScreenState extends State<AddNewBlogScreen>
    with SingleTickerProviderStateMixin {
  late quill.QuillController _controller;
  late FocusNode _editorFocusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _hideToolbars = false;
  bool _distractionFreeMode = false;
  String _blogTitle = 'Untitled Story';
  final FocusNode _titleFocusNode = FocusNode();
  final TextEditingController _titleController =
      TextEditingController(text: 'Untitled Story');
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    _editorFocusNode = FocusNode();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Listen to text changes
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    // Auto-hide toolbars when user starts typing for a distraction-free experience
    if (_controller.document.length > 1 && !_hideToolbars) {
      setState(() {
        _hideToolbars = true;
      });
    }
  }

  /// Picks an image from gallery or camera and inserts it into the editor
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        // Insert image to editor
        final file = File(pickedFile.path);
        final imageBytes = await file.readAsBytes();
        final imageUrl = pickedFile.path;

        // Insert image to document
        final index = _controller.selection.baseOffset;
        final length = _controller.selection.extentOffset - index;

        _controller.replaceText(
          index,
          length,
          quill.BlockEmbed.image(imageUrl),
          null,
        );

        // Insert a new line after image
        _controller.replaceText(
          index + 1,
          0,
          '\n',
          null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image added successfully'),
            backgroundColor: AppPallete.gradient2.withOpacity(0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add image: ${e.toString()}'),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Shows an image source dialog
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPallete.backgroundColor,
        title: Text(
          'Choose image source',
          style: TextStyle(color: AppPallete.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppPallete.gradient1),
              title: Text('Gallery',
                  style: TextStyle(color: AppPallete.textWhite)),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppPallete.gradient1),
              title:
                  Text('Camera', style: TextStyle(color: AppPallete.textWhite)),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles full-screen immersive mode by hiding system overlays.
  void _toggleImmersiveMode() {
    if (_distractionFreeMode) {
      // Return to normal
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      _animationController.reverse();
    } else {
      // Hide system UI for distraction-free
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _animationController.forward();
    }
    setState(() {
      _distractionFreeMode = !_distractionFreeMode;
    });
  }

  void _toggleToolbars() {
    setState(() => _hideToolbars = !_hideToolbars);
    if (_hideToolbars) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Animated top app bar
            AnimatedSizeAndFade(
              isVisible: !_distractionFreeMode && !_hideToolbars,
              child: _buildTopAppBar(context),
            ),

            // Enhanced Title input (Medium-like)
            AnimatedSizeAndFade(
              isVisible: !_distractionFreeMode,
              child: _buildTitleInput(),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_editorFocusNode.hasFocus) {
                    _editorFocusNode.requestFocus();
                  } else {
                    _toggleToolbars();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: QuillEditor(
                    controller: _controller,
                    focusNode: _editorFocusNode,
                    scrollController: ScrollController(),
                    config: quill.QuillEditorConfig(
                      scrollable: true,
                      autoFocus: false,
                      expands: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      placeholder: 'Tell your story...',
                      customStyles: DefaultStyles(
                        h1: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: AppPallete.textWhite,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(24, 14),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h2: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: AppPallete.textWhite,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(18, 12),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h3: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: AppPallete.textWhite,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(14, 10),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        paragraph: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                              fontSize: 22,
                              height: 1.7,
                              color: AppPallete.textWhite),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(12, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        placeHolder: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                            fontSize: 22,
                            height: 1.7,
                            color: AppPallete.textWhite.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(12, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        lists: DefaultListBlockStyle(
                          GoogleFonts.notoSerif(
                              fontSize: 22,
                              height: 1.7,
                              color: AppPallete.textWhite),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          null,
                          null,
                        ),
                        quote: DefaultTextBlockStyle(
                          GoogleFonts.notoSerif(
                            fontSize: 22,
                            height: 1.7,
                            color: AppPallete.textWhite.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          const HorizontalSpacing(16, 8),
                          const VerticalSpacing(16, 16),
                          const VerticalSpacing(0, 0),
                          BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppPallete.gradient1,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                        // Add custom image styles
                      ),
                      embedBuilders: [
                        // Custom image renderer
                        _CustomImageEmbedBuilder(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Enhanced formatted toolbar with headlines & image options
            AnimatedSizeAndFade(
              isVisible: !_distractionFreeMode && !_hideToolbars,
              child: _buildQuillToolbar(),
            ),
          ],
        ),
      ),
      // Floating button to show toolbar when hidden
      floatingActionButton: _hideToolbars || _distractionFreeMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppPallete.backgroundColor.withOpacity(0.8),
              onPressed: _toggleToolbars,
              child: Icon(
                Icons.format_paint_outlined,
                color: AppPallete.gradient2,
              ),
            )
          : null,
    );
  }

  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        onChanged: (value) {
          setState(() {
            _blogTitle = value;
          });
        },
        style: GoogleFonts.notoSerif(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppPallete.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'Your story title',
          hintStyle: GoogleFonts.notoSerif(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppPallete.textWhite.withOpacity(0.5),
          ),
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppPallete.backgroundColor,
      automaticallyImplyLeading: false,
      title: Text(
        'Write your story',
        style: GoogleFonts.notoSans(
          color: AppPallete.textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      actions: [
        // Add image button
        IconButton(
          icon: Icon(Icons.add_photo_alternate_outlined,
              color: AppPallete.borderColor),
          onPressed: _showImageSourceDialog,
          tooltip: 'Add image',
        ),
        IconButton(
          icon: Icon(
            _distractionFreeMode ? Icons.fullscreen_exit : Icons.fullscreen,
            color: AppPallete.borderColor,
          ),
          onPressed: _toggleImmersiveMode,
          tooltip: 'Distraction-free mode',
        ),
        IconButton(
          icon: Icon(Icons.save_outlined, color: AppPallete.borderColor),
          onPressed: () {
            // Save post logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saving draft...'),
                backgroundColor: AppPallete.gradient2.withOpacity(0.8),
              ),
            );
          },
          tooltip: 'Save draft',
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppPallete.borderColor),
          onPressed: () {
            // Show dialog to confirm exit if there are changes
            if (_controller.document.length > 1) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppPallete.backgroundColor,
                  title: Text('Discard changes?',
                      style: TextStyle(color: AppPallete.textWhite)),
                  content: Text('Your story will be lost if not saved.',
                      style: TextStyle(color: AppPallete.textWhite)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: AppPallete.gradient2)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Discard',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          tooltip: 'Close editor',
        ),
      ],
    );
  }

  Widget _buildQuillToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.backgroundColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: AppPallete.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Custom formatting bar for headlines
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFormatButton(
                    text: 'H1',
                    onPressed: () => _applyHeadingStyle(1),
                    tooltip: 'Heading 1',
                    isActive: _checkIfSelectionHasHeading(1),
                  ),
                  _buildFormatButton(
                    text: 'H2',
                    onPressed: () => _applyHeadingStyle(2),
                    tooltip: 'Heading 2',
                    isActive: _checkIfSelectionHasHeading(2),
                  ),
                  _buildFormatButton(
                    text: 'H3',
                    onPressed: () => _applyHeadingStyle(3),
                    tooltip: 'Heading 3',
                    isActive: _checkIfSelectionHasHeading(3),
                  ),
                  VerticalDivider(
                      color: AppPallete.borderColor,
                      width: 16,
                      indent: 8,
                      endIndent: 8),
                  _buildFormatButton(
                    text: 'Image',
                    icon: Icons.image,
                    onPressed: _showImageSourceDialog,
                    tooltip: 'Insert image',
                  ),
                  _buildFormatButton(
                    text: 'Quote',
                    icon: Icons.format_quote,
                    onPressed: () {
                      final selectionStyle = _controller.getSelectionStyle();
                      final isQuote =
                          selectionStyle.attributes['blockquote'] != null;
                      _controller.formatSelection(quill.Attribute(
                        'blockquote',
                        AttributeScope.block,
                        isQuote ? null : true,
                      ));
                    },
                    tooltip: 'Quote',
                    isActive: _controller
                            .getSelectionStyle()
                            .attributes['blockquote'] !=
                        null,
                  ),
                ],
              ),
            ),
          ),
          // Standard Quill toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.bold,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_bold),
                ),
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.italic,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_italic),
                ),
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.underline,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_underline),
                ),
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.strikeThrough,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_strikethrough),
                ),
                VerticalDivider(
                    color: AppPallete.borderColor,
                    width: 16,
                    indent: 8,
                    endIndent: 8),
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.ol,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_list_numbered),
                ),
                QuillToolbarToggleStyleButton(
                  attribute: quill.Attribute.ul,
                  controller: _controller,
                  options: const QuillToolbarToggleStyleButtonOptions(
                      iconData: Icons.format_list_bulleted),
                ),
                QuillToolbarToggleCheckListButton(
                  controller: _controller,
                ),
                VerticalDivider(
                    color: AppPallete.borderColor,
                    width: 16,
                    indent: 8,
                    endIndent: 8),
                QuillToolbarLinkStyleButton(
                  controller: _controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build format buttons
  Widget _buildFormatButton({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppPallete.gradient1.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      isActive ? AppPallete.gradient1 : AppPallete.borderColor,
                  width: 1,
                ),
              ),
              child: icon != null
                  ? Icon(
                      icon,
                      size: 20,
                      color: isActive
                          ? AppPallete.gradient1
                          : AppPallete.borderColor,
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: isActive
                            ? AppPallete.gradient1
                            : AppPallete.borderColor,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to check if selection has heading style
  bool _checkIfSelectionHasHeading(int level) {
    final attributes = _controller.getSelectionStyle().attributes;
    return attributes['heading'] != null &&
        attributes['heading']?.value == level;
  }

  // Apply heading style
  void _applyHeadingStyle(int level) {
    final selectionStyle = _controller.getSelectionStyle();
    final currentHeading = selectionStyle.attributes['header'];

    if (currentHeading != null && currentHeading.value == level) {
      // If the same heading is already applied, remove it
      _controller
          .formatSelection(quill.Attribute.clone(quill.Attribute.header, null));
    } else {
      // Apply the heading style
      _controller.formatSelection(quill.Attribute.header);
    }
  }
}

// Custom image embed builder for better UI
class _CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final node = embedContext.node;
    final controller = embedContext.controller;
    final readOnly = embedContext.readOnly;
    final imageUrl = node.value.data;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Image with error handling
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Center(
                child: Image.file(
                  File(imageUrl),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade800,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported,
                              color: Colors.white70, size: 40),
                          SizedBox(height: 8),
                          Text('Could not load image',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Edit overlay (only visible in edit mode)
            if (!readOnly)
              Positioned(
                top: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    color: Colors.black54,
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              Icon(Icons.delete, color: Colors.white, size: 20),
                          onPressed: () {
                            final offset = controller.selection.baseOffset;
                            final length =
                                controller.selection.extentOffset - offset;
                            controller.replaceText(offset, length, '', null);
                          },
                          tooltip: 'Remove image',
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
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

// Custom animation widget for smooth transitions