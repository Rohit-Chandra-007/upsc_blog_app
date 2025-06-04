import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
// Placeholder for markdown plugin if you use it directly for serialization/deserialization
// import 'package:super_editor_markdown/super_editor_markdown.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
// Note: 'overlord' might be a dependency of follow_the_leader or a specific example utility.
// If you encounter issues, check the super_editor example project for 'CupertinoPopoverToolbarAligner'.
// For simplicity, I'll use a more basic aligner if that specific one isn't directly available.

//--- INITIAL DOCUMENT ---
MutableDocument createInitialBlogDocument() {
  return MutableDocument(
    nodes: [
      ImageNode(
        id: "initial_image_1",
        imageUrl:
            'https://i.ibb.co/5nvRdx1/flutter-horizon.png', // Replace with placeholder or actual image logic
        expectedBitmapSize: const ExpectedSize(1911, 630),
        metadata: const SingleColumnLayoutComponentStyles(
          width: double.infinity,
          padding: EdgeInsets.zero,
        ).toMetadata(),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('Welcome to Your Blog Editor!'),
        metadata: {
          'blockType': header1Attribution,
        },
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(
          "Start writing your amazing blog post here. You can format text, add images, and more.",
        ),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText('Content Ideas'),
        metadata: {
          'blockType': header2Attribution,
        },
      ),
      ListItemNode.unordered(
        id: Editor.createNodeId(),
        text: AttributedText(
          'Introduce your topic.',
        ),
      ),
      ListItemNode.unordered(
        id: Editor.createNodeId(),
        text: AttributedText(
          'Share key insights and details.',
        ),
      ),
      TaskNode(
        id: Editor.createNodeId(),
        isComplete: false,
        text: AttributedText(
          'Add a concluding paragraph.',
        ),
      ),
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(
          "Happy writing!",
        ),
      ),
    ],
  );
}

//--- EDITOR SCREEN ---
class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _docLayoutKey = GlobalKey();

  late MutableDocument _doc;
  final _docChangeSignal = SignalNotifier();
  late MutableDocumentComposer _composer;
  late Editor _docEditor;
  late CommonEditorOperations _docOps;

  late FocusNode _editorFocusNode;
  late ScrollController _scrollController;

  final SelectionLayerLinks _selectionLayerLinks = SelectionLayerLinks();

  final _darkBackground = const Color(0xFF222222);
  final _lightBackground = Colors.white;
  final _brightness = ValueNotifier<Brightness>(Brightness.light);

  SuperEditorDebugVisualsConfig? _debugConfig;

  final _textFormatBarOverlayController = OverlayPortalController();
  final _imageFormatBarOverlayController = OverlayPortalController();

  final MagnifierAndToolbarController _overlayController =
      MagnifierAndToolbarController()
        ..screenPadding = const EdgeInsets.all(20.0);

  late final SuperEditorIosControlsController _iosControlsController;

  @override
  void initState() {
    super.initState();
    _doc = createInitialBlogDocument()..addListener(_onDocumentChange);
    _composer = MutableDocumentComposer();
    _composer.selectionNotifier.addListener(_hideOrShowToolbar);
    _docEditor = createDefaultDocumentEditor(
        document: _doc, composer: _composer, isHistoryEnabled: true);
    _docOps = CommonEditorOperations(
      editor: _docEditor,
      document: _doc,
      composer: _composer,
      documentLayoutResolver: () =>
          _docLayoutKey.currentState as DocumentLayout,
    );
    _editorFocusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_hideOrShowToolbar);
    _iosControlsController = SuperEditorIosControlsController();

    // TODO: Implement loading document content if editing an existing blog post
    // For example:
    // loadDocumentContent().then((loadedDoc) {
    //   if (loadedDoc != null) {
    //     setState(() {
    //       _doc.removeListener(_onDocumentChange);
    //       _doc = loadedDoc;
    //       _doc.addListener(_onDocumentChange);
    //       _docEditor = createDefaultDocumentEditor(document: _doc, composer: _composer);
    //       _docOps = CommonEditorOperations(editor: _docEditor, document: _doc, composer: _composer, documentLayoutResolver: () => _docLayoutKey.currentState as DocumentLayout);
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _iosControlsController.dispose();
    _scrollController.dispose();
    _editorFocusNode.dispose();
    _composer.selectionNotifier.removeListener(_hideOrShowToolbar);
    _composer.dispose();
    _doc.removeListener(_onDocumentChange);
    // Consider disposing _doc if it's not managed elsewhere
    super.dispose();
  }

  void _onDocumentChange(_) {
    _hideOrShowToolbar();
    _docChangeSignal.notifyListeners();
    // TODO: Implement auto-save or indicate unsaved changes
  }

  void _hideOrShowToolbar() {
    final selection = _composer.selection;
    if (selection == null ||
        selection.base.nodeId != selection.extent.nodeId ||
        selection.isCollapsed) {
      _hideEditorToolbar();
      _hideImageToolbar();
      return;
    }

    final selectedNode = _doc.getNodeById(selection.extent.nodeId);

    if (selectedNode is ImageNode) {
      print("Showing image toolbar");
      _showImageToolbar();
      _hideEditorToolbar();
    } else if (selectedNode is TextNode) {
      print("Showing text format toolbar");
      _showEditorToolbar();
      _hideImageToolbar();
    } else {
      _hideEditorToolbar();
      _hideImageToolbar();
    }
  }

  void _showEditorToolbar() {
    _textFormatBarOverlayController.show();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted ||
          _docLayoutKey.currentState == null ||
          _composer.selection == null) return;
      final layout = _docLayoutKey.currentState as DocumentLayout;
      final docBoundingBox = layout.getRectForSelection(
          _composer.selection!.base, _composer.selection!.extent);
      if (docBoundingBox == null) return;

      final RenderBox? docRenderBox =
          _docLayoutKey.currentContext?.findRenderObject() as RenderBox?;
      if (docRenderBox == null || !docRenderBox.attached) return;

      final globalOffset = docRenderBox.localToGlobal(Offset.zero);
      final overlayBoundingBox = docBoundingBox.shift(globalOffset);
      _selectionLayerLinks.expandedSelectionBoundsLink.leader?.offset =
          overlayBoundingBox.topCenter;
    });
  }

  void _hideEditorToolbar() {
    _textFormatBarOverlayController.hide();
    // _selectionLayerLinks.expandedSelectionBoundsLink.leader?.offset = null;
    // Instead of assigning null, you may want to assign Offset.zero or skip assignment.
    _selectionLayerLinks.expandedSelectionBoundsLink.leader?.offset =
        Offset.zero;
    if (FocusManager.instance.primaryFocus != FocusManager.instance.rootScope) {
      _editorFocusNode.requestFocus();
    }
  }

  void _showImageToolbar() {
    _imageFormatBarOverlayController.show();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted ||
          _docLayoutKey.currentState == null ||
          _composer.selection == null) return;
      final layout = _docLayoutKey.currentState as DocumentLayout;
      final docBoundingBox = layout.getRectForSelection(
          _composer.selection!.base, _composer.selection!.extent);
      if (docBoundingBox == null) return;

      final RenderBox? docRenderBox =
          _docLayoutKey.currentContext?.findRenderObject() as RenderBox?;
      if (docRenderBox == null || !docRenderBox.attached) return;

      final globalOffset = docRenderBox.localToGlobal(Offset.zero);
      final overlayBoundingBox = docBoundingBox.shift(globalOffset);
      // For ImageFormatToolbar, you might need a different anchor or adjust its internal positioning.
      // This example uses a ValueNotifier; ensure ImageFormatToolbar uses it.
      // _imageSelectionAnchor.value = overlayBoundingBox.center; // Assuming ImageFormatToolbar uses this
      _selectionLayerLinks.expandedSelectionBoundsLink.leader?.offset =
          overlayBoundingBox.center;
    });
  }

  void _hideImageToolbar() {
    _imageFormatBarOverlayController.hide();
    // _imageSelectionAnchor.value = null; // Assuming ImageFormatToolbar uses this
    _selectionLayerLinks.expandedSelectionBoundsLink.leader?.offset =
        Offset.zero;

    if (FocusManager.instance.primaryFocus != FocusManager.instance.rootScope) {
      _editorFocusNode.requestFocus();
    }
  }

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

  bool get _isMobile => _gestureMode != DocumentGestureMode.mouse;

  TextInputSource get _inputSource => TextInputSource.ime;

  void _cut() => _docOps.cut();
  void _copy() => _docOps.copy();
  void _paste() => _docOps.paste();
  void _selectAll() => _docOps.selectAll();

  void _saveDocument() {
    // TODO: Implement document saving
    // 1. Serialize _doc to JSON or Markdown
    //    Example (conceptual for JSON):
    //    String jsonDocument = serializeDocumentToJson(_doc);
    // 2. Send to backend
    //    await myBackend.saveBlogPost(postId, jsonDocument);
    print("Save Document Tapped: Implement serialization and backend call.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Save functionality not yet implemented.")),
    );
  }

  // TODO: Implement Future<MutableDocument?> loadDocumentContent() async { ... }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _brightness,
      builder: (context, brightness, child) {
        return Theme(
          data: ThemeData(brightness: brightness, useMaterial3: true),
          child: child!,
        );
      },
      child: Builder(
        builder: (themedContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Blog Post Editor"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveDocument,
                  tooltip: "Save Document",
                ),
                IconButton(
                  icon: Icon(_brightness.value == Brightness.light
                      ? Icons.dark_mode
                      : Icons.light_mode),
                  onPressed: () {
                    _brightness.value = _brightness.value == Brightness.light
                        ? Brightness.dark
                        : Brightness.light;
                  },
                  tooltip: "Toggle Theme",
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report),
                  onPressed: () {
                    setState(() {
                      _debugConfig = _debugConfig != null
                          ? null
                          : const SuperEditorDebugVisualsConfig(
                              showFocus: true,
                              showImeConnection: true,
                            );
                    });
                  },
                  tooltip: "Toggle Debug Visuals",
                ),
              ],
            ),
            body: OverlayPortal(
              controller: _textFormatBarOverlayController,
              overlayChildBuilder: (context) => EditorToolbar(
                editorViewportKey: _viewportKey,
                anchorLink: _selectionLayerLinks.expandedSelectionBoundsLink,
                editorFocusNode: _editorFocusNode,
                editor: _docEditor,
                document: _doc,
                composer: _composer,
                closeToolbar: _hideEditorToolbar,
              ),
              child: OverlayPortal(
                controller: _imageFormatBarOverlayController,
                overlayChildBuilder: (context) => Container(),
                child: _buildEditor(themedContext),
              ),
            ),
            // Example of a mobile-specific bottom toolbar (optional)
            // bottomNavigationBar: _isMobile ? _buildMountedToolbar() : null,
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final editorBackgroundColor = isLight ? _lightBackground : _darkBackground;

    return ColoredBox(
      color: editorBackgroundColor,
      child: SuperEditorDebugVisuals(
        config: _debugConfig ?? const SuperEditorDebugVisualsConfig(),
        child: KeyedSubtree(
          key: _viewportKey,
          child: SuperEditorIosControlsScope(
            // Or SuperEditorAndroidControlsScope if targeting Android primarily
            controller: _iosControlsController,
            child: SuperEditor(
              editor: _docEditor,
              focusNode: _editorFocusNode,
              scrollController: _scrollController,
              documentLayoutKey: _docLayoutKey,
              documentOverlayBuilders: [
                DefaultCaretOverlayBuilder(
                  caretStyle: CaretStyle(
                      color: isLight ? Colors.black : Colors.redAccent),
                ),
                if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                  SuperEditorIosHandlesDocumentLayerBuilder(),
                  SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
                ],
                if (defaultTargetPlatform == TargetPlatform.android) ...[
                  SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
                  SuperEditorAndroidHandlesDocumentLayerBuilder(),
                ],
              ],
              selectionLayerLinks: _selectionLayerLinks,
              selectionStyle: isLight
                  ? defaultSelectionStyle
                  : SelectionStyles(selectionColor: Colors.red.withAlpha(70)),
              stylesheet: defaultStylesheet.copyWith(
                addRulesAfter: [
                  if (!isLight) ..._darkModeStyles,
                  taskStyles, // From super_editor
                  // Add any custom blog-specific styles here
                ],
              ),
              componentBuilders: [
                TaskComponentBuilder(_docEditor), // From super_editor
                // TODO: Add custom component builder for Tables if you implement them
                ...defaultComponentBuilders, // From super_editor
                // TODO: Add an ImageComponentBuilder that handles image uploads/selection
              ],
              gestureMode: _gestureMode,
              inputSource: _inputSource,
              keyboardActions: _inputSource == TextInputSource.ime
                  ? defaultImeKeyboardActions
                  : defaultKeyboardActions,
              androidToolbarBuilder: (_) => _buildAndroidFloatingToolbar(),
              overlayController: _overlayController,
              // plugins: { // Example of using a Markdown plugin
              //   MarkdownInlineUpstreamSyntaxPlugin(),
              // },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidFloatingToolbar() {
    return Theme(
      // Ensure toolbar matches app theme
      data: Theme.of(context),
      child: AndroidTextEditingFloatingToolbar(
        onCutPressed: _cut,
        onCopyPressed: _copy,
        onPastePressed: _paste,
        onSelectAllPressed: _selectAll,
      ),
    );
  }

  // Optional: A toolbar that mounts at the bottom on mobile, e.g., above keyboard
  // Widget _buildMountedToolbar() {
  //   return MultiListenableBuilder(
  //     listenables: <Listenable>{
  //       _docChangeSignal,
  //       _composer.selectionNotifier,
  //     },
  //     builder: (_) {
  //       if (_composer.selection == null) return const SizedBox();
  //       return KeyboardEditingToolbar( // This is a conceptual name, use/create actual widget
  //         editor: _docEditor,
  //         document: _doc,
  //         composer: _composer,
  //         commonOps: _docOps,
  //       );
  //     },
  //   );
  // }
}

// Styles for dark mode
final _darkModeStyles = [
  StyleRule(
    BlockSelector.all,
    (doc, docNode) =>
        {Styles.textStyle: const TextStyle(color: Color(0xFFDDDDDD))},
  ),
  StyleRule(
    const BlockSelector("header1"),
    (doc, docNode) => {
      Styles.textStyle:
          const TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.bold)
    },
  ),
  StyleRule(
    const BlockSelector("header2"),
    (doc, docNode) => {
      Styles.textStyle:
          const TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.bold)
    },
  ),
  StyleRule(
    const BlockSelector("link"),
    (doc, docNode) => {
      Styles.textStyle: const TextStyle(
          color: Colors.lightBlueAccent, decoration: TextDecoration.underline)
    },
  ),
];

//--- EDITOR TOOLBAR WIDGETS ---
// Note: SuperEditorDemoTextItemSelector and SuperEditorDemoIconItemSelector
// are likely custom widgets from the super_editor example project.
// You'll need to implement these or use alternatives like DropdownButton.
// For this example, I'll include their structure but you might need to adapt.

// Placeholder for SuperEditorDemoTextItem
class SuperEditorDemoTextItem {
  final String id;
  final String label;
  const SuperEditorDemoTextItem({required this.id, required this.label});
}

// Placeholder for SuperEditorDemoIconItem
class SuperEditorDemoIconItem {
  final String id;
  final IconData icon;
  const SuperEditorDemoIconItem({required this.id, required this.icon});
}

// Placeholder for SuperEditorDemoTextItemSelector
class SuperEditorDemoTextItemSelector extends StatelessWidget {
  final SuperEditorDemoTextItem value;
  final List<SuperEditorDemoTextItem> items;
  final Function(SuperEditorDemoTextItem?) onSelected;
  final FocusNode parentFocusNode; // To return focus
  final GlobalKey boundaryKey; // For positioning dropdown

  const SuperEditorDemoTextItemSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.parentFocusNode,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    // Replace with a proper DropdownButton or custom selector
    return TextButton(
      onPressed: () async {
        // Simulate selection for now
        // In a real app, show a dropdown menu
        print("Block type selector pressed. Implement dropdown.");
        // Example: onSelected(items.firstWhere((item) => item.id == "paragraph", orElse: () => items.first));
        parentFocusNode.requestFocus();
      },
      child: Text(value.label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

// Placeholder for SuperEditorDemoIconItemSelector
class SuperEditorDemoIconItemSelector extends StatelessWidget {
  final SuperEditorDemoIconItem value;
  final List<SuperEditorDemoIconItem> items;
  final Function(SuperEditorDemoIconItem?) onSelected;
  final FocusNode parentFocusNode;
  final GlobalKey boundaryKey;

  const SuperEditorDemoIconItemSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.parentFocusNode,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    // Replace with a proper icon button that shows a menu or a series of toggle buttons
    return IconButton(
      icon: Icon(value.icon),
      onPressed: () {
        print("Alignment selector pressed. Implement selection UI.");
        // Example: onSelected(items.firstWhere((item) => item.id == "left", orElse: () => items.first));
        parentFocusNode.requestFocus();
      },
    );
  }
}

class EditorToolbar extends StatefulWidget {
  const EditorToolbar({
    super.key,
    required this.editorViewportKey,
    required this.editorFocusNode,
    required this.editor,
    required this.document,
    required this.composer,
    required this.anchorLink,
    required this.closeToolbar,
  });

  final GlobalKey editorViewportKey;
  final LeaderLink anchorLink;
  final FocusNode editorFocusNode;
  final Editor? editor;
  final Document document;
  final DocumentComposer composer;
  final VoidCallback closeToolbar;

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  // Using a simpler aligner for broader compatibility.
  // Replace with CupertinoPopoverToolbarAligner if you have it from 'overlord' package or examples.
  late final FollowerAligner _toolbarAligner; // Example, might need adjustment

  late FollowerBoundary _screenBoundary;

  bool _showUrlField = false;
  late FocusScopeNode _popoverFocusNode; // For the toolbar itself
  late FocusNode _urlFocusNode;
  ImeAttributedTextEditingController? _urlController;

  @override
  void initState() {
    super.initState();
    _popoverFocusNode = FocusScopeNode();
    _urlFocusNode = FocusNode();
    _urlController = ImeAttributedTextEditingController(
      controller: SingleLineAttributedTextEditingController(_applyLink),
    )
      ..onPerformActionPressed = _onPerformAction
      ..text = AttributedText("https://");

    // Initialize _toolbarAligner based on editorViewportKey if needed
    // _toolbarAligner = CupertinoPopoverToolbarAligner(widget.editorViewportKey); // If using this specific aligner
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // It's important that the boundary key is attached to a widget in the tree.
    _screenBoundary = WidgetFollowerBoundary(
      boundaryKey:
          widget.editorViewportKey, // Ensure this key is valid and attached
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    _urlController?.dispose();
    _popoverFocusNode.dispose();
    super.dispose();
  }

  bool _isConvertibleNode() {
    final selection = widget.composer.selection;
    if (selection == null || selection.base.nodeId != selection.extent.nodeId) {
      return false;
    }
    final selectedNode = widget.document.getNodeById(selection.extent.nodeId);
    return selectedNode is ParagraphNode || selectedNode is ListItemNode;
  }

  _TextType _getCurrentTextType() {
    final selectedNode =
        widget.document.getNodeById(widget.composer.selection!.extent.nodeId);
    if (selectedNode is ParagraphNode) {
      final type = selectedNode.getMetadataValue('blockType');
      if (type == header1Attribution) return _TextType.header1;
      if (type == header2Attribution) return _TextType.header2;
      // Add other header types if needed
      if (type == blockquoteAttribution) return _TextType.blockquote;
      return _TextType.paragraph;
    } else if (selectedNode is ListItemNode) {
      return selectedNode.type == ListItemType.ordered
          ? _TextType.orderedListItem
          : _TextType.unorderedListItem;
    }
    return _TextType.paragraph; // Default
  }

  TextAlign _getCurrentTextAlignment() {
    final selectedNode =
        widget.document.getNodeById(widget.composer.selection!.extent.nodeId);
    if (selectedNode is ParagraphNode) {
      final align = selectedNode.getMetadataValue('textAlign');
      switch (align) {
        case 'left':
          return TextAlign.left;
        case 'center':
          return TextAlign.center;
        case 'right':
          return TextAlign.right;
        case 'justify':
          return TextAlign.justify;
      }
    }
    return TextAlign.left; // Default
  }

  bool _isTextAlignable() {
    final selection = widget.composer.selection;
    if (selection == null || selection.base.nodeId != selection.extent.nodeId)
      return false;
    return widget.document.getNodeById(selection.extent.nodeId)
        is ParagraphNode;
  }

  void _convertTextToNewType(_TextType? newType) {
    if (newType == null || widget.editor == null) return;
    final existingTextType = _getCurrentTextType();
    if (existingTextType == newType) return;

    final nodeId = widget.composer.selection!.extent.nodeId;

    if (_isListItem(existingTextType) && _isListItem(newType)) {
      widget.editor!.execute([
        ChangeListItemTypeRequest(
          nodeId: nodeId,
          newType: newType == _TextType.orderedListItem
              ? ListItemType.ordered
              : ListItemType.unordered,
        ),
      ]);
    } else if (_isListItem(existingTextType) && !_isListItem(newType)) {
      widget.editor!.execute([
        ConvertListItemToParagraphRequest(
          nodeId: nodeId,
          paragraphMetadata: {'blockType': _getBlockTypeAttribution(newType)},
        ),
      ]);
    } else if (!_isListItem(existingTextType) && _isListItem(newType)) {
      widget.editor!.execute([
        ConvertParagraphToListItemRequest(
          nodeId: nodeId,
          type: newType == _TextType.orderedListItem
              ? ListItemType.ordered
              : ListItemType.unordered,
        ),
      ]);
    } else {
      widget.editor!.execute([
        ChangeParagraphBlockTypeRequest(
          nodeId: nodeId,
          blockType: _getBlockTypeAttribution(newType),
        ),
      ]);
    }
    widget.closeToolbar();
  }

  bool _isListItem(_TextType? type) =>
      type == _TextType.orderedListItem || type == _TextType.unorderedListItem;

  Attribution? _getBlockTypeAttribution(_TextType? newType) {
    switch (newType) {
      case _TextType.header1:
        return header1Attribution;
      case _TextType.header2:
        return header2Attribution;
      // Add other header types
      case _TextType.blockquote:
        return blockquoteAttribution;
      case _TextType.paragraph:
      default:
        return null;
    }
  }

  void _toggleAttribute(Attribution attribution) {
    if (widget.composer.selection == null || widget.editor == null) return;
    widget.editor!.execute([
      ToggleTextAttributionsRequest(
          documentRange: widget.composer.selection!,
          attributions: {attribution}),
    ]);
  }

  bool _isSingleLinkSelected() => _getSelectedLinkSpans().length == 1;
  bool _areMultipleLinksSelected() => _getSelectedLinkSpans().length >= 2;

  Set<AttributionSpan> _getSelectedLinkSpans() {
    final selection = widget.composer.selection;
    if (selection == null ||
        selection.base.nodeId != selection.extent.nodeId ||
        selection.base.nodePosition is! TextPosition) {
      return {};
    }
    final textNode =
        widget.document.getNodeById(selection.extent.nodeId) as TextNode;
    final baseOffset = (selection.base.nodePosition as TextNodePosition).offset;
    final extentOffset =
        (selection.extent.nodePosition as TextNodePosition).offset;
    final selectionRange = SpanRange(
      baseOffset < extentOffset ? baseOffset : extentOffset,
      baseOffset > extentOffset ? baseOffset : extentOffset,
    );
    return textNode.text.getAttributionSpansInRange(
      attributionFilter: (att) => att is LinkAttribution,
      range: selectionRange,
    );
  }

  void _onLinkPressed() {
    if (widget.composer.selection == null || widget.editor == null) return;
    final selection = widget.composer.selection!;
    if (selection.base.nodeId != selection.extent.nodeId ||
        selection.base.nodePosition is! TextPosition) return;

    final textNode =
        widget.document.getNodeById(selection.extent.nodeId) as TextNode;
    final baseOffset = (selection.base.nodePosition as TextNodePosition).offset;
    final extentOffset =
        (selection.extent.nodePosition as TextNodePosition).offset;
    final selectionRange = SpanRange(
      baseOffset < extentOffset ? baseOffset : extentOffset,
      baseOffset > extentOffset ? baseOffset : extentOffset,
    );
    final overlappingLinks = _getSelectedLinkSpans();

    if (overlappingLinks.length >= 2) return; // Do nothing for multiple links

    if (overlappingLinks.isNotEmpty) {
      // One link selected, remove it
      widget.editor!.execute([
        RemoveTextAttributionsRequest(
          documentRange: selection, // Remove from the selected range
          attributions: {overlappingLinks.first.attribution},
        )
      ]);
    } else {
      // No link selected, show URL field
      setState(() => _showUrlField = true);
      _urlFocusNode.requestFocus();
    }
  }

  void _applyLink() {
    if (widget.composer.selection == null ||
        _urlController == null ||
        widget.editor == null) return;
    final url = _urlController!.text.toPlainText(includePlaceholders: false);
    if (url.isEmpty || url == "https://") {
      // Basic validation
      setState(() => _showUrlField = false);
      widget.editorFocusNode.requestFocus();
      widget.closeToolbar();
      return;
    }

    final selection = widget.composer.selection!;
    final trimmedRange = _trimTextRangeWhitespace(
        (widget.document.getNodeById(selection.extent.nodeId) as TextNode).text,
        TextRange(
            start: (selection.start.nodePosition as TextPosition).offset,
            end: (selection.end.nodePosition as TextPosition).offset));

    final linkAttribution = LinkAttribution.fromUri(Uri.parse(url));
    widget.editor!.execute([
      AddTextAttributionsRequest(
        documentRange: DocumentRange(
          start: DocumentPosition(
              nodeId: selection.start.nodeId,
              nodePosition: TextNodePosition(offset: trimmedRange.start)),
          end: DocumentPosition(
              nodeId: selection.end.nodeId,
              nodePosition: TextNodePosition(offset: trimmedRange.end)),
        ),
        attributions: {linkAttribution},
      ),
    ]);

    _urlController!.clearTextAndSelection();
    setState(() => _showUrlField = false);
    widget.editorFocusNode.requestFocus();
    widget.closeToolbar();
  }

  SpanRange _trimTextRangeWhitespace(AttributedText text, TextRange range) {
    int startOffset = range.start;
    int endOffset = range.end;
    final plainText = text.toPlainText();

    while (startOffset < range.end &&
        (startOffset < plainText.length && plainText[startOffset] == ' ')) {
      startOffset += 1;
    }
    // endOffset is exclusive for TextRange, but inclusive for typical string slicing.
    // For SpanRange, end is exclusive.
    while (endOffset > startOffset &&
        (endOffset - 1 >= 0 &&
            endOffset - 1 < plainText.length &&
            plainText[endOffset - 1] == ' ')) {
      endOffset -= 1;
    }
    return SpanRange(startOffset, endOffset);
  }

  void _changeAlignment(TextAlign? newAlignment) {
    if (newAlignment == null ||
        widget.composer.selection == null ||
        widget.editor == null) return;
    widget.editor!.execute([
      ChangeParagraphAlignmentRequest(
          nodeId: widget.composer.selection!.extent.nodeId,
          alignment: newAlignment),
    ]);
    widget.closeToolbar();
  }

  String _getTextTypeName(_TextType textType) {
    // Replace with your localization
    switch (textType) {
      case _TextType.header1:
        return "Header 1";
      case _TextType.header2:
        return "Header 2";
      case _TextType.paragraph:
        return "Paragraph";
      case _TextType.blockquote:
        return "Blockquote";
      case _TextType.orderedListItem:
        return "Ordered List";
      case _TextType.unorderedListItem:
        return "Unordered List";
      default:
        return "Text";
    }
  }

  void _onPerformAction(TextInputAction action) {
    if (action == TextInputAction.done) _applyLink();
  }

  void _onBlockTypeSelected(SuperEditorDemoTextItem? selectedItem) {
    if (selectedItem != null) {
      final type = _TextType.values.firstWhere((e) => e.name == selectedItem.id,
          orElse: () => _TextType.paragraph);
      _convertTextToNewType(type);
    }
  }

  void _onAlignmentSelected(SuperEditorDemoIconItem? selectedItem) {
    if (selectedItem != null) {
      final align = TextAlign.values.firstWhere(
          (e) => e.name == selectedItem.id,
          orElse: () => TextAlign.left);
      _changeAlignment(align);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the Follower is rebuilt if the anchorLink changes or the boundary changes.
    // The Follower.withAligner constructor is suitable here.
    return Follower.withAligner(
      link: widget.anchorLink,
      aligner: _toolbarAligner,
      boundary: _screenBoundary, // Use the screen boundary
      showWhenUnlinked: false, // Hide if the leader (selection) is not present
      child: _buildToolbars(),
    );
  }

  Widget _buildToolbars() {
    // SuperEditorPopover is a custom widget from super_editor examples.
    // You might need to implement a similar popover or use Material's Card.
    return SuperEditorPopover(
      popoverFocusNode: _popoverFocusNode,
      editorFocusNode: widget.editorFocusNode,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolbar(),
          if (_showUrlField) ...[
            const SizedBox(height: 8),
            _buildUrlField(),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface;

    return IntrinsicWidth(
      child: Material(
        shape: const StadiumBorder(),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        child: SizedBox(
          height: 48, // Increased height for better touch targets
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isConvertibleNode()) ...[
                Tooltip(
                  message: "Block Type", // Replace with localization
                  child: SuperEditorDemoTextItemSelector(
                    // Placeholder - implement this
                    parentFocusNode: widget.editorFocusNode,
                    boundaryKey:
                        widget.editorViewportKey, // For dropdown positioning
                    value: SuperEditorDemoTextItem(
                        id: _getCurrentTextType().name,
                        label: _getTextTypeName(_getCurrentTextType())),
                    items: _TextType.values
                        .map((type) => SuperEditorDemoTextItem(
                            id: type.name, label: _getTextTypeName(type)))
                        .toList(),
                    onSelected: _onBlockTypeSelected,
                  ),
                ),
                _buildVerticalDivider(theme),
              ],
              IconButton(
                  icon: Icon(Icons.format_bold, color: iconColor),
                  onPressed: () => _toggleAttribute(boldAttribution),
                  tooltip: "Bold"),
              IconButton(
                  icon: Icon(Icons.format_italic, color: iconColor),
                  onPressed: () => _toggleAttribute(italicsAttribution),
                  tooltip: "Italic"),
              IconButton(
                  icon: Icon(Icons.strikethrough_s, color: iconColor),
                  onPressed: () => _toggleAttribute(strikethroughAttribution),
                  tooltip: "Strikethrough"),
              IconButton(
                  icon: Icon(Icons.link,
                      color: _isSingleLinkSelected()
                          ? theme.colorScheme.primary
                          : iconColor),
                  onPressed:
                      _areMultipleLinksSelected() ? null : _onLinkPressed,
                  tooltip: "Link"),
              if (_isTextAlignable()) ...[
                _buildVerticalDivider(theme),
                Tooltip(
                  message: "Text Alignment", // Replace with localization
                  child: SuperEditorDemoIconItemSelector(
                    // Placeholder - implement this
                    parentFocusNode: widget.editorFocusNode,
                    boundaryKey: widget.editorViewportKey,
                    value: SuperEditorDemoIconItem(
                        id: _getCurrentTextAlignment().name,
                        icon: _buildTextAlignIcon(_getCurrentTextAlignment())),
                    items: TextAlign.values
                        .where((a) =>
                            a != TextAlign.start &&
                            a !=
                                TextAlign
                                    .end) // Filter out start/end for simplicity
                        .map((align) => SuperEditorDemoIconItem(
                            id: align.name, icon: _buildTextAlignIcon(align)))
                        .toList(),
                    onSelected: _onAlignmentSelected,
                  ),
                ),
              ],
              // IconButton(icon: Icon(Icons.more_vert, color: iconColor), onPressed: () {}, tooltip: "More Options"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlField() {
    final theme = Theme.of(context);
    return Material(
      shape: const StadiumBorder(),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      child: Container(
        width: min(
            MediaQuery.of(context).size.width * 0.8, 300), // Responsive width
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SuperTextField(
                // From super_editor
                focusNode: _urlFocusNode,
                textController: _urlController!,
                minLines: 1,
                maxLines: 1,
                inputSource: TextInputSource.ime,
                hintBehavior: HintBehavior.displayHintUntilTextEntered,
                hintBuilder: (context) => Text("Enter URL...",
                    style: TextStyle(color: theme.hintColor)),
                textStyleBuilder: (_) =>
                    TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.check, color: theme.colorScheme.primary),
              onPressed: _applyLink,
              tooltip: "Apply Link",
            ),
            IconButton(
              icon:
                  Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () {
                setState(() => _showUrlField = false);
                _urlController!.clearTextAndSelection();
                widget.editorFocusNode.requestFocus();
              },
              tooltip: "Cancel",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) => Container(
      width: 1,
      color: theme.dividerColor.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 8));

  IconData _buildTextAlignIcon(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Icons.format_align_left;
      case TextAlign.center:
        return Icons.format_align_center;
      case TextAlign.right:
        return Icons.format_align_right;
      case TextAlign.justify:
        return Icons.format_align_justify;
      default:
        return Icons.format_align_left;
    }
  }
}

enum _TextType {
  header1,
  header2,
  paragraph,
  blockquote,
  orderedListItem,
  unorderedListItem
} // Add more as needed

// class ImageFormatToolbar extends StatelessWidget {
//   const ImageFormatToolbar({
//     super.key,
//     required this.anchorLink,
//     required this.composer,
//     required this.editor, // Added editor
//     required this.document, // Added document
//     required this.setWidth,
//     required this.closeToolbar,
//   });

//   final LeaderLink anchorLink;
//   final DocumentComposer composer;
//   final Editor editor; // Added editor
//   final Document document; // Added document
//   final void Function(String nodeId, double? width) setWidth;
//   final VoidCallback closeToolbar;

//   void _makeImageConfined() {
//     if (composer.selection == null) return;
//     setWidth(composer.selection!.extent.nodeId, null); // null usually means default/confined width
//     closeToolbar();
//   }

//   void _makeImageFullBleed() {
//     if (composer.selection == null) return;
//     setWidth(composer.selection!.extent.nodeId, double.infinity);
//     closeToolbar();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final iconColor = theme.colorScheme.onSurface;

//     return Follower.withAligner(
//       link: anchorLink,
//        // Centered aligner for toolbar positioning
//       showWhenUnlinked: false,
//       aligner: FunctionalAligner(delegate: (Rect globalLeaderRect, Size followerSize) {
//         // Center the toolbar horizontally below the anchor
//         final screenSize = MediaQuery.of(context).size;
//         final x = (globalLeaderRect.left + globalLeaderRect.right - followerSize.width) / 2;
//         final y = globalLeaderRect.bottom + 8; // 8 pixels below the anchor
//         // Clamp x to ensure it doesn't go off-screen
//         final clampedX = x.clamp(0.0, screenSize.width - followerSize.width);
//         return
//       }

//   ),
//       child: Material(
//         shape: const StadiumBorder(),
//         elevation: 4,
//         color: theme.colorScheme.surface,
//         clipBehavior: Clip.antiAlias,
//         child: SizedBox(
//           height: 48,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               IconButton(icon: Icon(Icons.photo_size_select_large, color: iconColor), onPressed: _makeImageConfined, tooltip: "Confined Width"),
//               IconButton(icon: Icon(Icons.photo_size_select_actual_outlined, color: iconColor), onPressed: _makeImageFullBleed, tooltip: "Full Width"),
//               // TODO: Add button to trigger image replacement/selection
//               // IconButton(icon: Icon(Icons.edit, color: iconColor), onPressed: () { /* Trigger image picker */ closeToolbar(); }, tooltip: "Change Image"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// A single-line text controller that calls onSubmit when newline is inserted (Enter key).
class SingleLineAttributedTextEditingController
    extends AttributedTextEditingController {
  SingleLineAttributedTextEditingController(this.onSubmit);
  final VoidCallback onSubmit;

  @override
  void insertNewline() {
    onSubmit();
    // SuperTextField handles single-line behavior, so we don't need to prevent newline insertion here.
  }
}

// Minimal SuperEditorPopover, as the original might be complex or internal to examples.
// This provides a basic popover structure.
class SuperEditorPopover extends StatelessWidget {
  final FocusScopeNode popoverFocusNode;
  final FocusNode editorFocusNode;
  final Widget child;

  const SuperEditorPopover({
    super.key,
    required this.popoverFocusNode,
    required this.editorFocusNode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      // Manages focus within the popover
      node: popoverFocusNode,
      child: child,
      onFocusChange: (hasFocus) {
        if (!hasFocus && !editorFocusNode.hasFocus) {
          // If popover loses focus AND editor doesn't have it,
          // it might mean user clicked outside.
          // Consider closing toolbar or returning focus to editor.
          // For now, this is handled by the toolbar's close logic.
        }
      },
    );
  }
}


// ImageFormatToolbar(
//                   anchorLink: _selectionLayerLinks.expandedSelectionBoundsLink, // You might need a different link or positioning logic for image toolbar
//                   composer: _composer,
//                   editor: _docEditor, // Pass editor to ImageFormatToolbar
//                   document: _doc,     // Pass document
//                   setWidth: (nodeId, width) {
//                     final node = _doc.getNodeById(nodeId)!;
//                     final currentStyles = SingleColumnLayoutComponentStyles.fromMetadata(node);
//                     _docEditor.execute([
//                       ChangeSingleColumnLayoutComponentStylesRequest(
//                         nodeId: nodeId,
//                         styles: SingleColumnLayoutComponentStyles(
//                           width: width,
//                           padding: currentStyles.padding,
//                         ),
//                       )
//                     ]);
//                   },
//                   closeToolbar: _hideImageToolbar,
//                 )