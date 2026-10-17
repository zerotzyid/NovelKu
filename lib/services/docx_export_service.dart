import 'dart:io';
import 'package:docx/docx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/chapter_model.dart';
import '../models/novel_model.dart';

class DocxExportService {
  Future<String> exportNovel(NovelModel novel, List<ChapterModel> chapters) async {
    final document = Document();

    document.add(Paragraph(text: novel.title, style: DocumentStyles.heading1));
    document.add(Paragraph(text: 'Dibuat dengan Novelku', style: DocumentStyles.heading2));
    document.add(Paragraph(text: 'Diperbarui: ${novel.updatedAt.toString()}'));
    document.add(Paragraph(text: ''));

    final sorted = chapters..sort((a, b) => a.number.compareTo(b.number));
    for (final chapter in sorted) {
      document.add(Paragraph(
        text: 'Bab ${chapter.number}: ${chapter.title}',
        style: DocumentStyles.heading2,
      ));
      document.add(Paragraph(text: chapter.content.isEmpty ? '[Kosong]' : chapter.content));
      document.add(Paragraph(text: ''));
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_sanitize(novel.title)}_${DateTime.now().millisecondsSinceEpoch}.docx';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(document.save());

    return file.path;
  }

  Future<String> exportChapter(ChapterModel chapter) async {
    final document = Document();
    document.add(Paragraph(text: 'Bab ${chapter.number}: ${chapter.title}', style: DocumentStyles.heading1));
    document.add(Paragraph(text: chapter.content.isEmpty ? '[Kosong]' : chapter.content));

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'bab_${chapter.number}_${_sanitize(chapter.title)}_${DateTime.now().millisecondsSinceEpoch}.docx';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(document.save());

    return file.path;
  }

  String _sanitize(String s) => s.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').trim();
}
