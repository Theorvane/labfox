import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:markdown/markdown.dart' as md;

import '../tokens/icon_size.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Renders a safe subset of Markdown, including the HTML READMEs actually use.
///
/// Markdown structure comes from the parsed AST; raw HTML inside it is parsed
/// with `package:html` and rendered through a **whitelist**: headings,
/// paragraphs and centering, lists, blockquotes, code, emphasis, links,
/// images, and `<details>`/`<summary>` as an expandable section. The safety
/// properties, covered by tests:
///
/// - **Nothing from the document is ever executed.** Only whitelisted elements
///   render, and every widget is built by this renderer from attribute values —
///   never from live HTML. `<script>`/`<style>`/`<iframe>` and friends are
///   dropped with their contents; event-handler attributes are never read;
///   unknown tags unwrap to their children as plain content.
/// - **Links and images are the only outward touchpoints.** A link tap reports
///   its href through [onTapLink] and the viewer never navigates itself; an
///   image loads only from an http(s) `src` and falls back to its alt text.
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
      // A block-level text node is raw HTML the markdown parser passed
      // through. Render it through the HTML whitelist.
      final children = _htmlBlocks(node.text, theme);
      if (children.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
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
      borderRadius: BorderRadius.circular(LabFoxRadius.xs),
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
              // Inline raw HTML (tags, entities, badges) renders through the
              // same whitelist; plain text passes straight through.
              if (node.text.contains('<') || node.text.contains('&')) {
                return TextSpan(
                  style: style,
                  children: _htmlSpans(
                    html_parser.parseFragment(node.text).nodes,
                    style,
                  ),
                );
              }
              return TextSpan(text: node.text);
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
                case 'img':
                  return _imageSpan(
                    node.attributes['src'],
                    node.attributes['alt'],
                    width: node.attributes['width'],
                    height: node.attributes['height'],
                  );
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

  // ── HTML rendering ───────────────────────────────────────────────────────

  /// Tags that vanish with their entire contents. Everything here either runs
  /// code, embeds a foreign document, or collects input — none of it has a
  /// safe reading.
  static const _dropped = {
    'script', 'style', 'iframe', 'object', 'embed', 'svg', 'canvas', //
    'form', 'input', 'button', 'select', 'textarea', 'video', 'audio',
    'source', 'template', 'noscript', 'head', 'link', 'meta', 'base',
  };

  /// Tags laid out as their own block rather than inline.
  static const _blockTags = {
    'p', 'div', 'center', 'section', 'article', 'figure', 'figcaption', //
    'header', 'footer', 'main', 'aside', 'nav', 'h1', 'h2', 'h3', 'h4',
    'h5', 'h6', 'ul', 'ol', 'li', 'table', 'pre', 'blockquote', 'details',
    'hr', 'dl', 'dt', 'dd',
  };

  List<Widget> _htmlBlocks(String rawHtml, ThemeData theme) {
    final fragment = html_parser.parseFragment(rawHtml);
    return fragment.nodes
        .map((node) => _htmlBlock(node, theme))
        .whereType<Widget>()
        .toList(growable: false);
  }

  Widget? _htmlBlock(dom.Node node, ThemeData theme) {
    if (node is dom.Text) {
      final text = node.text;
      if (text.trim().isEmpty) {
        return null;
      }
      return _paragraph(text.trim(), theme.textTheme.bodyMedium);
    }
    if (node is! dom.Element) {
      return null;
    }
    final tag = node.localName ?? '';
    if (_dropped.contains(tag)) {
      return null;
    }

    switch (tag) {
      case 'h1':
        return _paragraph(node.text.trim(), theme.textTheme.headlineSmall);
      case 'h2':
        return _paragraph(node.text.trim(), theme.textTheme.titleLarge);
      case 'h3':
        return _paragraph(node.text.trim(), theme.textTheme.titleMedium);
      case 'h4':
      case 'h5':
      case 'h6':
        return _paragraph(node.text.trim(), theme.textTheme.titleSmall);
      case 'br':
        return const SizedBox(height: LabFoxSpacing.sm);
      case 'hr':
        return const Divider(height: LabFoxSpacing.lg);
      case 'pre':
        return _codeBlock(node.text, theme);
      case 'img':
        return _blockImage(node);
      case 'ul':
      case 'ol':
        return _htmlList(node, theme, ordered: tag == 'ol');
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
            child: _htmlRich(node.nodes, theme.textTheme.bodyMedium),
          ),
        );
      case 'details':
        return _details(node, theme);
      default:
        // p, div, center, and anything unknown: a container. When it holds
        // block children, recurse; otherwise lay its inline content out as
        // one rich paragraph. `<center>` and align="center" centre it.
        final centered =
            tag == 'center' ||
            node.attributes['align']?.toLowerCase() == 'center';
        final hasBlockChild = node.children.any(
          (child) => _blockTags.contains(child.localName),
        );
        final Widget content;
        if (hasBlockChild) {
          final children = node.nodes
              .map((child) => _htmlBlock(child, theme))
              .whereType<Widget>()
              .toList(growable: false);
          if (children.isEmpty) {
            return null;
          }
          content = Column(
            crossAxisAlignment: centered
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: children,
          );
        } else {
          final spans = _htmlSpans(node.nodes, theme.textTheme.bodyMedium);
          if (spans.isEmpty) {
            return null;
          }
          content = Padding(
            padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
            child: RichText(
              textAlign: centered ? TextAlign.center : TextAlign.start,
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: spans,
              ),
            ),
          );
        }
        return centered
            ? SizedBox(
                width: double.infinity,
                child: Center(child: content),
              )
            : content;
    }
  }

  Widget _htmlRich(List<dom.Node> nodes, TextStyle? style) => RichText(
    text: TextSpan(style: style, children: _htmlSpans(nodes, style)),
  );

  Widget _htmlList(dom.Element node, ThemeData theme, {required bool ordered}) {
    final items = node.children
        .where((child) => child.localName == 'li')
        .toList(growable: false);
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
                    child: _htmlRich(
                      items[i].nodes,
                      theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// `<details>`: the summary as an always-visible header, the rest revealed
  /// on tap. Content stays local — expanding never loads anything.
  Widget _details(dom.Element node, ThemeData theme) {
    final summary = node.children.firstWhere(
      (child) => child.localName == 'summary',
      orElse: () => dom.Element.tag('summary'),
    );
    final summaryText = summary.text.trim();
    final body = node.nodes
        .where((child) => child != summary)
        .map((child) => _htmlBlock(child, theme))
        .whereType<Widget>()
        .toList(growable: false);
    return _HtmlDetails(
      summary: summaryText.isEmpty ? 'Details' : summaryText,
      children: body,
    );
  }

  List<InlineSpan> _htmlSpans(List<dom.Node> nodes, TextStyle? base) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is dom.Text) {
        if (node.text.isNotEmpty) {
          spans.add(TextSpan(text: node.text));
        }
        continue;
      }
      if (node is! dom.Element) {
        continue;
      }
      final tag = node.localName ?? '';
      if (_dropped.contains(tag)) {
        continue;
      }
      final style = base ?? const TextStyle();
      switch (tag) {
        case 'br':
          spans.add(const TextSpan(text: '\n'));
        case 'img':
          spans.add(
            _imageSpan(
              node.attributes['src'],
              node.attributes['alt'],
              width: node.attributes['width'],
              height: node.attributes['height'],
            ),
          );
        case 'b':
        case 'strong':
          spans.add(
            TextSpan(
              style: style.copyWith(fontWeight: FontWeight.bold),
              children: _htmlSpans(node.nodes, base),
            ),
          );
        case 'i':
        case 'em':
          spans.add(
            TextSpan(
              style: style.copyWith(fontStyle: FontStyle.italic),
              children: _htmlSpans(node.nodes, base),
            ),
          );
        case 'del':
        case 's':
        case 'strike':
          spans.add(
            TextSpan(
              style: style.copyWith(decoration: TextDecoration.lineThrough),
              children: _htmlSpans(node.nodes, base),
            ),
          );
        case 'code':
        case 'kbd':
          spans.add(
            TextSpan(
              text: node.text,
              style: style.copyWith(fontFamily: 'monospace'),
            ),
          );
        case 'sub':
        case 'sup':
        case 'small':
          spans.add(
            TextSpan(
              style: style.copyWith(fontSize: (style.fontSize ?? 14) * 0.8),
              children: _htmlSpans(node.nodes, base),
            ),
          );
        case 'a':
          spans.add(_htmlLink(node, style));
        default:
          spans.addAll(_htmlSpans(node.nodes, base));
      }
    }
    return spans;
  }

  TextSpan _htmlLink(dom.Element node, TextStyle style) {
    final href = node.attributes['href'];
    final linkStyle = style.copyWith(
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
      style: linkStyle,
      recognizer: recognizer,
      children: [
        for (final span in _htmlSpans(node.nodes, linkStyle))
          span is TextSpan
              ? TextSpan(
                  text: span.text,
                  children: span.children,
                  style: span.style,
                  recognizer: recognizer,
                )
              : span,
      ],
    );
  }

  /// An image as an inline span; block contexts wrap it in a paragraph.
  InlineSpan _imageSpan(
    String? src,
    String? alt, {
    String? width,
    String? height,
  }) {
    final image = _image(src, alt, width: width, height: height);
    if (image == null) {
      return TextSpan(text: alt ?? '');
    }
    return WidgetSpan(alignment: PlaceholderAlignment.middle, child: image);
  }

  Widget? _blockImage(dom.Element node) {
    final image = _image(
      node.attributes['src'],
      node.attributes['alt'],
      width: node.attributes['width'],
      height: node.attributes['height'],
    );
    if (image == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: LabFoxSpacing.sm),
      child: image,
    );
  }

  /// Builds the image widget, or null when the src is not plain http(s).
  /// A failed load falls back to the alt text so a broken badge never leaves
  /// a hole.
  Widget? _image(String? src, String? alt, {String? width, String? height}) {
    final uri = src == null ? null : Uri.tryParse(src);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return Image.network(
      uri.toString(),
      width: double.tryParse(width ?? ''),
      height: double.tryParse(height ?? ''),
      errorBuilder: (context, error, stack) {
        if (alt == null || alt.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(alt, style: LabFoxTextRoles.of(context).meta);
      },
    );
  }
}

/// The expandable `<details>` section: a tappable summary row with a chevron,
/// revealing its children when open.
class _HtmlDetails extends StatefulWidget {
  const _HtmlDetails({required this.summary, required this.children});

  final String summary;
  final List<Widget> children;

  @override
  State<_HtmlDetails> createState() => _HtmlDetailsState();
}

class _HtmlDetailsState extends State<_HtmlDetails> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: LabFoxSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _open ? Icons.expand_more : Icons.chevron_right,
                  size: LabFoxIconSize.md,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: LabFoxSpacing.xs),
                Flexible(
                  child: Text(
                    widget.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(
              left: LabFoxSpacing.lg,
              top: LabFoxSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}
