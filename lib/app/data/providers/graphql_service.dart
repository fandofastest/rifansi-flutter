import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get/get.dart';
import 'storage_service.dart';
import '../models/area_model.dart' as area_model;
import '../models/spk_model.dart';
import '../models/daily_activity_model.dart'
    hide PersonnelRole, Equipment, Material;
import '../models/personnel_role_model.dart';
import '../models/equipment_model.dart';
import '../models/material_model.dart' as material_model;
import '../models/daily_activity_response.dart';
import 'dart:convert';
import '../models/spk_detail_with_progress_response.dart' as spk_progress;

class GraphQLService extends GetxService {
  late GraphQLClient client;
  final String baseUrl = 'https://laptop3000.fando.id/graphql';

  Future<GraphQLService> init() async {
    final HttpLink httpLink = HttpLink(baseUrl);

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ${await getToken()}',
    );

    final Link link = authLink.concat(httpLink);

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );

    return this;
  }

  Future<String?> getToken() async {
    // Retrieve token from secure storage
    return await Get.find<StorageService>().getToken();
  }

  Future<QueryResult> query(String document,
      {Map<String, dynamic>? variables}) async {
    final QueryOptions options = QueryOptions(
      document: gql(document),
      variables: variables ?? const {},
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      pollInterval: const Duration(seconds: 10),
    );

    try {
      return await client.query(options).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[GraphQL] Query timeout after 10 seconds');
          throw Exception('Koneksi timeout setelah 10 detik');
        },
      );
    } catch (e) {
      print('[GraphQL] Query error: $e');
      rethrow;
    }
  }

  Future<QueryResult> mutate(String document,
      {Map<String, dynamic>? variables}) async {
    final MutationOptions options = MutationOptions(
      document: gql(document),
      variables: variables ?? const {},
    );

    return await client.mutate(options);
  }

  static const String getAllAreasQuery = r'''
    query {
      areas {
        id
        name
        location {
          type
          coordinates
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<List<area_model.Area>> getAllAreas() async {
    final result = await query(getAllAreasQuery);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final List areas = result.data?['areas'] ?? [];
    return areas.map((json) => area_model.Area.fromJson(json)).toList();
  }

  static const String getSPKsQuery = r'''
    query GetSPKs(
      $startDate: String, $endDate: String, $locationId: ID, $keyword: String
    ) {
      spks(startDate: $startDate, endDate: $endDate, locationId: $locationId, keyword: $keyword) {
        id
        spkNo
        wapNo
        title
        projectName
        date
        contractor
        workDescription
        location {
          id
          name
        }
        startDate
        endDate
        budget
        workItems {
          workItemId
          boqVolume {
            nr
            r
          }
          amount
          rates {
            nr {
              rate
              description
            }
            r {
              rate
              description
            }
          }
          description
          workItem {
            id
            name
            category {
              id
              name
            }
            subCategory {
              id
              name
            }
            unit {
              id
              name
            }
          }
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<List<Spk>> fetchSPKs(
      {String? startDate,
      String? endDate,
      String? locationId,
      String? keyword}) async {
    final variables = <String, dynamic>{};
    if (startDate != null) variables['startDate'] = startDate;
    if (endDate != null) variables['endDate'] = endDate;
    if (locationId != null) variables['locationId'] = locationId;
    if (keyword != null && keyword.isNotEmpty) variables['keyword'] = keyword;
    final result = await query(getSPKsQuery, variables: variables);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final List spks = result.data?['spks'] ?? [];
    return spks.map((json) => Spk.fromJson(json)).toList();
  }

  static const String getDailyActivitiesWithDetailsByUserQuery = r'''
    query GetDailyActivitiesWithDetailsByUser($userId: ID!) {
      dailyActivitiesWithDetailsByUser(userId: $userId) {
        id
        date
        location
        weather
        status
        workStartTime
        workEndTime
        startImages
        finishImages
        closingRemarks
        progressPercentage
        activityDetails {
          id
          actualQuantity {
            nr
            r
          }
          status
          remarks
          workItem {
            id
            name
            unit {
              name
            }
          }
        }
        equipmentLogs {
          id
          fuelIn
          fuelRemaining
          workingHour
          isBrokenReported
          remarks
          equipment {
            id
            equipmentCode
            equipmentType
          }
        }
        manpowerLogs {
          id
          role
          personCount
          hourlyRate
          personnelRole {
            id
            roleName
          }
        }
        materialUsageLogs {
          id
          quantity
          unitRate
          remarks
          material {
            id
            name
          }
        }
        otherCosts {
          id
          costType
          amount
          description
          receiptNumber
          remarks
        }
        spkDetail {
          id
          spkNo
          title
          projectName
          location {
            id
            name
          }
        }
        userDetail {
          id
          username
          fullName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<List<DailyActivity>> fetchDailyActivities({String? userId}) async {
    try {
      print('[GraphQL] Fetching daily activities for user: $userId');
      // Jika userId tidak ada, gunakan id dari token (user yang login)
      if (userId == null) {
        final currentUser = await Get.find<StorageService>().getUser();
        userId = currentUser?['id'];
        if (userId == null) {
          throw Exception('User ID tidak ditemukan');
        }
      }

      final variables = {'userId': userId};
      final result = await query(getDailyActivitiesWithDetailsByUserQuery,
          variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List? activities = result.data?['dailyActivitiesWithDetailsByUser'];
      if (activities == null) {
        print('[GraphQL] No activities found');
        return [];
      }

      print('[GraphQL] Found ${activities.length} activities');
      return activities.map((json) => DailyActivity.fromJson(json)).toList();
    } catch (e) {
      print('[GraphQL] Error fetching activities: $e');
      throw Exception('Gagal mengambil data aktivitas: $e');
    }
  }

  // Metode untuk synchronize data dari server
  Future<void> syncActivitiesFromServer(
      List<DailyActivity> serverActivities) async {
    // ... existing code ...
  }

  static const String getAllPersonnelRolesQuery = r'''
    query GetAllPersonnelRoles {
      personnelRoles {
        id
        roleCode
        roleName
        description
        isPersonel
        createdAt
        updatedAt
        salaryComponent {
          id
          gajiPokok
          tunjanganTetap
          tunjanganTidakTetap
          transport
          pulsa
          bpjsKT
          bpjsJP
          bpjsKES
          uangCuti
          thr
          santunan
          hariPerBulan
          totalGajiBulanan
          biayaTetapHarian
          upahLemburHarian
        }
      }
    }
  ''';

  Future<List<PersonnelRole>> fetchPersonnelRoles() async {
    try {
      print('[GraphQL] Starting fetchPersonnelRoles');
      print('[GraphQL] Executing query: getAllPersonnelRolesQuery');
      
      final result = await query(getAllPersonnelRolesQuery);
      print('[GraphQL] Query execution completed');

      if (result.hasException) {
        print('[GraphQL] Error fetching personnel roles: ${result.exception}');
        print('[GraphQL] Error details: ${result.exception?.graphqlErrors}');
        throw Exception(result.exception.toString());
      }

      final List personnelRoles = result.data?['personnelRoles'] ?? [];
      print('[GraphQL] Successfully fetched ${personnelRoles.length} personnel roles');
      
      if (personnelRoles.isEmpty) {
        print('[GraphQL] Warning: No personnel roles found in response');
      } else {
        print('[GraphQL] First role sample: ${personnelRoles.first}');
      }

      final roles = personnelRoles
          .map((json) => PersonnelRole.fromJson(json))
          .toList();
      
      print('[GraphQL] Successfully parsed ${roles.length} personnel roles');
      return roles;
    } catch (e) {
      print('[GraphQL] Error in fetchPersonnelRoles: $e');
      print('[GraphQL] Stack trace: ${StackTrace.current}');
      throw Exception('Gagal mengambil data jabatan personel: $e');
    }
  }

  static const String getSalaryComponentDetailQuery = r'''
    query GetSalaryComponentDetailWithDate($personnelRoleId: ID!, $date: String!, $workHours: Int!) {
      getSalaryComponentDetailWithDate(
        personnelRoleId: $personnelRoleId
        date: $date
        workHours: $workHours
      ) {
        gajiPokok
        tunjanganTetap
        tunjanganTidakTetap
        transport
        pulsa
        bpjsKT
        bpjsJP
        bpjsKES
        uangCuti
        thr
        santunan
        hariPerBulan
        subTotalPenghasilanTetap
        biayaMPTetapHarian
        upahLemburHarian
        manpowerHarian
        isHoliday
        isWeekend
        dayType
        overtimeMultiplier
        workHours
      }
    }
  ''';

  Future<double> fetchManpowerDailyRate(
      {required String personnelRoleId,
      required DateTime date,
      required int workHours}) async {
    try {
      print(
          '[GraphQL] Fetching manpower daily rate for role: $personnelRoleId');

      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final variables = {
        'personnelRoleId': personnelRoleId,
        'date': dateStr,
        'workHours': workHours
      };

      final result =
          await query(getSalaryComponentDetailQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching manpower daily rate: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final salaryDetail = result.data?['getSalaryComponentDetailWithDate'];
      if (salaryDetail == null) {
        print('[GraphQL] No salary detail found');
        return 0.0;
      }

      final manpowerHarian = salaryDetail['manpowerHarian'] as num;
      print('[GraphQL] Fetched manpower daily rate: $manpowerHarian');

      return manpowerHarian.toDouble();
    } catch (e) {
      print('[GraphQL] Error in fetchManpowerDailyRate: $e');
      throw Exception('Gagal mengambil data biaya manpower harian: $e');
    }
  }

  static const String getAllEquipmentsQuery = r'''
    query GetEquipments {
      equipments {
        id
        equipmentCode
        plateOrSerialNo
        equipmentType
        defaultOperator
        area {
          id
          name
        }
        currentFuelPrice {
          id
          pricePerLiter
          effectiveDate
        }
        contracts {
          contractId
          equipmentId
          rentalRate
          contract {
            id
            contractNo
            description
            startDate
            endDate
            vendorName
          }
        }
      }
    }
  ''';

  Future<List<Equipment>> fetchEquipments() async {
    try {
      print('[GraphQL] Fetching equipments');
      final result = await query(getAllEquipmentsQuery);

      if (result.hasException) {
        print('[GraphQL] Error fetching equipments: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List equipments = result.data?['equipments'] ?? [];
      print('[GraphQL] Fetched ${equipments.length} equipments');

      return equipments.map((json) => Equipment.fromJson(json)).toList();
    } catch (e) {
      print('[GraphQL] Error in fetchEquipments: $e');
      throw Exception('Gagal mengambil data peralatan: $e');
    }
  }

  static const String getAllMaterialsQuery = r'''
    query GetAllMaterials {
      materials {
        id
        name
        unitId
        unitRate
        description
        unit {
          id
          code
          name
          description
        }
      }
    }
  ''';

  Future<List<material_model.Material>> fetchMaterials() async {
    try {
      print('[GraphQL] Fetching materials');
      final result = await query(getAllMaterialsQuery);

      if (result.hasException) {
        print('[GraphQL] Error fetching materials: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List materials = result.data?['materials'] ?? [];
      print('[GraphQL] Fetched ${materials.length} materials');

      return materials
          .map((json) => material_model.Material.fromJson(json))
          .toList();
    } catch (e) {
      print('[GraphQL] Error in fetchMaterials: $e');
      throw Exception('Gagal mengambil data material: $e');
    }
  }

  Future<List<DailyActivityResponse>> fetchWorkReports({String? userId}) async {
    try {
      print('[GraphQL] Fetching work reports for user: $userId');

      if (userId == null) {
        final currentUser = await Get.find<StorageService>().getUser();
        userId = currentUser?['id'];
        if (userId == null) {
          throw Exception('User ID tidak ditemukan');
        }
      }

      final variables = {'userId': userId};
      final result = await query(getDailyActivitiesWithDetailsByUserQuery,
          variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List? activities = result.data?['dailyActivitiesWithDetailsByUser'];
      if (activities == null) {
        print('[GraphQL] No activities found');
        return [];
      }

      print('[GraphQL] Found ${activities.length} activities');
      return activities.map((json) {
        try {
          return DailyActivityResponse.fromJson(json);
        } catch (e) {
          print('[GraphQL] Error parsing activity: $e');
          print('[GraphQL] JSON data: $json');
          throw Exception('Error parsing activity: $e');
        }
      }).toList();
    } catch (e) {
      print('[GraphQL] Error fetching activities: $e');
      throw Exception('Gagal mengambil data aktivitas: $e');
    }
  }

  static const String submitDailyReportMutation = r'''
    mutation SubmitDailyReport($input: SubmitDailyReportInput!) {
      submitDailyReport(input: $input) {
        id
        date
        status
        progress {
          physical
          financial
        }
        costs {
          equipment
          manpower
          material
          other
          total
        }
        activityDetails {
          id
          workItemId
          actualQuantity {
            nr
            r
          }
          status
          remarks
        }
        equipmentLogs {
          id
          equipmentId
          fuelIn
          fuelRemaining
          hourlyRate
          workingHour
          isBrokenReported
          remarks
        }
        manpowerLogs {
          id
          role
          personCount
          hourlyRate
          personnelRole {
            id
            roleName
            description
          }
        }
        materialUsageLogs {
          id
          materialId
          quantity
          unitRate
          remarks
        }
        otherCosts {
          id
          costType
          amount
        }
      }
    }
  ''';

  Future<Map<String, dynamic>> submitDailyReport(
      Map<String, dynamic> input) async {
    try {
      print('[GraphQL] Submitting daily report');

      // Log input yang diterima
      print('[GraphQL] Raw input received:');
      print(json.encode(input));

      // Buat dua alternatif variabel untuk dicoba - mungkin server mengharapkan format yang berbeda
      final variables1 = {
        'input': input
      }; // Format 1: {'input': {...}} - standar GraphQL
      final variables2 =
          input; // Format 2: langsung data tanpa pembungkus 'input'

      // Coba format 1
      print('[GraphQL] Trying Format 1 (with input wrapper):');
      print(json.encode(variables1));

      try {
        final result1 =
            await mutate(submitDailyReportMutation, variables: variables1);

        // Berhasil dengan format 1
        if (!result1.hasException &&
            result1.data != null &&
            result1.data!['submitDailyReport'] != null) {
          print('[GraphQL] Format 1 succeeded!');
          print('[GraphQL] Raw response data:');
          print(json.encode(result1.data));

          final data = result1.data!['submitDailyReport'];
          print(
              '[GraphQL] Daily report submitted successfully with ID: ${data['id']}');
          return data;
        } else {
          print('[GraphQL] Format 1 failed, details:');
          if (result1.hasException) print(result1.exception);
          if (result1.data == null)
            print('Null data response');
          else
            print(json.encode(result1.data));
        }
      } catch (e) {
        print('[GraphQL] Format 1 exception: $e');
      }

      // Jika format 1 gagal, coba format 2
      print('[GraphQL] Trying Format 2 (direct input):');
      print(json.encode(variables2));

      final result2 =
          await mutate(submitDailyReportMutation, variables: variables2);

      if (result2.hasException) {
        print('[GraphQL] Format 2 failed too. Error: ${result2.exception}');
        print('[GraphQL] Detailed error: ${result2.exception}');

        // Kedua format gagal, kembalikan error terakhir
        throw Exception(
            'Gagal menyimpan daily report dengan kedua format. Error: ${result2.exception}');
      }

      if (result2.data == null) {
        print('[GraphQL] Empty response received from Format 2');
        throw Exception('Empty response received from server with Format 2');
      }

      print('[GraphQL] Format 2 raw response data:');
      print(json.encode(result2.data));

      final data = result2.data?['submitDailyReport'];
      if (data == null) {
        print('[GraphQL] No data returned from Format 2 submission');
        throw Exception(
            'Tidak ada data yang dikembalikan dari server dengan Format 2');
      }

      print(
          '[GraphQL] Format 2 succeeded! Daily report submitted with ID: ${data['id']}');
      return data;
    } catch (e) {
      print('[GraphQL] Final error in submitDailyReport: $e');
      throw Exception('Gagal menyimpan daily report: $e');
    }
  }

  static const String getSPKDetailQuery = r'''
    query GetSPK($id: ID!) {
      spk(id: $id) {
        id
        spkNo
        wapNo
        title
        projectName
        date
        contractor
        workDescription
        location {
          id
          name
        }
        startDate
        endDate
        budget
        workItems {
          workItemId
          boqVolume {
            nr
            r
          }
          amount
          rates {
            nr {
              rate
              description
            }
            r {
              rate
              description
            }
          }
          description
          workItem {
            id
            name
            category {
              id
              name
            }
            subCategory {
              id
              name
            }
            unit {
              id
              name
            }
          }
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String getSPKbyIdQuery = r'''
    query GetSPKbyId($id: ID!) {
      spk(id: $id) {
        id
        spkNo
        title
        projectName
        contractor
        workDescription
        location {
          id
          name
        }
        startDate
        endDate
        budget
        workItems {
          workItemId
          boqVolume {
            nr
            r
          }
          amount
          rates {
            nr {
              rate
              description
            }
            r {
              rate
              description
            }
          }
          workItem {
            id
            name
            description
            category {
              id
              name
            }
            subCategory {
              id
              name
            }
            unit {
              id
              name
            }
          }
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<Spk> fetchSPKById(String spkId) async {
    try {
      print('[GraphQL] Fetching SPK by ID: $spkId');
      final variables = {'id': spkId};
      final result = await query(getSPKbyIdQuery, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error fetching SPK by ID: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final spkData = result.data?['spk'];
      if (spkData == null) {
        print('[GraphQL] No SPK found with ID: $spkId');
        throw Exception('SPK tidak ditemukan');
      }

      // Pastikan semua field yang diperlukan ada
      final Map<String, dynamic> safeData = {
        'id': spkData['id'] ?? '',
        'spkNo': spkData['spkNo'] ?? '',
        'title': spkData['title'] ?? '',
        'projectName': spkData['projectName'] ?? '',
        'contractor': spkData['contractor'] ?? '',
        'workDescription': spkData['workDescription'] ?? '',
        'location': spkData['location'] != null
            ? {
                'id': spkData['location']['id'] ?? '',
                'name': spkData['location']['name'] ?? '',
              }
            : null,
        'startDate': spkData['startDate'] ?? '',
        'endDate': spkData['endDate'] ?? '',
        'budget': spkData['budget'] ?? 0.0,
        'workItems': (spkData['workItems'] as List?)
                ?.map((item) => {
                      'workItemId': item['workItemId'] ?? '',
                      'boqVolume': {
                        'nr': item['boqVolume']?['nr'] ?? 0.0,
                        'r': item['boqVolume']?['r'] ?? 0.0,
                      },
                      'amount': item['amount'] ?? 0.0,
                      'rates': {
                        'nr': {
                          'rate': item['rates']?['nr']?['rate'] ?? 0.0,
                          'description':
                              item['rates']?['nr']?['description'] ?? '',
                        },
                        'r': {
                          'rate': item['rates']?['r']?['rate'] ?? 0.0,
                          'description':
                              item['rates']?['r']?['description'] ?? '',
                        },
                      },
                      'workItem': {
                        'id': item['workItem']?['id'] ?? '',
                        'name': item['workItem']?['name'] ?? '',
                        'description': item['workItem']?['description'] ?? '',
                        'category': {
                          'id': item['workItem']?['category']?['id'] ?? '',
                          'name': item['workItem']?['category']?['name'] ?? '',
                        },
                        'subCategory': {
                          'id': item['workItem']?['subCategory']?['id'] ?? '',
                          'name':
                              item['workItem']?['subCategory']?['name'] ?? '',
                        },
                        'unit': {
                          'id': item['workItem']?['unit']?['id'] ?? '',
                          'name': item['workItem']?['unit']?['name'] ?? '',
                        },
                      },
                    })
                .toList() ??
            [],
        'createdAt': spkData['createdAt'] ?? '',
        'updatedAt': spkData['updatedAt'] ?? '',
      };

      print('[GraphQL] Successfully fetched SPK by ID');
      return Spk.fromJson(safeData);
    } catch (e) {
      print('[GraphQL] Error in fetchSPKById: $e');
      throw Exception('Gagal mengambil SPK: $e');
    }
  }

  Future<Spk> fetchSPKDetail(String spkId) async {
    try {
      print('[GraphQL] Fetching SPK detail for ID: $spkId');
      final variables = {'id': spkId};
      final result = await query(getSPKDetailQuery, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error fetching SPK detail: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final spkData = result.data?['spk'];
      if (spkData == null) {
        print('[GraphQL] No SPK found with ID: $spkId');
        throw Exception('SPK tidak ditemukan');
      }

      print('[GraphQL] Successfully fetched SPK detail');
      return Spk.fromJson(spkData);
    } catch (e) {
      print('[GraphQL] Error in fetchSPKDetail: $e');
      throw Exception('Gagal mengambil detail SPK: $e');
    }
  }

  static const String getSPKDetailsWithProgressQuery = r'''
    query GetSPKDetailsWithProgressBySpkId($spkId: ID!) {
      spkDetailsWithProgress(spkId: $spkId) {
        id
        spkNo
        wapNo
        title
        projectName
        date
        contractor
        workDescription
        location {
          id
          name
        }
        startDate
        endDate
        budget
        dailyActivities {
          id
          date
          location
          weather
          status
          workStartTime
          workEndTime
          createdBy
          closingRemarks
          workItems {
            id
            name
            description
            categoryId
            subCategoryId
            unitId
            category {
              id
              name
              code
            }
            subCategory {
              id
              name
            }
            unit {
              id
              name
              code
            }
            rates {
              nr {
                rate
                description
              }
              r {
                rate
                description
              }
            }
            boqVolume {
              nr
              r
            }
            dailyProgress { 
              nr 
              r 
            }
            progressAchieved { 
              nr 
              r 
            }
            actualQuantity {
              nr
              r
            }
            dailyCost { 
              nr 
              r 
            }
            lastUpdatedAt
          }
          costs {
            materials {
              totalCost
              items {
                material
                quantity
                unit
                unitRate
                cost
              }
            }
            manpower {
              totalCost
              items {
                role
                numberOfWorkers
                workingHours
                hourlyRate
                cost
              }
            }
            equipment {
              totalCost
              items {
                equipment {
                  id
                  equipmentCode
                  plateOrSerialNo
                  equipmentType
                  description
                }
                workingHours
                hourlyRate
                fuelUsed
                fuelPrice
                cost
              }
            }
            otherCosts {
              totalCost
              items {
                description
                cost
              }
            }
          }
        }
        totalProgress {
          percentage
          totalBudget
          totalSpent
          remainingBudget
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<spk_progress.SpkDetailWithProgressResponse>
      fetchSPKDetailsWithProgress(String spkId) async {
    try {
      print('[GraphQL] Fetching SPK details with progress for ID: $spkId');
      final variables = {'spkId': spkId};
      final result =
          await query(getSPKDetailsWithProgressQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching SPK details with progress: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final spkData = result.data?['spkDetailsWithProgress'];
      if (spkData == null) {
        print('[GraphQL] No SPK details found with ID: $spkId');
        throw Exception('Detail SPK tidak ditemukan');
      }

      print('[GraphQL] Successfully fetched SPK details with progress');
      return spk_progress.SpkDetailWithProgressResponse.fromJson(
          Map<String, dynamic>.from(spkData));
    } catch (e) {
      print('[GraphQL] Error in fetchSPKDetailsWithProgress: $e');
      throw Exception('Gagal mengambil detail SPK dengan progress: $e');
    }
  }
}
