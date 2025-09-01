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
  // final String baseUrl = 'https://lap3000.fando.id/graphql';

  final String baseUrl = 'https://app25.rifansi.co.id/graphql';


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
      pollInterval: const Duration(seconds: 60),
    );

    try {
      return await client.query(options).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print('[GraphQL] Query timeout after 20 seconds');
          throw Exception('Koneksi timeout setelah 20 detik');
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

    try {
      return await client.mutate(options).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print('[GraphQL] Mutation timeout after 20 seconds');
          throw Exception('Koneksi timeout setelah 20 detik');
        },
      );
    } catch (e) {
      print('[GraphQL] Mutation error: $e');
      rethrow;
    }
  }

  // Areas Query
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

  // SPK Queries
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

  static const String getSPKsNoDetailsQuery = r'''
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
      }
    }
  ''';

  Future<List<Spk>> fetchSPKs({
    String? startDate,
    String? endDate,
    String? locationId,
    String? keyword,
    bool withDetails = true,
  }) async {
    final variables = <String, dynamic>{};
    if (startDate != null) variables['startDate'] = startDate;
    if (endDate != null) variables['endDate'] = endDate;
    if (locationId != null) variables['locationId'] = locationId;
    if (keyword != null && keyword.isNotEmpty) variables['keyword'] = keyword;

    final queryDoc = withDetails ? getSPKsQuery : getSPKsNoDetailsQuery;
    final result = await query(queryDoc, variables: variables);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final List spks = result.data?['spks'] ?? [];
    return spks.map((json) => Spk.fromJson(json)).toList();
  }

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

      print('[GraphQL] Successfully fetched SPK by ID');
      return Spk.fromJson(spkData);
    } catch (e) {
      print('[GraphQL] Error in fetchSPKById: $e');
      throw Exception('Gagal mengambil SPK: $e');
    }
  }

  static const String getSPKWithProgressBySpkIdQuery = r'''
    query GetSPKWithProgressBySpkId($spkId: ID!) {
      spkWithProgressBySpkId(spkId: $spkId) {
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
          dailyTarget {
            nr
            r
          }
          boqVolume {
            nr
            r
          }
          completedVolume {
            nr
            r
          }
          remainingVolume {
            nr
            r
          }
          progressPercentage
          amount
          spentAmount
          remainingAmount
        }
        totalProgress {
          percentage
          totalTargetBOQ
          totalCompletedBOQ
          remainingBOQ
          totalBudget
          totalSpent
          remainingBudget
        }
        createdAt
        updatedAt
      }
    }
  ''';

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

  Future<Map<String, dynamic>> fetchSPKWithProgressBySpkId(String spkId) async {
    try {
      print('[GraphQL] Fetching SPK with progress by ID: $spkId');
      final variables = {'spkId': spkId};
      final result =
          await query(getSPKWithProgressBySpkIdQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching SPK with progress by ID: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final spkData = result.data?['spkWithProgressBySpkId'];
      if (spkData == null) {
        print('[GraphQL] No SPK with progress found with ID: $spkId');
        throw Exception('SPK dengan progress tidak ditemukan');
      }

      print('[GraphQL] Successfully fetched SPK with progress by ID');
      return Map<String, dynamic>.from(spkData);
    } catch (e) {
      print('[GraphQL] Error in fetchSPKWithProgressBySpkId: $e');
      throw Exception('Gagal mengambil SPK dengan progress: $e');
    }
  }

  // Daily Activity Queries
  static const String getDailyActivityByUserQuery = r'''
    query GetDailyActivityWithDetails(
      $areaId: ID
      $userId: ID
      $activityId: ID
      $startDate: String
      $endDate: String
    ) {
      getDailyActivityWithDetails(
        areaId: $areaId
        userId: $userId
        activityId: $activityId
        startDate: $startDate
        endDate: $endDate
      ) {
        id
        date
        area {
          id
          name
          location {
            type
            coordinates
          }
        }
        weather
        status
        workStartTime
        workEndTime
        startImages
        finishImages
        closingRemarks
        isApproved
        progressPercentage
        approvedBy {
          id
          username
          fullName
          email
        }
        approvedAt
        rejectionReason
        progressPercentage
        budgetUsage
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
            description
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
            category {
              id
              name
            }
            subCategory {
              id
              name
            }
          }
        }
        equipmentLogs {
          id
          equipment {
            id
            equipmentCode
            equipmentType
            plateOrSerialNo
            defaultOperator
            year
            serviceStatus
          }
          fuelIn
          fuelRemaining
          workingHour
          hourlyRate
          rentalRatePerDay
          fuelPrice
          isBrokenReported
          remarks
        }
        manpowerLogs {
          id
          role
          personCount
          hourlyRate
          workingHours
          personnelRole {
            id
            roleCode
            roleName
            description
            isPersonel
          }
        }
        materialUsageLogs {
          id
          material {
            id
            name
            description
            unitRate
            unit {
              id
              name
              code
            }
          }
          quantity
          unitRate
          remarks
        }
        otherCosts {
          id
          costType
          description
          amount
          receiptNumber
          remarks
        }
        spkDetail {
          id
          spkNo
          wapNo
          title
          projectName
          contractor
          budget
          startDate
          endDate
          workDescription
          date
          location {
            id
            name
          }
          workItems {
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
              description
              unit {
                id
                name
                code
              }
              category {
                id
                name
              }
              subCategory {
                id
                name
              }
            }
          }
        }
        userDetail {
          id
          username
          fullName
          email
          phone
          role {
            id
            roleCode
            roleName
            description
          }
          area {
            id
            name
            location {
              type
              coordinates
            }
          }
          lastLogin
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String getDailyActivityWithDetailsByActivityIdQuery = r'''
    query GetDailyActivityWithDetailsbyActivityId($activityId: ID!) {
      getDailyActivityWithDetailsByActivityId(activityId: $activityId) {
        id
        date
        area {
          id
          name
          location {
            type
            coordinates
          }
        }
        weather
        status
        workStartTime
        workEndTime
        startImages
        finishImages
        closingRemarks
        isApproved
        progressPercentage
        approvedBy {
          id
          username
          fullName
          email
        }
        approvedAt
        rejectionReason
        budgetUsage
        dailyProgress {
          totalDailyTargetBOQ {
            nr
            r
            total
          }
          totalActualBOQ {
            nr
            r
            total
          }
          dailyProgressPercentage
          workItemProgress {
            workItemName
            targetBOQ {
              nr
              r
              total
            }
            actualBOQ {
              nr
              r
              total
            }
            progressPercentage
            unit {
              id
              name
              code
            }
          }
        }
        activityDetails {
          id
          actualQuantity {
            nr
            r
          }
          status
          remarks
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
          workItem {
            id
            name
            description
            unit {
              id
              name
              code
            }
            category {
              id
              name
            }
            subCategory {
              id
              name
            }
          }
        }
        equipmentLogs {
          id
          equipment {
            id
            equipmentCode
            equipmentType
            plateOrSerialNo
            defaultOperator
            year
            serviceStatus
          }
          fuelIn
          fuelRemaining
          workingHour
          hourlyRate
          rentalRatePerDay
          fuelPrice
          isBrokenReported
          remarks
        }
        manpowerLogs {
          id
          role
          personCount
          hourlyRate
          workingHours
          personnelRole {
            id
            roleCode
            roleName
            description
            isPersonel
          }
        }
        materialUsageLogs {
          id
          material {
            id
            name
            description
            unitRate
            unit {
              id
              name
              code
            }
          }
          quantity
          unitRate
          remarks
        }
        otherCosts {
          id
          costType
          description
          amount
          receiptNumber
          remarks
        }
        spkDetail {
          id
          spkNo
          wapNo
          title
          projectName
          contractor
          budget
          startDate
          endDate
          workDescription
          date
          location {
            id
            name
          }
          workItems {
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
              description
              unit {
                id
                name
                code
              }
              category {
                id
                name
              }
              subCategory {
                id
                name
              }
            }
          }
        }
        userDetail {
          id
          username
          fullName
          email
          phone
          role {
            id
            roleCode
            roleName
            description
          }
          area {
            id
            name
            location {
              type
              coordinates
            }
          }
          lastLogin
        }
        createdAt
        updatedAt
      }
    }
  ''';

  Future<List<Map<String, dynamic>>> fetchDailyActivityByUser({
    String? userId,
    String? areaId,
    String? activityId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('[GraphQL] Fetching daily activities for user: $userId');

      // if (userId == null) {
      //   final currentUser = await Get.find<StorageService>().getUser();
      //   userId = currentUser?['id'];
      //   if (userId == null) {
      //     throw Exception('User ID tidak ditemukan');
      //   }
      // }

      final variables = <String, dynamic>{};
      if (userId != null) variables['userId'] = userId;
      if (areaId != null) variables['areaId'] = areaId;
      if (activityId != null) variables['activityId'] = activityId;
      if (startDate != null) variables['startDate'] = startDate;
      if (endDate != null) variables['endDate'] = endDate;

      final result =
          await query(getDailyActivityByUserQuery, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Errorsss: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List? activities = result.data?['getDailyActivityWithDetails'];
      if (activities == null) {
        print('[GraphQL] No activities found');
        return [];
      }

      print('[GraphQL] Found ${activities.length} activities');
      return activities.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQL] Error fetching activities: $e');
      throw Exception('Gagal mengambil data aktivitas: $e');
    }
  }

  // Daily Activity Queries
  static const String getMyDailyActivityQuery = r'''
    query GetMyDailyActivity($limit: Int, $skip: Int) {
      getMyDailyActivity(limit: $limit, skip: $skip) {
        activities {
          id
          date
          status
          workStartTime
          workEndTime
          area {
            id
            name
            location {
              type
              coordinates
            }
          }
          weather
          spk {
            spkNo
            title
            projectName
          }
        }
        totalCount
        hasMore
        currentPage
        totalPages
      }
    }
  ''';

  static const String getActivityByAreaQuery = r'''
    query GetActivityByArea($areaId: ID!, $limit: Int, $skip: Int) {
      getActivityByArea(areaId: $areaId, limit: $limit, skip: $skip) {
        activities {
          id
          date
          status
          workStartTime
          workEndTime
          area {
            id
            name
            location {
              type
              coordinates
            }
          }
          weather
          spk {
            spkNo
            title
            projectName
          }
          user {
            id
            username
            fullName
          }
        }
        totalCount
        hasMore
        currentPage
        totalPages
      }
    }
  ''';

  Future<Map<String, dynamic>> fetchMyDailyActivity(
      {int? limit, int? skip}) async {
    try {
      print('[GraphQL] Fetching my daily activities');

      final variables = <String, dynamic>{};
      if (limit != null) variables['limit'] = limit;
      if (skip != null) variables['skip'] = skip;

      final result = await query(getMyDailyActivityQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching my daily activities: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['getMyDailyActivity'];
      if (data == null) {
        print('[GraphQL] No daily activities found');
        return {
          'activities': [],
          'totalCount': 0,
          'hasMore': false,
          'currentPage': 1,
          'totalPages': 1
        };
      }

      print('[GraphQL] Successfully fetched daily activities');
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('[GraphQL] Error in fetchMyDailyActivity: $e');
      throw Exception('Gagal mengambil data aktivitas harian: $e');
    }
  }

  Future<Map<String, dynamic>> fetchActivityByArea(
      {required String areaId, int? limit, int? skip}) async {
    try {
      print('[GraphQL] Fetching activities by area: $areaId');

      final variables = <String, dynamic>{
        'areaId': areaId,
      };
      if (limit != null) variables['limit'] = limit;
      if (skip != null) variables['skip'] = skip;

      final result = await query(getActivityByAreaQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching activities by area: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['getActivityByArea'];
      if (data == null) {
        print('[GraphQL] No activities found for area: $areaId');
        return {
          'activities': [],
          'totalCount': 0,
          'hasMore': false,
          'currentPage': 1,
          'totalPages': 1
        };
      }

      print('[GraphQL] Successfully fetched activities by area');
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('[GraphQL] Error in fetchActivityByArea: $e');
      throw Exception('Gagal mengambil data aktivitas berdasarkan area: $e');
    }
  }

  // Personnel Role Queries
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
      final result = await query(getAllPersonnelRolesQuery);

      if (result.hasException) {
        print('[GraphQL] Error fetching personnel roles: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List personnelRoles = result.data?['personnelRoles'] ?? [];
      print(
          '[GraphQL] Successfully fetched ${personnelRoles.length} personnel roles');

      return personnelRoles
          .map((json) => PersonnelRole.fromJson(json))
          .toList();
    } catch (e) {
      print('[GraphQL] Error in fetchPersonnelRoles: $e');
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

  // Equipment Queries
  static const String getAllEquipmentsQuery = r'''
    query GetEquipments {
      equipments(status: ACTIVE) {
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
          rentalRatePerDay
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

  static const String getAllEquipmentsWithStatusQuery = r'''
    query GetEquipments {
      equipments{
        id
        equipmentCode
        plateOrSerialNo
        equipmentType
        defaultOperator
        serviceStatus
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

  Future<List<Equipment>> fetchEquipmentsWithStatus() async {
    try {
      print('[GraphQL] Fetching equipments with status');
      final result = await query(getAllEquipmentsWithStatusQuery);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching equipments with status: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List equipments = result.data?['equipments'] ?? [];
      print('[GraphQL] Fetched ${equipments.length} equipments with status');

      return equipments.map((json) => Equipment.fromJson(json)).toList();
    } catch (e) {
      print('[GraphQL] Error in fetchEquipmentsWithStatus: $e');
      throw Exception('Gagal mengambil data peralatan dengan status: $e');
    }
  }

  // Material Queries
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

  // Daily Report Mutations
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
          workingHour
          hourlyRate
          isBrokenReported
          remarks
        }
        manpowerLogs {
          id
          role
          personCount
          hourlyRate
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
          remarks
        }
      }
    }
  ''';

  Future<Map<String, dynamic>> submitDailyReport(
      Map<String, dynamic> input) async {
    try {
      print('[GraphQL] Submitting daily report');
      print('[GraphQL] Input: ${json.encode(input)}');

      final variables = {'input': input};
      final result =
          await mutate(submitDailyReportMutation, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error submitting daily report: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['submitDailyReport'];
      if (data == null) {
        throw Exception('No data returned from server');
      }

      print(
          '[GraphQL] Daily report submitted successfully with ID: ${data['id']}');
      return data;
    } catch (e) {
      print('[GraphQL] Error in submitDailyReport: $e');
      throw Exception('Gagal menyimpan daily report: $e');
    }
  }

  // Equipment Repair Report
  static const String createEquipmentRepairReportMutation = r'''
    mutation CreateRepairReport($input: CreateEquipmentRepairReportInput!) {
      createEquipmentRepairReport(input: $input) {
        id
        reportNumber
        equipment {
          equipmentCode
          equipmentType
        }
        status
        damageLevel
        reportDate
      }
    }
  ''';

  Future<Map<String, dynamic>> createEquipmentRepairReport(
      Map<String, dynamic> input) async {
    try {
      print('[GraphQL] Creating equipment repair report');
      print('[GraphQL] Input: ${json.encode(input)}');

      final variables = {'input': input};
      final result = await mutate(createEquipmentRepairReportMutation,
          variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error creating equipment repair report: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['createEquipmentRepairReport'];
      if (data == null) {
        throw Exception('No data returned from server');
      }

      print(
          '[GraphQL] Equipment repair report created successfully with ID: ${data['id']}');
      return data;
    } catch (e) {
      print('[GraphQL] Error in createEquipmentRepairReport: $e');
      throw Exception('Gagal membuat laporan kerusakan alat: $e');
    }
  }

  static const String getMyEquipmentRepairReportsQuery = r'''
    query GetMyReports {
      myEquipmentRepairReports {
        id
        reportNumber
        equipment {
        id
          equipmentCode
          plateOrSerialNo
          equipmentType
          description
          serviceStatus
        }
        reportedBy {
          id
          fullName
        }
        reportDate
        problemDescription
        damageLevel
        location {
          id
          name
        }
        status
        priority
        reviewedBy {
          id
          fullName
        }
        reviewDate
        estimatedCost
        actualCost
        createdAt
        updatedAt
      }
    }
  ''';

  static const String getPendingRepairReportsQuery = r'''
    query GetPendingRepairReports {
      pendingRepairReports {
        id
        reportNumber
        equipment {
          id
          equipmentCode
          plateOrSerialNo
          equipmentType
          defaultOperator
          serviceStatus
        }
        reportedBy {
            id
          username
          fullName
          role {
            roleCode
            roleName
          }
        }
        reportDate
        problemDescription
        damageLevel
        reportImages
        location {
              id
              name
            }
        immediateAction
        status
        priority
        createdAt
        updatedAt
      }
    }
  ''';

  static const String getMyAreaRepairReportsQuery = r'''
    query GetMyAreaRepairReports($status: RepairReportStatus) {
      equipmentRepairReports(status: $status) {
        id
        reportNumber
        equipment {
          id
          equipmentCode
          plateOrSerialNo
          equipmentType
              description
          serviceStatus
            }
        reportedBy {
            id
          fullName
          role {
            roleName
          }
        }
        reportDate
        problemDescription
        damageLevel
        reportImages
        status
        priority
        location {
              id
              name
            }
        reviewedBy {
              id
          fullName
        }
        reviewDate
        reviewNotes
        rejectionReason
        actualCost
        repairCompletionDate
        createdAt
        updatedAt
      }
    }
  ''';

  Future<List<Map<String, dynamic>>> fetchEquipmentRepairReports() async {
    try {
      print('[GraphQL] Fetching my equipment repair reports');

      final result = await query(getMyEquipmentRepairReportsQuery);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching my equipment repair reports: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List reports = result.data?['myEquipmentRepairReports'] ?? [];
      print('[GraphQL] Fetched ${reports.length} my equipment repair reports');

      return reports.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQL] Error in fetchEquipmentRepairReports: $e');
      throw Exception('Gagal mengambil data laporan kerusakan alat: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingRepairReports() async {
    try {
      print('[GraphQL] Fetching pending repair reports');

      final result = await query(getPendingRepairReportsQuery);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching pending repair reports: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List reports = result.data?['pendingRepairReports'] ?? [];
      print('[GraphQL] Fetched ${reports.length} pending repair reports');

      return reports.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQL] Error in fetchPendingRepairReports: $e');
      throw Exception('Gagal mengambil data laporan kerusakan pending: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyAreaRepairReports(
      {String? status}) async {
    try {
      print('[GraphQL] Fetching my area repair reports with status: $status');

      final variables = <String, dynamic>{};
      if (status != null) variables['status'] = status;

      final result =
          await query(getMyAreaRepairReportsQuery, variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching my area repair reports: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List reports = result.data?['equipmentRepairReports'] ?? [];
      print('[GraphQL] Fetched ${reports.length} my area repair reports');

      return reports.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQL] Error in fetchMyAreaRepairReports: $e');
      throw Exception('Gagal mengambil data laporan kerusakan area: $e');
    }
  }

  // Area Report Queries
  static const String getLaporanByAreaQuery = r'''
    query GetLaporanByArea($areaId: ID!) {
      getLaporanByArea(areaId: $areaId) {
        id
        date
        area {
          id
          name
          location {
            type
            coordinates
          }
        }
          status
        weather
          workStartTime
          workEndTime
        isApproved
        approvedBy {
            id
          fullName
        }
        progressPercentage
        spkDetail {
              id
          spkNo
          title
          projectName
        }
        userDetail {
              id
          fullName
        }
        activityDetails {
          id
          workItem {
            name
            }
            actualQuantity {
              nr
              r
            }
        }
        createdAt
      }
    }
  ''';

  Future<List<Map<String, dynamic>>> fetchLaporanByArea(String areaId) async {
    try {
      print('[GraphQL] Fetching laporan by area: $areaId');

      final variables = {'areaId': areaId};
      final result = await query(getLaporanByAreaQuery, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error fetching laporan by area: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List reports = result.data?['getLaporanByArea'] ?? [];
      print('[GraphQL] Fetched ${reports.length} laporan for area: $areaId');

      return reports.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[GraphQL] Error in fetchLaporanByArea: $e');
      throw Exception('Gagal mengambil data laporan area: $e');
    }
  }

  // Approval Mutations
  static const String approveDailyReportMutation = r'''
    mutation ApproveDailyReport($id: ID!, $status: String!, $remarks: String) {
      approveDailyReport(id: $id, status: $status, remarks: $remarks) {
                  id
        date
        weather
        status
        workStartTime
        workEndTime
        startImages
        finishImages
        closingRemarks
        isApproved
        approvedBy {
          id
          fullName
        }
        approvedAt
        rejectionReason
        approvalHistory {
          status
          remarks
          updatedBy {
            id
            fullName
          }
          updatedAt
        }
        lastUpdatedBy {
          id
          fullName
        }
        lastUpdatedAt
              }
            }
  ''';

  static const String reviewEquipmentRepairReportMutation = r'''
    mutation ReviewEquipmentRepairReport($id: ID!, $input: ReviewEquipmentRepairReportInput!) {
      reviewEquipmentRepairReport(id: $id, input: $input) {
        id
        reportNumber
        status
        reviewedBy {
          id
          username
          fullName
          role {
            roleCode
            roleName
          }
        }
        reviewDate
        reviewNotes
        rejectionReason
        equipment {
          id
          equipmentCode
          serviceStatus
        }
      }
    }
  ''';

  Future<Map<String, dynamic>> approveDailyReport({
    required String id,
    required String status,
    String? remarks,
  }) async {
    try {
      print('[GraphQL] Approving daily report: $id with status: $status');

      final variables = {
        'id': id,
        'status': status,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final result =
          await mutate(approveDailyReportMutation, variables: variables);

      if (result.hasException) {
        print('[GraphQL] Error approving daily report: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['approveDailyReport'];
      if (data == null) {
        throw Exception('No data returned from server');
      }

      print(
          '[GraphQL] Daily report approved successfully with ID: ${data['id']}');
      return data;
    } catch (e) {
      print('[GraphQL] Error in approveDailyReport: $e');
      throw Exception('Gagal memproses approval laporan: $e');
    }
  }

  Future<Map<String, dynamic>> reviewEquipmentRepairReport({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    try {
      print('[GraphQL] Reviewing equipment repair report: $id');
      print('[GraphQL] Review input: ${json.encode(input)}');

      final variables = {
        'id': id,
        'input': input,
      };

      final result = await mutate(reviewEquipmentRepairReportMutation,
          variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error reviewing equipment repair report: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['reviewEquipmentRepairReport'];
      if (data == null) {
        throw Exception('No data returned from server');
      }

      print(
          '[GraphQL] Equipment repair report reviewed successfully with ID: ${data['id']}');
      return data;
    } catch (e) {
      print('[GraphQL] Error in reviewEquipmentRepairReport: $e');
      throw Exception('Gagal memproses review laporan kerusakan alat: $e');
    }
  }

  // Helper methods for equipment repair report approval
  Future<Map<String, dynamic>> approveEquipmentRepairReport({
    required String id,
    required String reviewNotes,
    String? assignedTechnician,
    double? estimatedCost,
    String priority = 'MEDIUM',
  }) async {
    final input = {
      'status': 'APPROVED',
      'reviewNotes': reviewNotes,
      if (assignedTechnician != null && assignedTechnician.isNotEmpty)
        'assignedTechnician': assignedTechnician,
      if (estimatedCost != null) 'estimatedCost': estimatedCost,
      'priority': priority,
    };

    return await reviewEquipmentRepairReport(id: id, input: input);
  }

  Future<Map<String, dynamic>> rejectEquipmentRepairReport({
    required String id,
    required String rejectionReason,
    String? reviewNotes,
  }) async {
    final input = {
      'status': 'REJECTED',
      'rejectionReason': rejectionReason,
      if (reviewNotes != null && reviewNotes.isNotEmpty)
        'reviewNotes': reviewNotes,
    };

    return await reviewEquipmentRepairReport(id: id, input: input);
  }

  Future<Map<String, dynamic>> fetchDailyActivityWithDetailsByActivityId(
      String activityId) async {
    try {
      print(
          '[GraphQL] Fetching daily activity details by activity ID: $activityId');

      final variables = {'activityId': activityId};
      final result = await query(getDailyActivityWithDetailsByActivityIdQuery,
          variables: variables);

      if (result.hasException) {
        print(
            '[GraphQL] Error fetching daily activity details: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['getDailyActivityWithDetailsByActivityId'];
      if (data == null) {
        print('[GraphQL] No daily activity details found');
        throw Exception('Detail aktivitas tidak ditemukan');
      }

      print('[GraphQL] Successfully fetched daily activity details');
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('[GraphQL] Error in fetchDailyActivityWithDetailsByActivityId: $e');
      throw Exception('Gagal mengambil detail aktivitas: $e');
    }
  }
}
