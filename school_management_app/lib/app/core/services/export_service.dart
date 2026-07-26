import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/models/enrollment_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/student_model.dart';
import '../utils/formatters.dart';

/// Builds and shares PDF / Excel exports.
///
/// The `build*` methods are pure (bytes in → bytes out) so they are unit
/// tested; the `share*` methods hand the result to the platform share sheet.
class ExportService {
  ExportService._();

  static const _violet = PdfColor.fromInt(0xFF8B7CF6);

  /// The built-in PDF fonts (Helvetica) can't draw the typographic dashes and
  /// bullets used in the UI, which would leave blank cells in the export.
  static String _pdfSafe(String value) => value
      .replaceAll('—', '-')
      .replaceAll('–', '-')
      .replaceAll('•', '*');

  // --- Builders (pure, testable) -----------------------------------------

  /// A4 landscape table of all students.
  static Future<Uint8List> buildStudentsPdf(List<StudentModel> students) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _pdfHeader('Students'),
        footer: (context) => _pdfFooter(context),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Code', 'Name', 'Gender', 'Date of birth',
              'Email', 'Phone', 'Address', 'Status',
            ],
            data: [
              for (final s in students)
                [
                  s.studentCode,
                  s.fullName,
                  _pdfSafe(Formatters.gender(s.gender)),
                  _pdfSafe(Formatters.date(s.dateOfBirth)),
                  s.email ?? '-',
                  s.phone ?? '-',
                  s.address ?? '-',
                  s.status ?? '-',
                ],
            ],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(color: _violet),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            oddRowDecoration:
                const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF4F4F7)),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Total: ${students.length} students',
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    return doc.save();
  }

  /// Report card for one student: profile, enrollments and per-term grades.
  static Future<Uint8List> buildTranscriptPdf({
    required StudentModel student,
    required List<EnrollmentModel> enrollments,
    required List<GradeModel> grades,
  }) async {
    final doc = pw.Document();
    final average = grades.isEmpty
        ? null
        : grades.map((g) => g.score).reduce((a, b) => a + b) / grades.length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _pdfHeader('Student Report Card'),
        footer: (context) => _pdfFooter(context),
        build: (context) => [
          // Profile block
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF4F4F7),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(student.fullName,
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text(student.studentCode,
                        style: const pw.TextStyle(
                            fontSize: 11, color: _violet)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Gender: ${_pdfSafe(Formatters.gender(student.gender))}',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        'Date of birth: ${_pdfSafe(Formatters.date(student.dateOfBirth))}',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Email: ${student.email ?? '-'}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Enrollments',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (enrollments.isEmpty)
            pw.Text('No enrollments',
                style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              headers: ['Class', 'Code', 'Enrolled at', 'Status'],
              data: [
                for (final e in enrollments)
                  [
                    e.className ?? '-',
                    e.classCode ?? '-',
                    _pdfSafe(Formatters.dateTime(e.enrolledAt)),
                    e.status ?? '-',
                  ],
              ],
              headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: _violet),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          pw.SizedBox(height: 16),
          pw.Text('Grades',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (grades.isEmpty)
            pw.Text('No grades recorded',
                style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              headers: ['Subject', 'Code', 'Term', 'Score', 'Grade', 'Graded by'],
              data: [
                for (final g in grades)
                  [
                    g.subjectName ?? '-',
                    g.subjectCode ?? '-',
                    Formatters.term(g.term),
                    g.score.toStringAsFixed(1),
                    g.letter,
                    g.gradedBy ?? '-',
                  ],
              ],
              headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: _violet),
              cellStyle: const pw.TextStyle(fontSize: 9),
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF4F4F7)),
            ),
          if (average != null) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Average score: ${average.toStringAsFixed(1)} / 100',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }

  /// XLSX workbook with one "Students" sheet.
  static Uint8List buildStudentsExcel(List<StudentModel> students) {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Students'];
    workbook.delete('Sheet1');

    sheet.appendRow([
      xls.TextCellValue('Code'),
      xls.TextCellValue('First name'),
      xls.TextCellValue('Last name'),
      xls.TextCellValue('Gender'),
      xls.TextCellValue('Date of birth'),
      xls.TextCellValue('Email'),
      xls.TextCellValue('Phone'),
      xls.TextCellValue('Address'),
      xls.TextCellValue('Status'),
    ]);
    for (final s in students) {
      sheet.appendRow([
        xls.TextCellValue(s.studentCode),
        xls.TextCellValue(s.firstName),
        xls.TextCellValue(s.lastName),
        xls.TextCellValue(Formatters.gender(s.gender)),
        xls.TextCellValue(Formatters.date(s.dateOfBirth)),
        xls.TextCellValue(s.email ?? ''),
        xls.TextCellValue(s.phone ?? ''),
        xls.TextCellValue(s.address ?? ''),
        xls.TextCellValue(s.status ?? ''),
      ]);
    }
    return Uint8List.fromList(workbook.save()!);
  }

  // --- Save & open ----------------------------------------------------------

  static const _xlsxMime = 'application/vnd.openxmlformats-officedocument.'
      'spreadsheetml.sheet';

  static Future<void> saveAndOpenPdf(Uint8List bytes, String filename) =>
      _saveAndOpen(bytes, filename, 'application/pdf');

  static Future<void> saveAndOpenExcel(Uint8List bytes, String filename) =>
      _saveAndOpen(bytes, filename, _xlsxMime);

  /// Writes the file into the app's documents folder and opens it with the
  /// platform viewer right away. Falls back to the share sheet when no app
  /// can display the file (e.g. no spreadsheet viewer installed).
  static Future<void> _saveAndOpen(
      Uint8List bytes, String filename, String mimeType) async {
    if (kIsWeb) {
      throw UnsupportedError('Export is available in the mobile app.');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(file.path, type: mimeType);
    if (result.type != ResultType.done) {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        text: filename,
      ));
    }
  }

  // --- PDF chrome -----------------------------------------------------------

  static pw.Widget _pdfHeader(String title) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('School Management System',
                    style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: _violet)),
                pw.Text(title, style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            pw.Text(
              'Generated ${DateTime.now().toString().substring(0, 16)}',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      );

  static pw.Widget _pdfFooter(pw.Context context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
}
