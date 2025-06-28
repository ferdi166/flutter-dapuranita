import 'package:dapur_anita/model/produk.dart';

class KategoriModel {
  int? idKategori;
  String? namaKategori;
  String? deskripsiKategori;
  String? createdAt;
  String? updatedAt;

  KategoriModel({
    this.idKategori,
    this.namaKategori,
    this.deskripsiKategori,
    this.createdAt,
    this.updatedAt,
  });

  KategoriModel.fromJson(Map<String, dynamic> json) {
    idKategori = json['id_kategori'];
    namaKategori = json['nama_kategori'];
    deskripsiKategori = json['deskripsi_kategori'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_kategori'] = this.idKategori;
    data['nama_kategori'] = this.namaKategori;
    data['deskripsi_kategori'] = this.deskripsiKategori;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ProdukKategoriResponse {
  bool? success;
  String? message;
  ProdukKategoriData? data;
  int? totalProduk;

  ProdukKategoriResponse({
    this.success,
    this.message,
    this.data,
    this.totalProduk,
  });

  ProdukKategoriResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ProdukKategoriData.fromJson(json['data'])
        : null;
    totalProduk = json['total_produk'];
  }
}

class ProdukKategoriData {
  List<KategoriModel>? kategori;
  List<ProdukResponModel>? produk;

  ProdukKategoriData({this.kategori, this.produk});

  ProdukKategoriData.fromJson(Map<String, dynamic> json) {
    if (json['kategori'] != null) {
      kategori = <KategoriModel>[];
      json['kategori'].forEach((v) {
        kategori!.add(KategoriModel.fromJson(v));
      });
    }
    if (json['produk'] != null) {
      produk = <ProdukResponModel>[];
      json['produk'].forEach((v) {
        produk!.add(ProdukResponModel.fromJson(v));
      });
    }
  }
}
