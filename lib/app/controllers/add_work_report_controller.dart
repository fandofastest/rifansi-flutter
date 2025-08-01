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
import 'package:rifansi/app/controllers/daily_activity_controller.dart';
import 'package:collection/collection.dart';
import 'package:rifansi/app/data/models/daily_activity_model.dart'
    as daily_activity_model;
import 'package:rifansi/app/data/models/other_cost_model.dart';
import 'package:rifansi/app/data/providers/storage_service.dart';
import 'package:rifansi/app/controllers/material_controller.dart';
import 'package:rifansi/app/controllers/other_cost_controller.dart';
import 'package:rifansi/app/controllers/daily_activity_controller.dart';
import 'package:collection/collection.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/work_progress_model.dart';

class AddWorkReportController extends GetxController {
  final currentStep = 0.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Data SPK
  final selectedSpk = Rx<Spk?>(null);
  final spkList = <Spk>[].obs;
  final searchKeyword = ''.obs;
  
  // Temporary storage for progress data from draft
  final Map<String, Map<String, dynamic>> _draftProgressData = {};

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
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Njc0MmVhZTYzY2NhN2RkZGY1ZmJjOCIsImlhdCI6MTc1NDA1MzAxNywiZXhwIjoxNzg1MTU3MDE3fQ.ThpwP9O3hK6mTzj1EcWGrtBUgn1Fsif8lK4pss7fPz4';
  final String uploadUrl = 'https://api-app25.rifansi.co.id/api/files/upload';

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
    print('[AddWorkReport] === CONTROLLER onInit CALLED ===');
    _initializeData();
  }

  @override
  void onReady() {
    super.onReady();
    print('[AddWorkReport] === CONTROLLER onReady CALLED ===');

    // Cek apakah ini load dari draft setelah initialization selesai
    _checkAndLoadDraft();
  }

  // Method untuk cek dan load draft
  Future<void> _checkAndLoadDraft() async {
    try {
      print('[AddWorkReport] === _checkAndLoadDraft CALLED ===');
      final args = Get.arguments;
      print('[AddWorkReport] === CHECK AND LOAD DRAFT ===');
      print('[AddWorkReport] Arguments: $args');

      if (args != null && args['isDraft'] == true && args['spkId'] != null) {
        print('[AddWorkReport] Draft condition met, loading draft...');

        // Tunggu sebentar untuk memastikan controller ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Pastikan SPK list sudah dimuat
        if (spkList.isEmpty) {
          print('[AddWorkReport] SPK list empty, fetching SPKs first...');
          await fetchSPKs();
        }


        // Load draft data
        final loadSuccess = await loadTemporaryData(args['spkId']);
        print('[AddWorkReport] Load draft result: $loadSuccess');

        if (loadSuccess) {
          print('[AddWorkReport] Draft loaded successfully');
          print(
              '[AddWorkReport] selectedSpk: ${selectedSpk.value?.spkNo ?? 'NULL'}');
          print('[AddWorkReport] workItems: ${workItems.length}');
        }
      } else {
        print('[AddWorkReport] Not a draft load or missing parameters');
        if (args != null) {
          print('[AddWorkReport] - isDraft: ${args['isDraft']}');
          print('[AddWorkReport] - spkId: ${args['spkId']}');
        }
      }
    } catch (e) {
      print('[AddWorkReport] Error in _checkAndLoadDraft: $e');
      print('[AddWorkReport] Stack trace: ${StackTrace.current}');
    }
  }

  // Method tambahan untuk manual trigger load draft
  Future<void> manualLoadDraft() async {
    print('[AddWorkReport] === MANUAL LOAD DRAFT TRIGGERED ===');
    await _checkAndLoadDraft();
  }

  // Method untuk inisialisasi data
  Future<void> _initializeData() async {
    try {
      print('[AddWorkReport] Starting data initialization');

      // Initialize HiveService
      _hiveService = Get.find<HiveService>();

      // Fetch SPKs first to ensure list is available
      await fetchSPKs();
      print('[AddWorkReport] SPK list loaded: ${spkList.length} items');

      // Fetch other required data
      await Future.wait([
        fetchPersonnelRoles(),
        fetchEquipments(),
      ]);

      print('[AddWorkReport] Data initialization completed');
    } catch (e) {
      print('[AddWorkReport] Error during initialization: $e');
      error.value = 'Gagal memuat data: $e';
    }
  }

  // Method untuk memastikan SPK terpilih
  void ensureSpkSelected() {
    if (selectedSpk.value == null && spkList.isNotEmpty) {
      print(
          '[AddWorkReport] No SPK selected, auto-selecting first available SPK');
      selectedSpk.value = spkList.first;
      print('[AddWorkReport] Auto-selected SPK: ${selectedSpk.value?.spkNo}');
    }
  }

  Future<bool> fetchSPKs({area_model.Area? area, String? keyword}) async {
    // Jika sudah ada request yang berjalan, batalkan
    if (_isFetchingInProgress.value) {
      print('[AddWorkReport] Fetch sudah berjalan, menunggu selesai...');
      return false;
    }

    try {
      print('[AddWorkReport] === FETCH SPKS START ===');
      _isFetchingInProgress.value = true;
      isLoading.value = true;
      error.value = '';

      if (keyword != null) {
        searchKeyword.value = keyword;
      }

      // Buat Completer untuk menangani timeout dan hasil
      final completer = Completer<bool>();

      // Set timeout 8 detik
      Timer(const Duration(seconds: 20), () {
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
        withDetails: false,
      )
          .then((result) {
        if (!completer.isCompleted) {
          spkList.value = result;
          print('[AddWorkReport] Berhasil fetch ${spkList.length} SPK');

          // Debug: Print semua SPK yang berhasil di-fetch
          for (int i = 0; i < spkList.length && i < 5; i++) {
            // Limit to first 5
            final spk = spkList[i];
            print('[AddWorkReport] SPK $i: ${spk.spkNo} (ID: ${spk.id})');
          }
          if (spkList.length > 5) {
            print('[AddWorkReport] ... dan ${spkList.length - 5} SPK lainnya');
          }

          // Jika SPK yang sebelumnya dipilih tidak ada lagi dalam daftar, hapus pilihan
          if (selectedSpk.value != null &&
              !spkList.any((spk) => spk.id == selectedSpk.value!.id)) {
            print(
                '[AddWorkReport] SPK yang dipilih sebelumnya tidak ada di list baru, menghapus pilihan');
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
      print('[AddWorkReport] === FETCH SPKS END ===');
      print('[AddWorkReport] Fetch result: $success');
      print('[AddWorkReport] Final spkList.length: ${spkList.length}');
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

  Future<bool> fetchSPKsWithProgress(
      {area_model.Area? area, String? keyword}) async {
    // Jika sudah ada request yang berjalan, batalkan
    if (_isFetchingInProgress.value) {
      print(
          '[AddWorkReport] Fetch dengan progress sudah berjalan, menunggu selesai...');
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
      Timer(const Duration(seconds: 20), () {
        if (!completer.isCompleted) {
          print('[AddWorkReport] Timeout fetchSPKsWithProgress');
          error.value = 'Timeout: Proses terlalu lama';
          completer.complete(false);
        }
      });

      // Parameter untuk query
      final locationId = area?.id.isNotEmpty == true ? area!.id : null;
      final searchKey =
          searchKeyword.value.isNotEmpty ? searchKeyword.value : null;

      print(
          '[AddWorkReport] Memulai fetch SPK dengan progress: locationId=$locationId, keyword=$searchKey');

      // Fetch data SPK biasa terlebih dahulu untuk mendapatkan list SPK
      final service = Get.find<GraphQLService>();
      print('fetchSPKs withDetails: false');
      service
          .fetchSPKs(
            withDetails: false,
        locationId: locationId,
        keyword: searchKey,
      )
          .then((spkResults) async {
        if (!completer.isCompleted) {
          // Update work items untuk setiap SPK yang memiliki progress
          List<Map<String, dynamic>> enrichedWorkItems = [];

          // Debug: Log jumlah SPK yang ditemukan
          print(
              '[AddWorkReport] Found ${spkResults.length} SPKs, fetching progress for each...');

          for (var spk in spkResults) {
            try {
              print(
                  '[AddWorkReport] Fetching progress for SPK: ${spk.id} - ${spk.spkNo}');

              // Fetch detail progress untuk setiap SPK menggunakan query baru
              // final spkWithProgress =
              //     await service.fetchSPKWithProgressBySpkId(spk.id);

              // print(
              //     '[AddWorkReport] SPK ${spk.spkNo} progress data keys: ${spkWithProgress.keys}');

              // final workItemsData =
              //     spkWithProgress['workItems'] as List<dynamic>? ?? [];
              // print(
              //     '[AddWorkReport] SPK ${spk.spkNo} has ${workItemsData.length} work items');

              // for (var item in workItemsData) {
              //   print('[AddWorkReport] Processing work item: ${item['name']}');
              //   print('[AddWorkReport] - boqVolume: ${item['boqVolume']}');
              //   print(
              //       '[AddWorkReport] - completedVolume: ${item['completedVolume']}');
              //   print(
              //       '[AddWorkReport] - remainingVolume: ${item['remainingVolume']}');
              //   print(
              //       '[AddWorkReport] - progressPercentage: ${item['progressPercentage']}');

              //   // Safe casting untuk nilai numerik
              //   final boqNr =
              //       (item['boqVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
              //   final boqR =
              //       (item['boqVolume']?['r'] as num?)?.toDouble() ?? 0.0;
              //   final dailyTargetNr =
              //       (item['dailyTarget']?['nr'] as num?)?.toDouble() ?? 0.0;
              //   final dailyTargetR =
              //       (item['dailyTarget']?['r'] as num?)?.toDouble() ?? 0.0;
              //   final completedNr =
              //       (item['completedVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
              //   final completedR =
              //       (item['completedVolume']?['r'] as num?)?.toDouble() ?? 0.0;
              //   final remainingNr =
              //       (item['remainingVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
              //   final remainingR =
              //       (item['remainingVolume']?['r'] as num?)?.toDouble() ?? 0.0;
              //   final progress =
              //       (item['progressPercentage'] as num?)?.toDouble() ?? 0.0;
              //   final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              //   final spentAmount =
              //       (item['spentAmount'] as num?)?.toDouble() ?? 0.0;
              //   final remainingAmount =
              //       (item['remainingAmount'] as num?)?.toDouble() ?? 0.0;

              //   final enrichedItem = {
              //     'spkId': spk.id,
              //     'spkNo': spk.spkNo,
              //     'name': item['name'] ?? '',
              //     'volume': boqNr + boqR,
              //     'unit': item['unit']?['name'] ?? '',
              //     'volumeType': boqR > 0 ? 'r' : 'nr',
              //     'dailyTarget': {'nr': dailyTargetNr, 'r': dailyTargetR},
              //     'completedVolume': {'nr': completedNr, 'r': completedR},
              //     'remainingVolume': {'nr': remainingNr, 'r': remainingR},
              //     'progressPercentage': progress,
              //     'amount': amount,
              //     'spentAmount': spentAmount,
              //     'remainingAmount': remainingAmount,
              //   };

              //   enrichedWorkItems.add(enrichedItem);
              //   print(
              //       '[AddWorkReport] Added enriched item: ${enrichedItem['name']} with ${enrichedItem['progressPercentage']}% progress');
              // }
            } catch (e) {
              print(
                  '[AddWorkReport] Error fetching progress for SPK ${spk.id}: $e');
              print('[AddWorkReport] Stack trace: ${StackTrace.current}');

              // Jika gagal fetch progress, tetap tambahkan work items tanpa progress
              if (spk.workItems != null) {
                print(
                    '[AddWorkReport] Using fallback data for SPK ${spk.spkNo}');
                for (var workItem in spk.workItems!) {
                  // Safe casting untuk fallback data
                  final boqNr = workItem.boqVolume.nr.toDouble();
                  final boqR = workItem.boqVolume.r.toDouble();
                  final amount = (workItem.amount ?? 0).toDouble();

                  enrichedWorkItems.add({
                    'spkId': spk.id,
                    'spkNo': spk.spkNo,
                    'name': workItem.workItem?.name ?? '',
                    'volume': boqNr + boqR,
                    'unit': workItem.workItem?.unit?.name ?? '',
                    'volumeType': boqR > 0 ? 'r' : 'nr',
                    'dailyTarget': {'nr': 0.0, 'r': 0.0},
                    'completedVolume': {'nr': 0.0, 'r': 0.0},
                    'remainingVolume': {'nr': boqNr, 'r': boqR},
                    'progressPercentage': 0.0,
                    'amount': amount,
                    'spentAmount': 0.0,
                    'remainingAmount': amount,
                  });
                }
              }
            }
          }

          spkList.value = spkResults;
          workItems.value = enrichedWorkItems;

          print(
              '[AddWorkReport] Final result: ${spkList.length} SPK dengan ${workItems.length} work items');
          print(
              '[AddWorkReport] Work items dengan progress > 0: ${enrichedWorkItems.where((item) => item['progressPercentage'] > 0).length}');

          // Jika SPK yang sebelumnya dipilih tidak ada lagi dalam daftar, hapus pilihan
          if (selectedSpk.value != null &&
              !spkList.any((spk) => spk.id == selectedSpk.value!.id)) {
            selectedSpk.value = null;
          }

          completer.complete(true);
        }
      }).catchError((e) {
        if (!completer.isCompleted) {
          print('[AddWorkReport] Error fetch SPKs dengan progress: $e');
          error.value = e.toString();
          completer.complete(false);
        }
      });

      // Tunggu sampai fetch selesai atau timeout
      final success = await completer.future;
      return success;
    } catch (e) {
      print('[AddWorkReport] Unexpected error in fetchSPKsWithProgress: $e');
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
      final ImagePicker picker = ImagePicker();
      List<XFile> images = [];
      if (source == ImageSource.camera) {
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        if (image != null) images = [image];
      } else {
        images = await picker.pickMultiImage();
      }

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

          // Update waktu foto - hanya ambil komponen waktu, tanggal tetap menggunakan reportDate
          if (photoTime != null) {
            // Gabungkan tanggal dari reportDate dengan waktu dari foto
            final photoTimeWithReportDate = DateTime(
              reportDate.value.year,
              reportDate.value.month,
              reportDate.value.day,
              photoTime.hour,
              photoTime.minute,
              photoTime.second,
            );

            if (firstPhotoTime == null ||
                photoTimeWithReportDate.isBefore(firstPhotoTime)) {
              firstPhotoTime = photoTimeWithReportDate;
            }
            if (lastPhotoTime == null ||
                photoTimeWithReportDate.isAfter(lastPhotoTime)) {
              lastPhotoTime = photoTimeWithReportDate;
            }
          }
        }
      }

      // Update waktu berdasarkan jenis foto (start/end) - hanya waktu, bukan tanggal
      if (startPhotos.isEmpty && firstPhotoTime != null) {
        // Ini foto awal - set waktu mulai dengan tanggal dari reportDate
        workStartTime.value = firstPhotoTime;
      } else if (endPhotos.isEmpty && lastPhotoTime != null) {
        // Ini foto akhir - set waktu selesai dengan tanggal dari reportDate
        workEndTime.value = lastPhotoTime;
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
        // Gabungkan tanggal dari reportDate dengan waktu dari foto
        final photoTimeWithReportDate = DateTime(
          reportDate.value.year,
          reportDate.value.month,
          reportDate.value.day,
          photoTime.hour,
          photoTime.minute,
          photoTime.second,
        );

        // Update waktu berdasarkan jenis foto (start/end) - hanya waktu, bukan tanggal
        if (startPhotos.isEmpty) {
          // Ini foto awal
          workStartTime.value = photoTimeWithReportDate;
        } else if (endPhotos.isEmpty) {
          // Ini foto akhir
          workEndTime.value = photoTimeWithReportDate;
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

  Future<void> selectSPK(Spk spk) async {
    try {
      print('[AddWorkReport] === selectSPK START ===');
      print('[AddWorkReport] Selecting SPK: ${spk.spkNo}');

      selectedSpk.value = spk;

      // Pre-fill location from SPK if available
      if (spk.location?.name != null) {
        location.value = spk.location!.name;
      }

      // PERBAIKAN: Hanya panggil satu method untuk update workItems
      // Gunakan _updateWorkItemsForSelectedSPK yang lebih comprehensive
      print('[AddWorkReport] Updating work items for selected SPK...');
      await _updateWorkItemsForSelectedSPK(spk);

      // // Cek apakah ada draft untuk SPK ini pada hari ini
      // final hasDraft = await hasTodayDraft(spk.id);
      // if (hasDraft) {
      //   print('[AddWorkReport] Draft found for today, loading draft data...');
      //   // Muat data sementara
      //   await loadTemporaryData(spk.id);
        
      // } else {
      //   print('[AddWorkReport] No draft for today, checking for old drafts...');
      //   // Hapus draft lama jika ada (bukan hari ini)
      //   final existingDraft = await _hiveService.getDailyActivity(spk.id);
      //   if (existingDraft != null) {
      //     print('[AddWorkReport] Found old draft, clearing it...');
      //     await clearTemporaryData(spk.id);
      //   }
      // }

      print('[AddWorkReport] === selectSPK END ===');
      print('[AddWorkReport] Final workItems count: ${workItems.length}');
    } catch (e) {
      print('[AddWorkReport] Error in selectSPK: $e');
      error.value = e.toString();
    }
  }

  // Method helper untuk mengupdate work items untuk SPK yang dipilih
  Future<void> _updateWorkItemsForSelectedSPK(Spk spk) async {
    try {
      // Null check removed as it's not needed and causes lint warning
      
      print('[AddWorkReport] Checking for draft progress data: ${_draftProgressData.length} items saved');
      print('[AddWorkReport] Updating work items for selected SPK: ${spk.spkNo}');
      print(
          '[AddWorkReport] Current workItems count before update: ${workItems.length}');

      final service = Get.find<GraphQLService>();

      // Menggunakan satu sumber data (fetchSPKWithProgressBySpkId)
      // spkDetailsWithProgress akan di-set setelah data diterima di bawah.

      print(
          '[AddWorkReport] Calling fetchSPKWithProgressBySpkId for SPK ID: ${spk.id}');

      final spkWithProgress = await service.fetchSPKWithProgressBySpkId(spk.id);
      print(
          '[AddWorkReport] GraphQL response received. Keys: ${spkWithProgress.keys}');
      print('[AddWorkReport] Full GraphQL response: $spkWithProgress');

      // Konversi ke model dan set sebagai sumber tunggal untuk seluruh UI
      try {
        spkDetailsWithProgress.value =
            SpkDetailWithProgressResponse.fromJson(spkWithProgress);
        print('[AddWorkReport] spkDetailsWithProgress berhasil di-set (single source)');
      } catch (e) {
        print('[AddWorkReport] ERROR parsing SpkDetailWithProgressResponse: $e');
      }

      final workItemsData =
          spkWithProgress['workItems'] as List<dynamic>? ?? [];
      print(
          '[AddWorkReport] Found ${workItemsData.length} work items for SPK ${spk.spkNo}');

      if (workItemsData.isEmpty) {
        print(
            '[AddWorkReport] WARNING: No work items found in GraphQL response!');
        print('[AddWorkReport] This could mean:');
        print('[AddWorkReport] 1. SPK has no work items defined');
        print('[AddWorkReport] 2. GraphQL query returned empty workItems');
        print('[AddWorkReport] 3. There\'s an issue with the GraphQL endpoint');
        return;
      }

      List<Map<String, dynamic>> updatedWorkItems = [];

      for (var item in workItemsData) {

        print('[AddWorkReport] Processing work item: ${item}'); 


        


        // Safe casting untuk nilai numerik
        final boqNr = (item['boqVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
        final boqR = (item['boqVolume']?['r'] as num?)?.toDouble() ?? 0.0;
        final dailyTargetNr =
            (item['dailyTarget']?['nr'] as num?)?.toDouble() ?? 0.0;
        final dailyTargetR =
            (item['dailyTarget']?['r'] as num?)?.toDouble() ?? 0.0;
        final completedNr =
            (item['completedVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
        final completedR =
            (item['completedVolume']?['r'] as num?)?.toDouble() ?? 0.0;
        final remainingNr =
            (item['remainingVolume']?['nr'] as num?)?.toDouble() ?? 0.0;
        final remainingR =
            (item['remainingVolume']?['r'] as num?)?.toDouble() ?? 0.0;
        final progress =
            (item['progressPercentage'] as num?)?.toDouble() ?? 0.0;
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final spentAmount = (item['spentAmount'] as num?)?.toDouble() ?? 0.0;
        final remainingAmount =
            (item['remainingAmount'] as num?)?.toDouble() ?? 0.0;

        final enrichedItem = {
          'spkId': spk.id,
          'spkNo': spk.spkNo,
          'name': item['name'] ?? '',
          'volume': boqNr + boqR,
          'unit': item['unit']?['name'] ?? '',
          'volumeType': boqR > 0 ? 'r' : 'nr',
          'dailyTarget': {'nr': dailyTargetNr, 'r': dailyTargetR},
          'completedVolume': {'nr': completedNr, 'r': completedR},
          'remainingVolume': {'nr': remainingNr, 'r': remainingR},
          'progressPercentage': progress,
          'amount': amount,
          'spentAmount': spentAmount,
          'remainingAmount': remainingAmount,
          // Tambahan field sesuai data backend
          'boqVolume': {'nr': boqNr, 'r': boqR}, // Tambahkan boqVolume untuk form
          'rates': item['rates'] ?? {'nr': {'rate': 0}, 'r': {'rate': 0}}, // Tambahkan rates
          'description': item['description'] ?? '',
        };

        updatedWorkItems.add(enrichedItem);
        print(
            '[AddWorkReport] Added work item: ${enrichedItem['name']} (${enrichedItem['progressPercentage']}%)');
      }

      // PERBAIKAN: Clear dan replace workItems instead of merging to prevent duplicates
      print(
          '[AddWorkReport] Clearing existing workItems to prevent duplicates...');
      print('[AddWorkReport] Old workItems count: ${workItems.length}');

      // Clear dan set ulang dengan data baru untuk SPK ini
      workItems.value = updatedWorkItems;

      print('[AddWorkReport] New workItems count: ${workItems.length}');
      print('[AddWorkReport] === _updateWorkItemsForSelectedSPK END ===');
    } catch (e) {
      print('[AddWorkReport] Error updating work items for selected SPK: $e');
      print('[AddWorkReport] Stack trace: ${StackTrace.current}');

      // Fallback ke data SPK biasa jika gagal
      if (spk.workItems != null) {
        print('[AddWorkReport] Using fallback work items data');
        List<Map<String, dynamic>> fallbackItems = [];

        for (var workItem in spk.workItems!) {
          final boqNr = workItem.boqVolume.nr.toDouble();
          final boqR = workItem.boqVolume.r.toDouble();
          final amount = (workItem.amount ?? 0).toDouble();

          fallbackItems.add({
            'spkId': spk.id,
            'spkNo': spk.spkNo,
            'name': workItem.workItem?.name ?? '',
            'volume': boqNr + boqR,
            'unit': workItem.workItem?.unit?.name ?? '',
            'volumeType': boqR > 0 ? 'r' : 'nr',
            'dailyTarget': {'nr': 0.0, 'r': 0.0},
            'completedVolume': {'nr': 0.0, 'r': 0.0},
            'remainingVolume': {'nr': boqNr, 'r': boqR},
            'progressPercentage': 0.0,
            'amount': amount,
            'spentAmount': 0.0,
            'remainingAmount': amount,
          });
        }

        // Clear dan set dengan fallback data
        workItems.value = fallbackItems;
        print(
            '[AddWorkReport] Updated work items with fallback data. Total: ${workItems.length}');
      }
    }
  }

  void setReportDate(DateTime date) {
    reportDate.value = date;
  }

  void setWorkStartTime(DateTime time) {
    // Combine the selected time with the report date
    final selectedDate = reportDate.value;
    workStartTime.value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
      time.second,
    );
  }

  void setWorkEndTime(DateTime time) {
    // Combine the selected time with the report date
    final selectedDate = reportDate.value;
    workEndTime.value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
      time.second,
    );
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
        // Manpower opsional, bisa di-skip
        return true;

      case 4: // Peralatan
        // Peralatan opsional, bisa di-skip
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
        print('[AddWorkReport] spkDetailsWithProgress status:');
        print(
            '[AddWorkReport] - spkDetailsWithProgress.value: ${spkDetailsWithProgress.value}');
        print('[AddWorkReport] - selectedSpk.value: ${selectedSpk.value}');
        print('[AddWorkReport] - selectedSpk.value?.id: ${selectedSpk.value?.id}');
        print('[AddWorkReport] - workItems.length: ${workItems.length}');

        if (spkDetailsWithProgress.value != null) {
          print(
              '[AddWorkReport] - dailyActivities.length: ${spkDetailsWithProgress.value!.dailyActivities.length}');
          if (spkDetailsWithProgress.value!.dailyActivities.isNotEmpty) {
            final latestActivity =
                spkDetailsWithProgress.value!.dailyActivities.first;
            print(
                '[AddWorkReport] - workItems in latestActivity: ${latestActivity.workItems.length}');
            print(
                '[AddWorkReport] - Work items: ${latestActivity.workItems.map((w) => w.name).toList()}');
          } else {
            print('[AddWorkReport] - dailyActivities is EMPTY!');
          }
        } else {
          print('[AddWorkReport] - spkDetailsWithProgress is NULL!');

          // Try to re-fetch if selectedSpk is available
          if (selectedSpk.value != null) {
            print(
                '[AddWorkReport] Attempting to re-fetch spkDetailsWithProgress...');
            try {
              final service = Get.find<GraphQLService>();
              final spkDetailWithProgress = await service
                  .fetchSPKDetailsWithProgress(selectedSpk.value!.id);
              if (spkDetailWithProgress != null) {
                spkDetailsWithProgress.value = spkDetailWithProgress;
                print(
                    '[AddWorkReport] Re-fetch successful! dailyActivities: ${spkDetailWithProgress.dailyActivities.length}');
                if (spkDetailWithProgress.dailyActivities.isNotEmpty) {
                  final latestActivity =
                      spkDetailWithProgress.dailyActivities.first;
                  print(
                      '[AddWorkReport] Re-fetch - workItems in latestActivity: ${latestActivity.workItems.length}');
                } else {
                  print(
                      '[AddWorkReport] Re-fetch - dailyActivities is still EMPTY!');
                }
              } else {
                print('[AddWorkReport] Re-fetch returned null');
              }
            } catch (e) {
              print('[AddWorkReport] Re-fetch error: $e');
            }
          }
        }
        print('=== END DEBUG ===');

        // Ambil workItems dari SpkDetailWithProgressResponse dan tambahkan data dailyTarget
        if (spkDetailsWithProgress.value == null ||
            spkDetailsWithProgress.value!.dailyActivities.isEmpty) {
          print(
              '[AddWorkReport] VALIDATION FAILED: spkDetailsWithProgress is null or dailyActivities is empty');
          print(
              '[AddWorkReport] Checking if we can use fallback from workItems...');
          print(
              '[AddWorkReport] Current workItems for SPK: ${workItems.where((item) => item['spkId'] == selectedSpk.value?.id).length}');

          // Try fallback: check if we have workItems that can be used
          final filteredWorkItems = workItems
              .where((item) => item['spkId'] == selectedSpk.value?.id)
              .toList();
          if (filteredWorkItems.isNotEmpty) {
            print(
                '[AddWorkReport] Found ${filteredWorkItems.length} workItems for fallback');
            print(
                '[AddWorkReport] Fallback workItems: ${filteredWorkItems.map((w) => w['name']).toList()}');

            // Create fallback workItemsForProgress using workItems
            final fallbackWorkItemsForProgress = filteredWorkItems.map((item) {
              return {
                'workItemId': item['id'],
                'workItem': {
                  'id': item['id'],
                  'name': item['name'],
                  'unit': {'name': item['unit']},
                },
                'boqVolume': item['boqVolume'] ?? {'nr': 0.0, 'r': 0.0},
                'dailyTarget': item['dailyTarget'] ?? {'nr': 0.0, 'r': 0.0},
                'rates': item['rates'] ??
                    {
                      'nr': {'rate': 0.0, 'description': ''},
                      'r': {'rate': 0.0, 'description': ''}
                    },
                'progressAchieved':
                    item['progressAchieved'] ?? {'nr': 0.0, 'r': 0.0},
                'actualQuantity':
                    item['actualQuantity'] ?? {'nr': 0.0, 'r': 0.0},
                'dailyProgress': item['dailyProgress'] ?? {'nr': 0.0, 'r': 0.0},
                'dailyCost': item['dailyCost'] ?? {'nr': 0.0, 'r': 0.0},
                'description': item['description'] ?? '',
                'spk': {
                  'startDate': selectedSpk.value?.startDate,
                  'endDate': selectedSpk.value?.endDate,
                },
              };
            }).toList();

            print(
                '[AddWorkReport] Using fallback workItems for progress: ${fallbackWorkItemsForProgress.length} items');
            workProgressController
                .initializeFromWorkItems(fallbackWorkItemsForProgress);
      workProgressController.workProgresses.forEach((element) {
        print('xxzxtestxx'+element.workItemName+element.progressVolumeNR.toString());
      });

            // Proceed to WorkProgressForm with fallback data
            final result = await Get.to<bool>(
              () => WorkProgressForm(controller: workProgressController),
              transition: Transition.rightToLeft,
            );
            return;
          }

          error.value =
              'Data progress SPK tidak lengkap. Pastikan SPK telah dipilih dengan benar.';
          showSnackbar(
            'Error',
            'Data progress SPK tidak lengkap. Pastikan SPK telah dipilih dengan benar.',
            isError: true,
          );
          return;
        }
        final latestActivity =
            spkDetailsWithProgress.value!.dailyActivities.first;

        // Ambil data dailyTarget dari workItems yang sudah diupdate
        final workItemsWithDailyTarget = workItems
            .where((item) => item['spkId'] == selectedSpk.value?.id)
            .toList();

        final workItemsForProgress =
            latestActivity.workItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          // Cari matching workItem berdasarkan ID atau index
          Map<String, dynamic>? matchingWorkItem;
          try {
            matchingWorkItem = workItemsWithDailyTarget.firstWhere(
              (wItem) => wItem['name'] == item.name,
            );
          } catch (e) {
            matchingWorkItem = <String, dynamic>{};
          }

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
            'dailyTarget': matchingWorkItem?['dailyTarget'] ??
                {
                  'nr': 0.0,
                  'r': 0.0,
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

        print(
            'DEBUG: workItems untuk progress: ${workItemsForProgress.length} item');
        if (workItemsForProgress.isEmpty) {
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

        // Debug: Log data dailyTarget sebelum pass ke WorkProgressController
        print('[AddWorkReport] === DEBUG DAILY TARGET DATA ===');
        for (int i = 0; i < workItemsForProgress.length; i++) {
          final item = workItemsForProgress[i];
          print('[AddWorkReport] Item $i: ${item['workItem']['name']}');
          print('[AddWorkReport]   - dailyTarget: ${item['dailyTarget']}');
          print('[AddWorkReport]   - boqVolume: ${item['boqVolume']}');
        }
        print('[AddWorkReport] === END DEBUG DAILY TARGET ===');

        workProgressController.initializeFromWorkItems(workItemsForProgress);

        // Add validation before navigating to WorkProgressForm
        print('[AddWorkReport] === BEFORE WORK PROGRESS FORM ===');
        print('selectedSpk.value: ${selectedSpk.value}');
        print('selectedSpk.value?.id: ${selectedSpk.value?.id}');
        print('selectedSpk.value?.spkNo: ${selectedSpk.value?.spkNo}');
        print('spkList.length: ${spkList.length}');

        if (selectedSpk.value == null) {
          print(
              '[AddWorkReport] ERROR: selectedSpk is null before WorkProgressForm!');

          // Try to recover
          ensureSpkSelected();

          if (selectedSpk.value == null) {
            error.value =
                'SPK tidak terpilih. Silakan pilih SPK terlebih dahulu.';
            showSnackbar(
              'Error',
              'SPK tidak terpilih. Silakan pilih SPK terlebih dahulu.',
              isError: true,
            );
            return;
          } else {
            print(
                '[AddWorkReport] Recovery successful before WorkProgressForm: ${selectedSpk.value?.spkNo}');
          }
        }

        print(
            '[AddWorkReport] SPK validation passed, opening WorkProgressForm');

workProgressController.workProgresses.forEach((element) {
        print('xxzxtestxx'+element.workItemName+element.progressVolumeNR.toString()+'x'+element.progressVolumeR.toString());
      });
        final result = await Get.to<bool>(
          () => WorkProgressForm(controller: workProgressController),
          transition: Transition.rightToLeft,
        );

        // Submit sudah ditangani di WorkProgressForm
        // Tidak perlu submit lagi di sini untuk menghindari double submit
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

      // Enhanced SPK validation with debugging
      print('[AddWorkReport] === SUBMIT VALIDATION ===');
      print('selectedSpk.value: ${selectedSpk.value}');
      print('selectedSpk.value?.id: ${selectedSpk.value?.id}');
      print('selectedSpk.value?.spkNo: ${selectedSpk.value?.spkNo}');
      print('spkList.length: ${spkList.length}');

      if (selectedSpk.value == null) {
        print('[AddWorkReport] ERROR: selectedSpk is null!');

        // Try to recover by ensuring SPK is selected
        ensureSpkSelected();

        // If still null after recovery attempt, check if there are SPKs available
        if (selectedSpk.value == null) {
          if (spkList.isEmpty) {
            print('[AddWorkReport] No SPK available in spkList for recovery');
            throw Exception(
                'Tidak ada SPK tersedia. Silakan refresh halaman dan coba lagi.');
          } else {
            print('[AddWorkReport] SPK list available but selection failed');
            throw Exception(
                'SPK belum dipilih. Silakan pilih SPK terlebih dahulu.');
          }
        } else {
          print(
              '[AddWorkReport] Recovery successful: selectedSpk now = ${selectedSpk.value?.spkNo}');
        }
      }

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

      // Create fresh input data to avoid any cached references
      final freshInput = <String, dynamic>{
        "spkId": selectedSpk.value!.id,
        "date": reportDate.value.toIso8601String().split('T')[0],
        "areaId": selectedSpk.value!.location?.id ?? '',
        "workStartTime": workStartTime.value.toUtc().toIso8601String(),
        "workEndTime": workEndTime.value?.toUtc().toIso8601String() ?? '',
        "closingRemarks": remarks.value,
        "startImages": startPhotos.map((p) => p.accessUrl).toList(),
        "finishImages": endPhotos.map((p) => p.accessUrl).toList(),
        "activityDetails": Get.find<WorkProgressController>()
            .workProgresses
            .map((p) => <String, dynamic>{
                  "workItemId": p.workItemId,
                  "actualQuantity": <String, dynamic>{
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
            .map((e) => <String, dynamic>{
                  "equipmentId": e.equipment.id,
                  "fuelIn": e.fuelIn,
                  "fuelRemaining": e.fuelRemaining,
                  "workingHour": e.workingHours,
                  "isBrokenReported": e.isBrokenReported,
                  "remarks": e.remarks ?? '',
                  "hourlyRate": e.selectedContract?.rentalRatePerDay ?? 0.0,
                })
            .toList(),
        "manpowerLogs": selectedManpower
            .map((m) => <String, dynamic>{
                  "role": m.personnelRole.id,
                  "personCount": m.personCount ?? 0,
                  "hourlyRate": m.normalHourlyRate ?? 0.0,
                })
            .toList(),
        "materialUsageLogs": materialController.selectedMaterials
            .map((m) => <String, dynamic>{
                  "materialId": m.material.id,
                  "quantity": m.quantity ?? 0.0,
                  "unitRate": m.material.unitRate ?? 0.0,
                  "remarks": m.remarks ?? '',
                })
            .toList(),
        "otherCosts": otherCostController.otherCosts
            .map((cost) => <String, dynamic>{
                  "costType": cost.costType,
                  "amount": cost.amount,
                  "description": cost.description,
                  "receiptNumber": cost.receiptNumber,
                  "remarks": cost.remarks,
                })
            .toList(),
      };

      final input = freshInput;

      print('=== DATA YANG DIKIRIM KE SERVER ===');
      print('SPK ID: ${input["spkId"]}');
      print(
          'Equipment Logs: ${(input["equipmentLogs"] as List?)?.length ?? 0} items');
      print(
          'Manpower Logs: ${(input["manpowerLogs"] as List?)?.length ?? 0} items');
      print(
          'Material Usage Logs: ${(input["materialUsageLogs"] as List?)?.length ?? 0} items');
      print(
          'Other Costs: ${(input["otherCosts"] as List?)?.length ?? 0} items');

      // Debug each section to find the problematic object
      try {
        print('Testing equipment logs encoding...');
        print('Equipment logs data: ${input["equipmentLogs"]}');
        final equipmentJson = jsonEncode(input["equipmentLogs"]);
        print('Equipment logs OK');
      } catch (e) {
        print('ERROR in equipment logs: $e');
      }

      try {
        print('Testing manpower logs encoding...');
        print('Manpower logs data: ${input["manpowerLogs"]}');
        final manpowerJson = jsonEncode(input["manpowerLogs"]);
        print('Manpower logs OK');
      } catch (e) {
        print('ERROR in manpower logs: $e');
      }

      try {
        print('Testing material logs encoding...');
        print('Material logs data: ${input["materialUsageLogs"]}');
        final materialJson = jsonEncode(input["materialUsageLogs"]);
        print('Material logs OK');
      } catch (e) {
        print('ERROR in material logs: $e');
      }

      try {
        print('Testing other costs encoding...');
        print('Other costs data: ${input["otherCosts"]}');
        final otherCostsJson = jsonEncode(input["otherCosts"]);
        print('Other costs OK');
      } catch (e) {
        print('ERROR in other costs: $e');
      }

      // Debug activityDetails yang akan dikirim
      print('=== DEBUG ACTIVITY DETAILS ===');
      final activityDetails = input["activityDetails"] as List;
      print('Total activityDetails: ${activityDetails.length}');
      for (int i = 0; i < activityDetails.length; i++) {
        final detail = activityDetails[i];
        print('Activity $i:');
        print('  - workItemId: ${detail["workItemId"]}');
        print('  - actualQuantity: ${detail["actualQuantity"]}');
        print('  - status: ${detail["status"]}');
        print('  - remarks: ${detail["remarks"]}');
      }
      print('=== END ACTIVITY DETAILS ===');

      // Final validation before sending
      print('=== FINAL VALIDATION BEFORE SEND ===');
      try {
        final fullInputJson = jsonEncode(input);
        print('Full input JSON encoding: OK');
        print('JSON length: ${fullInputJson.length} characters');
      } catch (e) {
        print('ERROR: Full input JSON encoding failed: $e');
        throw Exception('Data tidak valid untuk dikirim: $e');
      }
      print('=== END FINAL VALIDATION ===');

      print('=== END DATA KIRIM ===');

      //Kirim data ke server menggunakan GraphQL service
      print('[AddWorkReport] Calling service.submitDailyReport...');
      final service = Get.find<GraphQLService>();

      final result;
      try {
        result = await service.submitDailyReport(input);
        print('[AddWorkReport] service.submitDailyReport returned: $result');
      } catch (serviceError) {
        print(
            '[AddWorkReport] ERROR from service.submitDailyReport: $serviceError');
        print('[AddWorkReport] Stack trace: ${StackTrace.current}');
        rethrow;
      }

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
      // Don't save temporary data during submit process to avoid conflicts
      // saveTemporaryData();
    }
  }

  // Ambil data jabatan personel
  Future<void> fetchPersonnelRoles() async {
    try {
      isLoadingPersonnel.value = true;
      error.value = '';

      print('[AddWorkReport] Mengambil data jabatan personel...');

      // Add timeout to prevent hanging
      final service = Get.find<GraphQLService>();
      final roles = await service
          .fetchPersonnelRoles()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Timeout saat mengambil data jabatan personel',
            const Duration(seconds: 30));
      });

      personnelRoles.value = roles;
      print(
          '[AddWorkReport] Berhasil mengambil ${roles.length} jabatan personel');
    } catch (e) {
      print('[AddWorkReport] Error mengambil jabatan personel: $e');
      error.value = 'Gagal mengambil data jabatan personel: $e';

      // Don't show snackbar here as it might be called during initialization
      // Just log the error and continue
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
      print(
          'Daily Rate: ${entry.manpowerDailyRate != null ? 'Rp ${entry.manpowerDailyRate}' : '-'}');
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
    final index = selectedManpower
        .indexWhere((item) => item.personnelRole.id == personnelRoleId);
    if (index >= 0) {
      print('Removing entry:');
      print('Role: ${selectedManpower[index].personnelRole.roleName}');
      print('Count: ${selectedManpower[index].personCount} orang');
      print('Hours: ${selectedManpower[index].normalHoursPerPerson} jam');
    }
    print('===========================\n');

    selectedManpower
        .removeWhere((item) => item.personnelRole.id == personnelRoleId);
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

      print('[AddWorkReport] Mengambil data peralatan...');

      // Add timeout to prevent hanging
      final graphQLService = Get.find<GraphQLService>();
      final equipments = await graphQLService
          .fetchEquipments()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Timeout saat mengambil data peralatan',
            const Duration(seconds: 30));
      });

      equipmentList.assignAll(equipments);
      print(
          '[AddWorkReport] Berhasil mengambil ${equipments.length} peralatan');
    } catch (e) {
      print('[AddWorkReport] Error mengambil data peralatan: $e');
      error.value = 'Gagal mengambil data peralatan: $e';

      // Don't show snackbar here as it might be called during initialization
      // Just log the error and continue
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

  // Method untuk mendapatkan status activity berdasarkan pengisian
  String getActivityStatus() {
    // Jika ada foto finish dan remarks, maka status COMPLETED
    if (endPhotos.isNotEmpty && remarks.value.isNotEmpty) {
      return 'COMPLETED';
    }
    // Jika ada foto start, maka status IN_PROGRESS
    else if (startPhotos.isNotEmpty) {
      return 'IN_PROGRESS';
    }
    // Jika tidak ada foto sama sekali, maka status DRAFT
    else {
      return 'DRAFT';
    }
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

      // Debug: Check other costs before saving
      final otherCostController = Get.find<OtherCostController>();

      // Ambil progress data dari WorkProgressController jika ada
      List<activity_input.ActivityDetail> activityDetails = [];
      try {
        final workProgressController = Get.find<WorkProgressController>();
        if (workProgressController.workProgresses.isNotEmpty) {
          print('[AddWorkReport] Saving ${workProgressController.workProgresses.length} progress items to draft');
          activityDetails = workProgressController.workProgresses.map((progress) {
            return activity_input.ActivityDetail(
              id: progress.workItemId,
              workItemId: progress.workItemId,
              actualQuantity: activity_input.Quantity(
                nr: progress.progressVolumeNR,
                r: progress.progressVolumeR,
              ),
              status: activityStatus,
              remarks: progress.remarks ?? '',
            );
          }).toList();
          print('[AddWorkReport] Successfully converted ${activityDetails.length} progress items for draft');
        }
      } catch (e) {
        print('[AddWorkReport] Error getting progress data for draft: $e');
        // Continue without progress data if there's an error
      }

      // Buat objek DailyActivity dari data sementara menggunakan model dari activity_input
      final dailyActivity = activity_input.DailyActivity(
        id: '', // ID akan di-generate oleh Hive
        spkId: spkId,
        spkDetails: spkDetails,
        date: reportDate.value.millisecondsSinceEpoch
            .toString(), // Simpan sebagai timestamp
        areaId: selectedSpk.value?.location?.id ?? '',
        weather: weather.value,
        status: activityStatus, // Gunakan status yang sesuai
        workStartTime: workStartTime.value.millisecondsSinceEpoch
            .toString(), // Simpan sebagai timestamp
        workEndTime: workEndTime.value?.millisecondsSinceEpoch.toString() ?? '',
        startImages: startPhotos.map((p) => p.accessUrl).toList(),
        finishImages: endPhotos.map((p) => p.accessUrl).toList(),
        closingRemarks: remarks.value,
        progressPercentage: 0.0,
        activityDetails: activityDetails, // Simpan progress data yang sudah diinput
        equipmentLogs: selectedEquipment
            .map((e) => activity_input.EquipmentLog(
                  id: '',
                  equipmentId: e.equipment.id,
                  fuelIn: e.fuelIn,
                  fuelRemaining: e.fuelRemaining,
                  workingHour: e.workingHours,
                  isBrokenReported: e.isBrokenReported,
                  remarks: e.remarks ?? '',
                  hourlyRate: e.selectedContract?.rentalRatePerDay ??
                      0.0, // Simpan rentalRatePerDay sebagai hourlyRate
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
                  quantity: m.quantity ?? 0.0,
                  unitRate: m.material.unitRate ?? 0.0,
                  remarks: m.remarks ?? '',
                ))
            .toList(),
        otherCosts: otherCostController.otherCosts
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

      // Refresh data lokal di DailyActivityController jika ada
      try {
        final dailyActivityController = Get.find<DailyActivityController>();
        await dailyActivityController.fetchLocalActivities();
        print('[AddWorkReport] Local activities refreshed after saving draft');
      } catch (e) {
        print('[AddWorkReport] Could not refresh local activities: $e');
      }
    } catch (e) {
      print('[AddWorkReport] Error menyimpan data sementara: $e');
    }
  }

  // Method untuk memuat data sementara dari local storage
  Future<bool> loadTemporaryData(String spkId) async {
    try {
      print('[AddWorkReport] === LOAD TEMPORARY DATA START ===');
      print('[AddWorkReport] Mulai memuat data sementara untuk SPK: $spkId');
      print('[AddWorkReport] Current spkList.length: ${spkList.length}');

      // Pastikan daftar SPK sudah tersedia
      if (spkList.isEmpty) {
        print('[AddWorkReport] spkList masih kosong, mengambil daftar SPK...');
        await fetchSPKs();
        print('[AddWorkReport] spkList diisi dengan ${spkList.length} items');
      }

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

      print('[AddWorkReport] Data draft ditemukan untuk SPK: $spkId');
      print('[AddWorkReport] Draft spkId: ${dailyActivity.spkId}');

      // Set selectedSpk dari draft jika ada di spkList
      print('[AddWorkReport] Mencari SPK di spkList...');
      print('[AddWorkReport] SPK list available:');
      for (int i = 0; i < spkList.length; i++) {
        final spk = spkList[i];
        // print('[AddWorkReport]   $i: ${spk.spkNo} (ID: ${spk.id})');
      }

      final spkFromList =
          spkList.firstWhereOrNull((spk) => spk.id == dailyActivity.spkId);
      if (spkFromList != null) {
        selectedSpk.value = spkFromList;
        print(
            '[AddWorkReport] selectedSpk berhasil diset dari spkList: ${spkFromList.spkNo}');
        // Panggil selectSPK agar perilaku sama seperti saat pengguna memilih SPK
        await selectSPK(spkFromList);
      } else {
        print(
            '[AddWorkReport] WARNING: SPK dengan ID ${dailyActivity.spkId} tidak ditemukan di spkList');
        print('[AddWorkReport] Available SPK IDs di spkList:');
        for (final spk in spkList) {
          print('[AddWorkReport]   - ${spk.id} (${spk.spkNo})');
        }

        // Sebagai fallback, coba reload SPK list sekali lagi
        print(
            '[AddWorkReport] Mencoba reload SPK list untuk mencari SPK yang dimaksud...');
        final reloadSuccess = await fetchSPKs();
        print('[AddWorkReport] Reload SPK result: $reloadSuccess');
        print(
            '[AddWorkReport] SPK list setelah reload: ${spkList.length} items');

        final spkFromListAfterReload =
            spkList.firstWhereOrNull((spk) => spk.id == dailyActivity.spkId);

        if (spkFromListAfterReload != null) {
          selectedSpk.value = spkFromListAfterReload;
          print(
              '[AddWorkReport] selectedSpk berhasil diset setelah reload: ${spkFromListAfterReload.spkNo}');
          // Panggil selectSPK agar perilaku sama seperti saat pengguna memilih SPK
          await selectSPK(spkFromListAfterReload);
        } else {
          print(
              '[AddWorkReport] ERROR: SPK dengan ID ${dailyActivity.spkId} tetap tidak ditemukan setelah reload');
          print('[AddWorkReport] Available SPK IDs setelah reload:');
          for (final spk in spkList) {
            print('[AddWorkReport]   - ${spk.id} (${spk.spkNo})');
          }
          // Tidak bisa membuat SPK object baru karena masalah type compatibility
          // Biarkan selectedSpk null dan akan ditangani di add_work_report_page.dart
        }
      }

      // Tambahkan print untuk debug data draft
      // print('[AddWorkReport] === DATA DRAFT YANG DIMUAT ===');
      // print('spkId: \\${dailyActivity.spkId}');
      // print('spkDetails: \\${dailyActivity.spkDetails}');
      // print('date: \\${dailyActivity.date}');
      // print('areaId: \\${dailyActivity.areaId}');
      // print('weather: \\${dailyActivity.weather}');
      // print('status: \\${dailyActivity.status}');
      // print('workStartTime: \\${dailyActivity.workStartTime}');
      // print('workEndTime: \\${dailyActivity.workEndTime}');
      // print('startImages: \\${dailyActivity.startImages}');
      // print('finishImages: \\${dailyActivity.finishImages}');
      // print('closingRemarks: \\${dailyActivity.closingRemarks}');
      // print('progressPercentage: \\${dailyActivity.progressPercentage}');
      // print('activityDetails: \\${dailyActivity.activityDetails}');
      // print('equipmentLogs: \\${dailyActivity.equipmentLogs}');
      // print('manpowerLogs: \\${dailyActivity.manpowerLogs}');
      // print('materialUsageLogs: \\${dailyActivity.materialUsageLogs}');
      // print('otherCosts: \\${dailyActivity.otherCosts}');
      // print('createdAt: \\${dailyActivity.createdAt}');
      // print('updatedAt: \\${dailyActivity.updatedAt}');
      // print('localId: \\${dailyActivity.localId}');
      // print('lastSyncAttempt: \\${dailyActivity.lastSyncAttempt}');
      // print('[AddWorkReport] === END DATA DRAFT ===');

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
      try {
        // Parse date dari timestamp atau ISO string
        if (dailyActivity.date.contains('-')) {
          // ISO string format
          reportDate.value = DateTime.parse(dailyActivity.date);
        } else {
          // Timestamp format
          reportDate.value = DateTime.fromMillisecondsSinceEpoch(
              int.parse(dailyActivity.date));
        }
      } catch (e) {
        print('[AddWorkReport] Error parsing date: $e, using current date');
        reportDate.value = DateTime.now();
      }

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
                  '[AddWorkReport] Equipment tidak ditemukan untuk ID: ${log.equipmentId}');
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

          // Debug: Print equipment contracts
          print(
              '[AddWorkReport] Equipment ${equipment.equipmentCode} memiliki ${equipment.contracts.length} kontrak');
          for (var contract in equipment.contracts) {
            print(
                '[AddWorkReport] - Contract: ${contract.contractId}, rentalRatePerDay: ${contract.rentalRatePerDay}, rentalRate: ${contract.rentalRate}');
          }
          print('[AddWorkReport] Saved hourlyRate: ${log.hourlyRate}');

          // Cari contract yang rentalRatePerDay-nya sama dengan log.hourlyRate (yang sebenarnya adalah rentalRatePerDay)
          equipment_model.EquipmentContract? selectedContract;
          if (equipment.contracts.isNotEmpty) {
            selectedContract = equipment.contracts.firstWhereOrNull(
              (c) => c.rentalRatePerDay == log.hourlyRate,
            );

            // Jika tidak ditemukan berdasarkan rentalRatePerDay, coba cari berdasarkan rentalRate
            selectedContract ??= equipment.contracts.firstWhereOrNull(
              (c) => c.rentalRate == log.hourlyRate,
            );
          }

          // Jika tidak ada contract yang cocok, buat dummy contract dengan nilai yang tersimpan
          selectedContract ??= equipment_model.EquipmentContract(
            contractId: 'draft',
            equipmentId: equipment.id,
            rentalRate: log.hourlyRate,
            rentalRatePerDay:
                log.hourlyRate, // Set both fields dengan nilai yang sama
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
                '[AddWorkReport] Menambahkan equipment entry untuk: ${equipment.equipmentCode} (saved hourlyRate: ${log.hourlyRate}, selected contract rentalRatePerDay: ${selectedContract.rentalRatePerDay})');
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
          print(
              '[AddWorkReport] Memuat other cost: ${cost.description} - Rp ${cost.amount}');

          // Gunakan model OtherCost dari daily_activity_model.dart yang digunakan oleh OtherCostController
          final otherCostModel = daily_activity_model.OtherCost(
            id: cost.id,
            costType: cost.costType,
            amount: cost.amount,
            description: cost.description,
            receiptNumber: cost.receiptNumber,
            remarks: cost.remarks,
          );

          otherCostController.addOtherCost(otherCostModel);
          print(
              '[AddWorkReport] Berhasil menambahkan other cost: ${cost.costType}');
        } catch (e) {
          print('[AddWorkReport] Error saat memuat other cost: $e');
        }
      }


      // Load progress data dari draft jika ada - SIMPAN SEMENTARA KE STORAGE
      // PENTING: JANGAN load draft progress sekarang, kita akan menggunakan data ini nanti
      // setelah workItems diload dan diproses
      _draftProgressData.clear();
      
      if (dailyActivity.activityDetails.isNotEmpty) {
        print('[AddWorkReport] Loading ${dailyActivity.activityDetails.length} progress items from draft (saved to temporary storage)');

        try {
          // Buat map untuk menyimpan data progress berdasarkan workItemId
          for (var detail in dailyActivity.activityDetails) {
            if (detail.workItemId.isNotEmpty) {
              _draftProgressData[detail.workItemId] = {
                'progressVolumeR': detail.actualQuantity.r,
                'progressVolumeNR': detail.actualQuantity.nr,
                'remarks': detail.remarks,
              };
              
              print('[AddWorkReport] Saved draft progress for item ${detail.workItemId}: ' +
                    'R=${detail.actualQuantity.r}, NR=${detail.actualQuantity.nr}');
            }
          }
          print('[AddWorkReport] Successfully saved ${_draftProgressData.length} progress items to temporary storage');
        } catch (e) {
          print('[AddWorkReport] Error processing progress data from draft: $e');
          _draftProgressData.clear();
        }
      } else {
        print('[AddWorkReport] No progress data found in draft');
      }

      print('[AddWorkReport] Berhasil memuat semua data untuk SPK: $spkId');

      // Setelah semua data berhasil dimuat, pastikan workItems juga diupdate
      // dengan data terkini dari selectedSpk jika tersedia
      if (selectedSpk.value != null) {
        print('[AddWorkReport] Memuat work items untuk SPK yang dipilih...');
        print('[AddWorkReport] selectedSpk.value: ${selectedSpk.value?.spkNo}');
        print(
            '[AddWorkReport] Current workItems count before update: ${workItems.length}');

        try {
          await _updateWorkItemsForSelectedSPK(selectedSpk.value!);
          print(
              '[AddWorkReport] Work items berhasil dimuat: ${workItems.length} items');

          // Debug: Print semua workItems yang berhasil dimuat
          for (int i = 0; i < workItems.length; i++) {
            final item = workItems[i];
            print(
                '[AddWorkReport] WorkItem $i: ${item['name']} (spkId: ${item['spkId']})');
          }
        } catch (e) {
          print('[AddWorkReport] Error memuat work items: $e');
          print('[AddWorkReport] Stack trace: ${StackTrace.current}');
          // Jika gagal, biarkan workItems kosong - tidak perlu error
        }
      } else {
        print(
            '[AddWorkReport] WARNING: selectedSpk.value is null, cannot load work items');
      }

      print('[AddWorkReport] === LOAD TEMPORARY DATA FINAL STATUS ===');
      print(
          '[AddWorkReport] selectedSpk: ${selectedSpk.value?.spkNo ?? 'NULL'}');
      print(
          '[AddWorkReport] selectedSpk.id: ${selectedSpk.value?.id ?? 'NULL'}');
      print('[AddWorkReport] workItems.length: ${workItems.length}');
      print('[AddWorkReport] currentStep: ${currentStep.value}');
      print('[AddWorkReport] === LOAD TEMPORARY DATA END ===');

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

  // Fungsi parsing tanggal yang aman
  DateTime? safeParseDate(dynamic value) {
    print(
        '[AddWorkReport] safeParseDate input: $value (type: ${value.runtimeType})');

    if (value == null) {
      print('[AddWorkReport] safeParseDate: value is null');
      return null;
    }

    if (value is DateTime) {
      print('[AddWorkReport] safeParseDate: value is already DateTime');
      return value;
    }

    if (value is int) {
      try {
        print('[AddWorkReport] safeParseDate: parsing int timestamp: $value');
        final result = DateTime.fromMillisecondsSinceEpoch(value);
        print('[AddWorkReport] safeParseDate: int parsing success: $result');
        return result;
      } catch (e) {
        print('[AddWorkReport] safeParseDate: int parsing failed: $e');
      }
    }

    if (value is String) {
      print('[AddWorkReport] safeParseDate: trying to parse string: "$value"');

      // Coba parse ISO string dulu
      try {
        final result = DateTime.parse(value);
        print(
            '[AddWorkReport] safeParseDate: ISO string parsing success: $result');
        return result;
      } catch (e) {
        print('[AddWorkReport] safeParseDate: ISO string parsing failed: $e');
      }

      // Coba parse sebagai epoch timestamp string
      try {
        final epoch = int.parse(value);
        print('[AddWorkReport] safeParseDate: parsed string as epoch: $epoch');
        final result = DateTime.fromMillisecondsSinceEpoch(epoch);
        print('[AddWorkReport] safeParseDate: epoch parsing success: $result');
        return result;
      } catch (e) {
        print('[AddWorkReport] safeParseDate: epoch parsing failed: $e');
      }

      // Coba handle format timestamp yang tidak standard
      if (value.contains('T') || value.contains('-')) {
        try {
          // Handle ISO format variants
          String cleanValue = value.replaceAll('Z', '').trim();
          if (!cleanValue.contains('.')) {
            cleanValue += '.000';
          }
          if (!cleanValue.endsWith('Z')) {
            cleanValue += 'Z';
          }
          final result = DateTime.parse(cleanValue);
          print(
              '[AddWorkReport] safeParseDate: cleaned ISO parsing success: $result');
          return result;
        } catch (e) {
          print(
              '[AddWorkReport] safeParseDate: cleaned ISO parsing failed: $e');
        }
      }
    }

    print(
        '[AddWorkReport] safeParseDate: all parsing attempts failed, returning null');
    return null;
  }

  Future<void> fetchSpkDetailsWithProgress(String spkId) async {
    try {
      print('[AddWorkReport] === fetchSpkDetailsWithProgress START ===');
      print('[AddWorkReport] SPK ID: $spkId');

      isLoading.value = true;
      error.value = '';

      final service = Get.find<GraphQLService>();
      print(
          '[AddWorkReport] Calling GraphQL service.fetchSPKDetailsWithProgress...');

      final result = await service.fetchSPKDetailsWithProgress(spkId);
      print('[AddWorkReport] GraphQL service response received');

      if (result != null) {
        print('[AddWorkReport] Setting spkDetailsWithProgress...');
        spkDetailsWithProgress.value = result;
        print('[AddWorkReport] spkDetailsWithProgress set successfully');

        // Update workItems jika ada data
        if (result.dailyActivities.isNotEmpty) {
          print(
              '[AddWorkReport] Processing ${result.dailyActivities.length} daily activities...');
          final latestActivity = result.dailyActivities.first;
          print(
              '[AddWorkReport] Latest activity has ${latestActivity.workItems.length} work items');

          final newWorkItems = latestActivity.workItems
              .map((item) => {
                    'spkId': spkId, // TAMBAHKAN FIELD INI
                    'name': item.name,
                    'description': item.description,
                    // Choose volume: use remote if non-remote is 0, otherwise use non-remote
                    'volume': item.boqVolume.nr != 0
                        ? item.boqVolume.nr
                        : item.boqVolume.r,
                    'volumeType': item.boqVolume.nr != 0
                        ? 'nr'
                        : 'r', // Track which type is being used
                    'unit': item.unit.name,
                    'unitRate': item.boqVolume.nr != 0
                        ? item.rates.nr.rate
                        : item.rates.r.rate,
                    'progress': item.boqVolume.nr != 0
                        ? item.progressAchieved.nr
                        : item.progressAchieved.r,
                    'actualQuantity': item.boqVolume.nr != 0
                        ? item.actualQuantity.nr
                        : item.actualQuantity.r,
                    'dailyProgress': item.boqVolume.nr != 0
                        ? item.dailyProgress.nr
                        : item.dailyProgress.r,
                    'dailyCost': item.boqVolume.nr != 0
                        ? item.dailyCost.nr
                        : item.dailyCost.r,
                    // Tambahkan data progress untuk work_details_widget
                    'completedVolume': {
                      'nr': item.progressAchieved.nr,
                      'r': item.progressAchieved.r,
                    },
                    'remainingVolume': {
                      'nr': item.boqVolume.nr - item.progressAchieved.nr,
                      'r': item.boqVolume.r - item.progressAchieved.r,
                    },
                    'dailyTarget': {
                      'nr': item.dailyProgress.nr,
                      'r': item.dailyProgress.r,
                    },
                    'progressPercentage': item.boqVolume.nr != 0
                        ? (item.progressAchieved.nr / item.boqVolume.nr * 100)
                        : (item.boqVolume.r != 0
                            ? (item.progressAchieved.r / item.boqVolume.r * 100)
                            : 0.0),
                    'amount': item.boqVolume.nr != 0
                        ? item.dailyCost.nr
                        : item.dailyCost.r,
                  })
              .toList();

          workItems.value = newWorkItems;
          print(
              '[AddWorkReport] workItems updated with ${workItems.length} items');

          // Debug: Print semua workItems yang berhasil di-set
          for (int i = 0; i < workItems.length; i++) {
            final item = workItems[i];
            print(
                '[AddWorkReport] New WorkItem $i: ${item['name']} (spkId: ${item['spkId']})');
          }
        } else {
          print('[AddWorkReport] WARNING: No daily activities found in result');
          workItems.value = [];
        }
      } else {
        print('[AddWorkReport] WARNING: GraphQL service returned null result');
        workItems.value = [];
      }

      print('[AddWorkReport] === fetchSpkDetailsWithProgress END ===');
    } catch (e) {
      print('[AddWorkReport] Error fetching SPK details: $e');
      print('[AddWorkReport] Stack trace: ${StackTrace.current}');
      error.value = e.toString();
      workItems.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk memvalidasi state controller
  bool validateControllerState() {
    print('[AddWorkReport] === VALIDATING CONTROLLER STATE ===');
    print('selectedSpk.value: ${selectedSpk.value}');
    print('selectedSpk.value?.id: ${selectedSpk.value?.id}');
    print('selectedSpk.value?.spkNo: ${selectedSpk.value?.spkNo}');
    print('spkList.length: ${spkList.length}');
    print('currentStep.value: ${currentStep.value}');
    print('startPhotos.length: ${startPhotos.length}');
    print('endPhotos.length: ${endPhotos.length}');
    print('selectedManpower.length: ${selectedManpower.length}');
    print('selectedEquipment.length: ${selectedEquipment.length}');

    if (selectedSpk.value == null) {
      print('[AddWorkReport] ERROR: selectedSpk is null!');
      return false;
    }

    print('[AddWorkReport] Controller state validation passed');
    return true;
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
