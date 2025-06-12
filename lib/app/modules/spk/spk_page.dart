import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/spk_controller.dart';
import '../../controllers/auth_controller.dart';
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
    final authController = Get.find<AuthController>();
    
    // Reset and initialize page every time it's built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage(authController, lokasiController);
    });
    
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
              _buildHeader(context, lokasiController, authController),
              const SizedBox(height: 24),
              _buildSpkList(),
            ],
          ),
        );
      }),
    );
  }

  void _initializePage(AuthController authController, LokasiController lokasiController) async {
    // Prevent multiple simultaneous calls
    if (controller.isLoading.value) {
      print('[SPK Page] Already loading, skipping initialization');
      return;
    }

    // Reset controller state first
    controller.spks.clear();
    controller.error.value = '';
    
    // Wait a bit to ensure user data is loaded
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Get fresh user data
    await authController.fetchCurrentUser();
    
    // Debug user area information
    final user = authController.currentUser.value;
    final userArea = user?.area;
    
    print('[SPK Page] =================================');
    print('[SPK Page] User: ${user?.fullName}');
    print('[SPK Page] User Area: ${userArea?.name}');
    print('[SPK Page] User Area ID: ${userArea?.id}');
    print('[SPK Page] =================================');
    
    // Fetch SPKs - controller will automatically handle area filtering
    await controller.fetchSPKs();
    
    // Set location controller based on user area
    if (userArea != null && userArea.id.isNotEmpty && userArea.name.toLowerCase() != 'allarea') {
      lokasiController.selectArea(userArea);
    } else {
      // Reset location controller to default
      lokasiController.selectedArea.value = Area(
        id: '',
        name: 'Semua Lokasi',
        location: Location(type: '', coordinates: []),
      );
    }
    
    print('[SPK Page] Initialization complete. SPKs loaded: ${controller.spks.length}');
  }

  Widget _buildHeader(BuildContext context, LokasiController lokasiController, AuthController authController) {
    final userArea = authController.currentUser.value?.area;
    final hasSpecificArea = userArea != null && userArea.id.isNotEmpty;

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
                child: Column(
                  children: [
                    Text(
                      'Daftar SPK',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    if (hasSpecificArea) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.75),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userArea!.name,
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Only show filter if user doesn't have a specific area
              if (!hasSpecificArea)
                Obx(() => GestureDetector(
                      onTap: () {
                        _showPilihLokasiDialog(context, lokasiController);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt,
                                color: FigmaColors.primary, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              lokasiController.selectedArea.value?.name ??
                                  'Pilih Lokasi',
                              style: GoogleFonts.dmSans(
                                color: FigmaColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
              else
                const SizedBox(width: 60), // Spacer to maintain layout balance
              const SizedBox(width: 16),
            ],
          ),
          _buildSearchBar(lokasiController, authController),
        ],
      ),
    );
  }

  void _showPilihLokasiDialog(
      BuildContext context, LokasiController lokasiController) async {
    
    print('[Dialog Lokasi] =================================');
    print('[Dialog Lokasi] Opening location picker dialog');
    print('[Dialog Lokasi] Current areas count: ${lokasiController.areas.length}');
    print('[Dialog Lokasi] Current areas: ${lokasiController.areas.map((a) => a.name).toList()}');
    print('[Dialog Lokasi] Has loaded areas: ${lokasiController.hasLoadedAreas.value}');
    print('[Dialog Lokasi] Is loading: ${lokasiController.isLoading.value}');
    print('[Dialog Lokasi] Error: ${lokasiController.error.value}');
    
    // Force fetch areas
    print('[Dialog Lokasi] Force fetching areas...');
    final success = await lokasiController.fetchAreas();
    print('[Dialog Lokasi] Fetch result: $success');
    print('[Dialog Lokasi] After fetch - areas count: ${lokasiController.areas.length}');
    print('[Dialog Lokasi] After fetch - areas: ${lokasiController.areas.map((a) => a.name).toList()}');
    print('[Dialog Lokasi] =================================');
    
    // Use only actual areas, no default "Semua Lokasi"
    List<Area> areaList = [...lokasiController.areas];
    Area? tempSelected = lokasiController.selectedArea.value;
    
    print('[Dialog Lokasi] Area list for dialog: ${areaList.map((a) => a.name).toList()}');
    print('[Dialog Lokasi] Current selected: ${tempSelected?.name}');
    
    // If current selection is "Semua Lokasi", reset to first actual area
    if (tempSelected?.id == '' || tempSelected?.name == 'Semua Lokasi') {
      tempSelected = areaList.isNotEmpty ? areaList.first : null;
      print('[Dialog Lokasi] Reset selection to: ${tempSelected?.name}');
    }
    
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Obx(() {
              print('[Dialog Lokasi] Building dialog - areas count: ${lokasiController.areas.length}');
              print('[Dialog Lokasi] Building dialog - is loading: ${lokasiController.isLoading.value}');
              
              if (lokasiController.areas.isEmpty &&
                  !lokasiController.isLoading.value) {
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Pilih Lokasi',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                      ],
                    ),
                  ),
                  if (lokasiController.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (lokasiController.error.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text('Error: ${lokasiController.error.value}',
                              style: GoogleFonts.dmSans(
                                color: Colors.red,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              print('[Dialog Lokasi] Retry button pressed');
                              await lokasiController.fetchAreas();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (areaList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Tidak ada area tersedia'),
                    )
                  else ...[
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: areaList.length,
                        itemBuilder: (context, index) {
                          final area = areaList[index];
                          print('[Dialog Lokasi] Rendering area: ${area.name} (${area.id})');
                          return RadioListTile<Area>(
                            value: area,
                            groupValue: tempSelected,
                            onChanged: (val) {
                              print('[Dialog Lokasi] Selected: ${val?.name}');
                              setState(() => tempSelected = val);
                            },
                            title: Text(area.name,
                                style: GoogleFonts.dmSans(fontSize: 18)),
                            activeColor: FigmaColors.primary,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FigmaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (tempSelected != null) {
                              print('[Dialog Lokasi] Applying selection: ${tempSelected!.name}');
                              lokasiController.selectArea(tempSelected!);
                              Get.find<SpkController>().fetchSPKs(area: tempSelected);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Done',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
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

  Widget _buildSearchBar(LokasiController lokasiController, AuthController authController) {
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
                  final userArea = authController.currentUser.value?.area;
                  if (userArea != null && userArea.id.isNotEmpty) {
                    // User has specific area, search within that area
                    Get.find<SpkController>().fetchSPKs(
                      keyword: value,
                      area: userArea,
                    );
                  } else {
                    // User doesn't have specific area, use selected area from filter
                    Get.find<SpkController>().fetchSPKs(
                      keyword: value,
                      area: lokasiController.selectedArea.value,
                    );
                  }
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
                final userArea = authController.currentUser.value?.area;
                if (userArea != null && userArea.id.isNotEmpty) {
                  // User has specific area, search within that area
                  Get.find<SpkController>().fetchSPKs(
                    keyword: searchController.text,
                    area: userArea,
                  );
                } else {
                  // User doesn't have specific area, use selected area from filter
                  Get.find<SpkController>().fetchSPKs(
                    keyword: searchController.text,
                    area: lokasiController.selectedArea.value,
                  );
                }
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
