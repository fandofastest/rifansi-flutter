import 'package:get/get.dart';
import '../data/models/spk_model.dart';
import '../data/models/area_model.dart' as area_model;
import '../data/providers/graphql_service.dart';
import './lokasi_controller.dart';
import '../data/models/personnel_role_model.dart' as personnel_model;
import '../data/models/equipment_model.dart' as equipment_model;
import '../data/models/daily_activity_model.dart';
import '../data/models/daily_activity_input.dart' as activity_input;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../data/providers/hive_service.dart';
import '../data/models/material_model.dart' as material_model;
import '../controllers/material_controller.dart';
import 'package:flutter/material.dart';
import '../controllers/work_progress_controller.dart';
import '../modules/add_work_report/widgets/work_progress_form.dart';
import '../controllers/other_cost_controller.dart';
import 'package:intl/intl.dart';
import '../data/models/spk_details.dart';
import 'package:exif/exif.dart';
import '../data/models/spk_detail_with_progress_response.dart';

class AddWorkReportController extends GetxController {
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Data SPK
  final selectedSpk = Rx<Spk?>(null);
  final spkList = <Spk>[].obs;
  final searchKeyword = ''.obs;

  // Form data
  final reportDate = DateTime.now().obs;
  final location = ''.obs;
  final weather = ''.obs;
  final workStartTime = DateTime.now().obs;
  final workEndTime = Rxn<DateTime>();
  final remarks = ''.obs;

  // Foto-foto
  final startPhotos = <WorkPhoto>[].obs;
  final endPhotos = <WorkPhoto>[].obs;
  final isUploadingPhoto = false.obs;
  final uploadProgress = 0.0.obs;

  // Manpower data
  final personnelRoles = <personnel_model.PersonnelRole>[].obs;
  final selectedManpower = <ManpowerEntry>[].obs;
  final isLoadingPersonnel = false.obs;

  // Equipment data
  final equipmentList = <equipment_model.Equipment>[].obs;
  final selectedEquipment = <EquipmentEntry>[].obs;
  final isLoadingEquipment = false.obs;

  // Flag untuk menandai apakah request sedang berjalan
  final _isFetchingInProgress = false.obs;

  // Token untuk upload
  final String uploadToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MmE5NzUzOTRlNGQ3ZWJkMDc1YjM2NyIsImlhdCI6MTc0NzYyMTgyMywiZXhwIjoxNzc4NzI1ODIzfQ.teq_-tgZBuaQQ5h3DxcY5xHmZIIEA6NA8omq2NLnGq8';
  final String uploadUrl = 'https://cloudfiles.fando.id/api/files/upload';

  // Layanan Hive untuk penyimpanan lokal
  late HiveService _hiveService;

  // Getter untuk akses hiveService dari luar
  HiveService get hiveService => _hiveService;

  final spkDetailsWithProgress = Rxn<SpkDetailWithProgressResponse>();

  // Work items from SPK
  final workItems = RxList<Map<String, dynamic>>([]);

  // State untuk pengurutan
  final sortBy = 'name'.obs;
  final ascending = true.obs;

  @override
  void onInit() {
    super.onInit();
    _hiveService = Get.find<HiveService>();
    fetchSPKs();
    fetchPersonnelRoles();
    fetchEquipments();
  }

  Future<bool> fetchSPKs({area_model.Area? area, String? keyword}) async {
    // Jika sudah ada request yang berjalan, batalkan
    if (_isFetchingInProgress.value) {
      print('[AddWorkReport] Fetch sudah berjalan, menunggu selesai...');
      return false;
    }

    try {
      _isFetchingInProgress.value = true;
      isLoading.value = true;
      error.value = '';

      if (keyword != null) {
        searchKeyword.value = keyword;
      }

      // Buat Completer untuk menangani timeout dan hasil
      final completer = Completer<bool>();

      // Set timeout 8 detik
      Timer(const Duration(seconds: 8), () {
        if (!completer.isCompleted) {
          print('[AddWorkReport] Timeout fetchSPKs');
          error.value = 'Timeout: Proses terlalu lama';
          completer.complete(false);
        }
      });

      // Parameter untuk query
      final locationId = area?.id.isNotEmpty == true ? area!.id : null;
      final searchKey =
          searchKeyword.value.isNotEmpty ? searchKeyword.value : null;

      print(
          '[AddWorkReport] Memulai fetch SPK: locationId=$locationId, keyword=$searchKey');

      // Fetch data
      final service = Get.find<GraphQLService>();
      service
          .fetchSPKs(
        locationId: locationId,
        keyword: searchKey,
      )
          .then((result) {
        if (!completer.isCompleted) {
          spkList.value = result;
          print('[AddWorkReport] Berhasil fetch ${spkList.length} SPK');

          // Jika SPK yang sebelumnya dipilih tidak ada lagi dalam daftar, hapus pilihan
          if (selectedSpk.value != null &&
              !spkList.any((spk) => spk.id == selectedSpk.value!.id)) {
            selectedSpk.value = null;
          }

          completer.complete(true);
        }
      }).catchError((e) {
        if (!completer.isCompleted) {
          print('[AddWorkReport] Error fetch SPKs: $e');
          error.value = e.toString();
          completer.complete(false);
        }
      });

      // Tunggu sampai fetch selesai atau timeout
      final success = await completer.future;
      return success;
    } catch (e) {
      print('[AddWorkReport] Unexpected error in fetchSPKs: $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
      _isFetchingInProgress.value = false;
    }
  }

  Future<WorkPhoto?> uploadPhoto(File file) async {
    try {
      isUploadingPhoto.value = true;
      uploadProgress.value = 0.0;
      error.value = '';

      print('[PhotoUpload] Memulai upload foto: ${file.path}');

      // Buat completer untuk menangani timeout
      final completer = Completer<WorkPhoto?>();

      // Set timeout 15 detik
      Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          print('[PhotoUpload] Timeout upload foto');
          error.value = 'Timeout: Upload foto terlalu lama';
          completer.complete(null);
        }
      });

      try {
        // Baca file sebagai bytes
        final bytes = await file.readAsBytes();
        final fileLength = bytes.length;

        // Buat form data secara manual
        final boundary = '----${DateTime.now().millisecondsSinceEpoch}';
        final uri = Uri.parse(uploadUrl);

        // Buat request dengan manual HttpClient untuk lebih banyak kontrol
        final httpClient = HttpClient();
        final request = await httpClient.postUrl(uri);

        // Tambahkan headers
        request.headers.set('Authorization', 'Bearer $uploadToken');
        request.headers
            .set('Content-Type', 'multipart/form-data; boundary=$boundary');

        // Prepare body parts
        final parts = <List<int>>[];

        // Add field isPublic
        parts.add(utf8.encode('--$boundary\r\n'));
        parts.add(utf8
            .encode('Content-Disposition: form-data; name="isPublic"\r\n\r\n'));
        parts.add(utf8.encode('true\r\n'));

        // Add file
        final filename = file.path.split('/').last;
        parts.add(utf8.encode('--$boundary\r\n'));
        parts.add(utf8.encode(
            'Content-Disposition: form-data; name="file"; filename="$filename"\r\n'));
        parts
            .add(utf8.encode('Content-Type: application/octet-stream\r\n\r\n'));
        parts.add(bytes);
        parts.add(utf8.encode('\r\n'));

        // Add end boundary
        parts.add(utf8.encode('--$boundary--\r\n'));

        // Compute content length
        int contentLength = 0;
        for (var part in parts) {
          contentLength += part.length;
        }
        request.headers.set('Content-Length', contentLength.toString());

        // Kirim data
        for (var part in parts) {
          request.add(part);
          // Update progress - estimasi kasar
          if (part == bytes) {
            uploadProgress.value = 0.8; // 80% saat file selesai dikirim
          }
        }

        // Dapatkan response
        final httpResponse = await request.close();
        uploadProgress.value = 0.9; // 90% saat mendapatkan response

        // Baca response body
        final responseBody = await httpResponse.transform(utf8.decoder).join();
        uploadProgress.value = 1.0; // 100% saat selesai

        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
          final jsonResponse = json.decode(responseBody);

          if (jsonResponse['status'] == 'success') {
            final fileData = jsonResponse['data']['file'];

            // Buat object WorkPhoto
            final workPhoto = WorkPhoto(
              id: fileData['id'],
              filename: fileData['filename'],
              accessUrl: fileData['accessUrl'],
              downloadUrl: fileData['downloadUrl'],
              uploadedAt: DateTime.now(),
            );

            print('[PhotoUpload] Berhasil upload foto: ${workPhoto.accessUrl}');

            if (!completer.isCompleted) {
              completer.complete(workPhoto);
            }
          } else {
            if (!completer.isCompleted) {
              error.value = 'Upload failed: ${jsonResponse['message']}';
              completer.complete(null);
            }
          }
        } else {
          if (!completer.isCompleted) {
            error.value =
                'Upload failed with status: ${httpResponse.statusCode}, $responseBody';
            completer.complete(null);
          }
        }

        // Tutup client
        httpClient.close();
      } catch (e) {
        if (!completer.isCompleted) {
          print('[PhotoUpload] Error dalam proses upload: $e');
          error.value = 'Error upload: $e';
          completer.complete(null);
        }
      }

      // Tunggu hasil upload atau timeout
      return await completer.future;
    } catch (e) {
      print('[PhotoUpload] Error upload foto: $e');
      error.value = 'Gagal upload foto: $e';
      return null;
    } finally {
      isUploadingPhoto.value = false;
      uploadProgress.value = 0.0;
    }
  }

  Future<List<WorkPhoto>> pickAndUploadMultiplePhotos(
      ImageSource source) async {
    try {
      // Ambil foto dari gallery atau kamera
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) {
        return [];
      }

      List<WorkPhoto> uploadedPhotos = [];
      DateTime? firstPhotoTime;
      DateTime? lastPhotoTime;

      // Upload dan proses setiap foto
      for (var image in images) {
        final File file = File(image.path);
        final DateTime? photoTime = await getPhotoCreationTime(file);
        final WorkPhoto? uploadedPhoto = await uploadPhoto(file);

        if (uploadedPhoto != null) {
          uploadedPhotos.add(uploadedPhoto);

          // Update waktu foto
          if (photoTime != null) {
            if (firstPhotoTime == null || photoTime.isBefore(firstPhotoTime)) {
              firstPhotoTime = photoTime;
            }
            if (lastPhotoTime == null || photoTime.isAfter(lastPhotoTime)) {
              lastPhotoTime = photoTime;
            }
          }
        }
      }

      // Update waktu berdasarkan jenis foto (start/end)
      if (startPhotos.isEmpty && firstPhotoTime != null) {
        // Ini foto awal
        workStartTime.value = firstPhotoTime!;
        reportDate.value = DateTime(
          firstPhotoTime!.year,
          firstPhotoTime!.month,
          firstPhotoTime!.day,
        );
      } else if (endPhotos.isEmpty && lastPhotoTime != null) {
        // Ini foto akhir
        workEndTime.value = lastPhotoTime!;
      }

      return uploadedPhotos;
    } catch (e) {
      print('[PhotoPicker] Error picking multiple photos: $e');
      error.value = 'Gagal mengambil foto: $e';
      return [];
    }
  }

  Future<WorkPhoto?> pickAndUploadSinglePhoto(ImageSource source) async {
    try {
      // Ambil foto dari gallery atau kamera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) {
        return null;
      }

      // Dapatkan metadata foto
      final File file = File(image.path);
      final DateTime? photoTime = await getPhotoCreationTime(file);

      // Upload foto
      final WorkPhoto? uploadedPhoto = await uploadPhoto(file);

      if (uploadedPhoto != null && photoTime != null) {
        // Update waktu berdasarkan jenis foto (start/end)
        if (startPhotos.isEmpty) {
          // Ini foto awal
          workStartTime.value = photoTime;
          reportDate.value = DateTime(
            photoTime.year,
            photoTime.month,
            photoTime.day,
          );
        } else if (endPhotos.isEmpty) {
          // Ini foto akhir
          workEndTime.value = photoTime;
        }
      }

      return uploadedPhoto;
    } catch (e) {
      print('[PhotoPicker] Error picking photo: $e');
      error.value = 'Gagal mengambil foto: $e';
      return null;
    }
  }

  Future<DateTime?> getPhotoCreationTime(File imageFile) async {
    try {
      print(
          '[PhotoTime] Mencoba membaca metadata dari file: ${imageFile.path}');

      // Baca data EXIF dari file foto
      final bytes = await imageFile.readAsBytes();
      final exifData = await readExifFromBytes(bytes);

      print(
          '[PhotoTime] Data EXIF yang ditemukan: ${exifData.keys.join(', ')}');

      // Coba ambil waktu dari metadata EXIF
      if (exifData.containsKey('EXIF DateTimeOriginal')) {
        final dateTimeStr = exifData['EXIF DateTimeOriginal']!.toString();
        print('[PhotoTime] Menemukan EXIF DateTimeOriginal: $dateTimeStr');

        // Format EXIF biasanya: 'YYYY:MM:DD HH:MM:SS'
        final parts = dateTimeStr.split(' ');
        final dateParts = parts[0].split(':');
        final timeParts = parts[1].split(':');

        final dateTime = DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
          int.parse(timeParts[2]), // second
        );

        print('[PhotoTime] Berhasil parse waktu EXIF: $dateTime');
        return dateTime;
      } else if (exifData.containsKey('DateTime')) {
        // Coba alternatif tag DateTime jika DateTimeOriginal tidak ada
        final dateTimeStr = exifData['DateTime']!.toString();
        print('[PhotoTime] Menggunakan tag DateTime alternatif: $dateTimeStr');

        final parts = dateTimeStr.split(' ');
        final dateParts = parts[0].split(':');
        final timeParts = parts[1].split(':');

        final dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );

        print('[PhotoTime] Berhasil parse waktu dari DateTime: $dateTime');
        return dateTime;
      }

      print(
          '[PhotoTime] Tidak menemukan metadata waktu di EXIF, mencoba waktu pembuatan file');

      // Coba ambil waktu pembuatan file
      final FileStat stat = await imageFile.stat();

      // Di Windows dan beberapa sistem lain, stat.changed bisa berisi waktu pembuatan
      if (Platform.isWindows) {
        print('[PhotoTime] Waktu pembuatan file (Windows): ${stat.changed}');
        return stat.changed;
      }

      // Untuk sistem lain, coba baca waktu pembuatan dengan cara alternatif
      try {
        // Gunakan process untuk menjalankan perintah sistem
        ProcessResult result;
        if (Platform.isMacOS || Platform.isLinux) {
          // Di MacOS/Linux gunakan stat command
          result = await Process.run('stat', ['-f %B', imageFile.path]);
          if (result.exitCode == 0) {
            final timestamp = int.tryParse(result.stdout.toString().trim());
            if (timestamp != null) {
              final createTime =
                  DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              print('[PhotoTime] Waktu pembuatan file (Unix): $createTime');
              return createTime;
            }
          }
        }
      } catch (e) {
        print('[PhotoTime] Error saat membaca waktu pembuatan: $e');
      }

      // Jika semua cara gagal, gunakan waktu modifikasi sebagai fallback terakhir
      print(
          '[PhotoTime] Menggunakan waktu modifikasi sebagai fallback: ${stat.modified}');
      return stat.modified;
    } catch (e, stackTrace) {
      print('[PhotoTime] Error saat membaca waktu foto:');
      print('[PhotoTime] Error: $e');
      print('[PhotoTime] Stack trace: $stackTrace');
      return null;
    }
  }

  void addStartPhoto(WorkPhoto photo) {
    startPhotos.add(photo);
  }

  void addEndPhoto(WorkPhoto photo) {
    endPhotos.add(photo);
  }

  void removeStartPhoto(String photoId) {
    startPhotos.removeWhere((p) => p.id == photoId);
  }

  void removeEndPhoto(String photoId) {
    endPhotos.removeWhere((p) => p.id == photoId);
  }

  void selectSPK(Spk spk) async {
    try {
      selectedSpk.value = spk;

      // Pre-fill location from SPK if available
      if (spk.location?.name != null) {
        location.value = spk.location!.name;
      }

      // Fetch SPK details with progress
      await fetchSpkDetailsWithProgress(spk.id);

      // Cek apakah ada draft untuk SPK ini pada hari ini
      final hasDraft = await hasTodayDraft(spk.id);
      if (hasDraft) {
        // Muat data sementara
        await loadTemporaryData(spk.id);
      } else {
        // Hapus draft lama jika ada (bukan hari ini)
        final existingDraft = await _hiveService.getDailyActivity(spk.id);
        if (existingDraft != null) {
          await clearTemporaryData(spk.id);
        }
      }
    } catch (e) {
      print('[AddWorkReport] Error in selectSPK: $e');
      error.value = e.toString();
    }
  }

  void setReportDate(DateTime date) {
    reportDate.value = date;
  }

  void setWorkStartTime(DateTime time) {
    workStartTime.value = time;
  }

  void setWorkEndTime(DateTime time) {
    workEndTime.value = time;
  }

  bool validateStep(int step) {
    error.value = '';

    switch (step) {
      case 0: // Pilih SPK
        if (selectedSpk.value == null) {
          error.value = 'Silakan pilih SPK terlebih dahulu';
          return false;
        }
        return true;

      case 1: // Foto dan Waktu
        if (startPhotos.isEmpty) {
          error.value = 'Silakan pilih minimal 1 foto untuk mulai pekerjaan';
          return false;
        }
        // Foto akhir pekerjaan menjadi opsional
        return true;

      case 3: // Manpower dan Konfigurasi
        if (selectedManpower.isEmpty) {
          error.value = 'Silakan tambahkan minimal 1 personel';
          return false;
        }
        return true;

      case 4: // Peralatan
        if (selectedEquipment.isEmpty) {
          error.value = 'Silakan tambahkan minimal 1 peralatan';
          return false;
        }
        return true;

      case 5: // Material
        // Material is optional
        return true;

      case 6: // Other Cost
        // Other cost is optional
        return true;

      case 7: // Cost Summary
        // Just view step, no validation needed
        return true;

      default:
        return true;
    }
  }

  // Method untuk menampilkan snackbar
  void showSnackbar(String title, String message, {bool isError = false}) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: isError ? Colors.red[50] : Colors.green[50],
          colorText: isError ? Colors.red[900] : Colors.green[900],
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
      }
    });
  }

  void nextStep() async {
    if (validateStep(currentStep.value)) {
      if (currentStep.value == 7) {
        // Jika di step terakhir (rincian biaya), buka form progress kerja
        final workProgressController = Get.find<WorkProgressController>();

        // Print detail SpkDetailWithProgressResponse dan workItems untuk debug
        print(
            '=== DEBUG NEXT STEP TERAKHIR (SpkDetailWithProgressResponse) ===');
        if (spkDetailsWithProgress.value != null &&
            spkDetailsWithProgress.value!.dailyActivities.isNotEmpty) {
          final latestActivity =
              spkDetailsWithProgress.value!.dailyActivities.first;
          print('Work items dari SpkDetailWithProgressResponse:');
          print(latestActivity.workItems);
        } else {
          print('Tidak ada data work items di SpkDetailWithProgressResponse');
        }
        print('=== END DEBUG ===');

        // Ambil workItems dari SpkDetailWithProgressResponse
        if (spkDetailsWithProgress.value == null ||
            spkDetailsWithProgress.value!.dailyActivities.isEmpty) {
          error.value = 'Data progress SPK tidak lengkap';
          showSnackbar(
            'Error',
            'Data progress SPK tidak lengkap',
            isError: true,
          );
          return;
        }
        final latestActivity =
            spkDetailsWithProgress.value!.dailyActivities.first;
        final workItems = latestActivity.workItems.map((item) {
          return {
            'workItemId': item.id,
            'workItem': {
              'id': item.id,
              'name': item.name,
              'unit': {'name': item.unit.name},
            },
            'boqVolume': {
              'nr': item.boqVolume.nr,
              'r': item.boqVolume.r,
            },
            'rates': {
              'nr': {
                'rate': item.rates.nr.rate,
                'description': item.rates.nr.description,
              },
              'r': {
                'rate': item.rates.r.rate,
                'description': item.rates.r.description,
              },
            },
            'progressAchieved': {
              'nr': item.progressAchieved.nr,
              'r': item.progressAchieved.r,
            },
            'actualQuantity': {
              'nr': item.actualQuantity.nr,
              'r': item.actualQuantity.r,
            },
            'dailyProgress': {
              'nr': item.dailyProgress.nr,
              'r': item.dailyProgress.r,
            },
            'dailyCost': {
              'nr': item.dailyCost.nr,
              'r': item.dailyCost.r,
            },
            'description': item.description,
            'spk': {
              'startDate': selectedSpk.value?.startDate,
              'endDate': selectedSpk.value?.endDate,
            },
          };
        }).toList();

        print('DEBUG: workItems untuk progress: ${workItems.length} item');
        if (workItems.isEmpty) {
          print(
              'WARNING: Tidak ada workItems yang akan diinisialisasi ke progress!');
          error.value = 'Tidak ada item pekerjaan yang tersedia';
          showSnackbar(
            'Error',
            'Tidak ada item pekerjaan yang tersedia',
            isError: true,
          );
          return;
        }

        workProgressController.initializeFromWorkItems(workItems);

        final result = await Get.to<bool>(
          () => WorkProgressForm(controller: workProgressController),
          transition: Transition.rightToLeft,
        );

        if (result == true) {
          // Progress sudah diisi, submit report
          await submitWorkReport();
        }
      } else {
        // Simpan data sementara di setiap perpindahan step (kecuali step terakhir)
        await saveTemporaryData();
        showSnackbar(
          'Draft Tersimpan',
          'Data berhasil disimpan',
        );
        currentStep.value++;
      }
    } else {
      // Tampilkan error jika validasi gagal
      if (error.value.isNotEmpty) {
        showSnackbar(
          'Validasi Gagal',
          error.value,
          isError: true,
        );
      }
    }
  }

  Future<bool> submitWorkReport() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Validasi SPK

      final workProgressController = Get.find<WorkProgressController>();
      final materialController = Get.find<MaterialController>();
      final otherCostController = Get.find<OtherCostController>();

      // Print semua atribut penting controller untuk debug
      print('=== DEBUG SEMUA ATRIBUT AddWorkReportController ===');
      print('selectedSpk: ${selectedSpk.value}');
      print('reportDate: $reportDate');
      print('location: $location');
      print('weather: $weather');
      print('workStartTime: $workStartTime');
      print('workEndTime: $workEndTime');
      print('remarks: $remarks');
      print('startPhotos: ${startPhotos.map((p) => p.accessUrl).toList()}');
      print('endPhotos: ${endPhotos.map((p) => p.accessUrl).toList()}');
      print('selectedManpower: $selectedManpower');
      print('selectedEquipment: $selectedEquipment');
      print(
          'materialController.selectedMaterials: ${materialController.selectedMaterials}');
      print(
          'otherCostController.otherCosts: ${otherCostController.otherCosts}');
      print('spkDetailsWithProgress: $spkDetailsWithProgress');
      print('workItems: $workItems');
      print('===============================================');
      if (selectedSpk.value == null) {
        throw Exception('SPK belum dipilih');
      }

      final input = {
        "spkId": selectedSpk.value?.id ?? '',
        "date": reportDate.value.toIso8601String().split('T')[0],
        "areaId": selectedSpk.value?.location?.id ?? '',
        "workStartTime": workStartTime.value.toUtc().toIso8601String(),
        "workEndTime": workEndTime.value?.toUtc().toIso8601String() ?? '',
        "closingRemarks": remarks.value,
        "startImages": startPhotos.map((p) => p.accessUrl).toList(),
        "finishImages": endPhotos.map((p) => p.accessUrl).toList(),
        "activityDetails": Get.find<WorkProgressController>()
            .workProgresses
            .map((p) => {
                  "workItemId": p.workItemId,
                  "actualQuantity": {
                    "nr": p.progressVolumeNR ?? 0.0,
                    "r": p.progressVolumeR ?? 0.0,
                  },
                  "status": (p.progressVolumeR >= (p.dailyTargetR ?? 0.0) &&
                          p.progressVolumeNR >= (p.dailyTargetNR ?? 0.0))
                      ? 'Completed'
                      : 'In Progress',
                  "remarks": p.remarks ?? '',
                })
            .toList(),
        "equipmentLogs": selectedEquipment
            .map((e) => {
                  "equipmentId": e.equipment.id,
                  "fuelIn": e.fuelIn ?? 0.0,
                  "fuelRemaining": e.fuelRemaining ?? 0.0,
                  "workingHour": e.workingHours ?? 0.0,
                  "hourlyRate": e.selectedContract?.rentalRate ?? 0.0,
                  "isBrokenReported": e.isBrokenReported ?? false,
                  "remarks": e.remarks ?? '',
                })
            .toList(),
        "manpowerLogs": selectedManpower
            .map((m) => {
                  "role": m.personnelRole.id,
                  "personCount": m.personCount ?? 0,
                  "hourlyRate": m.normalHourlyRate ?? 0.0,
                })
            .toList(),
        "materialUsageLogs": materialController.selectedMaterials
            .map((m) => {
                  "materialId": m.material.id,
                  "quantity": m.quantity ?? 0.0,
                  "unitRate": m.material.unitRate ?? 0.0,
                  "remarks": m.remarks ?? '',
                })
            .toList(),
        "otherCosts": otherCostController.otherCosts
            .map((cost) => {
                  "costType": cost.costType,
                  "amount": cost.amount,
                  "remarks": cost.remarks ?? '',
                })
            .toList(),
      };
      final previewData = {"input": input};
      final encoder = JsonEncoder.withIndent('  ');
      print('=== DATA YANG DIKIRIM KE SERVER ===');
      print(encoder.convert(previewData));
      print('=== END DATA KIRIM ===');

      //Kirim data ke server menggunakan GraphQL service
      final service = Get.find<GraphQLService>();
      final result = await service.submitDailyReport({'input': input});

      if (result != null) {
        print('[AddWorkReport] Berhasil mengirim laporan: ${result['id']}');

        try {
          // Tampilkan ringkasan biaya dengan null safety
          final costs = result['costs'] as Map<String, dynamic>? ?? {};
          print('[AddWorkReport] Total biaya:');
          print('- Peralatan: ${costs['equipment'] ?? 0}');
          print('- Tenaga Kerja: ${costs['manpower'] ?? 0}');
          print('- Material: ${costs['material'] ?? 0}');
          print('- Biaya Lain: ${costs['other'] ?? 0}');
          print('- Total: ${costs['total'] ?? 0}');

          // Tampilkan progress dengan null safety
          final progress = result['progress'] as Map<String, dynamic>? ?? {};
          print('[AddWorkReport] Progress:');
          print('- Fisik: ${progress['physical'] ?? 0}%');
          print('- Keuangan: ${progress['financial'] ?? 0}%');
        } catch (e) {
          print('[AddWorkReport] Error saat menampilkan ringkasan: $e');
        }

        // Setelah sukses mengirim laporan, hapus data sementara
        if (selectedSpk.value != null) {
          await clearTemporaryData(selectedSpk.value!.id);
        }

        Get.back(); // Kembali ke halaman sebelumnya
        showSnackbar(
          'Sukses',
          'Laporan pekerjaan berhasil disimpan',
        );

        return true;
      } else {
        throw Exception('Gagal mengirim laporan: Response kosong dari server');
      }
      return false;
    } catch (e) {
      print('[AddWorkReport] Error submitting work report: $e');
      error.value = e.toString();
      showSnackbar(
        'Error',
        'Gagal menyimpan laporan: ${e.toString()}',
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      saveTemporaryData(); // Simpan data setiap kali pindah langkah
    }
  }

  // Ambil data jabatan personel
  Future<void> fetchPersonnelRoles() async {
    try {
      isLoadingPersonnel.value = true;
      error.value = '';

      final service = Get.find<GraphQLService>();
      final roles = await service.fetchPersonnelRoles();

      personnelRoles.value = roles;
      print(
          '[AddWorkReport] Berhasil mengambil ${roles.length} jabatan personel');
    } catch (e) {
      print('[AddWorkReport] Error mengambil jabatan personel: $e');
      error.value = 'Gagal mengambil data jabatan personel: $e';
    } finally {
      isLoadingPersonnel.value = false;
    }
  }

  // Tambah entry manpower
  Future<void> addManpowerEntry(ManpowerEntry entry) async {
    try {
      print('\n=== ADDING MANPOWER ENTRY ===');
      print('Role: ${entry.personnelRole.roleName}');
      print('Count: ${entry.personCount} orang');
      print('Hours: ${entry.normalHoursPerPerson} jam');
      print('Daily Rate: ${entry.manpowerDailyRate != null ? 'Rp ${entry.manpowerDailyRate}' : '-'}');
      print('Total Hours: ${entry.totalNormalHours} jam');
      print('Total Cost: Rp ${entry.totalCost}');
      print('===========================\n');

      // Cek jika sudah ada dengan personnel role yang sama
      final existingIndex = selectedManpower.indexWhere(
          (item) => item.personnelRole.id == entry.personnelRole.id);

      // Ambil biaya manpower harian dari server
      final graphQLService = Get.find<GraphQLService>();
      final totalHours =
          entry.normalHoursPerPerson + (entry.overtimeHoursPerPerson ?? 0.0);

      final manpowerDailyRate = await graphQLService.fetchManpowerDailyRate(
          personnelRoleId: entry.personnelRole.id,
          date: reportDate.value,
          workHours: totalHours.toInt());

      // Buat entry baru dengan biaya manpower dari server
      final updatedEntry = ManpowerEntry(
        personnelRole: entry.personnelRole,
        personCount: entry.personCount,
        normalHoursPerPerson: entry.normalHoursPerPerson,
        overtimeHoursPerPerson: entry.overtimeHoursPerPerson,
        manpowerDailyRate: manpowerDailyRate,
      );

      if (existingIndex >= 0) {
        // Update entry yang sudah ada
        selectedManpower[existingIndex] = updatedEntry;
        print('Updated existing entry at index $existingIndex');
      } else {
        // Tambah entry baru
        selectedManpower.add(updatedEntry);
        print('Added new entry');
      }

      print('\n=== UPDATED MANPOWER LIST ===');
      printManpowerList();

      saveTemporaryData();
    } catch (e) {
      print('[AddWorkReport] Error saat menambahkan manpower: $e');
      error.value = 'Gagal mengambil data biaya manpower: $e';
      rethrow;
    }
  }

  // Hapus entry manpower
  void removeManpowerEntry(String personnelRoleId) {
    print('\n=== REMOVING MANPOWER ENTRY ===');
    final index = selectedManpower.indexWhere((item) => item.personnelRole.id == personnelRoleId);
    if (index >= 0) {
      print('Removing entry:');
      print('Role: ${selectedManpower[index].personnelRole.roleName}');
      print('Count: ${selectedManpower[index].personCount} orang');
      print('Hours: ${selectedManpower[index].normalHoursPerPerson} jam');
    }
    print('===========================\n');

    selectedManpower.removeWhere((item) => item.personnelRole.id == personnelRoleId);
    saveTemporaryData();

    print('\n=== UPDATED MANPOWER LIST ===');
    printManpowerList();
  }

  // Add a method to print current manpower list
  void printManpowerList() {
    print('\n=== CURRENT MANPOWER LIST ===');
    for (var i = 0; i < selectedManpower.length; i++) {
      final entry = selectedManpower[i];
      print('''
Entry #${i + 1}:
Role: ${entry.personnelRole.roleName}
Count: ${entry.personCount} orang
Hours: ${entry.normalHoursPerPerson} jam
Daily Rate: ${entry.manpowerDailyRate != null ? 'Rp ${entry.manpowerDailyRate}' : '-'}
Total Hours: ${entry.totalNormalHours} jam
Total Cost: Rp ${entry.totalCost}
-------------------''');
    }
    print('===========================\n');
  }

  // Ambil data peralatan
  Future<void> fetchEquipments() async {
    try {
      isLoadingEquipment.value = true;
      error.value = '';

      final service = Get.find<GraphQLService>();
      final equipments = await service.fetchEquipments();

      equipmentList.assignAll(equipments);
      print(
          '[AddWorkReport] Berhasil mengambil ${equipments.length} peralatan');
    } catch (e) {
      print('[AddWorkReport] Error mengambil data peralatan: $e');
      error.value = 'Gagal mengambil data peralatan: $e';
    } finally {
      isLoadingEquipment.value = false;
    }
  }

  // Tambah entry equipment
  void addEquipmentEntry(EquipmentEntry entry) {
    // Cek jika sudah ada dengan equipment yang sama
    final existingIndex = selectedEquipment
        .indexWhere((item) => item.equipment.id == entry.equipment.id);

    if (existingIndex >= 0) {
      // Update entry yang sudah ada
      selectedEquipment[existingIndex] = entry;
    } else {
      // Tambah entry baru
      selectedEquipment.add(entry);
    }
  }

  // Hapus entry equipment
  void removeEquipmentEntry(String equipmentId) {
    selectedEquipment.removeWhere((item) => item.equipment.id == equipmentId);
  }

  // Method untuk mengecek apakah semua biaya sudah terisi
  bool isAllCostFilled() {
    final materialController = Get.find<MaterialController>();
    final otherCostController = Get.find<OtherCostController>();

    // Cek apakah minimal ada satu entry untuk setiap kategori biaya wajib
    bool hasManpower = selectedManpower.isNotEmpty;
    bool hasEquipment = selectedEquipment.isNotEmpty;

    // Material dan biaya lain opsional, jadi tidak perlu dicek

    return hasManpower && hasEquipment;
  }

  // Fungsi untuk menentukan status aktivitas berdasarkan pengisian biaya
  String getActivityStatus() {
    // Cek apakah semua biaya wajib sudah terisi
    bool isAllMandatoryCostFilled = true;

    // Cek biaya tenaga kerja
    if (selectedManpower.isEmpty) {
      isAllMandatoryCostFilled = false;
    }

    // Cek biaya peralatan
    if (selectedEquipment.isEmpty) {
      isAllMandatoryCostFilled = false;
    }

    // Cek biaya material
    final materialController = Get.find<MaterialController>();
    if (materialController.selectedMaterials.isEmpty) {
      isAllMandatoryCostFilled = false;
    }

    // Jika semua biaya wajib terisi, status menjadi "Menunggu Progress"
    // Jika belum, status tetap "Draft"
    return isAllMandatoryCostFilled ? 'Menunggu Progress' : 'Draft';
  }

  // Method untuk menyimpan data sementara ke local storage
  Future<void> saveTemporaryData() async {
    if (selectedSpk.value == null) return;

    try {
      final spk = selectedSpk.value!;
      final spkId = spk.id;
      final now = DateTime.now();

      // Buat SPKDetails dari SPK yang dipilih
      final spkDetails = activity_input.SPKDetails.fromSpk(spk);

      // Tentukan status berdasarkan pengisian
      final activityStatus = getActivityStatus();

      // Buat objek DailyActivity dari data sementara menggunakan model dari activity_input
      final dailyActivity = activity_input.DailyActivity(
        id: '', // ID akan di-generate oleh Hive
        spkId: spkId,
        spkDetails: spkDetails,
        date: reportDate.value.toIso8601String(),
        areaId: selectedSpk.value?.location?.id ?? '',
        weather: weather.value,
        status: activityStatus, // Gunakan status yang sesuai
        workStartTime: workStartTime.value.toIso8601String(),
        workEndTime: workEndTime.value?.toIso8601String() ?? '',
        startImages: startPhotos.map((p) => p.accessUrl).toList(),
        finishImages: endPhotos.map((p) => p.accessUrl).toList(),
        closingRemarks: remarks.value,
        progressPercentage: 0.0,
        activityDetails: [], // Ini perlu diisi jika ada data progress
        equipmentLogs: selectedEquipment
            .map((e) => activity_input.EquipmentLog(
                  id: '',
                  equipmentId: e.equipment.id,
                  fuelIn: e.fuelIn,
                  fuelRemaining: e.fuelRemaining,
                  workingHour: e.workingHours,
                  isBrokenReported: e.isBrokenReported,
                  remarks: e.remarks ?? '',
                  hourlyRate: e.selectedContract?.rentalRate ?? 0.0,
                ))
            .toList(),
        manpowerLogs: selectedManpower
            .map((m) => activity_input.ManpowerLog(
                  id: '',
                  role: m.personnelRole.id,
                  personCount: m.personCount,
                  hourlyRate: m.normalHourlyRate,
                ))
            .toList(),
        materialUsageLogs: Get.find<MaterialController>()
            .selectedMaterials
            .map((m) => activity_input.MaterialUsageLog(
                  id: '',
                  materialId: m.material.id,
                  quantity: m.quantity,
                  unitRate: m.material.unitRate ?? 0.0,
                  remarks: m.remarks ?? '',
                ))
            .toList(),
        otherCosts: Get.find<OtherCostController>()
            .otherCosts
            .map((cost) => activity_input.OtherCost(
                  id: cost.id,
                  costType: cost.costType,
                  amount: cost.amount,
                  description: cost.description,
                  receiptNumber: cost.receiptNumber,
                  remarks: cost.remarks,
                ))
            .toList(),
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        localId: spkId,
        lastSyncAttempt: now,
      );

      // Simpan ke HiveService yang menggunakan model DailyActivity dari activity_input
      await _hiveService.saveDailyActivity(dailyActivity);
      print(
          '[AddWorkReport] Data sementara berhasil disimpan untuk SPK: $spkId dengan status: $activityStatus');
    } catch (e) {
      print('[AddWorkReport] Error menyimpan data sementara: $e');
    }
  }

  // Method untuk memuat data sementara dari local storage
  Future<bool> loadTemporaryData(String spkId) async {
    try {
      print('[AddWorkReport] Mulai memuat data sementara untuk SPK: $spkId');

      // Ambil data dari HiveService menggunakan model dari activity_input
      final dailyActivity = await _hiveService.getDailyActivity(spkId);
      if (dailyActivity == null) {
        print('[AddWorkReport] Tidak ada data sementara untuk SPK: $spkId');
        showSnackbar(
          'Info',
          'Tidak ada draft tersimpan untuk SPK ini',
          isError: true,
        );
        return false;
      }

      // Set selectedSpk dari draft jika ada di spkList
      final spkFromList =
          spkList.firstWhereOrNull((spk) => spk.id == dailyActivity.spkId);
      if (spkFromList != null) {
        selectedSpk.value = spkFromList;
      }

      // Tambahkan print untuk debug data draft
      print('[AddWorkReport] === DATA DRAFT YANG DIMUAT ===');
      print('spkId: \\${dailyActivity.spkId}');
      print('spkDetails: \\${dailyActivity.spkDetails}');
      print('date: \\${dailyActivity.date}');
      print('areaId: \\${dailyActivity.areaId}');
      print('weather: \\${dailyActivity.weather}');
      print('status: \\${dailyActivity.status}');
      print('workStartTime: \\${dailyActivity.workStartTime}');
      print('workEndTime: \\${dailyActivity.workEndTime}');
      print('startImages: \\${dailyActivity.startImages}');
      print('finishImages: \\${dailyActivity.finishImages}');
      print('closingRemarks: \\${dailyActivity.closingRemarks}');
      print('progressPercentage: \\${dailyActivity.progressPercentage}');
      print('activityDetails: \\${dailyActivity.activityDetails}');
      print('equipmentLogs: \\${dailyActivity.equipmentLogs}');
      print('manpowerLogs: \\${dailyActivity.manpowerLogs}');
      print('materialUsageLogs: \\${dailyActivity.materialUsageLogs}');
      print('otherCosts: \\${dailyActivity.otherCosts}');
      print('createdAt: \\${dailyActivity.createdAt}');
      print('updatedAt: \\${dailyActivity.updatedAt}');
      print('localId: \\${dailyActivity.localId}');
      print('lastSyncAttempt: \\${dailyActivity.lastSyncAttempt}');
      print('[AddWorkReport] === END DATA DRAFT ===');

      // Pastikan data personnel roles dan equipment sudah dimuat
      if (personnelRoles.isEmpty) {
        print('[AddWorkReport] Memuat data personnel roles...');
        await fetchPersonnelRoles();
      }

      if (equipmentList.isEmpty) {
        print('[AddWorkReport] Memuat data equipment...');
        await fetchEquipments();
      }

      // Atur current step
      currentStep.value = 1;

      // Atur form data
      reportDate.value = DateTime.parse(dailyActivity.date);
      location.value = dailyActivity.spkDetails?.location?.name ?? '';
      workStartTime.value =
          safeParseDate(dailyActivity.workStartTime) ?? DateTime.now();
      workEndTime.value = safeParseDate(dailyActivity.workEndTime);
      remarks.value = dailyActivity.closingRemarks;

      // Atur foto-foto
      startPhotos.clear();
      for (var url in dailyActivity.startImages) {
        startPhotos.add(WorkPhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filename: url.split('/').last,
          accessUrl: url,
          downloadUrl: url,
          uploadedAt: DateTime.now(),
        ));
      }

      endPhotos.clear();
      for (var url in dailyActivity.finishImages) {
        endPhotos.add(WorkPhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filename: url.split('/').last,
          accessUrl: url,
          downloadUrl: url,
          uploadedAt: DateTime.now(),
        ));
      }

      print('[AddWorkReport] Memuat data manpower...');
      // Atur manpower
      selectedManpower.clear();
      for (var log in dailyActivity.manpowerLogs) {
        try {
          // Temukan personnel role berdasarkan ID
          final role = personnelRoles.firstWhere(
            (role) => role.id == log.role,
            orElse: () {
              print(
                  '[AddWorkReport] Role tidak ditemukan untuk ID: ${log.role}');
              return personnel_model.PersonnelRole(
                id: '',
                roleName: 'Role tidak ditemukan',
                roleCode: '',
                description: '',
                isPersonel: false,
                createdAt: '',
                updatedAt: '',
              );
            },
          );

          if (role.id.isNotEmpty) {
            print(
                '[AddWorkReport] Menambahkan manpower entry untuk role: ${role.roleName}');
            selectedManpower.add(ManpowerEntry(
              personnelRole: role,
              personCount: log.personCount,
              normalHoursPerPerson: 8.0, // Default
              manpowerDailyRate: log.hourlyRate * 8, // 8 jam per hari
            ));
          }
        } catch (e) {
          print('[AddWorkReport] Error saat memuat manpower entry: $e');
        }
      }

      print('[AddWorkReport] Memuat data equipment...');
      // Atur equipment
      selectedEquipment.clear();
      for (var log in dailyActivity.equipmentLogs) {
        try {
          // Temukan equipment berdasarkan ID
          final equipment = equipmentList.firstWhere(
            (equipment) => equipment.id == log.equipmentId,
            orElse: () {
              print(
                  '[AddWorkReport] Equipment tidak ditemukan untuk ID: \\${log.equipmentId}');
              return equipment_model.Equipment(
                id: '',
                equipmentCode: 'Peralatan tidak ditemukan',
                equipmentType: '',
                plateOrSerialNo: '',
                defaultOperator: '',
                contracts: [],
                createdAt: '',
                updatedAt: '',
              );
            },
          );

          // Cari contract yang rentalRate-nya sama dengan log.hourlyRate
          equipment_model.EquipmentContract? selectedContract;
          if (equipment.contracts.isNotEmpty) {
            selectedContract = equipment.contracts.firstWhereOrNull(
              (c) => c.rentalRate == log.hourlyRate,
            );
          }
          // Jika tidak ada contract yang cocok, buat dummy contract
          selectedContract ??= equipment_model.EquipmentContract(
            contractId: 'draft',
            equipmentId: equipment.id,
            rentalRate: log.hourlyRate,
            contract: equipment_model.Contract(
              id: '',
              contractNo: '',
              description: '',
              startDate: '',
              endDate: '',
              vendorName: '',
            ),
          );

          if (equipment.id.isNotEmpty) {
            print(
                '[AddWorkReport] Menambahkan equipment entry untuk: \\${equipment.equipmentCode} (hourlyRate: \\${log.hourlyRate})');
            selectedEquipment.add(EquipmentEntry(
              equipment: equipment,
              workingHours: log.workingHour,
              fuelIn: log.fuelIn,
              fuelRemaining: log.fuelRemaining,
              isBrokenReported: log.isBrokenReported,
              remarks: log.remarks,
              selectedContract: selectedContract,
            ));
          }
        } catch (e) {
          print('[AddWorkReport] Error saat memuat equipment entry: $e');
        }
      }

      // Atur material
      final materialController = Get.find<MaterialController>();
      materialController.selectedMaterials.clear();
      for (var log in dailyActivity.materialUsageLogs) {
        try {
          // Temukan material berdasarkan ID
          final material = materialController.materials.firstWhere(
            (material) => material.id == log.materialId,
            orElse: () {
              print(
                  '[AddWorkReport] Material tidak ditemukan untuk ID: ${log.materialId}');
              return material_model.Material(
                id: '',
                name: 'Material tidak ditemukan',
                unitId: null,
                unitRate: null,
                description: null,
                unit: null,
              );
            },
          );

          if (material.id.isNotEmpty) {
            print(
                '[AddWorkReport] Menambahkan material entry untuk: ${material.name}');
            materialController.selectedMaterials.add(MaterialEntry(
              material: material,
              quantity: log.quantity,
              remarks: log.remarks,
            ));
          }
        } catch (e) {
          print('[AddWorkReport] Error saat memuat material entry: $e');
        }
      }

      // Atur other costs
      final otherCostController = Get.find<OtherCostController>();
      otherCostController.otherCosts.clear();
      for (var cost in dailyActivity.otherCosts) {
        try {
          print('[AddWorkReport] Menambahkan other cost: ${cost.description}');
          otherCostController.addOtherCost(OtherCost(
            id: cost.id,
            costType: cost.costType,
            amount: cost.amount,
            description: cost.description,
            receiptNumber: cost.receiptNumber,
            remarks: cost.remarks,
          ));
        } catch (e) {
          print('[AddWorkReport] Error saat memuat other cost: $e');
        }
      }

      print('[AddWorkReport] Berhasil memuat semua data untuk SPK: $spkId');
      showSnackbar(
        'Sukses',
        'Berhasil memuat data draft',
      );
      return true;
    } catch (e) {
      print('[AddWorkReport] Error memuat data sementara: $e');
      showSnackbar(
        'Error',
        'Gagal memuat data draft: ${e.toString()}',
        isError: true,
      );
      return false;
    }
  }

  // Method untuk menghapus data sementara
  Future<void> clearTemporaryData(String spkId) async {
    try {
      await _hiveService.deleteDailyActivity(spkId);
      print(
          '[AddWorkReport] Data sementara berhasil dihapus untuk SPK: $spkId');
      showSnackbar(
        'Sukses',
        'Data draft berhasil dihapus',
      );
    } catch (e) {
      print('[AddWorkReport] Error menghapus data sementara: $e');
      showSnackbar(
        'Error',
        'Gagal menghapus data draft: ${e.toString()}',
        isError: true,
      );
    }
  }

  // Method untuk memeriksa apakah ada draft untuk SPK tertentu pada hari ini
  Future<bool> hasTodayDraft(String spkId) async {
    try {
      final dailyActivity = await _hiveService.getDailyActivity(spkId);
      if (dailyActivity == null) return false;

      // Ambil tanggal saat draft dibuat
      final lastUpdated = DateTime.parse(dailyActivity.updatedAt);
      final today = DateTime.now();

      // Cek apakah draft dibuat pada hari yang sama (hari ini)
      final isSameDay = lastUpdated.year == today.year &&
          lastUpdated.month == today.month &&
          lastUpdated.day == today.day;

      print(
          '[AddWorkReport] Draft untuk SPK: $spkId ${isSameDay ? "dibuat hari ini" : "bukan dari hari ini"}');
      return isSameDay;
    } catch (e) {
      print('[AddWorkReport] Error memeriksa draft hari ini: $e');
      return false;
    }
  }

  // Menciptakan data aktivitas sementara
  Future<void> createTemporaryActivity() async {
    try {
      if (selectedSpk.value == null) {
        return;
      }

      final spk = selectedSpk.value!;
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      final existingActivity = await _hiveService.getDailyActivity(spk.id);
      if (existingActivity != null) {
        // Hapus aktivitas sebelumnya jika ada
        await _hiveService.deleteDailyActivity(existingActivity.id);
      }

      // Buat SPKDetails untuk menyimpan detail lengkap SPK
      final spkDetails = activity_input.SPKDetails.fromSpk(spk);

      final dailyActivity = activity_input.DailyActivity(
        id: '', // ID akan di-generate oleh Hive
        spkId: spk.id,
        spkDetails: spkDetails,
        date: today,
        areaId: spk.location?.id ?? '',
        weather: 'Cerah',
        status: 'Draft',
        workStartTime: '08:00',
        workEndTime: '17:00',
        startImages: [],
        finishImages: [],
        closingRemarks: '',
        progressPercentage: 0.0,
        activityDetails: [],
        equipmentLogs: [],
        manpowerLogs: [],
        materialUsageLogs: [],
        otherCosts: [],
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        localId: spk.id,
        lastSyncAttempt: now,
      );

      await _hiveService.saveDailyActivity(dailyActivity);
    } catch (e) {
      print('Error saving temporary activity: $e');
    }
  }

  // Fungsi parsing tanggal yang aman
  DateTime? safeParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {}
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
      try {
        final epoch = int.parse(value);
        return DateTime.fromMillisecondsSinceEpoch(epoch);
      } catch (_) {}
    }
    return null;
  }

  Future<void> fetchSpkDetailsWithProgress(String spkId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final service = Get.find<GraphQLService>();
      final result = await service.fetchSPKDetailsWithProgress(spkId);

      if (result != null) {
        spkDetailsWithProgress.value = result;

        // Update workItems jika ada data
        if (result.dailyActivities.isNotEmpty) {
          final latestActivity = result.dailyActivities.first;
          workItems.value = latestActivity.workItems
              .map((item) => {
                    'name': item.name,
                    'description': item.description,
                    'volume': item.boqVolume.nr,
                    'unit': item.unit.name,
                    'unitRate': item.rates.nr.rate,
                    'progress': item.progressAchieved.nr,
                    'actualQuantity': item.actualQuantity.nr,
                    'dailyProgress': item.dailyProgress.nr,
                    'dailyCost': item.dailyCost.nr,
                  })
              .toList();
        }
      }
    } catch (e) {
      print('[AddWorkReport] Error fetching SPK details: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

class WorkPhoto {
  final String id;
  final String filename;
  final String accessUrl;
  final String downloadUrl;
  final DateTime uploadedAt;

  WorkPhoto({
    required this.id,
    required this.filename,
    required this.accessUrl,
    required this.downloadUrl,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'accessUrl': accessUrl,
      'downloadUrl': downloadUrl,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
    };
  }

  factory WorkPhoto.fromJson(Map<String, dynamic> json) {
    return WorkPhoto(
      id: json['id'],
      filename: json['filename'],
      accessUrl: json['accessUrl'],
      downloadUrl: json['downloadUrl'],
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(json['uploadedAt']),
    );
  }
}

class ManpowerEntry {
  final personnel_model.PersonnelRole personnelRole;
  final int personCount;
  final double normalHoursPerPerson;
  final double? overtimeHoursPerPerson;
  final double? manpowerDailyRate; // Biaya manpower harian dari server

  ManpowerEntry({
    required this.personnelRole,
    required this.personCount,
    required this.normalHoursPerPerson,
    this.overtimeHoursPerPerson,
    this.manpowerDailyRate,
  });

  double get totalNormalHours => personCount * normalHoursPerPerson;

  double get totalOvertimeHours => overtimeHoursPerPerson != null
      ? personCount * overtimeHoursPerPerson!
      : 0.0;

  double get normalHourlyRate => manpowerDailyRate != null
      ? manpowerDailyRate! / 8 // Asumsi 8 jam per hari
      : personnelRole.salaryComponent?.gajiPokok ?? 0.0;

  double get overtimeHourlyRate =>
      normalHourlyRate * 1.5; // Asumsi overtime 1.5x

  double get totalNormalCost => totalNormalHours * normalHourlyRate;

  double get totalOvertimeCost => totalOvertimeHours * overtimeHourlyRate;

  double get totalCost => totalNormalCost + totalOvertimeCost;

  Map<String, dynamic> toJson() {
    return {
      'personnelRoleId': personnelRole.id,
      'personCount': personCount,
      'normalHoursPerPerson': normalHoursPerPerson,
      'overtimeHoursPerPerson': overtimeHoursPerPerson,
      'normalHourlyRate': normalHourlyRate,
      'overtimeHourlyRate': overtimeHourlyRate,
      'manpowerDailyRate': manpowerDailyRate,
    };
  }

  factory ManpowerEntry.fromJson(
      Map<String, dynamic> json, personnel_model.PersonnelRole role) {
    return ManpowerEntry(
      personnelRole: role,
      personCount: json['personCount'] ?? 1,
      normalHoursPerPerson: json['normalHoursPerPerson'] ?? 8.0,
      overtimeHoursPerPerson: json['overtimeHoursPerPerson'],
      manpowerDailyRate: json['manpowerDailyRate'],
    );
  }
}

class EquipmentEntry {
  final equipment_model.Equipment equipment;
  final double workingHours;
  final double fuelIn;
  final double fuelRemaining;
  final bool isBrokenReported;
  final String? remarks;
  final equipment_model.EquipmentContract? selectedContract;

  EquipmentEntry({
    required this.equipment,
    required this.workingHours,
    required this.fuelIn,
    required this.fuelRemaining,
    this.isBrokenReported = false,
    this.remarks,
    this.selectedContract,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipmentId': equipment.id,
      'workingHours': workingHours,
      'fuelIn': fuelIn,
      'fuelRemaining': fuelRemaining,
      'isBrokenReported': isBrokenReported,
      'remarks': remarks,
      'contractId': selectedContract?.contractId,
      'rentalRate': selectedContract?.rentalRate,
    };
  }

  factory EquipmentEntry.fromJson(
      Map<String, dynamic> json, equipment_model.Equipment equipment) {
    // Find matching contract
    equipment_model.EquipmentContract? contract;
    if (json['contractId'] != null && equipment.contracts.isNotEmpty) {
      contract = equipment.contracts.firstWhere(
        (c) => c.contractId == json['contractId'],
        orElse: () => equipment.contracts.first,
      );
    }

    return EquipmentEntry(
      equipment: equipment,
      workingHours: (json['workingHours'] as num?)?.toDouble() ?? 0.0,
      fuelIn: (json['fuelIn'] as num?)?.toDouble() ?? 0.0,
      fuelRemaining: (json['fuelRemaining'] as num?)?.toDouble() ?? 0.0,
      isBrokenReported: json['isBrokenReported'] as bool? ?? false,
      remarks: json['remarks']?.toString(),
      selectedContract: contract,
    );
  }
}
