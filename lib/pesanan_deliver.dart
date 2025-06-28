// file: lib/pesanan_deliver.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/pesanan_deliver.dart';
import 'package:dapur_anita/invoice_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PesananDeliverPage extends StatefulWidget {
  const PesananDeliverPage({super.key});

  @override
  State<PesananDeliverPage> createState() => _PesananDeliverPageState();
}

class _PesananDeliverPageState extends State<PesananDeliverPage> {
  bool isLoading = true;
  int? userId;
  List<PesananDeliverModel> pesananList = [];
  final _komentarController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');
    if (userId != null) {
      _fetchPesananDeliver();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Anda belum login', Colors.red);
    }
  }

  Future<void> _fetchPesananDeliver() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('$baseUrl/customer/pesanan_deliver?id_user=$userId'),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final pesananResponse = PesananDeliverResponse.fromJson(responseData);

      if (response.statusCode == 200 && pesananResponse.success == true) {
        setState(() {
          pesananList = pesananResponse.data ?? [];
        });
      } else {
        _showSnackBar(
          pesananResponse.message ?? 'Gagal memuat data pengiriman',
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

  Future<void> _refreshPesanan() async {
    await _fetchPesananDeliver();
  }

  void _showKomentarDialog(PesananDeliverModel pesanan) {
    _komentarController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Konfirmasi Pesanan Diterima',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        '$gambarUrl/produk/${pesanan.fotoProduk}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.namaProduk ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pesanan #${pesanan.idPesanan}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Apakah Anda sudah menerima pesanan ini dengan baik?',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),

              Text(
                'Berikan komentar Anda tentang produk ini:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 8),

              TextFormField(
                controller: _komentarController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Tulis komentar Anda tentang kualitas produk, pelayanan, dll...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Komentar minimal 10 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              Text(
                'Komentar Anda akan membantu pembeli lain dan meningkatkan kualitas produk.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (_komentarController.text.trim().isEmpty) {
                _showSnackBar('Komentar tidak boleh kosong', Colors.red);
                return;
              }
              if (_komentarController.text.trim().length < 10) {
                _showSnackBar('Komentar minimal 10 karakter', Colors.red);
                return;
              }

              Navigator.pop(context);
              _terimaPesanan(pesanan);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              'Konfirmasi Diterima',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _terimaPesanan(PesananDeliverModel pesanan) async {
    try {
      _showLoadingDialog();

      final response = await http.post(
        Uri.parse('$baseUrl/customer/pesanan_diterima'),
        headers: {'Accept': 'application/json'},
        body: {
          'id_pesanan': pesanan.idPesanan.toString(),
          'id_produk': pesanan.idProduk.toString(),
          'id_user': userId.toString(),
          'komentar': _komentarController.text.trim(),
        },
      );

      Navigator.pop(context); // Close loading dialog

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _showSuccessDialog(pesanan);
      } else if (response.statusCode == 422) {
        String errorMessage = 'Validation error: ';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage += errors.values.first[0];
        }
        _showSnackBar(errorMessage, Colors.red);
      } else {
        _showSnackBar(
          responseData['message'] ?? 'Gagal mengkonfirmasi pesanan',
          Colors.red,
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Error: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses konfirmasi...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(PesananDeliverModel pesanan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #${pesanan.idPesanan} berhasil dikonfirmasi sebagai diterima.',
            ),
            SizedBox(height: 8),
            Text(
              'Komentar Anda telah ditambahkan dan akan membantu pembeli lain.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              _refreshPesanan(); // Refresh data
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showPesananDetail(PesananDeliverModel pesanan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pengiriman #${pesanan.idPesanan}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('No. Resi', pesanan.noResi ?? '-'),
              _buildDetailRow('Produk', pesanan.namaProduk ?? ''),
              _buildDetailRow('Quantity', '${pesanan.quantity}'),
              _buildDetailRow(
                'Harga Produk',
                currencyFormatter.format(pesanan.hargaTotalBayar ?? 0),
              ),
              _buildDetailRow(
                'Ongkir',
                currencyFormatter.format(pesanan.ongkir ?? 0),
              ),
              _buildDetailRow(
                'Total',
                currencyFormatter.format(pesanan.totalOngkir ?? 0),
              ),
              _buildDetailRow(
                'Pembayaran',
                pesanan.tipePembayaran?.toUpperCase() ?? '',
              ),
              if (pesanan.tipePembayaran == 'dp') ...[
                _buildDetailRow(
                  'DP',
                  currencyFormatter.format(pesanan.totalDp ?? 0),
                ),
                _buildDetailRow('Status DP', pesanan.getPaymentStatusText()),
              ],
              _buildDetailRow('Status', pesanan.getStatusText()),
              _buildDetailRow(
                'Alamat',
                '${pesanan.namaKota}, ${pesanan.namaProv}',
              ),
              _buildDetailRow('Tanggal', _formatDate(pesanan.createdAt)),
            ],
          ),
        ),
        actions: [
          // if (pesanan.noResi != null && pesanan.noResi!.isNotEmpty)
          //   TextButton(
          //     onPressed: () => _lacakPaket(pesanan.noResi!),
          //     child: Text('Lacak Paket'),
          //   ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _lacakPaket(String noResi) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lacak Paket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No. Resi: $noResi'),
            SizedBox(height: 16),
            Text('Pilih kurir untuk melacak paket:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openTrackingUrl(
                'https://www.jne.co.id/id/tracking/trace',
                noResi,
              );
            },
            child: Text('JNE'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openTrackingUrl('https://www.tiki.id/id/tracking', noResi);
            },
            child: Text('TIKI'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openTrackingUrl(
                'https://www.posindonesia.co.id/id/tracking',
                noResi,
              );
            },
            child: Text('POS'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTrackingUrl(String baseUrl, String noResi) async {
    try {
      if (await canLaunch(baseUrl)) {
        await launch(baseUrl);
      } else {
        _showSnackBar('Tidak dapat membuka browser', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengiriman'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refreshPesanan, icon: Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pesananList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshPesanan,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: pesananList.length,
                itemBuilder: (context, index) {
                  return _buildPesananCard(pesananList[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pesanan dalam pengiriman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pesanan yang sedang dikirim akan muncul di sini',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananCard(PesananDeliverModel pesanan) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan #${pesanan.idPesanan}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pesanan.getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: pesanan.getStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 14,
                        color: pesanan.getStatusColor(),
                      ),
                      SizedBox(width: 4),
                      Text(
                        pesanan.getStatusText(),
                        style: TextStyle(
                          color: pesanan.getStatusColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Resi info
            if (pesanan.noResi != null && pesanan.noResi!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. Resi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pesanan.getFormattedResi(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        // TextButton(
                        //   onPressed: () => _lacakPaket(pesanan.noResi!),
                        //   style: TextButton.styleFrom(
                        //     backgroundColor: Colors.purple.withOpacity(0.1),
                        //     minimumSize: Size(0, 30),
                        //   ),
                        //   child: Text(
                        //     'Lacak',
                        //     style: TextStyle(
                        //       color: Colors.purple,
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

            // Product info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$gambarUrl/produk/${pesanan.fotoProduk}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pesanan.namaProduk ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Qty: ${pesanan.quantity} / Pcs',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${pesanan.namaKota}, ${pesanan.namaProv}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Payment info (move this before SizedBox(height: 8))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      currencyFormatter.format(pesanan.totalOngkir ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (pesanan.tipePembayaran == 'dp')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'DP',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        currencyFormatter.format(pesanan.totalDp ?? 0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12),

            // Date and simplified actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(pesanan.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showPesananDetail(pesanan),
                      icon: Icon(Icons.info_outline, size: 20),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Detail',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoicePage(pesananId: pesanan.idPesanan!),
                          ),
                        );
                      },
                      icon: Icon(Icons.receipt, size: 20),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Invoice',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // Terima Pesanan button (full width)
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showKomentarDialog(pesanan),
                icon: Icon(Icons.check_circle, size: 16),
                label: Text('Terima Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }
}
