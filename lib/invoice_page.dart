import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/invoice.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoicePage extends StatefulWidget {
  final int pesananId;

  const InvoicePage({super.key, required this.pesananId});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool isLoading = true;
  bool isGeneratingPdf = false;
  InvoiceModel? invoice;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Helper method untuk encode URL gambar
  String _encodeImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    final encodedName = Uri.encodeComponent(imageName);
    return '$gambarUrl/produk/$encodedName';
  }

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
  }

  Future<void> _fetchInvoice() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('$baseUrl/customer/pesanan_invoice/${widget.pesananId}'),
        headers: {'Accept': 'application/json'},
      );

      print('Invoice Response status: ${response.statusCode}');
      print('Invoice Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final invoiceResponse = InvoiceResponse.fromJson(responseData);

      if (response.statusCode == 200 && invoiceResponse.success == true) {
        setState(() {
          invoice = invoiceResponse.data;
        });
      } else {
        _showSnackBar(
          invoiceResponse.message ?? 'Gagal memuat invoice',
          Colors.red,
        );
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DAPUR ANITA',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Invoice No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '#${invoice!.idPesanan}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Tanggal',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(_formatDate(invoice!.createdAt)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Shipping Address
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Dikirim Kepada:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice!.namaPenerima ?? '',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(invoice!.noTelp ?? ''),
                    pw.SizedBox(height: 2),
                    pw.Text(invoice!.alamatLengkap ?? ''),
                    pw.SizedBox(height: 2),
                    pw.Text('${invoice!.namaKota}, ${invoice!.namaProv}'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Product Details
              pw.Text(
                'Detail Produk:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Product Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Produk',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Harga',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Product Row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              invoice!.namaProduk ?? '',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Berat: ${invoice!.berat ?? 0}g',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${invoice!.quantity}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          currencyFormatter.format(invoice!.hargaProduk ?? 0),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          currencyFormatter.format(invoice!.getSubtotal()),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfSummaryRow(
                      'Subtotal',
                      currencyFormatter.format(invoice!.getSubtotal()),
                    ),
                    _buildPdfSummaryRow(
                      'Ongkos Kirim',
                      currencyFormatter.format(invoice!.ongkir ?? 0),
                    ),
                    pw.Divider(),
                    _buildPdfSummaryRow(
                      'Total',
                      currencyFormatter.format(invoice!.totalOngkir ?? 0),
                      isTotal: true,
                    ),
                    if (invoice!.tipePembayaran == 'dp') ...[
                      pw.Divider(),
                      _buildPdfSummaryRow('Metode Pembayaran', 'DP'),
                      _buildPdfSummaryRow(
                        'DP Dibayar',
                        currencyFormatter.format(invoice!.totalDp ?? 0),
                      ),
                      if (invoice!.dpStatus == 'dp')
                        _buildPdfSummaryRow(
                          'Sisa Pembayaran',
                          currencyFormatter.format(
                            (invoice!.totalOngkir ?? 0) -
                                (invoice!.totalDp ?? 0),
                          ),
                        ),
                    ] else
                      _buildPdfSummaryRow('Metode Pembayaran', 'LUNAS'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Status
              pw.Center(
                child: pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    'STATUS: ${invoice!.getStatusText().toUpperCase()}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Terima kasih atas kepercayaan Anda!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice() async {
    if (invoice == null) return;

    try {
      setState(() => isGeneratingPdf = true);

      final pdf = await _generatePdf();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${invoice!.idPesanan}.pdf',
      );

      _showSnackBar('Invoice siap untuk dicetak', Colors.green);
    } catch (e) {
      print('Error printing: $e');
      _showSnackBar('Gagal mencetak invoice: $e', Colors.red);
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (invoice == null) return;

    try {
      setState(() => isGeneratingPdf = true);

      final pdf = await _generatePdf();
      // Gunakan temp directory untuk menghindari permission issues
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Invoice_${invoice!.idPesanan}.pdf');

      await file.writeAsBytes(await pdf.save());

      // Langsung share karena temp directory bisa tidak accessible oleh user
      await _sharePdf(file);

      _showSnackBar('PDF berhasil dibuat dan siap dibagikan', Colors.green);
    } catch (e) {
      print('Error creating PDF: $e');
      _showSnackBar('Gagal membuat PDF: $e', Colors.red);
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }

  Future<void> _sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Invoice #${invoice!.idPesanan} - Dapur Anita',
        subject: 'Invoice Pesanan',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
      _showSnackBar('Gagal membagikan PDF: $e', Colors.red);
    }
  }

  Future<void> _shareInvoice() async {
    if (invoice == null) return;

    try {
      setState(() => isGeneratingPdf = true);

      final pdf = await _generatePdf();
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Invoice_${invoice!.idPesanan}.pdf');

      await file.writeAsBytes(await pdf.save());
      await _sharePdf(file);
    } catch (e) {
      print('Error sharing: $e');
      _showSnackBar('Gagal membagikan invoice: $e', Colors.red);
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${widget.pesananId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (isGeneratingPdf)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            IconButton(
              onPressed: _printInvoice,
              icon: Icon(Icons.print),
              tooltip: 'Cetak Invoice',
            ),
            IconButton(
              onPressed: _shareInvoice,
              icon: Icon(Icons.share),
              tooltip: 'Bagikan Invoice',
            ),
          ],
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : invoice == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Invoice tidak ditemukan'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Kembali'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInvoiceCard(),
                  SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildInvoiceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Invoice
            Center(
              child: Column(
                children: [
                  Text(
                    'DAPUR ANITA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'INVOICE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Divider(thickness: 2, color: Colors.blue),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Invoice Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice No.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '#${invoice!.idPesanan}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(_formatDate(invoice!.createdAt)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Shipping Address
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dikirim Kepada:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    invoice!.namaPenerima ?? '',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(invoice!.noTelp ?? ''),
                  SizedBox(height: 4),
                  Text(invoice!.alamatLengkap ?? ''),
                  SizedBox(height: 4),
                  Text('${invoice!.namaKota}, ${invoice!.namaProv}'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Product Details
            Text(
              'Detail Produk:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Produk',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Harga',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Subtotal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product Row
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice!.namaProduk ?? '',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Berat: ${invoice!.berat ?? 0}g',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${invoice!.quantity}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormatter.format(invoice!.hargaProduk ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormatter.format(invoice!.getSubtotal()),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    currencyFormatter.format(invoice!.getSubtotal()),
                  ),
                  _buildSummaryRow(
                    'Ongkos Kirim',
                    currencyFormatter.format(invoice!.ongkir ?? 0),
                  ),
                  Divider(),
                  _buildSummaryRow(
                    'Total',
                    currencyFormatter.format(invoice!.totalOngkir ?? 0),
                    isTotal: true,
                  ),
                  if (invoice!.tipePembayaran == 'dp') ...[
                    Divider(),
                    _buildSummaryRow('Metode Pembayaran', 'DP'),
                    _buildSummaryRow(
                      'DP Dibayar',
                      currencyFormatter.format(invoice!.totalDp ?? 0),
                    ),
                    if (invoice!.dpStatus == 'dp')
                      _buildSummaryRow(
                        'Sisa Pembayaran',
                        currencyFormatter.format(
                          (invoice!.totalOngkir ?? 0) - (invoice!.totalDp ?? 0),
                        ),
                        isHighlight: true,
                      ),
                  ] else
                    _buildSummaryRow('Metode Pembayaran', 'LUNAS'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Status
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  'STATUS: ${invoice!.getStatusText().toUpperCase()}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                'Terima kasih atas kepercayaan Anda!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isHighlight ? Colors.orange : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal
                  ? Colors.blue
                  : (isHighlight ? Colors.orange : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isGeneratingPdf ? null : _printInvoice,
                icon: isGeneratingPdf
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.print),
                label: Text(isGeneratingPdf ? 'Memproses...' : 'Cetak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isGeneratingPdf ? null : _downloadPdf,
                icon: isGeneratingPdf
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.download),
                label: Text(isGeneratingPdf ? 'Memproses...' : 'Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isGeneratingPdf ? null : _shareInvoice,
            icon: isGeneratingPdf
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.share),
            label: Text(isGeneratingPdf ? 'Memproses...' : 'Bagikan PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
