class AlamatModel {
  bool? success;
  String? message;
  Data? data;

  AlamatModel({this.success, this.message, this.data});

  AlamatModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Alamat? alamat;
  List<Provinsi>? provinsi;
  List<City>? city;

  Data({this.alamat, this.provinsi, this.city});

  Data.fromJson(Map<String, dynamic> json) {
    alamat = json['alamat'] != null
        ? new Alamat.fromJson(json['alamat'])
        : null;
    if (json['provinsi'] != null) {
      provinsi = <Provinsi>[];
      json['provinsi'].forEach((v) {
        provinsi!.add(new Provinsi.fromJson(v));
      });
    }
    if (json['city'] != null) {
      city = <City>[];
      json['city'].forEach((v) {
        city!.add(new City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.alamat != null) {
      data['alamat'] = this.alamat!.toJson();
    }
    if (this.provinsi != null) {
      data['provinsi'] = this.provinsi!.map((v) => v.toJson()).toList();
    }
    if (this.city != null) {
      data['city'] = this.city!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Alamat {
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

  Alamat({
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

  Alamat.fromJson(Map<String, dynamic> json) {
    idAlamat = json['id_alamat'];
    idUser = json['id_user'];
    noTelp = json['no_telp'];
    namaPenerima = json['nama_penerima'];
    idProvinsi = json['id_provinsi'];
    namaProv = json['nama_prov'];
    idKota = json['id_kota'];
    namaKota = json['nama_kota'];
    kodePos = json['kode_pos'];
    alamatLengkap = json['alamat_lengkap'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_alamat'] = this.idAlamat;
    data['id_user'] = this.idUser;
    data['no_telp'] = this.noTelp;
    data['nama_penerima'] = this.namaPenerima;
    data['id_provinsi'] = this.idProvinsi;
    data['nama_prov'] = this.namaProv;
    data['id_kota'] = this.idKota;
    data['nama_kota'] = this.namaKota;
    data['kode_pos'] = this.kodePos;
    data['alamat_lengkap'] = this.alamatLengkap;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Provinsi {
  String? provinceId;
  String? province;

  Provinsi({this.provinceId, this.province});

  Provinsi.fromJson(Map<String, dynamic> json) {
    provinceId = json['province_id'];
    province = json['province'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['province_id'] = this.provinceId;
    data['province'] = this.province;
    return data;
  }
}

class City {
  String? cityId;
  String? provinceId;
  String? province;
  String? type;
  String? cityName;
  String? postalCode;

  City({
    this.cityId,
    this.provinceId,
    this.province,
    this.type,
    this.cityName,
    this.postalCode,
  });

  City.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    provinceId = json['province_id'];
    province = json['province'];
    type = json['type'];
    cityName = json['city_name'];
    postalCode = json['postal_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city_id'] = this.cityId;
    data['province_id'] = this.provinceId;
    data['province'] = this.province;
    data['type'] = this.type;
    data['city_name'] = this.cityName;
    data['postal_code'] = this.postalCode;
    return data;
  }
}
