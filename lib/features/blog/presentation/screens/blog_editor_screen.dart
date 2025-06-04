import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// Blog editor screen built with `super_editor`.
///
/// This screen exposes a modern rich text editor with a floating
/// formatting toolbar. The entire app uses a dark theme so the
/// editor follows the same style.
class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;
  late final CommonEditorOperations _ops;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<DocumentLayoutState> _layoutKey = GlobalKey();
  final SelectionLayerLinks _layerLinks = SelectionLayerLinks();
  final OverlayPortalController _toolbarController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _document = MutableDocument(nodes: [
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText('Start writing...'),
      ),
    ]);
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(document: _document, composer: _composer);
    _ops = CommonEditorOperations(
      editor: _editor,
      document: _document,
      composer: _composer,
      documentLayoutResolver: () => _layoutKey.currentState as DocumentLayout,
    );
    _composer.selectionNotifier.addListener(_updateToolbarVisibility);
  }

  @override
  void dispose() {
    _composer.selectionNotifier.removeListener(_updateToolbarVisibility);
    _focusNode.dispose();
    _scrollController.dispose();
    _composer.dispose();
    super.dispose();
  }

  void _updateToolbarVisibility() {
    final selection = _composer.selection;
    if (selection == null || selection.isCollapsed ||
        selection.base.nodeId != selection.extent.nodeId) {
      _toolbarController.hide();
    } else {
      _toolbarController.show();
    }
  }

  void _cut() => _ops.cut();
  void _copy() => _ops.copy();
  void _paste() => _ops.paste();
  void _selectAll() => _ops.selectAll();

  DocumentGestureMode get _gestureMode {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DocumentGestureMode.android;
      case TargetPlatform.iOS:
        return DocumentGestureMode.iOS;
      default:
        return DocumentGestureMode.mouse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Blog')),
      body: OverlayPortal(
        controller: _toolbarController,
        overlayChildBuilder: (_) => EditorToolbar(
          editorViewportKey: _layoutKey,
          anchor: _layerLinks.expandedSelectionBoundsLink,
          editorFocusNode: _focusNode,
          editor: _editor,
          document: _document,
          composer: _composer,
          closeToolbar: _toolbarController.hide,
        ),
        child: _buildEditor(context),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return SuperEditor(
      editor: _editor,
      focusNode: _focusNode,
      scrollController: _scrollController,
      documentLayoutKey: _layoutKey,
      selectionLayerLinks: _layerLinks,
      gestureMode: _gestureMode,
      inputSource: TextInputSource.ime,
      androidToolbarBuilder: (_) => AndroidTextEditingFloatingToolbar(
        onCutPressed: _cut,
        onCopyPressed: _copy,
        onPastePressed: _paste,
        onSelectAllPressed: _selectAll,
      ),
    );
  }
}
