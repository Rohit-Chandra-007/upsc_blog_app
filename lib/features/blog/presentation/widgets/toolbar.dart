import 'dart:math';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:super_editor/super_editor.dart';

/// A light-weight floating toolbar for `SuperEditor`.
///
/// Put this widget in an [Overlay] or any [Stack].  Attach its [anchor] to
/// the current document selection rectangle (see example call below).
///
/// ```dart
/// OverlayEntry _toolbarEntry() => OverlayEntry(
///   builder: (_) => SimpleEditorToolbar(
///     anchor: mySelectionLink,
///     composer: myComposer,
///     editor: myEditor,
///     document: myDocument,
///   ),
/// );
/// ```
class EditorToolbar extends StatefulWidget {
  const EditorToolbar({
    super.key,
    required this.anchor,
    required this.composer,
    required this.editor,
    required this.document,
  });

  /// Where the toolbar should hover.
  final LeaderLink anchor;

  final DocumentComposer composer;
  final Editor editor;
  final Document document;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  late final FollowerAligner _toolbarAligner;
  final GlobalKey _viewportKey = GlobalKey();

  // ─────────────────────────────────────────── Formatting helpers ──────────── //
  bool get _validSelection {
    final sel = widget.composer.selection;
    return sel != null && sel.base.nodeId == sel.extent.nodeId;
  }

  ParagraphNode? get _selectedParagraph {
    if (!_validSelection) return null;
    final node = widget.document.getNodeById(widget.composer.selection!.extent.nodeId);
    return node is ParagraphNode ? node : null;
  }

  ListItemNode? get _selectedList => _validSelection
      ? widget.document.getNodeById(widget.composer.selection!.extent.nodeId) as ListItemNode?
      : null;

  void _toggleAttrib(Set<Attribution> attrs) {
    widget.editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: widget.composer.selection!,
        attributions: attrs,
      ),
    ]);
  }

  void _toggleBlockType(_TextType target) {
    if (!_validSelection) return;
    final isList = target == _TextType.orderedList || target == _TextType.unorderedList;

    if (isList && _selectedList == null) {
      // paragraph → list
      widget.editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: widget.composer.selection!.extent.nodeId,
          type: target == _TextType.orderedList ? ListItemType.ordered : ListItemType.unordered,
        ),
      ]);
    } else if (!isList && _selectedList != null) {
      // list → paragraph
      widget.editor.execute([
        ConvertListItemToParagraphRequest(
          nodeId: widget.composer.selection!.extent.nodeId,
          paragraphMetadata: {
            'blockType': target == _TextType.header1 ? header1Attribution : null,
          },
        ),
      ]);
    } else {
      // paragraph ↔ header
      widget.editor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: widget.composer.selection!.extent.nodeId,
          blockType: target == _TextType.header1 ? header1Attribution : null,
        ),
      ]);
    }
  }

  void _toggleAlignment(TextAlign align) {
    final para = _selectedParagraph;
    if (para == null) return;

    widget.editor.execute([
      ChangeParagraphAlignmentRequest(
        nodeId: para.id,
        alignment: align,
      ),
    ]);
  }

  void _toggleLink() {
    if (!_validSelection) return;
    final textNode = widget.document.getNodeById(widget.composer.selection!.extent.nodeId) as TextNode;
    final sel = widget.composer.selection!;
    final start = (sel.base.nodePosition as TextPosition).offset;
    final end = (sel.extent.nodePosition as TextPosition).offset;
    final range = SpanRange(min(start, end), max(start, end) - 1);

    final spans = textNode.text.getAttributionSpansInRange(
      range: range,
      attributionFilter: (a) => a is LinkAttribution,
    );

    if (spans.isEmpty) {
      // add link
      widget.editor.execute([
        AddTextAttributionsRequest(
          documentRange: sel,
          attributions: {LinkAttribution.fromUri(Uri.parse('https://example.com'))},
        ),
      ]);
    } else {
      // remove link(s)
      for (final span in spans) {
        textNode.text.removeAttribution(span.attribution, span.range);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Place the toolbar above the content by default.
    _toolbarAligner = CupertinoPopoverToolbarAligner(_viewportKey);
  }
  // ──────────────────────────────────────────────────────────────── UI ───── //
  @override
  Widget build(BuildContext context) {
    return Follower.withAligner(
      link: widget.anchor,
      showWhenUnlinked: false,
      aligner: _toolbarAligner,
      child: Material(
        elevation: 4,
        shape: const StadiumBorder(),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _icon(Icons.format_bold, () => _toggleAttrib({boldAttribution})),
              _icon(Icons.format_italic, () => _toggleAttrib({italicsAttribution})),
              _icon(Icons.format_underline, () => _toggleAttrib({underlineAttribution})),
              _icon(Icons.strikethrough_s, () => _toggleAttrib({strikethroughAttribution})),
              _divider(),
              _icon(Icons.title, () => _toggleBlockType(_TextType.header1)),
              _icon(Icons.notes, () => _toggleBlockType(_TextType.paragraph)),
              _divider(),
              _icon(Icons.format_list_numbered, () => _toggleBlockType(_TextType.orderedList)),
              _icon(Icons.format_list_bulleted, () => _toggleBlockType(_TextType.unorderedList)),
              _divider(),
              _icon(Icons.format_align_left, () => _toggleAlignment(TextAlign.left)),
              _icon(Icons.format_align_center, () => _toggleAlignment(TextAlign.center)),
              _icon(Icons.format_align_right, () => _toggleAlignment(TextAlign.right)),
              _divider(),
              _icon(Icons.link, _toggleLink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, size: 18),
        splashRadius: 18,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      );

  Widget _divider() => Container(width: 1, height: 24, color: Colors.grey.shade300);
}

enum _TextType { header1, paragraph, orderedList, unorderedList }
