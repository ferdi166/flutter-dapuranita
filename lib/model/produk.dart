class ProdukResponModel {
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

  ProdukResponModel({
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

  ProdukResponModel.fromJson(Map<String, dynamic> json) {
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
