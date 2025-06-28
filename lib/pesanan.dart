import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/pesanan.dart';
import 'package:intl/intl.dart';

import 'package:dapur_anita/upload_ulang.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  bool isLoading = true;
  int? userId;
  List<PesananModel> pesananList = [];

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
      _fetchPesanan();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Anda belum login', Colors.red);
    }
  }

  Future<void> _fetchPesanan() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('$baseUrl/pesanan/indexApi?id_user=$userId'),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final pesananResponse = PesananResponse.fromJson(responseData);

      if (response.statusCode == 200 && pesananResponse.success == true) {
        setState(() {
          pesananList = pesananResponse.data ?? [];
        });
      } else {
        _showSnackBar(
          pesananResponse.message ?? 'Gagal memuat data pesanan',
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
    await _fetchPesanan();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showPesananDetail(PesananModel pesanan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pesanan #${pesanan.idPesanan}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
        title: Text('Pesanan Saya'),
        backgroundColor: Colors.blueAccent,
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
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pesanan Anda akan muncul di sini',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananCard(PesananModel pesanan) {
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
                  child: Text(
                    pesanan.getStatusText(),
                    style: TextStyle(
                      color: pesanan.getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
                        color: Colors.blue,
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

            // Date and action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(pesanan.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showPesananDetail(pesanan),
                      child: Text('Detail'),
                    ),

                    // Tombol Upload Ulang untuk status 0 (ditolak)
                    if (pesanan.status == 0)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UploadUlangPage(pesanan: pesanan),
                            ),
                          ).then((_) {
                            // Refresh data setelah upload ulang
                            _refreshPesanan();
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ),
                        child: Text(
                          'Upload Ulang',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    // Tombol Lunasi untuk DP
                    if (pesanan.tipePembayaran == 'dp' &&
                        pesanan.dpStatus == 'dp')
                      TextButton(
                        onPressed: () {
                          // TODO: Implement pelunasan
                          _showSnackBar(
                            'Fitur pelunasan akan segera tersedia',
                            Colors.blue,
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                        ),
                        child: Text(
                          'Lunasi',
                          style: TextStyle(color: Colors.orange),
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
