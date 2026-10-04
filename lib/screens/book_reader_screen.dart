import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen reader for a PDF book bundled as an asset. Scanned pages are
/// shown as-is so Arabic/Urdu typography is never re-rendered: one page at a
/// time, pinch to zoom, jump to a page, bookmarks, resume where you left off,
/// and a night mode that inverts the page.
///
/// There is deliberately no text search: the bundled books are image scans
/// with no text layer, and OCR of Urdu/Arabic is too unreliable to trust for
/// religious text.
class BookReaderScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const BookReaderScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  // Inverts RGB so black-on-white scans become white-on-black.
  static const _invert = ColorFilter.matrix(<double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  SharedPreferences? _prefs;
  PdfController? _controller;
  int _page = 1;
  int _total = 0;
  bool _night = false;
  bool _rtl = true;
  Set<int> _bookmarks = {};

  String get _key => 'book_${widget.assetPath}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final page = prefs.getInt('${_key}_page') ?? 1;
    setState(() {
      _prefs = prefs;
      _page = page;
      _night = prefs.getBool('${_key}_night') ?? false;
      _rtl = prefs.getBool('${_key}_rtl') ?? true;
      _bookmarks = (prefs.getStringList('${_key}_bookmarks') ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      _controller = PdfController(
        document: PdfDocument.openAsset(widget.assetPath),
        initialPage: page,
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _prefs?.setInt('${_key}_page', page);
  }

  void _jumpTo(int page) {
    if (_total == 0) return;
    _controller?.jumpToPage(page.clamp(1, _total));
  }

  void _step(int delta) {
    final target = _page + delta;
    if (target < 1 || target > _total) return;
    _controller?.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _toggleNight() {
    setState(() => _night = !_night);
    _prefs?.setBool('${_key}_night', _night);
  }

  void _toggleDirection() {
    setState(() => _rtl = !_rtl);
    _prefs?.setBool('${_key}_rtl', _rtl);
  }

  void _toggleBookmark() {
    setState(() {
      if (!_bookmarks.remove(_page)) _bookmarks.add(_page);
    });
    final sorted = _bookmarks.toList()..sort();
    _prefs?.setStringList(
      '${_key}_bookmarks',
      sorted.map((p) => '$p').toList(),
    );
  }

  Future<void> _askPage() async {
    final page = await showDialog<int>(
      context: context,
      builder: (context) => _GoToPageDialog(total: _total),
    );
    if (page != null) _jumpTo(page);
  }

  Future<void> _showBookmarks() async {
    final pages = _bookmarks.toList()..sort();
    final page = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: pages.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No bookmarks yet. Tap the bookmark icon to save a page.',
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final p in pages)
                    ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text('Page $p'),
                      onTap: () => Navigator.pop(context, p),
                    ),
                ],
              ),
      ),
    );
    if (page != null) _jumpTo(page);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final bookmarked = _bookmarks.contains(_page);

    // Night mode darkens the bars too, not just the page, so their icons and
    // text stay legible against the black background.
    return Theme(
      data: _night
          ? ThemeData.dark(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            )
          : Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark this page',
              icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
              onPressed: controller == null ? null : _toggleBookmark,
            ),
            IconButton(
              tooltip: _night ? 'Day mode' : 'Night mode',
              icon: Icon(_night ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleNight,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'goto') _askPage();
                if (value == 'bookmarks') _showBookmarks();
                if (value == 'direction') _toggleDirection();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'goto', child: Text('Go to page')),
                const PopupMenuItem(
                  value: 'bookmarks',
                  child: Text('Bookmarks'),
                ),
                PopupMenuItem(
                  value: 'direction',
                  child: Text(
                    _rtl
                        ? 'Swipe left-to-right: next (Urdu)'
                        : 'Swipe right-to-left: next',
                  ),
                ),
              ],
            ),
          ],
        ),
        body: controller == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ColorFiltered(
                      colorFilter: _night
                          ? _invert
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            ),
                      child: PdfView(
                        controller: controller,
                        reverse: _rtl,
                        onPageChanged: _onPageChanged,
                        onDocumentLoaded: (doc) {
                          if (mounted) setState(() => _total = doc.pagesCount);
                        },
                        builders: PdfViewBuilders<DefaultBuilderOptions>(
                          options: const DefaultBuilderOptions(),
                          documentLoaderBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          pageLoaderBuilder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                          errorBuilder: (_, error) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text('Could not open the book.\n$error'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _PageBar(
                    page: _page,
                    total: _total,
                    rtl: _rtl,
                    onPrev: () => _step(-1),
                    onNext: () => _step(1),
                    onSlide: _jumpTo,
                    onTapPage: _askPage,
                  ),
                ],
              ),
      ),
    );
  }
}

class _PageBar extends StatelessWidget {
  final int page;
  final int total;
  final bool rtl;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSlide;
  final VoidCallback onTapPage;

  const _PageBar({
    required this.page,
    required this.total,
    required this.rtl,
    required this.onPrev,
    required this.onNext,
    required this.onSlide,
    required this.onTapPage,
  });

  @override
  Widget build(BuildContext context) {
    final ready = total > 1;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
              onPressed: ready && page > 1 ? onPrev : null,
            ),
            Expanded(
              // The slider follows the swipe direction so dragging matches it.
              child: Directionality(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                child: Slider(
                  min: 1,
                  max: ready ? total.toDouble() : 2,
                  divisions: ready ? total - 1 : null,
                  value: page.clamp(1, ready ? total : 2).toDouble(),
                  onChanged: ready ? (v) => onSlide(v.round()) : null,
                ),
              ),
            ),
            TextButton(
              onPressed: ready ? onTapPage : null,
              child: Text(total == 0 ? '-' : '$page / $total'),
            ),
            IconButton(
              tooltip: 'Next page',
              icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
              onPressed: ready && page < total ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns its [TextEditingController] so it is disposed with the dialog's State,
/// i.e. only after the route's exit animation is done.
class _GoToPageDialog extends StatefulWidget {
  final int total;

  const _GoToPageDialog({required this.total});

  @override
  State<_GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<_GoToPageDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, int.tryParse(_controller.text));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Go to page'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: '1 - ${widget.total}'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Go')),
      ],
    );
  }
}
