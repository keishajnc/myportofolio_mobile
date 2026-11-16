# MyPortfolio Mobile

Aplikasi portofolio pribadi berbasis Flutter untuk Tugas 7 Pemrograman Berbasis Platform. Proyek ini melanjutkan kode Tutorial 08.

- Nama: Keisha Janice Maulina Napitupulu
- NPM: 2506551232
- Kelas: PBP A

Aplikasi menampilkan kartu identitas dan tiga tombol: Lihat Proyek, Tambah Proyek, dan Logout. Setiap tombol memiliki warna berbeda dan menampilkan SnackBar ketika ditekan. Pada tahap ini, tombol belum melakukan navigasi atau autentikasi.

## Cara Menjalankan

Pastikan Flutter SDK dan Chrome sudah terpasang. Setelah mengunduh atau melakukan clone repositori, buka terminal pada folder proyek dan jalankan:

```bash
flutter pub get
flutter run -d chrome
```

Untuk memeriksa kode:

```bash
flutter analyze
```

### Tugas 7

1. **Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!**

   Widget tree adalah susunan widget berbentuk hierarki yang membangun antarmuka aplikasi. Widget induk membungkus dan mengatur tata letak widget anak.

   Properti `child` biasanya digunakan untuk satu anak, sedangkan `children` digunakan untuk beberapa anak. Contohnya, `Padding` membungkus satu widget, sementara `Column` menyusun beberapa widget secara vertikal.

   Dalam proyek ini, `MyApp` menghasilkan `MaterialApp` dengan `MyHomePage` sebagai halaman awal. MyHomePage kemudian menghasilkan Scaffold yang berisi AppBar dan body halaman.

2. **Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   | Widget | Fungsi |
   | --- | --- |
   | `MyApp` | Mengatur aplikasi melalui MaterialApp. |
   | `MyHomePage` | Menyusun halaman utama portofolio. |
   | `InfoCard` | Menampilkan kartu identitas. |
   | `ItemCard` | Menampilkan kartu tombol aksi. |
   | `MaterialApp` | Mengatur tema dan halaman awal aplikasi. |
   | `Scaffold` | Menyediakan kerangka halaman. |
   | `AppBar` | Menampilkan judul di bagian atas. |
   | `Padding` | Memberikan ruang di sekitar widget anak. |
   | `Column` | Menyusun widget secara vertikal. |
   | `Row` | Menyusun widget secara horizontal. |
   | `Card` | Membentuk kartu informasi dengan elevasi. |
   | `Container` | Mengatur ukuran dan padding kartu. |
   | `Text` | Menampilkan tulisan. |
   | `SizedBox` | Memberikan jarak antarelemen. |
   | `Center` | Menempatkan widget anak di tengah. |
   | `GridView.count` | Menyusun tombol dalam tiga kolom. |
   | `Material` | Menyediakan permukaan dan warna latar tombol. |
   | `InkWell` | Mendeteksi ketukan dan memberikan efek interaksi. |
   | `Icon` | Menampilkan ikon tombol. |
   | `SnackBar` | Menampilkan pesan sementara setelah tombol ditekan. |

   Kode juga mengakses `Theme`, `MediaQuery`, dan `ScaffoldMessenger` melalui `.of(context)` untuk mengambil tema, ukuran layar, dan pengelola SnackBar. Ketiganya tidak dibuat langsung dalam susunan widget saya.

   `ItemHomepage` adalah model data, bukan widget.

3. **Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!**

   MaterialApp menyediakan fasilitas dasar aplikasi berbasis Material Design, seperti tema, halaman awal, navigasi, dan dukungan lokalisasi.

   Widget ini umumnya ditempatkan dekat akar widget tree agar pengaturannya tersedia bagi halaman di bawahnya. Pada proyek ini, MaterialApp mengatur judul, tema warna, dan `MyHomePage` sebagai halaman awal.

   Widget yang diberikan kepada `runApp()` adalah `MyApp`, kemudian metode `build()` milik MyApp mengembalikan MaterialApp.

4. **Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?**

   StatelessWidget tidak mengelola state internal yang berubah selama interaksi pengguna. Tampilannya mengikuti konfigurasi dan informasi dari lingkungannya. Widget ini tetap dapat dibangun ulang ketika konfigurasi atau dependensinya berubah.

   StatefulWidget digunakan ketika widget perlu mengelola state yang berubah, seperti nilai penghitung atau pilihan filter. State disimpan dalam objek `State`, dan `setState()` dapat digunakan untuk memberi tahu Flutter bahwa tampilan perlu diperbarui.

   MyHomePage, InfoCard, dan ItemCard menggunakan StatelessWidget karena belum memerlukan state internal yang berubah. Tombol tetap dapat menampilkan SnackBar melalui ScaffoldMessenger tanpa menyimpan state sendiri.

5. **Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?**

   BuildContext mewakili lokasi widget dalam widget tree. Context digunakan untuk mengakses informasi atau fasilitas dari widget leluhur yang sesuai, sehingga posisi context menentukan apa yang dapat ditemukan.

   Pada metode `build(BuildContext context)`, proyek ini menggunakan:

   - `Theme.of(context)` untuk mengambil tema warna.
   - `MediaQuery.of(context)` untuk mengambil ukuran layar.
   - `ScaffoldMessenger.of(context)` untuk menampilkan SnackBar.

6. **Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?**

   Hot reload menerapkan perubahan kode dan membangun ulang widget tree sambil mempertahankan state aplikasi. Proses ini tidak menjalankan ulang `main()` atau `initState()`. Biasanya, perubahan teks, warna, dan tata letak cukup diperiksa melalui hot reload.

   Hot restart menjalankan ulang aplikasi Flutter dan menghapus state yang sedang tersimpan. Proses ini diperlukan ketika perubahan harus menjalankan kembali inisialisasi, misalnya perubahan pada `main()` atau `initState()`.

   Full restart dilakukan dengan menghentikan lalu menjalankan kembali aplikasi. Proses ini diperlukan untuk perubahan kode native, seperti Kotlin atau Swift, serta dapat diperlukan setelah menambahkan plugin dengan komponen native.

## Penggunaan AI

Saya menggunakan ChatGPT untuk membantu membaca ketentuan tugas, memberikan panduan perubahan kode, menangani overflow, serta menyusun dokumentasi dan jawaban reflektif.

Perubahan kode saya terapkan secara manual melalui VS Code, termasuk penggantian identitas, penambahan warna tombol, dan pengaturan tinggi kartu.

Hasil bantuan AI tetap perlu diperiksa. Sebagai contoh, meskipun `flutter analyze` sudah bersih, tampilan aplikasi masih mengalami overflow. Setelah diperiksa melalui Chrome, tinggi kartu diatur menggunakan `mainAxisExtent: 150` dan tampilannya diperiksa kembali.