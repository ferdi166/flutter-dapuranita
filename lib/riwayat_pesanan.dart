// file: lib/riwayat_pesanan.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/riwayat_pesanan.dart';
import 'package:dapur_anita/invoice_page.dart';
import 'package:intl/intl.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  bool isLoading = true;
  int? userId;
  List<RiwayatPesananModel> pesananList = [];

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
      _fetchRiwayatPesanan();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Anda belum login', Colors.red);
    }
  }

  Future<void> _fetchRiwayatPesanan() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('$baseUrl/customer/riwayat_pesanan?id_user=$userId'),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final pesananResponse = RiwayatPesananResponse.fromJson(responseData);

      if (response.statusCode == 200 && pesananResponse.success == true) {
        setState(() {
          pesananList = pesananResponse.data ?? [];
        });
      } else {
        _showSnackBar(
          pesananResponse.message ?? 'Gagal memuat data riwayat pesanan',
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
    await _fetchRiwayatPesanan();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showPesananDetail(RiwayatPesananModel pesanan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pesanan #${pesanan.idPesanan}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('No. Resi', pesanan.getFormattedResi()),
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
              _buildDetailRow('Tanggal Pesan', _formatDate(pesanan.createdAt)),
              _buildDetailRow('Selesai', _formatDate(pesanan.updatedAt)),
            ],
          ),
        ),
        actions: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pesanan'),
        backgroundColor: Colors.green,
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
          Icon(Icons.history, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pesanan yang telah selesai akan muncul di sini',
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

  Widget _buildPesananCard(RiwayatPesananModel pesanan) {
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
                        Icons.check_circle,
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
                        'Qty: ${pesanan.quantity}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${pesanan.namaKota}, ${pesanan.namaProv}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      if (pesanan.noResi != null && pesanan.noResi!.isNotEmpty)
                        Text(
                          'Resi: ${pesanan.getFormattedResi()}',
                          style: TextStyle(
                            color: Colors.blue[600],
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

            // Payment info
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
                        color: Colors.green,
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
            SizedBox(height: 8),

            // Date completed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selesai pada:',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      _formatDate(pesanan.updatedAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showPesananDetail(pesanan),
                      child: Text('Detail'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoicePage(pesananId: pesanan.idPesanan!),
                          ),
                        );
                      },
                      icon: Icon(Icons.receipt, size: 16),
                      label: Text('Invoice'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
