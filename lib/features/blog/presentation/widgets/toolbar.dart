// editor_toolbar.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:super_editor/super_editor.dart';

class EditorToolbar extends StatefulWidget {
  const EditorToolbar({
    super.key,
    required this.anchor,
    required this.viewportKey,
    required this.boundary,
    required this.composer,
    required this.editor,
    required this.document,
  });

  final LeaderLink anchor;                 // leader from SelectionLayerLinks
  final GlobalKey viewportKey;             // editor viewport
  final FollowerBoundary boundary;         // keeps toolbar inside viewport
  final DocumentComposer composer;
  final Editor           editor;
  final Document         document;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  late final FollowerAligner _aligner;     // decides “above or below?”

  @override
  void initState() {
    super.initState();
    _aligner = CupertinoPopoverToolbarAligner(widget.viewportKey);
  }

  // ───────── selection helpers ─────────
  bool get _validSelection {
    final s = widget.composer.selection;
    return s != null && s.base.nodeId == s.extent.nodeId && !s.isCollapsed;
  }

  ParagraphNode? get _para =>
      _validSelection ? widget.document.getNodeById(
        widget.composer.selection!.extent.nodeId,
      ) as ParagraphNode? : null;

  ListItemNode? get _list => _validSelection
      ? widget.document.getNodeById(widget.composer.selection!.extent.nodeId)
          as ListItemNode? : null;

  void _toggleAttrib(Set<Attribution> attrs) => widget.editor.execute([
        ToggleTextAttributionsRequest(
          documentRange: widget.composer.selection!,
          attributions: attrs,
        ),
      ]);

  void _toggleBlockType(_TextType t) {
    if (!_validSelection) return;
    final id     = widget.composer.selection!.extent.nodeId;
    final isList = t == _TextType.ol || t == _TextType.ul;

    if (isList && _list == null) {
      widget.editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: id,
          type: t == _TextType.ol ? ListItemType.ordered : ListItemType.unordered,
        ),
      ]);
    } else if (!isList && _list != null) {
      widget.editor.execute([
        ConvertListItemToParagraphRequest(nodeId: id, paragraphMetadata: {
          'blockType': t == _TextType.h1 ? header1Attribution : null,
        }),
      ]);
    } else {
      widget.editor.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: id,
          blockType: t == _TextType.h1 ? header1Attribution : null,
        ),
      ]);
    }
  }

  void _toggleAlign(TextAlign a) {
    final p = _para;
    if (p == null) return;
    widget.editor.execute([
      ChangeParagraphAlignmentRequest(nodeId: p.id, alignment: a),
    ]);
  }

  void _toggleLink() {
    if (!_validSelection) return;
    final sel      = widget.composer.selection!;
    final textNode = widget.document.getNodeById(sel.extent.nodeId) as TextNode;

    final start = (sel.base.nodePosition   as TextPosition).offset;
    final end   = (sel.extent.nodePosition as TextPosition).offset;
    final range = SpanRange(min(start, end), max(start, end) - 1);

    final links = textNode.text.getAttributionSpansInRange(
      range: range,
      attributionFilter: (a) => a is LinkAttribution,
    );

    if (links.isEmpty) {
      widget.editor.execute([
        AddTextAttributionsRequest(
          documentRange: sel,
          attributions: {LinkAttribution.fromUri(Uri.parse('https://example.com'))},
        ),
      ]);
    } else {
      for (final span in links) {
        textNode.text.removeAttribution(span.attribution, span.range);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Follower.withAligner(
      link: widget.anchor,
      aligner: _aligner,
      boundary: widget.boundary,
      showWhenUnlinked: false,
      child: Material(
        elevation: 4,
        shape: const StadiumBorder(),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: 38,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _btn(Icons.format_bold,        () => _toggleAttrib({boldAttribution})),
            _btn(Icons.format_italic,      () => _toggleAttrib({italicsAttribution})),
            _btn(Icons.format_underline,   () => _toggleAttrib({underlineAttribution})),
            _btn(Icons.strikethrough_s,    () => _toggleAttrib({strikethroughAttribution})),
            _div(),
            _btn(Icons.title,              () => _toggleBlockType(_TextType.h1)),
            _btn(Icons.notes,              () => _toggleBlockType(_TextType.p)),
            _div(),
            _btn(Icons.format_list_numbered,() => _toggleBlockType(_TextType.ol)),
            _btn(Icons.format_list_bulleted,() => _toggleBlockType(_TextType.ul)),
            _div(),
            _btn(Icons.format_align_left,  () => _toggleAlign(TextAlign.left)),
            _btn(Icons.format_align_center,() => _toggleAlign(TextAlign.center)),
            _btn(Icons.format_align_right, () => _toggleAlign(TextAlign.right)),
            _div(),
            _btn(Icons.link,               _toggleLink),
          ]),
        ),
      ),
    );
  }

  IconButton _btn(IconData icon, VoidCallback cb) =>
      IconButton(icon: Icon(icon, size: 18), splashRadius: 18, padding: EdgeInsets.zero, onPressed: cb);
  Container  _div() => Container(width: 1, height: 24, color: Colors.grey.shade300);
}

enum _TextType { h1, p, ol, ul }
