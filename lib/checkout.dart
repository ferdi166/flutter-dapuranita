import 'package:dapur_anita/pembayaran.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/model/checkout.dart';
import 'package:dapur_anita/alamat.dart';
import 'package:intl/intl.dart';

class Checkout extends StatefulWidget {
  final int keranjangId;

  const Checkout({super.key, required this.keranjangId});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool isLoading = true;
  int? userId;
  CheckoutData? checkoutData;

  // Selected values - perbaiki tipe
  OngkirService? selectedOngkirService;
  OngkirCost? selectedOngkirCost;
  RekeningModel? selectedRekening;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id');
    if (userId != null) {
      _fetchCheckoutData();
    } else {
      setState(() => isLoading = false);
      _showSnackBar('Anda belum login', Colors.red);
    }
  }

  Future<void> _fetchCheckoutData() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse(
          '$baseUrl/checkout/indexApi/${widget.keranjangId}?id_user=$userId',
        ),
        headers: {'Accept': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      final checkoutResponse = CheckoutResponse.fromJson(responseData);

      if (response.statusCode == 200 && checkoutResponse.success == true) {
        setState(() {
          checkoutData = checkoutResponse.data;

          // Set default ongkir jika ada
          if (checkoutData?.ongkir?.isNotEmpty == true) {
            final firstProvider = checkoutData!.ongkir!.first;
            if (firstProvider.costs?.isNotEmpty == true) {
              selectedOngkirService = firstProvider.costs!.first;
              if (selectedOngkirService?.cost?.isNotEmpty == true) {
                selectedOngkirCost = selectedOngkirService!.cost!.first;
              }
            }
          }

          // Set default rekening jika ada
          if (checkoutData?.rekening?.isNotEmpty == true) {
            selectedRekening = checkoutData!.rekening!.first;
          }
        });
      } else if (response.statusCode == 404 &&
          checkoutResponse.redirectToCreateAlamat == true) {
        _showAlamatDialog();
      } else {
        _showSnackBar(
          checkoutResponse.message ?? 'Gagal memuat data checkout',
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

  void _showAlamatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Alamat Pengiriman'),
        content: Text(
          'Anda belum memiliki alamat pengiriman. Buat alamat terlebih dahulu untuk melanjutkan checkout.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlamatPage()),
              ).then((_) {
                _fetchCheckoutData();
              });
            },
            child: Text('Buat Alamat'),
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

  int get totalHarga {
    if (checkoutData?.keranjang == null) return 0;
    final subtotal =
        (checkoutData!.keranjang!.hargaProduk ?? 0) *
        (checkoutData!.keranjang!.quantity ?? 0);
    final ongkir = selectedOngkirCost?.value ?? 0;
    return subtotal + ongkir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : checkoutData == null
          ? Center(child: Text('Data tidak tersedia'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductCard(),
                  SizedBox(height: 16),
                  _buildShippingCard(),
                  SizedBox(height: 16),
                  _buildOngkirCard(),
                  SizedBox(height: 16),
                  _buildPaymentCard(),
                  SizedBox(height: 16),
                  _buildSummaryCard(),
                  SizedBox(height: 24),
                  _buildCheckoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard() {
    final keranjang = checkoutData!.keranjang!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$gambarUrl/produk/${keranjang.fotoProduk}',
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
                        keranjang.namaProduk ?? '',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(keranjang.hargaProduk ?? 0),
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Qty: ${keranjang.quantity} | Berat: ${checkoutData!.berat}g',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingCard() {
    final pengiriman = checkoutData!.pengiriman!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Alamat Pengiriman',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AlamatPage()),
                    ).then((_) => _fetchCheckoutData());
                  },
                  child: Text('Ubah'),
                ),
              ],
            ),
            Divider(),
            Text(
              pengiriman.namaPenerima ?? '',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(pengiriman.noTelp ?? ''),
            SizedBox(height: 4),
            Text(
              '${pengiriman.alamatLengkap}, ${pengiriman.namaKota}, ${pengiriman.namaProv} ${pengiriman.kodePos}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngkirCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Pilih Pengiriman',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            if (checkoutData!.ongkir?.isNotEmpty == true)
              ...checkoutData!.ongkir!.map((provider) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        provider.name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    if (provider.costs != null)
                      ...provider.costs!.map((service) {
                        return Column(
                          children: service.cost!.map((cost) {
                            final isSelected =
                                selectedOngkirService == service &&
                                selectedOngkirCost == cost;
                            return RadioListTile<String>(
                              value: '${service.service}_${cost.value}',
                              groupValue:
                                  selectedOngkirService != null &&
                                      selectedOngkirCost != null
                                  ? '${selectedOngkirService!.service}_${selectedOngkirCost!.value}'
                                  : null,
                              onChanged: (value) {
                                setState(() {
                                  selectedOngkirService = service;
                                  selectedOngkirCost = cost;
                                });
                              },
                              title: Text(
                                '${service.service} - ${service.description}',
                              ),
                              subtitle: Text(
                                '${currencyFormatter.format(cost.value ?? 0)} (${cost.etd} hari)',
                              ),
                              dense: true,
                            );
                          }).toList(),
                        );
                      }).toList(),
                  ],
                );
              }).toList()
            else
              Text('Tidak ada opsi pengiriman tersedia'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Pilih Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            if (checkoutData!.rekening?.isNotEmpty == true)
              ...checkoutData!.rekening!.map((rekening) {
                return RadioListTile<int>(
                  value: rekening.idRekening!,
                  groupValue: selectedRekening?.idRekening,
                  onChanged: (value) {
                    setState(() {
                      selectedRekening = rekening;
                    });
                  },
                  title: Text(rekening.jenisRekening ?? ''),
                  subtitle: Text('${rekening.noRek} - ${rekening.namaRek}'),
                  dense: true,
                );
              }).toList()
            else
              Text('Tidak ada metode pembayaran tersedia'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final subtotal =
        (checkoutData!.keranjang!.hargaProduk ?? 0) *
        (checkoutData!.keranjang!.quantity ?? 0);
    final ongkir = selectedOngkirCost?.value ?? 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Ringkasan Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),

            // Produk detail
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${checkoutData?.keranjang?.namaProduk}'),
                Text('x${checkoutData?.keranjang?.quantity}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal'),
                Text(currencyFormatter.format(subtotal)),
              ],
            ),
            SizedBox(height: 8),

            // Shipping detail
            if (selectedOngkirService != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedOngkirService?.service} (${selectedOngkirCost?.etd} hari)',
                  ),
                  Text(currencyFormatter.format(ongkir)),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ongkos Kirim'),
                  Text(currencyFormatter.format(ongkir)),
                ],
              ),

            SizedBox(height: 8),
            Text(
              'Berat total: ${checkoutData?.berat}g',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Bayar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormatter.format(totalHarga),
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

  Widget _buildCheckoutButton() {
    final isComplete =
        selectedOngkirService != null &&
        selectedOngkirCost != null &&
        selectedRekening != null;

    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isComplete ? _processCheckout : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Bayar ${currencyFormatter.format(totalHarga)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _processCheckout() {
    if (selectedOngkirService == null ||
        selectedOngkirCost == null ||
        selectedRekening == null) {
      _showSnackBar('Lengkapi semua pilihan terlebih dahulu', Colors.red);
      return;
    }

    // Debug info
    print('=== CHECKOUT DEBUG INFO ===');
    print('Keranjang ID: ${checkoutData?.keranjang?.idKeranjang}');
    print('User ID: $userId');
    print('Produk: ${checkoutData?.keranjang?.namaProduk}');
    print('Quantity: ${checkoutData?.keranjang?.quantity}');
    print(
      'Subtotal: ${(checkoutData!.keranjang!.hargaProduk ?? 0) * (checkoutData!.keranjang!.quantity ?? 0)}',
    );
    print(
      'Pengiriman: ${selectedOngkirService?.service} - ${selectedOngkirService?.description}',
    );
    print('Ongkir: ${selectedOngkirCost?.value}');
    print('ETD: ${selectedOngkirCost?.etd} hari');
    print('Total Berat: ${checkoutData?.berat}g');
    print(
      'Rekening: ${selectedRekening?.jenisRekening?.toUpperCase()} - ${selectedRekening?.noRek}',
    );
    print('Penerima: ${selectedRekening?.namaRek}');
    print('Total Bayar: $totalHarga');
    print(
      'Alamat: ${checkoutData?.pengiriman?.alamatLengkap}, ${checkoutData?.pengiriman?.namaKota}',
    );
    print('========================');

    // Tampilkan dialog konfirmasi
    _showCheckoutConfirmation();
  }

  void _showCheckoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Checkout'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${checkoutData?.keranjang?.namaProduk} x${checkoutData?.keranjang?.quantity}',
              ),
              SizedBox(height: 8),

              Text(
                'Pengiriman:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${selectedOngkirService?.service} - ${selectedOngkirService?.description}',
              ),
              Text(
                'Ongkir: ${currencyFormatter.format(selectedOngkirCost?.value ?? 0)}',
              ),
              SizedBox(height: 8),

              Text(
                'Pembayaran:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${selectedRekening?.jenisRekening?.toUpperCase()} - ${selectedRekening?.noRek}',
              ),
              Text('a.n ${selectedRekening?.namaRek}'),
              SizedBox(height: 8),

              Text('Alamat:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${checkoutData?.pengiriman?.namaPenerima}'),
              Text('${checkoutData?.pengiriman?.noTelp}'),
              Text('${checkoutData?.pengiriman?.alamatLengkap}'),
              Text(
                '${checkoutData?.pengiriman?.namaKota}, ${checkoutData?.pengiriman?.namaProv} ${checkoutData?.pengiriman?.kodePos}',
              ),
              SizedBox(height: 8),

              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    currencyFormatter.format(totalHarga),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeCheckout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              'Lanjut ke Pembayaran',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _executeCheckout() {
    // Navigasi ke halaman pembayaran
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          checkoutData: checkoutData!,
          selectedOngkirService: selectedOngkirService!,
          selectedOngkirCost: selectedOngkirCost!,
          selectedRekening: selectedRekening!,
          totalHarga: totalHarga,
        ),
      ),
    );
  }
}
