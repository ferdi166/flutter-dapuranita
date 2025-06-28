class CheckoutResponse {
  bool? success;
  String? message;
  CheckoutData? data;
  bool? redirectToCreateAlamat;

  CheckoutResponse({
    this.success,
    this.message,
    this.data,
    this.redirectToCreateAlamat,
  });

  CheckoutResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    redirectToCreateAlamat = json['redirect_to_create_alamat'];
    data = json['data'] != null ? CheckoutData.fromJson(json['data']) : null;
  }
}

class CheckoutData {
  KeranjangItem? keranjang;
  List<OngkirProvider>? ongkir;
  int? berat;
  PengirimanAlamat? pengiriman;
  List<RekeningModel>? rekening;

  CheckoutData({
    this.keranjang,
    this.ongkir,
    this.berat,
    this.pengiriman,
    this.rekening,
  });

  CheckoutData.fromJson(Map<String, dynamic> json) {
    keranjang = json['keranjang'] != null
        ? KeranjangItem.fromJson(json['keranjang'])
        : null;

    // Handle berat sebagai string atau int
    berat = json['berat'] is String
        ? int.tryParse(json['berat'])
        : json['berat'];

    pengiriman = json['pengiriman'] != null
        ? PengirimanAlamat.fromJson(json['pengiriman'])
        : null;

    if (json['ongkir'] != null) {
      ongkir = <OngkirProvider>[];
      json['ongkir'].forEach((v) {
        ongkir!.add(OngkirProvider.fromJson(v));
      });
    }

    if (json['rekening'] != null) {
      rekening = <RekeningModel>[];
      json['rekening'].forEach((v) {
        rekening!.add(RekeningModel.fromJson(v));
      });
    }
  }
}

class KeranjangItem {
  int? idKeranjang;
  int? idUser;
  int? idProduk;
  int? quantity;
  String? namaProduk;
  int? hargaProduk;
  String? fotoProduk;
  int? berat;
  String? createdAt;
  String? updatedAt;

  KeranjangItem({
    this.idKeranjang,
    this.idUser,
    this.idProduk,
    this.quantity,
    this.namaProduk,
    this.hargaProduk,
    this.fotoProduk,
    this.berat,
    this.createdAt,
    this.updatedAt,
  });

  KeranjangItem.fromJson(Map<String, dynamic> json) {
    idKeranjang = json['id_keranjang'];
    idUser = json['id_user'];
    idProduk = json['id_produk'];
    quantity = json['quantity'];
    namaProduk = json['nama_produk'];

    // Handle harga_produk sebagai string atau int
    hargaProduk = json['harga_produk'] is String
        ? int.tryParse(json['harga_produk'])
        : json['harga_produk'];

    fotoProduk = json['foto_produk'];

    // Handle berat sebagai string atau int
    berat = json['berat'] is String
        ? int.tryParse(json['berat'])
        : json['berat'];

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

// Sesuai dengan struktur response JNE
class OngkirProvider {
  String? code;
  String? name;
  List<OngkirService>? costs;

  OngkirProvider({this.code, this.name, this.costs});

  OngkirProvider.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    if (json['costs'] != null) {
      costs = <OngkirService>[];
      json['costs'].forEach((v) {
        costs!.add(OngkirService.fromJson(v));
      });
    }
  }
}

class OngkirService {
  String? service;
  String? description;
  List<OngkirCost>? cost;

  OngkirService({this.service, this.description, this.cost});

  OngkirService.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    description = json['description'];
    if (json['cost'] != null) {
      cost = <OngkirCost>[];
      json['cost'].forEach((v) {
        cost!.add(OngkirCost.fromJson(v));
      });
    }
  }
}

class OngkirCost {
  int? value;
  String? etd;
  String? note;

  OngkirCost({this.value, this.etd, this.note});

  OngkirCost.fromJson(Map<String, dynamic> json) {
    // Handle value sebagai string atau int
    value = json['value'] is String
        ? int.tryParse(json['value'])
        : json['value'];
    etd = json['etd'];
    note = json['note'];
  }
}

class PengirimanAlamat {
  int? idAlamat;
  int? idUser;
  String? noTelp;
  String? namaPenerima;
  int? idProvinsi;
  String? namaProv;
  int? idKota;
  String? namaKota;
  String? kodePos;
  String? alamatLengkap;
  String? createdAt;
  String? updatedAt;

  PengirimanAlamat({
    this.idAlamat,
    this.idUser,
    this.noTelp,
    this.namaPenerima,
    this.idProvinsi,
    this.namaProv,
    this.idKota,
    this.namaKota,
    this.kodePos,
    this.alamatLengkap,
    this.createdAt,
    this.updatedAt,
  });

  PengirimanAlamat.fromJson(Map<String, dynamic> json) {
    idAlamat = json['id_alamat'];
    idUser = json['id_user'];
    noTelp = json['no_telp'];
    namaPenerima = json['nama_penerima'];

    // Handle ID sebagai string atau int
    idProvinsi = json['id_provinsi'] is String
        ? int.tryParse(json['id_provinsi'])
        : json['id_provinsi'];

    namaProv = json['nama_prov'];

    idKota = json['id_kota'] is String
        ? int.tryParse(json['id_kota'])
        : json['id_kota'];

    namaKota = json['nama_kota'];
    kodePos = json['kode_pos'];
    alamatLengkap = json['alamat_lengkap'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class RekeningModel {
  int? idRekening;
  String? jenisRekening;
  String? noRek; // Ubah dari nomorRekening ke noRek
  String? namaRek; // Ubah dari namaRekening ke namaRek
  String? createdAt;
  String? updatedAt;

  RekeningModel({
    this.idRekening,
    this.jenisRekening,
    this.noRek,
    this.namaRek,
    this.createdAt,
    this.updatedAt,
  });

  RekeningModel.fromJson(Map<String, dynamic> json) {
    idRekening = json['id_rekening'];
    jenisRekening = json['jenis_rekening'];
    noRek = json['no_rek']; // Sesuai response API
    namaRek = json['nama_rek']; // Sesuai response API
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
