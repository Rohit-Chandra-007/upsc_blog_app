import 'package:flutter/material.dart';

class BlogEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? initialText;
  const BlogEditor({super.key, required this.controller, this.initialText});

  @override
  State<BlogEditor> createState() => _BlogEditorState();
}

class _BlogEditorState extends State<BlogEditor> {
  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      widget.controller.text = widget.initialText!;
    }
  }

  // Wrap the selected text with the given syntax.
  // If nothing is selected, insert a placeholder and select it.
  void _wrapSelection(String leftWrapper, [String? rightWrapper]) {
    rightWrapper ??= leftWrapper;
    final selection = widget.controller.selection;
    final text = widget.controller.text;

    if (!selection.isValid) return;

    String selectedText = selection.textInside(text);
    int newSelectionStart = selection.start + leftWrapper.length;
    if (selectedText.isEmpty) {
      // Insert a placeholder text if nothing was selected.
      selectedText = 'text';
    }
    final newText =
        '${selection.textBefore(text)}$leftWrapper$selectedText$rightWrapper${selection.textAfter(text)}';
    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection(
        baseOffset: newSelectionStart,
        extentOffset: newSelectionStart + selectedText.length,
      ),
    );
  }

  // Insert markdown syntax at the beginning of the current line.
  void _insertAtLineStart(String textToInsert) {
    final selection = widget.controller.selection;
    final text = widget.controller.text;
    if (!selection.isValid) return;
    // Find the beginning of the current line. If there's no newline found, lineStart will be 0.
    final lineStart = text.lastIndexOf('\n', selection.start - 1) + 1;
    final newText = text.replaceRange(lineStart, lineStart, textToInsert);
    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + textToInsert.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formatting toolbar
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              tooltip: 'Bold',
              onPressed: () => _wrapSelection('**'),
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              tooltip: 'Italic',
              onPressed: () => _wrapSelection('_'),
            ),
            IconButton(
              icon: const Icon(Icons.title),
              tooltip: 'Headline',
              onPressed: () => _insertAtLineStart('# '),
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: 'Bullet List',
              onPressed: () => _insertAtLineStart('- '),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Write your blog content here...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
