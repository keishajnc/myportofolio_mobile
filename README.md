# MyPortfolio Mobile

Aplikasi portofolio pribadi berbasis Flutter untuk Pemrograman Berbasis Platform. Proyek ini melanjutkan Tutorial 08 dan 09 dengan integrasi Django REST Framework, autentikasi token, dan CI/CD pada Tutorial 10.

- Nama: Keisha Janice Maulina Napitupulu
- NPM: 2506551232
- Kelas: PBP A

Aplikasi menampilkan kartu identitas serta aksi Lihat Proyek, Tambah Proyek, dan Login/Logout sesuai sesi. Daftar dan detail proyek dapat dibuka tanpa login. Menambah proyek membutuhkan login akun superuser Django dan menyimpan data melalui API. Drawer menyediakan navigasi Home, Lihat Proyek, Add Project, dan Login/Logout.

## Cara Menjalankan

Pastikan Flutter SDK dan Chrome sudah terpasang. Setelah mengunduh atau melakukan clone repositori, buka terminal pada folder proyek dan jalankan:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Untuk memeriksa kode:

```bash
flutter analyze
flutter test
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

## Tutorial 09: Navigation, Layouts, Forms, and Input Elements (sebelum integrasi API)

### Struktur kode

```text
lib/
  main.dart
  screens/
    menu.dart
    project_form.dart
  widgets/
    left_drawer.dart
    project_card.dart
```

- `LeftDrawer` menampilkan header My Portfolio serta menu Home dan Add Project pada kedua halaman. Navigasi drawer menutup drawer lalu menggunakan `Navigator.pushReplacement()` untuk mengganti halaman aktif.
- Tombol Tambah Proyek menggunakan `Navigator.push()` sehingga tombol Back sistem dapat kembali ke halaman utama.
- `ProjectFormPage` menggunakan `StatefulWidget`, `Form`, dan `GlobalKey<FormState>`. Nama dan deskripsi proyek wajib diisi; input kosong atau hanya spasi ditolak.
- Dropdown menyediakan Web Development, Mobile Development, Machine Learning, Data Science, dan Other. Nilai awalnya Web Development, memakai properti `initialValue`.
- Teknologi dan tautan proyek dapat dikosongkan sesuai contoh tutorial.
- Save memvalidasi formulir dan menampilkan kelima isian pada `AlertDialog`. Tombol OK menutup dialog, mengosongkan semua field dan data input, serta mengembalikan kategori ke Web Development. Data belum dikirim ke backend atau disimpan ke database.
- Halaman utama, formulir, dan isi dialog dapat digulir ketika ruang layar terbatas.

### Flutter 3.47 dan 3.50

Lingkungan pengerjaan memakai Flutter 3.47.9 dan Dart 3.13.7. Sesuai catatan PDF, dependensi `material_ui` ditambahkan melalui `flutter pub add material_ui`. Semua impor Material dalam kode aplikasi dan tes menggunakan `package:material_ui/material_ui.dart`, agar sesuai dengan pemisahan pustaka Material pada Flutter 3.50 tanpa harus memperbarui SDK lokal. Versi dependensi terkunci dalam `pubspec.lock`.

Referensi: [panduan migrasi resmi Flutter](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).

### Pemeriksaan

```bash
flutter analyze
flutter test
flutter run -d chrome
```

Tes widget mencakup tampilan identitas pada layar mobile, navigasi kartu dan Back sistem, navigasi drawer dengan penggantian route, validasi input kosong/spasi, seluruh isi dialog, reset kategori dan isian, pengiriman kedua tanpa data lama, perilaku SnackBar, serta formulir/dialog panjang pada layar kecil.

### Penggunaan AI pada Tutorial 09

Saya menggunakan Codex untuk membantu merapikan kode navigasi/formulir, memperbarui impor Material dan menjalankan pemeriksaan.

## Tutorial 10: Backend Integration, Authentication, and CI/CD

### Backend pendamping

Backend berada di `../myportofolio`. Karena backend sebelumnya berisi Experience dan Skill, model Project beserta serializer, migrasi, dan endpoint ditambahkan sebagai resource tersendiri. API Experience/Skill tetap tersedia dan sekarang menerima autentikasi token maupun session. Hak akses pemilik/editor yang sudah ada tetap berlaku.

Jalankan dari direktori backend:

```powershell
.\env\Scripts\python.exe -m pip install -r requirements.txt
.\env\Scripts\python.exe manage.py migrate
.\env\Scripts\python.exe manage.py runserver
```

Gunakan akun superuser Django yang sudah ada untuk menambah proyek. Jika belum memiliki akun, buat sendiri melalui `python manage.py createsuperuser` dalam virtual environment backend.

| Metode | Endpoint | Akses |
| --- | --- | --- |
| GET | `/api/v1/projects/` | Publik; array JSON |
| GET | `/api/v1/projects/<uuid>/` | Publik; detail proyek |
| POST | `/api/v1/projects/` | Superuser; `Authorization: Token <key>` |
| POST | `/api/v1/auth/token/` | Username/password; mengembalikan token |
| POST | `/api/v1/auth/logout/` | Mencabut token aktif; 204 tanpa body |

`TokenAuthentication` ditempatkan sebelum `SessionAuthentication`: permintaan tanpa token mendapat 401, pengguna biasa yang mencoba menambah proyek mendapat 403, dan penggunaan session di web tetap memerlukan CSRF. `django-cors-headers` mengizinkan origin lokal ketika `PRODUCTION=False`; produksi memakai daftar `CORS_ALLOWED_ORIGINS` dari environment.

### Struktur integrasi Flutter

```text
lib/
  config.dart
  main.dart
  models/project.dart
  screens/login_screen.dart
  screens/menu.dart
  screens/project_form.dart
  screens/project_list_screen.dart
  screens/project_detail_screen.dart
  services/api_client.dart
  services/auth_state.dart
  widgets/auth_guard.dart
  widgets/left_drawer.dart
  widgets/project_card.dart
```

- `Project` memakai `@JsonSerializable(fieldRename: FieldRename.snake)`. Field `id` hanya dibaca dari server; `project_image_url` yang hilang/null menjadi string kosong. Berkas `project.g.dart` dihasilkan oleh build_runner dan diabaikan Git/linter.
- `ApiClient` mengirim JSON melalui `http`, menangani respons non-2xx dengan `ApiException`, dan membatasi waktu tunggu 20 detik. UI menampilkan pesan kegagalan tanpa menampilkan HTML/debug server.
- `ProjectListScreen` menyimpan Future di `initState()`, menampilkan loading/error/kosong/data, mendukung retry serta pull-to-refresh termasuk saat kosong. Ketukan proyek membuka detail dan gambar opsional dengan penanganan gambar gagal.
- `AuthState` menyimpan token hanya di memori melalui `ChangeNotifier` dan `provider`. Restart aplikasi mengharuskan login ulang. Logout selalu menghapus sesi lokal, termasuk ketika server gagal dihubungi.
- `ensureLoggedIn()` melindungi navigasi kartu/drawer dan pengiriman form. Setelah login sukses, pengguna melanjutkan ke form; membatalkan login tidak membuka form.
- Form mengikuti skema API: Title, Description, Tech Stack, Project URL, dan Project Image URL (Optional). URL harus HTTP/HTTPS. Save menonaktifkan pengiriman ganda dan baru mengonfirmasi sesudah server menyimpan proyek. Respons 401 menghapus sesi dan meminta login lagi sambil mempertahankan isian; sesudah login tekan Save lagi. Respons 403 tidak menampilkan konfirmasi sukses.

### Target perangkat

`lib/config.dart` memakai `http://10.0.2.2:8000` sebagai default untuk emulator Android. Android memiliki izin INTERNET; HTTP lokal hanya diaktifkan pada manifest debug. APK release menggunakan HTTPS.

```bash
# Chrome + Django lokal
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000

# Emulator Android + Django lokal
flutter run

# Android fisik via USB
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Backend yang telah di-deploy
flutter run --dart-define=API_BASE_URL=https://keisha-janice-myportofolio.pws.cs.ui.ac.id
```

Konfigurasi Chrome dan emulator tersedia di `.vscode/launch.json`. URL deployment baru dapat dipakai setelah perubahan backend beserta migrasinya diterapkan ke server.

### CI/CD

`.github/workflows/main.yaml` berjalan pada push ke `main` dan pull request. Job `build` memakai `very_good_workflows@v2` untuk generator, format, analisis, serta pengujian. Flutter dipatok ke versi lokal 3.47.9. Job `build_apk` menunggu CI berhasil, membangun APK release, lalu mengunggah artefak `app-release-apk`.

Variabel GitHub Actions `API_BASE_URL` dapat diisi URL backend HTTPS. Jika tidak diisi, workflow memakai domain PWS proyek ini sebagai fallback. Jangan simpan password atau token dalam variabel tersebut. Pipeline akan berjalan setelah perubahan di-push; pembuatan file workflow lokal belum menjalankan GitHub Actions.

### Pemeriksaan Tutorial 10

```bash
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:8000
```

Pengujian mencakup kontrak JSON/HTTP, autentikasi dan pencabutan token, pembersihan sesi saat koneksi gagal, route guard, navigasi drawer, validasi form, respons 401/403, penyimpanan ke API, loading/error/retry, daftar kosong yang dapat di-refresh, dan detail proyek.

### Penggunaan AI pada Tutorial 10

Codex membantu menerapkan integrasi sesuai tutorial, menambahkan prasyarat API Project pada backend, menyusun pengujian, dan menjalankan pemeriksaan lokal.
