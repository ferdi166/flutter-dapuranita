import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/keranjang.dart';
import 'package:dapur_anita/checkout.dart';

class KeranjangSaya extends StatefulWidget {
  const KeranjangSaya({super.key});

  @override
  State<KeranjangSaya> createState() => _KeranjangSayaState();
}

class _KeranjangSayaState extends State<KeranjangSaya> {
  List<KeranjangModel> keranjangList = [];
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');
    if (userId != null) {
      fetchKeranjang();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda belum login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchKeranjang() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/keranjang/indexApi?id_user=$userId'),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          keranjangList = data
              .map((item) => KeranjangModel.fromJson(item))
              .toList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Gagal memuat keranjang',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in fetchKeranjang: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateQuantity(KeranjangModel item, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.put(
        Uri.parse('$baseUrl/keranjang/updateApi/${item.idKeranjang}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'id_produk': item.idProduk.toString(),
          'quantity': newQuantity.toString(),
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Quantity berhasil diupdate',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await fetchKeranjang();
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Stok tidak mencukupi'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Gagal mengupdate quantity',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi checkout per item
  Future<void> checkoutItem(KeranjangModel item) async {
    try {
      // TODO: Implementasi API checkout per item
      // Untuk sekarang hanya tampilkan dialog konfirmasi

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Checkout Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produk: ${item.namaProduk}'),
              SizedBox(height: 8),
              Text('Quantity: ${item.quantity}'),
              SizedBox(height: 8),
              Text(
                'Harga: Rp ${item.hargaProduk?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              ),
              SizedBox(height: 8),
              Text(
                'Total: Rp ${((item.hargaProduk ?? 0) * (item.quantity ?? 0)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text('Apakah Anda yakin ingin checkout item ini?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Panggil API checkout
                processCheckout(item);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Checkout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> processCheckout(KeranjangModel item) async {
    try {
      // Loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // TODO: Ganti dengan API endpoint checkout yang sebenarnya
      await Future.delayed(Duration(seconds: 2)); // Simulasi API call

      Navigator.pop(context); // Tutup loading

      // Tampilkan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout berhasil untuk ${item.namaProduk}'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh keranjang setelah checkout
      fetchKeranjang();
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi hapus item - versi sederhana
  Future<void> hapusItem(KeranjangModel item) async {
    // Konfirmasi hapus
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Item'),
        content: Text('Apakah Anda yakin ingin menghapus ${item.namaProduk}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Jika user membatalkan
    if (confirm != true) return;

    try {
      // Set loading
      setState(() {
        isLoading = true;
      });

      final response = await http.delete(
        Uri.parse('$baseUrl/keranjang/deleteApi/${item.idKeranjang}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Delete response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Item berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus item'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Refresh data
      await fetchKeranjang();
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang Saya"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : keranjangList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang Anda Kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: keranjangList.length,
              itemBuilder: (context, index) {
                final item = keranjangList[index];
                final totalHargaItem =
                    (item.hargaProduk ?? 0) * (item.quantity ?? 0);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Gambar Produk
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    '$gambarUrl/produk/${item.fotoProduk}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            // Detail Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.namaProduk ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.namaKategori ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Rp ${item.hargaProduk?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} x ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Total: Rp ${totalHargaItem.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Hapus
                            IconButton(
                              onPressed: () => hapusItem(item),
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Hapus Item',
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Quantity Controls
                        Row(
                          children: [
                            Text(
                              'Jumlah:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if ((item.quantity ?? 0) > 1) {
                                        updateQuantity(
                                          item,
                                          (item.quantity ?? 0) - 1,
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.remove, size: 18),
                                    constraints: BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      '${item.quantity ?? 0}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      updateQuantity(
                                        item,
                                        (item.quantity ?? 0) + 1,
                                      );
                                    },
                                    icon: Icon(Icons.add, size: 18),
                                    constraints: BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Tombol Checkout per Item
                        Container(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Checkout(
                                    keranjangId: item.idKeranjang ?? 0,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Checkout Item - Rp ${totalHargaItem.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchKeranjang,
        foregroundColor: Colors.white,
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
