import 'package:get/get.dart';
import '../data/models/material_model.dart';
import '../data/providers/graphql_service.dart';

class MaterialController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final materials = <Material>[].obs;
  final selectedMaterials = <MaterialEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    try {
      isLoading.value = true;
      error.value = '';

      final service = Get.find<GraphQLService>();
      final result = await service.fetchMaterials();

      materials.assignAll(result);
      print(
          '[MaterialController] Berhasil mengambil ${materials.length} material');
    } catch (e) {
      print('[MaterialController] Error mengambil data material: $e');
      error.value = 'Gagal mengambil data material: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void addMaterialEntry(MaterialEntry entry) {
    // Cek jika sudah ada dengan material yang sama
    final existingIndex = selectedMaterials
        .indexWhere((item) => item.material.id == entry.material.id);

    if (existingIndex >= 0) {
      // Update entry yang sudah ada
      selectedMaterials[existingIndex] = entry;
    } else {
      // Tambah entry baru
      selectedMaterials.add(entry);
    }
  }

  void removeMaterialEntry(String materialId) {
    selectedMaterials.removeWhere((item) => item.material.id == materialId);
  }

  double get totalCost {
    return selectedMaterials.fold(0.0,
        (sum, item) => sum + (item.quantity * (item.material.unitRate ?? 0.0)));
  }
}

class MaterialEntry {
  final Material material;
  final double quantity;
  final String? remarks;

  MaterialEntry({
    required this.material,
    required this.quantity,
    this.remarks,
  });

  double get totalCost => quantity * (material.unitRate ?? 0.0);

  Map<String, dynamic> toJson() {
    return {
      'materialId': material.id,
      'quantity': quantity,
      'remarks': remarks,
    };
  }

  factory MaterialEntry.fromJson(Map<String, dynamic> json, Material material) {
    return MaterialEntry(
      material: material,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      remarks: json['remarks']?.toString(),
    );
  }
}
