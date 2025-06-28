import 'package:flutter/material.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:dapur_anita/home_page.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key, this.idBarang});
  final String? idBarang;

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  String? id;
  TextEditingController namaController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();
  TextEditingController beratController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController hargaProdukController = TextEditingController();
  TextEditingController deskripsiProdukController = TextEditingController();

  String? gambar;
  @override
  void initState() {
    super.initState();
    var idBarang = widget.idBarang;
    id = idBarang;
    ambilDataEdit(id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Barang")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama Produk"),
            ),
            TextFormField(
              controller: kategoriController,
              decoration: InputDecoration(labelText: "Kategori"),
            ),
            TextFormField(
              controller: beratController,
              decoration: InputDecoration(labelText: "Berat"),
            ),
            TextFormField(
              controller: stokController,
              decoration: InputDecoration(labelText: "Stok"),
            ),
            TextFormField(
              controller: hargaProdukController,
              decoration: InputDecoration(labelText: "Harga"),
            ),
            TextFormField(
              controller: deskripsiProdukController,
              decoration: InputDecoration(labelText: "Deskripsi"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onSubmit(id!);
                  },
                  child: Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSubmit(id!);
                  },
                  child: Text("Clear"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> ambilDataEdit(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/editApi/$id'));

    if (response.statusCode == 200) {
      final user = json.decode(response.body)['user'];

      namaController.text = user['nama_produk'];
      kategoriController.text = user['id_kategori'].toString();
      beratController.text = user['berat'];
      stokController.text = user['stok'].toString();
      hargaProdukController.text = user['harga_produk'].toString();
      deskripsiProdukController.text = user['deskripsi_produk'];
      gambar = user['foto_produk'];
    }
  }

  Future<void> onSubmit(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateApi/$id'),
      headers: {'Content-Type': 'application/json; charser=UTF-8'},
      body: jsonEncode({
        "nama_produk": namaController.text,
        "kategori_produk": kategoriController.text,
        "berat_produk": beratController.text,
        "stok_produk": stokController.text,
        "harga_produk": hargaProdukController.text,
        "deskripsi_produk": deskripsiProdukController.text,
        "img1": gambar,
      }),
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print(response);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Pesan"),
          content: const Text(
            "Data Berhasil disimpan, Silahkan kembali ke Utama",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      throw Exception(response.body);
    }
  }
}
