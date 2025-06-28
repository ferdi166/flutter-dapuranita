import 'package:dapur_anita/alamat.dart';
import 'package:dapur_anita/keranjang_saya.dart';
import 'package:dapur_anita/login/form_login.dart';
import 'package:dapur_anita/pesanan.dart';
import 'package:dapur_anita/pesanan_deliver.dart';
import 'package:dapur_anita/riwayat_pesanan.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dapur_anita/konstanta.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dapur_anita/model/produk.dart';
import 'package:dapur_anita/admin/tambah_produk.dart';
import 'package:dapur_anita/admin/edit_produk.dart';

import 'package:dapur_anita/lihat_produk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.id, this.name, this.email, this.type});

  final int? id;
  final String? name;
  final String? email;
  final String? type;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? id;
  bool isAdmin = false;
  bool isCustomer = false;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    fetchData();
    getTypeValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Belanja Hemat dan Mudah",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      // navigation drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text(
                name ?? "Belum Login",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                email ?? "Belum Login",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: Image(
                image: AssetImage("assets/img/Logo_small.png"),
              ),
            ),
            if (isAdmin == false && isCustomer == false) ...[
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Login"),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => PageLogin()));
                },
              ),
            ] else if (isAdmin == true) ...[
              ListTile(
                leading: Icon(Icons.train),
                title: Text("Tambah Barang"),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => AddProduk()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  logOut(context);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => PageLogin()));
                },
              ),
            ] else if (isCustomer == true) ...[
              ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("Produk"),
                onTap: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  ); // Close drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text("Keranjang Saya"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KeranjangSaya()),
                  ); // Close drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text("Alamat Antar"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AlamatPage()),
                  ); // Close drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text("Lihat Pesanan"),
                onTap: () {
                  // Navigate to View Orders page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PesananPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.local_shipping),
                title: Text("Pengiriman"),
                onTap: () {
                  // Navigate to Shipping page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PesananDeliverPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text("Riwayat Pesanan"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RiwayatPesananPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  logOut(context);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => PageLogin()));
                },
              ),
            ],
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder<List<ProdukResponModel>>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var gambar = snapshot.data![index].fotoProduk.toString();
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                      width: double.infinity,
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            width: 150,
                            height: 128,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xffdbd8dd),
                              image: DecorationImage(
                                image: NetworkImage(
                                  '$gambarUrl/produk/$gambar' ??
                                      "'$gambarUrl/produk/download.jpg",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(2, 0, 0, 10),
                                    child: Text(
                                      snapshot.data![index].namaProduk
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Text(
                                    "Harga:${snapshot.data![index].hargaProduk.toString()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isAdmin == true) ...[
                                  Container(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            var idBarang = snapshot
                                                .data![index]
                                                .idProduk
                                                .toString();
                                            goEdit(idBarang);
                                          },
                                          icon: Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            var idBarang = snapshot
                                                .data![index]
                                                .idProduk
                                                .toString();
                                            delete(idBarang);
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (isCustomer == true) ...[
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LihatProduk(
                                              produk: snapshot.data![index],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
                                        "Lihat Produk",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.add_box),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.linked_camera),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // Return a loading indicator while waiting for data
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Future<List<ProdukResponModel>> fetchData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getProduk'),
      headers: {
        'Content-Type':
            'application/json; charset=UTF-8; Connection: KeepAlive',
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //final Map<String, dynamic> result =
      jsonDecode(response.body);
      //return ProdukResponModel.fromJson(result);
      List data = jsonDecode(response.body);
      List<ProdukResponModel> produkList = data
          .map((e) => ProdukResponModel.fromJson(e))
          .toList();
      return produkList;
    } else {
      throw Exception('Failed to load Produk');
    }
  }

  getTypeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString('type');
    String? nama = prefs.getString('name');
    String? email1 = prefs.getString('email');
    setState(() {
      fetchData();
      if (stringValue == "admin") {
        isAdmin = true;
        name = nama;
        email = email1;
      } else if (stringValue == "customer") {
        isCustomer = true;
        name = nama;
        email = email1;
      }
    });
  }

  logOut(BuildContext context) async {
    // untuk logout
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => PageLogin()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  goEdit(idBarang) {
    //untuk edit
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditForm(idBarang: idBarang)),
    );
  }

  Future<void> delete(String idBarang) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteApi/$idBarang'),
      );
      if (response.statusCode == 200) {
        if (!mounted) return; // Cek apakah context masih aktif
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Berhasil dihapus'),
              content: const Text("Data Berhasil dihapus"),
              actions: <Widget>[
                // ignore: deprecated_member_use
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      fetchData();
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (error) {
      print(error);
    }
  }
}
