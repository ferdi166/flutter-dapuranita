import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/checkout.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final CheckoutData checkoutData;
  final OngkirService selectedOngkirService;
  final OngkirCost selectedOngkirCost;
  final RekeningModel selectedRekening;
  final int totalHarga;

  const PaymentPage({
    super.key,
    required this.checkoutData,
    required this.selectedOngkirService,
    required this.selectedOngkirCost,
    required this.selectedRekening,
    required this.totalHarga,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _dpController = TextEditingController();

  String selectedMetode = 'lunas';
  File? selectedImage;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Set default DP ke 50% dari total
    _dpController.text = (widget.totalHarga * 0.5).round().toString();
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

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      _showSnackBar('Pilih bukti pembayaran terlebih dahulu', Colors.red);
      return;
    }

    try {
      setState(() => isLoading = true);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pesanan/storePesananApi'),
      );

      // Add form fields
      request.fields.addAll({
        'metode': selectedMetode,
        'id_keranjang': widget.checkoutData.keranjang!.idKeranjang.toString(),
        'id_produk': widget.checkoutData.keranjang!.idProduk.toString(),
        'id_user': widget.checkoutData.keranjang!.idUser.toString(),
        'quantity': widget.checkoutData.keranjang!.quantity.toString(),
        'harga_produk': widget.checkoutData.keranjang!.hargaProduk.toString(),
        'ongkir': widget.selectedOngkirCost.value.toString(),
        'total_bayar': widget.totalHarga.toString(),
      });

      // Add DP field if payment method is DP
      if (selectedMetode == 'dp') {
        request.fields['dp'] = _dpController.text;
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('bukti_bayar', selectedImage!.path),
      );

      print('Sending payment request...');
      print('Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
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
          responseData['message'] ?? 'Gagal memproses pembayaran',
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

  // Alternative: Custom success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              SizedBox(height: 16),

              // Title
              Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Content
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Pesanan Anda telah berhasil dibuat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    Divider(),
                    SizedBox(height: 8),

                    if (selectedMetode == 'dp') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DP Dibayar:', style: TextStyle(fontSize: 14)),
                          Text(
                            currencyFormatter.format(
                              int.tryParse(_dpController.text) ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Silakan lakukan pelunasan sesuai instruksi yang akan diberikan.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Dibayar:',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            currencyFormatter.format(widget.totalHarga),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pembayaran lunas telah diterima.\nPesanan akan segera diproses.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to payment page
                    Navigator.pop(context); // Back to checkout page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        title: Text('Pembayaran'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              SizedBox(height: 16),
              _buildPaymentMethod(),
              SizedBox(height: 16),
              _buildBankInfo(),
              SizedBox(height: 16),
              _buildUploadBukti(),
              SizedBox(height: 24),
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Produk'),
                Text('${widget.checkoutData.keranjang!.namaProduk}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity'),
                Text('${widget.checkoutData.keranjang!.quantity}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal'),
                Text(
                  currencyFormatter.format(
                    (widget.checkoutData.keranjang!.hargaProduk ?? 0) *
                        (widget.checkoutData.keranjang!.quantity ?? 0),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ongkir (${widget.selectedOngkirService.service})'),
                Text(
                  currencyFormatter.format(
                    widget.selectedOngkirCost.value ?? 0,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(widget.totalHarga),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                'Bayar penuh ${currencyFormatter.format(widget.totalHarga)}',
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
                      'Minimal 30% dari total (${currencyFormatter.format(widget.totalHarga * 0.3)})',
                ),
                validator: (value) {
                  if (value?.isEmpty == true)
                    return 'Jumlah DP tidak boleh kosong';
                  final dp = int.tryParse(value!) ?? 0;
                  final minDp = widget.totalHarga * 0.3;
                  if (dp < minDp) {
                    return 'DP minimal ${currencyFormatter.format(minDp)}';
                  }
                  if (dp >= widget.totalHarga) {
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
                          widget.selectedRekening.jenisRekening
                                  ?.toUpperCase() ??
                              '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.selectedRekening.namaRek ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No. Rekening: ${widget.selectedRekening.noRek}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedMetode == 'dp'
                        ? 'Transfer DP: ${currencyFormatter.format(int.tryParse(_dpController.text) ?? 0)}'
                        : 'Transfer: ${currencyFormatter.format(widget.totalHarga)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
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

  Widget _buildUploadBukti() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Bukti Transfer',
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
                            'Tap untuk upload bukti transfer',
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

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                selectedMetode == 'dp'
                    ? 'Bayar DP ${currencyFormatter.format(int.tryParse(_dpController.text) ?? 0)}'
                    : 'Bayar ${currencyFormatter.format(widget.totalHarga)}',
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
