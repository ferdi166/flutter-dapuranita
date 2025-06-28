class KeranjangModel {
  int? idKeranjang;
  int? idUser;
  int? idProduk;
  int? quantity;
  String? createdAt;
  String? updatedAt;
  String? namaProduk;
  int? hargaProduk;
  String? fotoProduk;
  String? namaKategori;

  KeranjangModel({
    this.idKeranjang,
    this.idUser,
    this.idProduk,
    this.quantity,
    this.createdAt,
    this.updatedAt,
    this.namaProduk,
    this.hargaProduk,
    this.fotoProduk,
    this.namaKategori,
  });

  KeranjangModel.fromJson(Map<String, dynamic> json) {
    idKeranjang = json['id_keranjang'];
    idUser = json['id_user'];
    idProduk = json['id_produk'];
    quantity = json['quantity'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    namaProduk = json['nama_produk'];
    hargaProduk = json['harga_produk'];
    fotoProduk = json['foto_produk'];
    namaKategori = json['nama_kategori'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_keranjang'] = idKeranjang;
    data['id_user'] = idUser;
    data['id_produk'] = idProduk;
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['nama_produk'] = namaProduk;
    data['harga_produk'] = hargaProduk;
    data['foto_produk'] = fotoProduk;
    data['nama_kategori'] = namaKategori;
    return data;
  }
}