// file: lib/model/invoice.dart
class InvoiceResponse {
  bool? success;
  String? message;
  InvoiceModel? data;

  InvoiceResponse({this.success, this.message, this.data});

  InvoiceResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? InvoiceModel.fromJson(json['data']) : null;
  }
}

class InvoiceModel {
  int? idPesanan;
  int? idProduk;
  int? idUser;
  int? quantity;
  int? hargaTotalBayar;
  int? ongkir;
  int? totalOngkir;
  String? buktiBayar;
  String? buktiBayarDp;
  int? totalDp;
  String? dpStatus;
  int? status;
  String? tipePembayaran;
  String? createdAt;
  String? updatedAt;

  // Join fields from alamat_user table
  String? alamatLengkap;
  String? namaPenerima;
  String? noTelp;
  String? namaProv;
  String? namaKota;

  // Join fields from produk table
  String? namaProduk;
  int? hargaProduk;
  String? fotoProduk;
  int? berat;

  InvoiceModel({
    this.idPesanan,
    this.idProduk,
    this.idUser,
    this.quantity,
    this.hargaTotalBayar,
    this.ongkir,
    this.totalOngkir,
    this.buktiBayar,
    this.buktiBayarDp,
    this.totalDp,
    this.dpStatus,
    this.status,
    this.tipePembayaran,
    this.createdAt,
    this.updatedAt,
    this.alamatLengkap,
    this.namaPenerima,
    this.noTelp,
    this.namaProv,
    this.namaKota,
    this.namaProduk,
    this.hargaProduk,
    this.fotoProduk,
    this.berat,
  });

  InvoiceModel.fromJson(Map<String, dynamic> json) {
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
    hargaProduk = _parseInt(json['harga_produk']);
    berat = _parseInt(json['berat']);

    // Handle string fields
    buktiBayar = json['bukti_bayar'];
    buktiBayarDp = json['bukti_bayar_dp'];
    dpStatus = json['dp_status'];
    tipePembayaran = json['tipe_pembayaran'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    // Join fields from alamat_user
    alamatLengkap = json['alamat_lengkap'];
    namaPenerima = json['nama_penerima'];
    noTelp = json['no_telp'];
    namaProv = json['nama_prov'];
    namaKota = json['nama_kota'];

    // Join fields from produk
    namaProduk = json['nama_produk'];
    fotoProduk = json['foto_produk'];
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

  int getSubtotal() {
    return (hargaProduk ?? 0) * (quantity ?? 0);
  }

  String getPaymentMethod() {
    return tipePembayaran?.toUpperCase() ?? 'LUNAS';
  }
}
