import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/spk_controller.dart';
import '../../theme/app_theme.dart';
import '../../data/models/spk_model.dart';
import 'widgets/spk_card.dart';
import '../../controllers/lokasi_controller.dart';
import '../../data/models/area_model.dart';

class SpkPage extends GetView<SpkController> {
  const SpkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lokasiController = Get.find<LokasiController>();
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${controller.error.value}',
              style: GoogleFonts.dmSans(
                color: FigmaColors.error,
                fontSize: 16,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, lokasiController),
              const SizedBox(height: 24),
              _buildSpkList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, LokasiController lokasiController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [FigmaColors.primary, FigmaColors.error],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  'Daftar SPK',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
              ),
              Obx(() => GestureDetector(
                onTap: () {
                  _showPilihLokasiDialog(context, lokasiController);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, color: FigmaColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        lokasiController.selectedArea.value?.name ?? 'Pilih Lokasi',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(width: 16),
            ],
          ),
                        _buildSearchBar(lokasiController),

        ],
      ),
    );
  }

  void _showPilihLokasiDialog(BuildContext context, LokasiController lokasiController) async {
    await lokasiController.fetchAreas();
    // Area khusus untuk Semua Lokasi
    final allArea = Area(
      id: '',
      name: 'Semua Lokasi',
      location: Location(type: '', coordinates: []),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    List<Area> areaList = [allArea, ...lokasiController.areas];
    Area? tempSelected = lokasiController.selectedArea.value ?? allArea;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Obx(() {
              if (lokasiController.areas.isEmpty && !lokasiController.isLoading.value) {
                print('[Dialog Lokasi] Area list kosong!');
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: FigmaColors.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Pilih Lokasi', style: GoogleFonts.dmSans(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,
                        )),
                      ],
                    ),
                  ),
                  if (lokasiController.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    ...areaList.map((area) => RadioListTile<Area>(
                      value: area,
                      groupValue: tempSelected,
                      onChanged: (val) => setState(() => tempSelected = val),
                      title: Text(area.name, style: GoogleFonts.dmSans(fontSize: 18)),
                      activeColor: FigmaColors.primary,
                    )),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FigmaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (tempSelected != null) {
                              lokasiController.selectArea(tempSelected!);
                              if (tempSelected?.id == '') {
                                // Semua Lokasi
                                Get.find<SpkController>().fetchSPKs();
                              } else {
                                Get.find<SpkController>().fetchSPKs(area: tempSelected);
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(LokasiController lokasiController) {
    final TextEditingController searchController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: searchController,
                onSubmitted: (value) {
                  Get.find<SpkController>().fetchSPKs(
                    keyword: value,
                    area: lokasiController.selectedArea.value,
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Cari SPK ...',
                  hintStyle: GoogleFonts.dmSans(
                    color: FigmaColors.hitam.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.find<SpkController>().fetchSPKs(
                  keyword: searchController.text,
                  area: lokasiController.selectedArea.value,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: FigmaColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpkList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar SPK',
            style: GoogleFonts.dmSans(
              color: FigmaColors.hitam,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          if (controller.spks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Data SPK tidak ditemukan',
                  style: GoogleFonts.dmSans(
                    color: FigmaColors.abu,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...controller.spks.map((spk) => SpkCard(spk: spk)).toList(),
        ],
      ),
    );
  }
}
