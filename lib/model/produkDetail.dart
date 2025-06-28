class ProdukDetailModel {
  Produk? produk;
  List<Komentar>? komentar;

  ProdukDetailModel({this.produk, this.komentar});

  ProdukDetailModel.fromJson(Map<String, dynamic> json) {
    produk = json['produk'] != null
        ? new Produk.fromJson(json['produk'])
        : null;
    if (json['komentar'] != null) {
      komentar = <Komentar>[];
      json['komentar'].forEach((v) {
        komentar!.add(new Komentar.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.produk != null) {
      data['produk'] = this.produk!.toJson();
    }
    if (this.komentar != null) {
      data['komentar'] = this.komentar!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Komentar {
  // Add your comment properties here
  String? isi;
  String? pengguna;
  String? tanggal;

  Komentar({this.isi, this.pengguna, this.tanggal});

  Komentar.fromJson(Map<String, dynamic> json) {
    isi = json['isi'];
    pengguna = json['pengguna'];
    tanggal = json['tanggal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isi'] = this.isi;
    data['pengguna'] = this.pengguna;
    data['tanggal'] = this.tanggal;
    return data;
  }
}

class Produk {
  int? idProduk;
  String? namaProduk;
  int? idKategori;
  String? berat;
  int? stok;
  int? hargaProduk;
  String? deskripsiProduk;
  String? fotoProduk;
  String? createdAt;
  String? updatedAt;
  String? namaKategori;

  Produk({
    this.idProduk,
    this.namaProduk,
    this.idKategori,
    this.berat,
    this.stok,
    this.hargaProduk,
    this.deskripsiProduk,
    this.fotoProduk,
    this.createdAt,
    this.updatedAt,
    this.namaKategori,
  });

  Produk.fromJson(Map<String, dynamic> json) {
    idProduk = json['id_produk'];
    namaProduk = json['nama_produk'];
    idKategori = json['id_kategori'];
    berat = json['berat'];
    stok = json['stok'];
    hargaProduk = json['harga_produk'];
    deskripsiProduk = json['deskripsi_produk'];
    fotoProduk = json['foto_produk'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    namaKategori = json['nama_kategori'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_produk'] = this.idProduk;
    data['nama_produk'] = this.namaProduk;
    data['id_kategori'] = this.idKategori;
    data['berat'] = this.berat;
    data['stok'] = this.stok;
    data['harga_produk'] = this.hargaProduk;
    data['deskripsi_produk'] = this.deskripsiProduk;
    data['foto_produk'] = this.fotoProduk;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['nama_kategori'] = this.namaKategori;
    return data;
  }
}
