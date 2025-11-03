# Rifansi

Aplikasi mobile untuk manajemen pekerjaan, progres harian, dan biaya proyek berbasis Flutter dengan arsitektur GetX dan backend GraphQL.

## Fitur Utama

- **Autentikasi**
- **Dashboard & Splash** (navigasi awal dengan GetX routes)
- **Manajemen SPK**: daftar SPK, detail, progres per item kerja, ringkasan anggaran
- **Aktivitas Harian**: input progres harian per item kerja, status, cuaca, jam kerja, catatan penutup
- **Log Biaya**: material, tenaga kerja (manpower), peralatan (equipment), biaya lainnya (other costs)
- **Peralatan**: jam kerja, bahan bakar, tarif sewa, laporan kerusakan
- **Area & Lokasi**: filter berdasarkan area/lokasi
- **Approval & Pelacakan**: status persetujuan, progress percentage, total spent vs budget
- **Tema Terang/Gelap** otomatis mengikuti sistem
- **Lokalisasi Indonesia**: format tanggal/angka `id_ID`

## Teknologi & Dependensi

- **Framework**: Flutter (Dart SDK ">=3.2.3 <4.0.0")
- **State Management & Routing**: GetX (`get`)
- **API**: `graphql_flutter`
- **Penyimpanan Lokal**: `hive`, `hive_flutter`, `get_storage`
- **Keamanan**: `flutter_secure_storage`
- **Utilitas UI**: `google_fonts`, `flutter_svg`, `dropdown_button2`, `marquee`
- **Media & Kompresi**: `image_picker`, `flutter_image_compress`, `exif`
- **Lainnya**: `intl`, `path_provider`, `local_auth`

Dev dependencies: `build_runner`, `json_serializable`, `hive_generator`, `flutter_lints`, `flutter_test`.

## Struktur Proyek (ringkas)

- `lib/main.dart`: inisialisasi layanan (GraphQL, Storage, Hive), controller, tema, route awal
- `lib/app/routes/`: definisi `AppPages` dan `Routes`
- `lib/app/theme/`: tema terang/gelap
- `lib/app/controllers/`: logika GetX per fitur (auth, spk, aktivitas harian, equipment, dll.)
- `lib/app/data/models/`: model JSON/Hive dgn generator
- `lib/app/data/providers/`:
  - `graphql_service.dart`: klien GraphQL, query/mutation, endpoint
  - `storage_service.dart`, `hive_service.dart`
- `lib/app/modules/`: halaman UI (mis. `login`, `splash`, dll.)
- `lib/app/core/widgets/`: komponen UI umum (loading, dialog, image viewer, dsb.)

## Persiapan & Menjalankan

1. Instal Flutter dan aktifkan platform target (Android/iOS)
2. Jalankan perintah berikut:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Untuk mode pengembangan dengan auto-generate:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Konfigurasi

- **Endpoint GraphQL**: di `lib/app/data/providers/graphql_service.dart`

```dart
final String baseUrl = 'https://app25.rifansi.co.id/graphql';
```

Ubah `baseUrl` sesuai environment (staging/production) bila diperlukan.

- **Auth Token**: Header Bearer otomatis lewat `AuthLink` dengan token yang diambil dari `StorageService` (`flutter_secure_storage`). Pastikan proses login menyimpan token terlebih dahulu.

- **Lokalisasi**: `main.dart` menginisialisasi `initializeDateFormatting('id_ID')` dan `Intl.defaultLocale = 'id_ID'`.

## Aset

Terkonfigurasi di `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/logo_light.png
    - assets/images/
```

Simpan gambar ke dalam folder `assets/images/`, lalu jalankan `flutter pub get` bila ada perubahan.

## Perizinan (ringkas)

- **Kamera/Galeri/Storage**: `image_picker`
- **Biometrik**: `local_auth`

Konfigurasi sesuai platform:
- Android: pastikan permission di `AndroidManifest.xml` (kamera, storage bila diperlukan). Untuk biometrik, gunakan `USE_BIOMETRIC`/`USE_FINGERPRINT` sesuai versi.
- iOS: tambahkan key yang relevan di `Info.plist` (akses foto/kamera/biometrik).

## Skrip Umum

- Generate model/adapter: `dart run build_runner build --delete-conflicting-outputs`
- Watch mode: `dart run build_runner watch --delete-conflicting-outputs`

## Troubleshooting

- **Timeout GraphQL (20 detik)**: koneksi lambat/endpoint tidak dapat diakses. Cek jaringan/endpoint/token.
- **Perubahan model tidak ter-reflect**: jalankan kembali build runner (build atau watch) dan bersihkan build bila perlu (`flutter clean`).
- **Gagal membaca token**: pastikan login sukses dan izin keamanan aktif. Di emulator iOS, sometimes perlu reinstall app agar keychain diset ulang.
- **Gambar besar/rotasi salah**: proyek sudah memakai `flutter_image_compress` dan `exif`; pastikan izin dan metadata gambar tersedia.

## Lisensi

Internal project. Hak cipta pemilik repositori.

