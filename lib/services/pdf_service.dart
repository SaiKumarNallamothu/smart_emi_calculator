import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFService {
  static final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);

  static Future<Uint8List> generateEmiReport({
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    required double monthlyEmi,
    required double totalInterest,
    required double totalPayment,
    double processingFee = 0.0,
    double extraPayment = 0.0,
  }) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Smart EMI Calculator',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Personalized Loan Repayment Report',
                            style: const pw.TextStyle(color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text(dateStr, style: const pw.TextStyle(color: PdfColors.grey600)),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.blue800),
                pw.SizedBox(height: 24),

                // Loan Summary Cards
                pw.Text('Calculation Summary',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),

                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildPdfSummaryCard(
                        'Monthly EMI',
                        currencyFormat.format(monthlyEmi),
                        PdfColors.blue100,
                        PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildPdfSummaryCard(
                        'Total Interest',
                        currencyFormat.format(totalInterest),
                        PdfColors.amber100,
                        PdfColors.amber900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildPdfSummaryCard(
                        'Total Payment',
                        currencyFormat.format(totalPayment),
                        PdfColors.green100,
                        PdfColors.green900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Loan Details Table
                pw.Text('Loan Parameters',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                  children: [
                    _buildPdfTableRow('Loan Principal Amount', currencyFormat.format(loanAmount)),
                    _buildPdfTableRow('Annual Interest Rate', '${interestRate.toStringAsFixed(2)}%'),
                    _buildPdfTableRow('Tenure', '$tenureMonths months (${(tenureMonths / 12).toStringAsFixed(1)} years)'),
                    if (processingFee > 0)
                      _buildPdfTableRow('Processing Fee', currencyFormat.format(processingFee)),
                    if (extraPayment > 0)
                      _buildPdfTableRow('Extra Monthly Payment', currencyFormat.format(extraPayment)),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Generated via Smart EMI Calculator App. Clear. Simple. Accurate.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfSummaryCard(String title, String value, PdfColor bgColor, PdfColor textColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 12, color: textColor)),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static Future<void> sharePdfReport({
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    required double monthlyEmi,
    required double totalInterest,
    required double totalPayment,
    double processingFee = 0.0,
    double extraPayment = 0.0,
  }) async {
    final pdfBytes = await generateEmiReport(
      loanAmount: loanAmount,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      monthlyEmi: monthlyEmi,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      processingFee: processingFee,
      extraPayment: extraPayment,
    );

    await Printing.sharePdf(bytes: pdfBytes, filename: 'EMI_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }
}
