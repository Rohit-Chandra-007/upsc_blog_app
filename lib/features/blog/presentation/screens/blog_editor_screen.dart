// blog_editor_screen.dart
import 'package:civilshots/features/blog/presentation/widgets/toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:super_editor/super_editor.dart';

class BlogEditorScreen extends StatefulWidget {
  const BlogEditorScreen({super.key});
  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  // ───────── Super Editor core objects ─────────
  final _doc = MutableDocument(nodes: [
    ParagraphNode(
        id: Editor.createNodeId(), text: AttributedText('Start writing…')),
  ]);
  final _composer = MutableDocumentComposer();
  late final Editor _editor =
      createDefaultDocumentEditor(document: _doc, composer: _composer);

  // cut/copy/paste helpers
  late final _ops = CommonEditorOperations(
    editor: _editor,
    document: _doc,
    composer: _composer,
    documentLayoutResolver: () => _layoutKey.currentState as DocumentLayout,
  );

  // ───────── overlay + linkage infra ──────────
  final _portal = OverlayPortalController();
  final _viewport = GlobalKey();
  final _links = SelectionLayerLinks();
  late FollowerBoundary _boundary; // calculated in didChangeDependencies()

  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _layoutKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _composer.selectionNotifier.addListener(_toggleToolbar);
  }

  final darkStylesheet = defaultStylesheet.copyWith(
    addRulesAfter: [
      /* ─────────────────────────── GLOBAL ────────────────────────── */
      // All blocks → light text
      StyleRule(
        BlockSelector.all,
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFECECEC),
            height: 1.45,
          ),
        },
      ),

      /* ─────────────────────────── HEADERS ───────────────────────── */
      StyleRule(
        const BlockSelector('header1'),
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFEEEEEE),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          Styles.padding: const EdgeInsets.only(top: 28, bottom: 14),
        },
      ),
      StyleRule(
        const BlockSelector('header2'),
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          Styles.padding: const EdgeInsets.only(top: 22, bottom: 12),
        },
      ),
      StyleRule(
        const BlockSelector('header3'),
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFCFCFCF),
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
          Styles.padding: const EdgeInsets.only(top: 18, bottom: 10),
        },
      ),

      /* ────────────────────────── LIST ITEMS ─────────────────────── */
      StyleRule(
        const BlockSelector('unorderedListItem > block'),
        (_, __) => {
          Styles.textStyle: const TextStyle(color: Color(0xFFECECEC)),
          Styles.dotColor: const Text('•',
              style: TextStyle(color: Color(0xFFECECEC), fontSize: 18)),
        },
      ),
      StyleRule(
        const BlockSelector('orderedListItem > block'),
        (_, __) => {
          Styles.textStyle: const TextStyle(color: Color(0xFFECECEC)),
        },
      ),

      /* ───────────────────────── BLOCKQUOTE ──────────────────────── */
      StyleRule(
        const BlockSelector('blockquote'),
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontStyle: FontStyle.italic,
          ),
          Styles.padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          Styles.borderRadius: const Border(
            left: BorderSide(color: Color(0xFF444444), width: 4),
          ),
        },
      ),

      /* ─────────────────────────── CODE BLOCK ────────────────────── */
      StyleRule(
        const BlockSelector('code'),
        (_, __) => {
          Styles.textStyle: const TextStyle(
            color: Color(0xFFFFF3B1),
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          Styles.padding: const EdgeInsets.all(8),
          Styles.backgroundColor: const Color(0xFF272727),
          Styles.borderRadius: BorderRadius.circular(4),
        },
      ),

      /* ─────────────────────────── LINKS ─────────────────────────── */
      // StyleRule(
      //   InlineSpan as BlockSelector, // matches any <a> span
      //   (_, __) => {
      //     Styles.textStyle: const TextStyle(
      //       color: Color(0xFF64A6FF),
      //       decoration: TextDecoration.underline,
      //     ),
      //   },
      // ),
    ],
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _boundary = WidgetFollowerBoundary(
      boundaryKey: _viewport,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  @override
  void dispose() {
    _composer.selectionNotifier.removeListener(_toggleToolbar);
    _focusNode.dispose();
    _scrollController.dispose();
    _composer.dispose();
    super.dispose();
  }

  // —— show toolbar only for single-node expanded selections ——
  void _toggleToolbar() {
    final sel = _composer.selection;
    if (sel == null ||
        sel.isCollapsed ||
        sel.base.nodeId != sel.extent.nodeId) {
      _portal.hide();
    } else {
      _portal.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit blog')),
      body: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (_) => EditorToolbar(
          anchor: _links.expandedSelectionBoundsLink,
          viewportKey: _viewport,
          boundary: _boundary,
          composer: _composer,
          editor: _editor,
          document: _doc,
        ),
        child: KeyedSubtree(
          key: _viewport,
          child: SuperEditor(
            document: _doc,
            composer: _composer,
            editor: _editor,
            focusNode: _focusNode,
            scrollController: _scrollController,
            documentLayoutKey: _layoutKey,
            selectionLayerLinks: _links,
            stylesheet: darkStylesheet,
            gestureMode: defaultTargetPlatform == TargetPlatform.android
                ? DocumentGestureMode.android
                : defaultTargetPlatform == TargetPlatform.iOS
                    ? DocumentGestureMode.iOS
                    : DocumentGestureMode.mouse,
            inputSource: TextInputSource.ime,
            androidToolbarBuilder: (_) => AndroidTextEditingFloatingToolbar(
              onCutPressed: () => _ops.cut(),
              onCopyPressed: () => _ops.copy(),
              onPastePressed: () => _ops.paste(),
              onSelectAllPressed: () => _ops.selectAll(),
            ),
          ),
        ),
      ),
    );
  }
}
