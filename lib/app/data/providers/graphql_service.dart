import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get/get.dart';
import 'storage_service.dart';
import '../models/area_model.dart';
import '../models/spk_model.dart';

class GraphQLService extends GetxService {
  late GraphQLClient client;
  final String baseUrl = 'https://localhost3000.fando.id/graphql';

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

  Future<QueryResult> query(String document, {Map<String, dynamic>? variables}) async {
    final QueryOptions options = QueryOptions(
      document: gql(document),
      variables: variables ?? const {},
    );

    return await client.query(options);
  }

  Future<QueryResult> mutate(String document, {Map<String, dynamic>? variables}) async {
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

  Future<List<Area>> getAllAreas() async {
    final result = await query(getAllAreasQuery);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    final List areas = result.data?['areas'] ?? [];
    return areas.map((json) => Area.fromJson(json)).toList();
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

  Future<List<Spk>> fetchSPKs({String? startDate, String? endDate, String? locationId, String? keyword}) async {
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
} 