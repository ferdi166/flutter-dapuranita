import 'dart:convert';

import 'package:dapur_anita/model/produk.dart';
import 'package:flutter/material.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LihatProduk extends StatefulWidget {
  final ProdukResponModel produk;
  const LihatProduk({super.key, required this.produk});

  @override
  State<LihatProduk> createState() => LihatProdukState();
}

class LihatProdukState extends State<LihatProduk> {
  int quantity = 1;
  bool isLoading = false;

  Future<void> tambahKeranjang() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Anda belum login"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Sending request to: $baseUrl/keranjang/storeApi');
      print('User ID: $userId');
      print('Product ID: ${widget.produk.idProduk}');
      print('Quantity: $quantity');

      final response = await http.post(
        Uri.parse('$baseUrl/keranjang/storeApi'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id_user': userId.toString(),
          'id_produk': widget.produk.idProduk.toString(),
          'quantity': quantity.toString(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  'Produk berhasil ditambahkan ke keranjang',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Stok tidak mencukupi'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Error lainnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Gagal menambahkan ke keranjang',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
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

  @override
  Widget build(BuildContext context) {
    var gambar = widget.produk.fotoProduk.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lihat Produk"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage('$gambarUrl/produk/$gambar'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.produk.namaKategori ?? "",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.produk.namaProduk ?? "",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "Rp ${widget.produk.hargaProduk != null ? widget.produk.hargaProduk.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') : "0"}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24),

            // deskripsi produk
            Text(
              "Deskripsi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.produk.deskripsiProduk ?? "",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),

            // Jumlah
            Text(
              "Jumlah",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // tambah keranjang
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading || (widget.produk.stok ?? 0) == 0
                    ? null
                    : tambahKeranjang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading || (widget.produk.stok ?? 0) == 0
                      ? Colors.grey
                      : Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        (widget.produk.stok ?? 0) == 0
                            ? "Stok Habis"
                            : "Tambah ke Keranjang",
                        style: TextStyle(
                          fontSize: 18,
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
  }
}
