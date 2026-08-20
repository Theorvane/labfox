import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import '../tokens/spacing.dart';

/// Renders a safe subset of Markdown.
///
/// It walks the parsed AST and builds widgets only for a whitelist of elements
/// a README uses: headings, paragraphs, lists, code, emphasis and links. Two
/// safety properties follow from that, both covered by tests:
///
/// - **Raw HTML is never executed.** The parser emits raw HTML as plain text
///   nodes, and the renderer draws every text node as a [TextSpan] and never a
///   [WidgetSpan] — nothing from the markdown becomes a live widget. Instead
///   of printing the tags, the renderer degrades them: tags are stripped and
///   their inner text kept, `<br>` becomes a line break, `<img>` falls back to
///   its alt text, and `<script>`/`<style>` are dropped with their contents.
///   The guarantee comes from this renderer's whitelist, not from any parser
///   setting — do not relax the whitelist assuming the parser sanitizes HTML,
///   because it does not.
/// - **Links are the only interactive element.** A tap reports the href through
///   [onTapLink]; the viewer never navigates or opens anything itself, leaving
///   that decision to the caller.
class MarkdownViewer extends StatefulWidget {
  const MarkdownViewer({required this.data, this.onTapLink, super.key});

  final String data;

  /// Called with the href when a link is tapped. Null makes links inert.
  final void Function(String href)? onTapLink;

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    // encodeHtml: false keeps raw HTML unescaped in the text node, so it shows
    // as `<script>` rather than `&lt;script&gt;`. It does NOT sanitize anything:
    // safety is the renderer's whitelist below, which turns raw HTML text into a
    // plain TextSpan, never a widget.
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final nodes = document.parse(widget.data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodes.map(_block).toList(growable: false),
    );
  }

  Widget _block(md.Node node) {
    final theme = Theme.of(context);
    if (node is md.Text) {
      // A block-level text node is raw HTML the parser passed through.
      // Degrade it to its readable text instead of printing the tags.
      final text = _degradeHtml(node.text);
      if (text.trim().isEmpty) {
        return const SizedBox.shrink();
      }
      return _paragraph(text, theme.textTheme.bodyMedium);
    }
    if (node is! md.Element) {
      return const SizedBox.shrink();
    }

    switch (node.tag) {
      case 'h1':
        return _paragraph(node.textContent, theme.textTheme.headlineSmall);
      case 'h2':
        return _paragraph(node.textContent, theme.textTheme.titleLarge);
      case 'h3':
        return _paragraph(node.textContent, theme.textTheme.titleMedium);
      case 'h4':
      case 'h5':
      case 'h6':
        return _paragraph(node.textContent, theme.textTheme.titleSmall);
      case 'pre':
        return _codeBlock(node.textContent, theme);
      case 'ul':
      case 'ol':
        return _list(node, theme, ordered: node.tag == 'ol');
      case 'blockquote':
        return Padding(
          padding: const EdgeInsets.only(
            left: LabFoxSpacing.md,
            bottom: LabFoxSpacing.sm,
          ),
          child: Container(
            padding: const EdgeInsets.only(left: LabFoxSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 3,
                ),
              ),
            ),
            child: RichText(
              text: _inline(
                node.children ?? const [],
                theme.textTheme.bodyMedium,
              ),
            ),
          ),
        );
      case 'hr':
        return const Divider(height: LabFoxSpacing.lg);
      case 'p':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
          child: RichText(
            text: _inline(
              node.children ?? const [],
              theme.textTheme.bodyMedium,
            ),
          ),
        );
    }
  }

  Widget _paragraph(String text, TextStyle? style) => Padding(
    padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
    child: Text(text, style: style),
  );

  Widget _codeBlock(String text, ThemeData theme) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
    padding: const EdgeInsets.all(LabFoxSpacing.sm),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text.trimRight(),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodySmall?.fontSize,
      ),
    ),
  );

  Widget _list(md.Element node, ThemeData theme, {required bool ordered}) {
    final items = node.children?.whereType<md.Element>().toList() ?? const [];
    return Padding(
      padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: LabFoxSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: LabFoxSpacing.sm),
                    child: Text(
                      ordered ? '${i + 1}.' : '•',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: _inline(
                        items[i].children ?? const [],
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds an inline span tree, the only place a link recognizer is created.
  TextSpan _inline(
    List<md.Node> nodes,
    TextStyle? base, {
    TextStyle? override,
  }) {
    final style = override ?? base;
    return TextSpan(
      style: style,
      children: nodes
          .map((node) {
            if (node is md.Text) {
              return TextSpan(text: _degradeHtml(node.text));
            }
            if (node is md.Element) {
              switch (node.tag) {
                case 'strong':
                  return _inline(
                    node.children ?? const [],
                    base,
                    override: (style ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                case 'em':
                  return _inline(
                    node.children ?? const [],
                    base,
                    override: (style ?? const TextStyle()).copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  );
                case 'code':
                  return TextSpan(
                    text: node.textContent,
                    style: (style ?? const TextStyle()).copyWith(
                      fontFamily: 'monospace',
                    ),
                  );
                case 'a':
                  return _link(node, style);
                default:
                  return _inline(
                    node.children ?? const [],
                    base,
                    override: style,
                  );
              }
            }
            return const TextSpan();
          })
          .toList(growable: false),
    );
  }

  TextSpan _link(md.Element node, TextStyle? style) {
    final href = node.attributes['href'];
    final linkStyle = (style ?? const TextStyle()).copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    TapGestureRecognizer? recognizer;
    if (href != null && widget.onTapLink != null) {
      recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onTapLink!(href);
      _recognizers.add(recognizer);
    }
    return TextSpan(
      text: node.textContent,
      style: linkStyle,
      recognizer: recognizer,
    );
  }

  static final _scriptOrStyle = RegExp(
    r'<(script|style)[^>]*>.*?</\1\s*>',
    caseSensitive: false,
    dotAll: true,
  );
  static final _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
  static final _imageWithAlt = RegExp(
    '''<img[^>]*\\balt\\s*=\\s*["']([^"']*)["'][^>]*>''',
    caseSensitive: false,
  );
  static final _image = RegExp(r'<img[^>]*>', caseSensitive: false);
  static final _tag = RegExp(r'</?[a-zA-Z][^>]*>');

  /// Reduces raw HTML to its readable text. Never renders anything: tags are
  /// stripped keeping their inner text, `<br>` becomes a newline, `<img>`
  /// falls back to its alt text, and `<script>`/`<style>` vanish with their
  /// contents. Entities decode last so `&lt;script&gt;` can never become a
  /// tag. Plain text without HTML passes through untouched.
  static String _degradeHtml(String text) {
    if (!text.contains('<') && !text.contains('&')) {
      return text;
    }
    var s = text.replaceAll(_scriptOrStyle, '');
    s = s.replaceAll(_lineBreak, '\n');
    s = s.replaceAllMapped(_imageWithAlt, (m) => m[1]!);
    s = s.replaceAll(_image, '');
    s = s.replaceAll(_tag, '');
    return s
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&');
  }
}
