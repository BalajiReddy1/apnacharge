import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

/// Renders a bundled Markdown legal document (Privacy Policy / Terms) in-app.
///
/// Uses a small, dependency-free renderer that handles headings, bullet lists,
/// tables (as plain rows), and inline **bold** — enough for these documents,
/// while keeping the app's dependency footprint small.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load document.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _renderMarkdown(snapshot.data!),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _renderMarkdown(String md) {
    final widgets = <Widget>[];
    for (final rawLine in md.split('\n')) {
      final line = rawLine.trimRight();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('### ')) {
        widgets.add(_heading(line.substring(4), 16));
      } else if (line.startsWith('## ')) {
        widgets.add(_heading(line.substring(3), 18));
      } else if (line.startsWith('# ')) {
        widgets.add(_heading(line.substring(2), 22));
      } else if (line.startsWith('> ')) {
        widgets.add(_quote(line.substring(2)));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(_bullet(line.substring(2)));
      } else if (line.startsWith('|')) {
        // Skip Markdown table separator rows; render others as plain text.
        if (!RegExp(r'^\|[\s:|-]+\|$').hasMatch(line)) {
          final cells = line
              .split('|')
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .join('  •  ');
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _inline(cells, const TextStyle(fontSize: 13)),
          ));
        }
      } else if (RegExp(r'^-{3,}$').hasMatch(line)) {
        widgets.add(const Divider(height: 20));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: _inline(line, const TextStyle(fontSize: 14, height: 1.4)),
        ));
      }
    }
    return widgets;
  }

  Widget _heading(String text, double size) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: _inline(
        text,
        TextStyle(fontSize: size, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: _inline(text, const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _quote(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Colors.green, width: 3),
        ),
      ),
      child: _inline(text, const TextStyle(fontSize: 14, height: 1.4)),
    );
  }

  /// Renders inline **bold** segments within a line.
  Widget _inline(String text, TextStyle base) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return SelectableText.rich(TextSpan(style: base, children: spans));
  }
}
