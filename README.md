# 🍲 Dapur Anita

Dapur Anita adalah aplikasi e-commerce berbasis Flutter yang memudahkan pelanggan untuk berbelanja produk makanan secara online, melakukan checkout, pembayaran, pelacakan pesanan, hingga melihat riwayat transaksi. Aplikasi ini juga menyediakan fitur manajemen produk untuk admin.

## ✨ Fitur Utama

### 👩‍🍳 Untuk Pelanggan

- 📝 **Registrasi & Login**: Autentikasi pengguna dengan penyimpanan sesi.
- 🛒 **Lihat Produk**: Jelajahi berbagai produk makanan dengan filter kategori.
- 🧺 **Keranjang Belanja**: Tambahkan produk ke keranjang dan atur jumlah pembelian.
- 📦 **Checkout**: Pilih alamat pengiriman, metode pembayaran, dan jasa pengiriman.
- 💳 **Pembayaran**: Upload bukti pembayaran, dukungan pembayaran lunas & DP.
- 📜 **Riwayat Pesanan**: Lihat status pesanan, detail, invoice, dan riwayat transaksi.
- 🚚 **Pelacakan Pengiriman**: Lacak status pengiriman dengan nomor resi.
- 🔄 **Upload Ulang Bukti**: Jika pembayaran ditolak, upload ulang bukti pembayaran.

### 🛠️ Untuk Admin

- 🗂️ **Manajemen Produk**: Tambah, edit, dan hapus produk.
- 🏷️ **Manajemen Kategori**: Kelola kategori produk.
- 📊 **Laporan Penjualan**: Lihat riwayat pesanan dan status pembayaran.

## 🛠️ Teknologi yang Digunakan

- 💙 **Flutter**: Framework utama aplikasi mobile.
- 🎯 **Dart**: Bahasa pemrograman utama.
- 🔗 **REST API**: Komunikasi dengan backend Laravel.
- 🌐 **HTTP**: Untuk request data ke server.
- 💾 **Shared Preferences**: Penyimpanan data lokal (session, user info).
- 🧾 **PDF & Printing**: Generate dan cetak invoice pesanan.
- 🖼️ **Image Picker**: Upload bukti pembayaran.
- 📅 **Intl**: Format tanggal dan mata uang.
- 📂 **Path Provider & Share Plus**: Download dan bagikan file PDF invoice.

## 📁 Struktur Folder

```
lib/
  admin/                # Halaman admin (tambah/edit produk)
  login/                # Halaman login
  model/                # Model data (produk, keranjang, pesanan, dsb)
  register/             # Halaman registrasi
  widgets/              # Widget custom
  alamat.dart           # Manajemen alamat pengiriman
  checkout.dart         # Proses checkout
  home_page.dart        # Halaman utama
  invoice_page.dart     # Halaman dan PDF invoice
  keranjang_saya.dart   # Halaman keranjang belanja
  konstanta.dart        # Konstanta aplikasi (baseUrl, dsb)
  lihat_produk.dart     # Detail produk
  main.dart             # Entry point aplikasi
  pembayaran.dart       # Proses pembayaran
  pesanan.dart          # Daftar pesanan user
  pesanan_deliver.dart  # Daftar pesanan dalam pengiriman
  riwayat_pesanan.dart  # Riwayat pesanan selesai
  upload_ulang.dart     # Upload ulang bukti pembayaran
```

## ▶️ Cara Menjalankan

1. **Clone repository ini**

   ```
   git clone https://github.com/USERNAME/dapur_anita.git
   cd dapur_anita
   ```

2. **Install dependencies**

   ```
   flutter pub get
   ```

3. **Jalankan aplikasi**

   ```
   flutter run
   ```

4. **Konfigurasi Backend**
   - Pastikan backend Laravel berjalan dan `baseUrl` di `lib/konstanta.dart` sudah sesuai dengan alamat server API Anda.

## ℹ️ Catatan

- 🖨️ Untuk fitur cetak/download invoice, aplikasi menggunakan package `pdf`, `printing`, dan `share_plus`.
- 🌐 Pastikan device/emulator memiliki akses internet untuk load gambar produk dan komunikasi API.
- 🖼️ Jika ada error gambar produk tidak muncul, pastikan URL gambar valid dan file tersedia di server.

## 🤝 Kontribusi

Kontribusi sangat terbuka! Silakan fork repository ini dan ajukan pull request untuk perbaikan atau penambahan fitur.

---

**Dapur Anita** - Belanja makanan jadi mudah, cepat, dan aman.
