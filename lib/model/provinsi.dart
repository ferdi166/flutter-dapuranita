class ProvinsiResponse {
  bool? success;
  String? message;
  List<ProvinsiModel>? data;

  ProvinsiResponse({this.success, this.message, this.data});

  ProvinsiResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ProvinsiModel>[];
      json['data'].forEach((v) {
        data!.add(ProvinsiModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProvinsiModel {
  String? provinceId;
  String? province;

  ProvinsiModel({this.provinceId, this.province});

  ProvinsiModel.fromJson(Map<String, dynamic> json) {
    provinceId = json['province_id'];
    province = json['province'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['province_id'] = provinceId;
    data['province'] = province;
    return data;
  }
}
