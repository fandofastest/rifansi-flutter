import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../data/providers/graphql_service.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/area_model.dart' as area_model;

class EquipmentReportController extends GetxController {
  final isLoading = false.obs;
  final reports = <Map<String, dynamic>>[].obs;
  final equipmentList = <Equipment>[].obs;
  final areaList = <area_model.Area>[].obs;
  final error = ''.obs;

  // Image upload related
  final isUploadingPhoto = false.obs;
  final uploadProgress = 0.0.obs;

  // Upload configuration
  final String uploadToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MmE5NzUzOTRlNGQ3ZWJkMDc1YjM2NyIsImlhdCI6MTc0NzYyMTgyMywiZXhwIjoxNzc4NzI1ODIzfQ.teq_-tgZBuaQQ5h3DxcY5xHmZIIEA6NA8omq2NLnGq8';
  final String uploadUrl = 'https://cloudfiles.fando.id/api/files/upload';

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchReports(),
      fetchEquipments(),
      fetchAreas(),
    ]);
  }

  Future<void> fetchEquipments() async {
    try {
      final graphQLService = Get.find<GraphQLService>();

      // Add timeout to prevent hanging
      final fetchedEquipments = await graphQLService
          .fetchEquipments()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Timeout saat mengambil data equipment',
            const Duration(seconds: 30));
      });

      equipmentList.value = fetchedEquipments;
      print('[EquipmentReport] Fetched ${equipmentList.length} equipments');
    } catch (e) {
      print('[EquipmentReport] Error fetching equipments: $e');
      // Don't show snackbar during initialization, just log the error
    }
  }

  Future<void> fetchAreas() async {
    try {
      final graphQLService = Get.find<GraphQLService>();

      // Add timeout to prevent hanging
      final fetchedAreas = await graphQLService
          .getAllAreas()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException(
            'Timeout saat mengambil data area', const Duration(seconds: 30));
      });

      areaList.value = fetchedAreas;
      print('[EquipmentReport] Fetched ${areaList.length} areas');
    } catch (e) {
      print('[EquipmentReport] Error fetching areas: $e');
      // Don't show snackbar during initialization, just log the error
    }
  }

  Future<void> fetchReports() async {
    try {
      isLoading.value = true;
      error.value = '';

      final graphQLService = Get.find<GraphQLService>();

      // Add timeout to prevent hanging
      final fetchedReports = await graphQLService
          .fetchEquipmentRepairReports()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException(
            'Timeout saat mengambil data laporan', const Duration(seconds: 30));
      });

      reports.value = fetchedReports;
      print('[EquipmentReport] Fetched ${reports.length} equipment reports');

      // Debug logging to check data structure
      if (reports.isNotEmpty) {
        print('[EquipmentReport] Sample report data:');
        final sampleReport = reports.first;
        print('- Equipment: ${sampleReport['equipment']}');
        print('- Location: ${sampleReport['location']}');
        print('- Problem: ${sampleReport['problemDescription']}');
        print('- Status: ${sampleReport['status']}');

        // Specifically check location structure
        if (sampleReport['location'] != null) {
          print('- Location Name: ${sampleReport['location']['name']}');
          print('- Location ID: ${sampleReport['location']['id']}');
        } else {
          print('- Location is NULL');
        }
      }
    } catch (e) {
      print('[EquipmentReport] Error fetching reports: $e');
      error.value = e.toString();

      // Show error to user only if it's not a timeout during initialization
      if (!e.toString().contains('Timeout')) {
        Get.snackbar(
          'Error',
          'Gagal mengambil data laporan: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
          colorText: Get.theme.colorScheme.error,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<WorkPhoto?> uploadPhoto(File file) async {
    try {
      isUploadingPhoto.value = true;
      uploadProgress.value = 0.0;
      error.value = '';

      print('[PhotoUpload] Starting photo upload: ${file.path}');

      // Create completer for timeout handling
      final completer = Completer<WorkPhoto?>();

      // Set 15 second timeout
      Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          print('[PhotoUpload] Photo upload timeout');
          error.value = 'Timeout: Upload foto terlalu lama';
          completer.complete(null);
        }
      });

      try {
        // Read file as bytes
        final bytes = await file.readAsBytes();
        final fileLength = bytes.length;

        // Create form data manually
        final boundary = '----${DateTime.now().millisecondsSinceEpoch}';
        final uri = Uri.parse(uploadUrl);

        // Create request with manual HttpClient for more control
        final httpClient = HttpClient();
        final request = await httpClient.postUrl(uri);

        // Add headers
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

        // Send data
        for (var part in parts) {
          request.add(part);
          // Update progress - rough estimate
          if (part == bytes) {
            uploadProgress.value = 0.8; // 80% when file is sent
          }
        }

        // Get response
        final httpResponse = await request.close();
        uploadProgress.value = 0.9; // 90% when response received

        // Read response body
        final responseBody = await httpResponse.transform(utf8.decoder).join();
        uploadProgress.value = 1.0; // 100% when complete

        if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
          final jsonResponse = json.decode(responseBody);

          if (jsonResponse['status'] == 'success') {
            final fileData = jsonResponse['data']['file'];

            // Create WorkPhoto object
            final workPhoto = WorkPhoto(
              id: fileData['id'],
              filename: fileData['filename'],
              accessUrl: fileData['accessUrl'],
              downloadUrl: fileData['downloadUrl'],
              uploadedAt: DateTime.now(),
            );

            print(
                '[PhotoUpload] Successfully uploaded photo: ${workPhoto.accessUrl}');

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

        // Close client
        httpClient.close();
      } catch (e) {
        if (!completer.isCompleted) {
          print('[PhotoUpload] Error in upload process: $e');
          error.value = 'Error upload: $e';
          completer.complete(null);
        }
      }

      // Wait for upload result or timeout
      return await completer.future;
    } catch (e) {
      print('[PhotoUpload] Error uploading photo: $e');
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
      // Pick photos from gallery or camera
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) {
        return [];
      }

      List<WorkPhoto> uploadedPhotos = [];

      // Upload and process each photo
      for (var image in images) {
        final File file = File(image.path);
        final WorkPhoto? uploadedPhoto = await uploadPhoto(file);

        if (uploadedPhoto != null) {
          uploadedPhotos.add(uploadedPhoto);
        }
      }

      return uploadedPhotos;
    } catch (e) {
      print('[PhotoPicker] Error picking multiple photos: $e');
      error.value = 'Gagal mengambil foto: $e';
      return [];
    }
  }

  Future<void> createReport(Map<String, dynamic> reportData) async {
    try {
      isLoading.value = true;
      error.value = '';

      final graphQLService = Get.find<GraphQLService>();
      final result =
          await graphQLService.createEquipmentRepairReport(reportData);

      print('[EquipmentReport] Created report: ${result['id']}');

      // Refresh reports list
      await fetchReports();

      // Show success message
      Get.snackbar(
        'Sukses',
        'Laporan kerusakan alat berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    } catch (e) {
      print('[EquipmentReport] Error creating report: $e');
      error.value = e.toString();

      // Show error to user
      Get.snackbar(
        'Error',
        'Gagal membuat laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReports() async {
    await fetchReports();
  }
}

// WorkPhoto class for equipment reports
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
