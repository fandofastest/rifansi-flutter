import 'package:get/get.dart';
import '../data/providers/graphql_service.dart';
import '../data/models/spk_details_model.dart';
import '../data/models/spk_detail_with_progress_response.dart' as spk_progress;

class SpkDetailsController extends GetxController {
  final GraphQLService _graphQLService = Get.find<GraphQLService>();

  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);
  final Rx<spk_progress.SpkDetailWithProgressResponse?> spkDetails =
      Rx<spk_progress.SpkDetailWithProgressResponse?>(null);

  final String spkId;

  SpkDetailsController({required this.spkId});

  @override
  void onInit() {
    super.onInit();
    fetchSpkDetails();
  }

  Future<void> fetchSpkDetails() async {
    try {
      isLoading.value = true;
      error.value = null;

      final details = await _graphQLService.fetchSPKDetailsWithProgress(spkId);
      if (details != null) {
        spkDetails.value = details;
      } else {
        error.value = 'Data SPK tidak ditemukan';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper getters untuk memudahkan akses data
  String get spkNo => spkDetails.value?.spkNo ?? '-';
  String get wapNo => spkDetails.value?.wapNo ?? '-';
  String get title => spkDetails.value?.title ?? '-';
  String get projectName => spkDetails.value?.projectName ?? '-';
  String get contractor => spkDetails.value?.contractor ?? '-';
  String get location => spkDetails.value?.location.name ?? '-';
  String get startDate => spkDetails.value?.startDate ?? '-';
  String get endDate => spkDetails.value?.endDate ?? '-';
  double get budget => (spkDetails.value?.budget ?? 0).toDouble();
  double get progressPercentage =>
      spkDetails.value?.totalProgress.percentage ?? 0;
  double get totalBudget => spkDetails.value?.totalProgress.totalBudget ?? 0;
  double get totalSpent => spkDetails.value?.totalProgress.totalSpent ?? 0;
  double get remainingBudget =>
      spkDetails.value?.totalProgress.remainingBudget ?? 0;
  List<spk_progress.DailyActivity> get dailyActivities =>
      spkDetails.value?.dailyActivities ?? [];
  List<spk_progress.WorkItem> get workItems =>
      spkDetails.value?.dailyActivities
          .expand((activity) => activity.workItems)
          .toList() ??
      [];
}
