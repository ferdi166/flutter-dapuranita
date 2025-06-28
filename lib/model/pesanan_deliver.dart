import 'package:flutter/material.dart';

class PesananDeliverResponse {
  bool? success;
  String? message;
  List<PesananDeliverModel>? data;
  int? totalPesanan;

  PesananDeliverResponse({
    this.success,
    this.message,
    this.data,
    this.totalPesanan,
  });

  PesananDeliverResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    totalPesanan = json['total_pesanan'];
    if (json['data'] != null) {
      data = <PesananDeliverModel>[];
      json['data'].forEach((v) {
        data!.add(PesananDeliverModel.fromJson(v));
      });
    }
  }
}

class PesananDeliverModel {
  int? idPesanan;
  int? idProduk;
  int? idUser;
  int? quantity;
  int? hargaTotalBayar;
  int? ongkir;
  int? totalOngkir;
  String? buktiBayar;
  String? buktiBayarDp;
  String? buktiBayarDpLunas;
  int? totalDp;
  String? dpStatus;
  int? status;
  String? tipePembayaran;
  String? createdAt;
  String? updatedAt;
  
  // Join fields from resi table - fix: bisa int atau string
  String? noResi;
  
  // Join fields from produk table
  String? namaProduk;
  String? fotoProduk;
  
  // Join fields from alamat_user table
  String? namaKota;
  String? namaProv;

  PesananDeliverModel({
    this.idPesanan,
    this.idProduk,
    this.idUser,
    this.quantity,
    this.hargaTotalBayar,
    this.ongkir,
    this.totalOngkir,
    this.buktiBayar,
    this.buktiBayarDp,
    this.buktiBayarDpLunas,
    this.totalDp,
    this.dpStatus,
    this.status,
    this.tipePembayaran,
    this.createdAt,
    this.updatedAt,
    this.noResi,
    this.namaProduk,
    this.fotoProduk,
    this.namaKota,
    this.namaProv,
  });

  PesananDeliverModel.fromJson(Map<String, dynamic> json) {
    // Handle int fields
    idPesanan = _parseInt(json['id_pesanan']);
    idProduk = _parseInt(json['id_produk']);
    idUser = _parseInt(json['id_user']);
    quantity = _parseInt(json['quantity']);
    hargaTotalBayar = _parseInt(json['harga_total_bayar']);
    ongkir = _parseInt(json['ongkir']);
    totalOngkir = _parseInt(json['total_ongkir']);
    totalDp = _parseInt(json['total_dp']);
    status = _parseInt(json['status']);
    
    // Handle string fields
    buktiBayar = json['bukti_bayar'];
    buktiBayarDp = json['bukti_bayar_dp'];
    buktiBayarDpLunas = json['bukti_bayar_dp_lunas'];
    dpStatus = json['dp_status'];
    tipePembayaran = json['tipe_pembayaran'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    
    // Join fields
    // Fix: no_resi bisa berupa int atau string
    noResi = _parseToString(json['no_resi']);
    namaProduk = json['nama_produk'];
    fotoProduk = json['foto_produk'];
    namaKota = json['nama_kota'];
    namaProv = json['nama_prov'];
  }

  // Helper method untuk parsing int yang aman
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  // Helper method untuk parsing ke string yang aman
  String? _parseToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  // Helper methods
  String getStatusText() {
    return 'Dalam Pengiriman';
  }

  Color getStatusColor() {
    return Colors.purple;
  }

  String getPaymentStatusText() {
    if (tipePembayaran == 'dp') {
      if (dpStatus == 'dp') {
        return 'DP Dibayar';
      } else if (dpStatus == 'lunas') {
        return 'Lunas';
      } else {
        return 'Menunggu DP';
      }
    }
    return 'Lunas';
  }

  // Helper method untuk icon status
  IconData getStatusIcon() {
    return Icons.local_shipping;
  }

  // Helper method untuk format resi yang lebih baik
  String getFormattedResi() {
    if (noResi == null || noResi!.isEmpty) return '-';
    // Jika resi berupa angka panjang, bisa diformat dengan spasi atau dash
    if (noResi!.length > 8) {
      // Format: 1234-5678-90
      return noResi!.replaceAllMapped(
        RegExp(r'(\d{4})(?=\d)'),
        (match) => '${match.group(1)}-',
      );
    }
    return noResi!;
  }
}
