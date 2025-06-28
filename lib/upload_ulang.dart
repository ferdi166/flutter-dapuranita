import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/checkout.dart';
import 'package:dapur_anita/model/pesanan.dart';
import 'package:intl/intl.dart';

class UploadUlangPage extends StatefulWidget {
  final PesananModel pesanan;

  const UploadUlangPage({super.key, required this.pesanan});

  @override
  State<UploadUlangPage> createState() => _UploadUlangPageState();
}

class _UploadUlangPageState extends State<UploadUlangPage> {
  bool isLoading = true;
  bool isUploading = false;
  CheckoutData? uploadData;
  File? selectedImage;
  String selectedMetode = 'lunas';
  final _dpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Set metode berdasarkan pesanan sebelumnya
    selectedMetode = widget.pesanan.tipePembayaran ?? 'lunas';

    // Set DP controller jika metode DP
    if (selectedMetode == 'dp') {
      _dpController.text = (widget.pesanan.totalDp ?? 0).toString();
    }

    _fetchUploadData();
  }

  Future<void> _fetchUploadData() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse(
          '$baseUrl/checkout/uploadUlangApi/${widget.pesanan.idPesanan}?id_user=${widget.pesanan.idUser}',
        ),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final checkoutResponse = CheckoutResponse.fromJson(responseData);

      if (response.statusCode == 200 && checkoutResponse.success == true) {
        setState(() {
          uploadData = checkoutResponse.data;
        });
      } else {
        _showSnackBar(
          checkoutResponse.message ?? 'Gagal memuat data upload ulang',
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  source: ImageSource.camera,
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  source: ImageSource.gallery,
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            selectedImage = File(image.path);
          });
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  int get totalBayar {
    if (selectedMetode == 'dp') {
      return int.tryParse(_dpController.text) ?? 0;
    }
    return widget.pesanan.totalOngkir ?? 0;
  }

  Future<void> _uploadBuktiPembayaran() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      _showSnackBar('Pilih bukti pembayaran terlebih dahulu', Colors.red);
      return;
    }

    try {
      setState(() => isUploading = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pesanan/uploadStoreApi'), // Endpoint yang benar
      );

      // Add form fields sesuai dengan API requirement
      request.fields.addAll({
        'metode': selectedMetode,
        'id_pesanan': widget.pesanan.idPesanan.toString(),
        'total_bayar': totalBayar.toString(),
      });

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('bukti_bayar', selectedImage!.path),
      );

      print('Uploading bukti pembayaran...');
      print('Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _showSuccessDialog();
      } else if (response.statusCode == 422) {
        String errorMessage = 'Validation error: ';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage += errors.values.first[0];
        }
        _showSnackBar(errorMessage, Colors.red);
      } else {
        _showSnackBar(
          responseData['message'] ?? 'Gagal mengupload bukti pembayaran',
          Colors.red,
        );
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Upload Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bukti pembayaran berhasil diupload ulang.'),
            SizedBox(height: 8),
            if (selectedMetode == 'dp')
              Text(
                'DP sebesar ${currencyFormatter.format(totalBayar)} telah diterima. Pesanan akan segera dikonfirmasi.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            else
              Text(
                'Pembayaran lunas sebesar ${currencyFormatter.format(totalBayar)} telah diterima. Pesanan akan segera dikonfirmasi.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
        title: Text('Upload Ulang Bukti'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : uploadData == null
          ? Center(child: Text('Data tidak tersedia'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReasonCard(),
                    SizedBox(height: 16),
                    _buildOrderSummary(),
                    SizedBox(height: 16),
                    _buildPaymentMethod(),
                    SizedBox(height: 16),
                    _buildBankInfo(),
                    SizedBox(height: 16),
                    _buildUploadSection(),
                    SizedBox(height: 24),
                    _buildUploadButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReasonCard() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Pembayaran Ditolak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Bukti pembayaran Anda sebelumnya ditolak. Silakan upload ulang bukti pembayaran yang valid.',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final pesanan = uploadData!.keranjang!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pesanan #${widget.pesanan.idPesanan}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$baseUrl/upload/produk/${pesanan.fotoProduk}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pesanan.namaProduk ?? '',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text('Qty: ${pesanan.quantity}'),
                      SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(pesanan.hargaProduk ?? 0),
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal'),
                Text(
                  currencyFormatter.format(
                    (pesanan.hargaProduk ?? 0) * (pesanan.quantity ?? 0),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ongkir'),
                Text(currencyFormatter.format(widget.pesanan.ongkir ?? 0)),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(widget.pesanan.totalOngkir ?? 0),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RadioListTile<String>(
              value: 'lunas',
              groupValue: selectedMetode,
              onChanged: (value) {
                setState(() {
                  selectedMetode = value!;
                });
              },
              title: Text('Bayar Lunas'),
              subtitle: Text(
                'Bayar penuh ${currencyFormatter.format(widget.pesanan.totalOngkir ?? 0)}',
              ),
            ),
            RadioListTile<String>(
              value: 'dp',
              groupValue: selectedMetode,
              onChanged: (value) {
                setState(() {
                  selectedMetode = value!;
                });
              },
              title: Text('Bayar DP'),
              subtitle: Text('Bayar sebagian terlebih dahulu'),
            ),
            if (selectedMetode == 'dp') ...[
              SizedBox(height: 8),
              TextFormField(
                controller: _dpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah DP',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                  helperText:
                      'Minimal 30% dari total (${currencyFormatter.format((widget.pesanan.totalOngkir ?? 0) * 0.3)})',
                ),
                validator: (value) {
                  if (value?.isEmpty == true)
                    return 'Jumlah DP tidak boleh kosong';
                  final dp = int.tryParse(value!) ?? 0;
                  final minDp = (widget.pesanan.totalOngkir ?? 0) * 0.3;
                  if (dp < minDp) {
                    return 'DP minimal ${currencyFormatter.format(minDp)}';
                  }
                  if (dp >= (widget.pesanan.totalOngkir ?? 0)) {
                    return 'DP tidak boleh melebihi total pembayaran';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo() {
    if (uploadData?.rekening?.isEmpty ?? true) {
      return Container();
    }

    final rekening = uploadData!.rekening!.first;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer ke Rekening',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
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
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rekening.jenisRekening?.toUpperCase() ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        rekening.namaRek ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No. Rekening: ${rekening.noRek}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedMetode == 'dp'
                        ? 'Transfer DP: ${currencyFormatter.format(totalBayar)}'
                        : 'Transfer: ${currencyFormatter.format(totalBayar)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Bukti Transfer Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap untuk upload bukti transfer baru',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Format: JPG, JPEG, PNG, PDF (Max 2MB)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isUploading ? null : _uploadBuktiPembayaran,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isUploading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                selectedMetode == 'dp'
                    ? 'Upload DP ${currencyFormatter.format(totalBayar)}'
                    : 'Upload ${currencyFormatter.format(totalBayar)}',
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
    _dpController.dispose();
    super.dispose();
  }
}
