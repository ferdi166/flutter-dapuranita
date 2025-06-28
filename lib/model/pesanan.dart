import 'package:flutter/material.dart';

class PesananResponse {
  bool? success;
  String? message;
  List<PesananModel>? data;
  int? totalPesanan;

  PesananResponse({this.success, this.message, this.data, this.totalPesanan});

  PesananResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    totalPesanan = json['total_pesanan'];
    if (json['data'] != null) {
      data = <PesananModel>[];
      json['data'].forEach((v) {
        data!.add(PesananModel.fromJson(v));
      });
    }
  }
}

class PesananModel {
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

  // Join fields
  String? namaProduk;
  String? fotoProduk;
  String? namaKota;
  String? namaProv;

  PesananModel({
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
    this.namaProduk,
    this.fotoProduk,
    this.namaKota,
    this.namaProv,
  });

  PesananModel.fromJson(Map<String, dynamic> json) {
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

  // Helper methods
  String getStatusText() {
    switch (status) {
      case 0:
        return 'Pembayaran di Tolak';
      case 1:
        return 'Pembayaran Sedang Di Tinjau';
      case 2:
        return 'Pesanan Anda Sedang Di Buat';
      case 3:
        return 'Dalam Pengiriman';
      case 4:
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
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
    switch (status) {
      case 0:
        return Icons.hourglass_empty;
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.local_shipping;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method untuk mendapatkan sisa pembayaran jika DP
  int getSisaPembayaran() {
    if (tipePembayaran == 'dp' && dpStatus == 'dp') {
      return (totalOngkir ?? 0) - (totalDp ?? 0);
    }
    return 0;
  }

  // Helper method untuk cek apakah bisa dibayar lunas
  bool canPayRemaining() {
    return tipePembayaran == 'dp' && dpStatus == 'dp' && status != 3;
  }

  // Helper method untuk total harga produk
  int getTotalHargaProduk() {
    return (hargaTotalBayar ?? 0) * (quantity ?? 0);
  }

  // Helper method untuk cek apakah pembayaran sudah lunas
  bool isFullyPaid() {
    if (tipePembayaran == 'lunas') return true;
    if (tipePembayaran == 'dp') {
      return dpStatus == 'lunas';
    }
    return false;
  }
}
