import 'package:flutter/material.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dapur_anita/model/kategori.dart';
import 'package:dapur_anita/home_page.dart';

class AddProduk extends StatefulWidget {
  const AddProduk({super.key});

  @override
  State<AddProduk> createState() => _AddProdukState();
}

class _AddProdukState extends State<AddProduk> {
  String? _valKategori;
  String result = '';
  TextEditingController nama_produk = TextEditingController();
  TextEditingController kategori_produk = TextEditingController();
  TextEditingController berat_produk = TextEditingController();
  TextEditingController stok_produk = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController deskripsi_produk = TextEditingController();
  File? image;

  @override
  void initState() {
    super.initState();
    ambilKategori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Data Produk"),
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: nama_produk,
              decoration: InputDecoration(labelText: "Nama Produk"),
            ),
            FutureBuilder<List<KategoriModel>>(
              future: ambilKategori(),
              builder: (context, snapshot) {
                print("hasil ");
                print(snapshot.data);
                if (snapshot.hasData) {
                  // Add this debug print to verify data
                  return DropdownButtonFormField(
                    decoration: InputDecoration(labelText: "Kategori"),
                    hint: Text("Pilih Kategori Makanan"),
                    value: _valKategori,
                    items: snapshot.data
                        ?.map(
                          (isi) => DropdownMenuItem<String>(
                            child: Text(isi.namaKategori.toString()),
                            value: isi.idKategori.toString(),
                          ),
                        )
                        .toList(),
                    onChanged: (newvalue) {
                      setState(() => _valKategori = newvalue);
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            TextFormField(
              controller: berat_produk,
              decoration: InputDecoration(labelText: "Berat Produk"),
            ),
            TextFormField(
              controller: stok_produk,
              decoration: InputDecoration(labelText: "Stok Produk"),
            ),
            TextFormField(
              controller: harga,
              decoration: InputDecoration(labelText: "Harga"),
            ),
            TextFormField(
              controller: deskripsi_produk,
              decoration: InputDecoration(labelText: "Deskripsi Produk"),
            ),
            ElevatedButton(onPressed: pickImage, child: Text("Pilih Gambar")),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: onSubmit, child: Text("Submit")),
            SizedBox(height: 20.0),
            Text("$image dipilih", style: TextStyle(fontSize: 18.0)),
            Container(),
          ],
        ),
      ),
    );
  }

  Future<List<KategoriModel>> ambilKategori() async {
    print("Fetching categories from: $baseUrl/kategoriApi");
    final response = await http.get(Uri.parse('$baseUrl/kategoriApi'));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<KategoriModel> kategoriList = data
          .map((e) => KategoriModel.fromJson(e))
          .toList();
      return kategoriList;
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> onSubmit() async {
    var nama = nama_produk.text;
    var header = {'Content-Type': 'multipart/form-data'};
    final request = await http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/storeApi'),
    );
    request.fields['nama_produk'] = nama_produk.text;
    request.fields['kategori_produk'] = _valKategori!;
    request.fields['berat_produk'] = berat_produk.text;
    request.fields['stok_produk'] = stok_produk.text;
    request.fields['harga_produk'] = harga.text;
    request.fields['deskripsi_produk'] = deskripsi_produk.text;
    request.headers.addAll(header);
    request.files.add(await http.MultipartFile.fromPath('img1', image!.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Simpan Data Berhasil'),
            content: Text("$nama Berhasil di Simpan"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Data gagal disimpan!"),
            content: Text("$nama Tidak Berhasil Disimpan!"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      print("HTTP CODE:${response.statusCode}");
    }
  }
}
