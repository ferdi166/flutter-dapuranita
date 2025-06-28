import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/alamat.dart';
import 'package:dapur_anita/widgets/searchable_field.dart';
import 'package:dapur_anita/widgets/searchable_dialog.dart';
import 'package:dapur_anita/widgets/custom_text_field.dart';
import 'package:dapur_anita/model/provinsi.dart';
import 'package:dapur_anita/model/city.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodePosController = TextEditingController();

  // State variables
  bool isLoading = true;
  bool hasAlamat = false;
  int? userId;
  int? alamatId; // Tambahkan ini untuk menyimpan ID alamat

  // Dropdown data
  List<ProvinsiModel> provinsiList = [];
  List<CityModel> kotaList = [];
  List<CityModel> filteredKotaList = [];

  // Selected values
  String? selectedProvinsiId;
  String? selectedKotaId;
  String? selectedProvinsiName;
  String? selectedKotaName;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');
    if (userId != null) {
      await _loadDropdownData();
      _fetchExistingAlamat();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Anda belum login', Colors.red);
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      setState(() => isLoading = true);

      final results = await Future.wait([_fetchProvinsi(), _fetchKota()]);

      provinsiList = results[0] as List<ProvinsiModel>;
      kotaList = results[1] as List<CityModel>;
    } catch (e) {
      print('Error loading dropdown data: $e');
      _showSnackBar('Gagal memuat data provinsi/kota', Colors.red);
    }
  }

  Future<List<ProvinsiModel>> _fetchProvinsi() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provinsi'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final provinsiResponse = ProvinsiResponse.fromJson(responseData);
          return provinsiResponse.data ?? [];
        }
      }
      throw Exception('Failed to load provinsi');
    } catch (e) {
      print('Error fetching provinsi: $e');
      return [];
    }
  }

  Future<List<CityModel>> _fetchKota() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/city'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final cityResponse = CityResponse.fromJson(responseData);
          return cityResponse.data ?? [];
        }
      }
      throw Exception('Failed to load cities');
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  Future<void> _fetchExistingAlamat() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alamat/indexApi?id_user=$userId'),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final alamatData = responseData['data']['alamat'];
        _setExistingData(alamatData);
      } else if (response.statusCode == 404) {
        setState(() => hasAlamat = false);
      } else {
        _showSnackBar(
          responseData['message'] ?? 'Gagal memuat alamat',
          Colors.red,
        );
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _setExistingData(Map<String, dynamic> alamatData) {
    setState(() {
      hasAlamat = true;
      alamatId = alamatData['id_alamat'];
      _namaController.text = alamatData['nama_penerima'] ?? '';
      _nomorHpController.text = alamatData['no_telp'] ?? '';
      _alamatController.text = alamatData['alamat_lengkap'] ?? '';
      _kodePosController.text = alamatData['kode_pos'] ?? '';

      selectedProvinsiId = alamatData['id_provinsi']?.toString();
      selectedProvinsiName = alamatData['nama_prov'];
      selectedKotaId = alamatData['id_kota']?.toString();
      selectedKotaName = alamatData['nama_kota'];

      if (selectedProvinsiId != null) {
        filteredKotaList = kotaList
            .where((city) => city.provinceId == selectedProvinsiId)
            .toList();
      }
    });
  }

  void _onProvinsiChanged(String? provinsiId) {
    setState(() {
      selectedProvinsiId = provinsiId;
      selectedKotaId = null;
      selectedKotaName = null;

      final provinsi = provinsiList.firstWhere(
        (p) => p.provinceId == provinsiId,
        orElse: () => ProvinsiModel(),
      );
      selectedProvinsiName = provinsi.province;

      filteredKotaList = kotaList
          .where((city) => city.provinceId == provinsiId)
          .toList();
    });
  }

  void _onKotaChanged(String? kotaId) {
    setState(() {
      selectedKotaId = kotaId;

      final kota = filteredKotaList.firstWhere(
        (k) => k.cityId == kotaId,
        orElse: () => CityModel(),
      );
      selectedKotaName = kota.cityName;
    });
  }

  Future<void> _showProvinsiSearch() async {
    final result = await showDialog<ProvinsiModel>(
      context: context,
      builder: (context) => SearchableDialog<ProvinsiModel>(
        title: 'Pilih Provinsi',
        items: provinsiList,
        displayText: (item) => item.province ?? '',
        searchHint: 'Cari provinsi...',
        currentValue: selectedProvinsiId,
        compareValue: (item) => item.provinceId,
      ),
    );

    if (result != null) {
      _onProvinsiChanged(result.provinceId);
    }
  }

  Future<void> _showKotaSearch() async {
    if (selectedProvinsiId == null) {
      _showSnackBar('Pilih provinsi terlebih dahulu', Colors.orange);
      return;
    }

    final result = await showDialog<CityModel>(
      context: context,
      builder: (context) => SearchableDialog<CityModel>(
        title: 'Pilih Kota',
        items: filteredKotaList,
        displayText: (item) => '${item.type} ${item.cityName}',
        searchHint: 'Cari kota...',
        currentValue: selectedKotaId,
        compareValue: (item) => item.cityId,
      ),
    );

    if (result != null) {
      _onKotaChanged(result.cityId);
    }
  }

  Future<void> _simpanAlamat() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateDropdowns()) return;

    try {
      setState(() => isLoading = true);

      // Format data sesuai requirement API
      final provinsiData = '$selectedProvinsiId|$selectedProvinsiName';
      final kotaData = '$selectedKotaId|$selectedKotaName';

      print('Sending ${hasAlamat ? 'update' : 'store'} request...');
      print('Provinsi: $provinsiData');
      print('Kota: $kotaData');

      http.Response response;

      if (hasAlamat) {
        // Update alamat existing
        response = await http.put(
          Uri.parse('$baseUrl/alamat/updateApi/$alamatId?id_user=$userId'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: {
            'nama': _namaController.text,
            'telp': _nomorHpController.text,
            'alamat': _alamatController.text,
            'kode_pos': _kodePosController.text,
            'provinsi': provinsiData,
            'kota': kotaData,
          },
        );
      } else {
        // Tambah alamat baru
        response = await http.post(
          Uri.parse('$baseUrl/alamat/storeApi?id_user=$userId'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: {
            'nama': _namaController.text,
            'telp': _nomorHpController.text,
            'alamat': _alamatController.text,
            'kode_pos': _kodePosController.text,
            'provinsi': provinsiData,
            'kota': kotaData,
          },
        );
      }

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        _showSnackBar(
          responseData['message'] ??
              (hasAlamat
                  ? 'Alamat berhasil diupdate'
                  : 'Alamat berhasil ditambahkan'),
          Colors.green,
        );

        // Refresh data setelah berhasil
        await _fetchExistingAlamat();
      } else if (response.statusCode == 422) {
        // Validation error
        String errorMessage = 'Validation error: ';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage += errors.values.first[0];
        }
        _showSnackBar(errorMessage, Colors.red);
      } else {
        _showSnackBar(
          responseData['message'] ??
              (hasAlamat
                  ? 'Gagal mengupdate alamat'
                  : 'Gagal menambahkan alamat'),
          Colors.red,
        );
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateDropdowns() {
    if (selectedProvinsiId == null) {
      _showSnackBar('Pilih provinsi terlebih dahulu', Colors.red);
      return false;
    }
    if (selectedKotaId == null) {
      _showSnackBar('Pilih kota terlebih dahulu', Colors.red);
      return false;
    }
    return true;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hasAlamat ? "Edit Alamat" : "Tambah Alamat"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildFormFields(),
                    SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                hasAlamat
                    ? 'Edit Alamat Pengiriman'
                    : 'Tambah Alamat Pengiriman',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            hasAlamat
                ? 'Perbarui data alamat pengiriman Anda'
                : 'Lengkapi data alamat untuk pengiriman pesanan',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _namaController,
          label: 'Nama Penerima',
          icon: Icons.person,
          validator: (value) => value?.isEmpty == true
              ? 'Nama penerima tidak boleh kosong'
              : null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _nomorHpController,
          label: 'Nomor HP',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty == true ? 'Nomor HP tidak boleh kosong' : null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _alamatController,
          label: 'Alamat Lengkap',
          icon: Icons.home,
          maxLines: 3,
          validator: (value) => value?.isEmpty == true
              ? 'Alamat lengkap tidak boleh kosong'
              : null,
        ),
        SizedBox(height: 16),
        SearchableField(
          label: 'Provinsi',
          icon: Icons.map,
          value: selectedProvinsiName,
          onTap: _showProvinsiSearch,
        ),
        SizedBox(height: 16),
        SearchableField(
          label: 'Kota',
          icon: Icons.location_city,
          value: selectedKotaName,
          onTap: _showKotaSearch,
          enabled: selectedProvinsiId != null,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _kodePosController,
          label: 'Kode Pos',
          icon: Icons.markunread_mailbox,
          keyboardType: TextInputType.number,
          validator: (value) =>
              value?.isEmpty == true ? 'Kode pos tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _simpanAlamat,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                hasAlamat ? 'Update Alamat' : 'Simpan Alamat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorHpController.dispose();
    _alamatController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }
}
