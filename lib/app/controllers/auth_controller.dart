import 'package:get/get.dart';
import 'package:rifansi/app/data/models/user_model.dart';
import '../data/models/login_response_model.dart';
import '../data/providers/graphql_service.dart';
import '../data/providers/storage_service.dart';

class AuthController extends GetxController {
  final GraphQLService _graphQLService = Get.find<GraphQLService>();
  final StorageService _storageService = Get.find<StorageService>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;

  static const String loginMutation = '''
    mutation Login(\$username: String!, \$password: String!) {
      login(username: \$username, password: \$password) {
        token
        user {
          id
          username
          fullName
          email
          role {
            id
            roleCode
            roleName
          }
        }
      }
    }
  ''';

  static const String meQuery = '''
    query {
      me {
        id
        username
        fullName
        email
        phone
        role {
          id
          roleCode
          roleName
        }
        area {
          id
          name
          location {
            type
            coordinates
          }
        }
        isActive
        lastLogin
        createdAt
        updatedAt
      }
    }
  ''';

  @override
  void onInit() {
    super.onInit();
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    print('[AuthController] Loading token from storage...');
    final storedToken = await _storageService.getToken();
    print(
        '[AuthController] Stored token: ${storedToken != null ? 'EXISTS (${storedToken.length} chars)' : 'NULL'}');

    if (storedToken != null && storedToken.isNotEmpty) {
      token.value = storedToken;
      print('[AuthController] Token loaded, fetching current user...');

      final success = await fetchCurrentUser();
      print('[AuthController] Fetch current user result: $success');

      if (!success) {
        print('[AuthController] Failed to fetch user data, clearing token...');
        // If we can't fetch user data, the token might be expired
        await logout();
      }
    } else {
      print('[AuthController] No stored token found');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;

      final result = await _graphQLService.mutate(
        loginMutation,
        variables: {
          'username': username,
          'password': password,
        },
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final loginResponse = LoginResponse.fromJson(
        result.data!['login'] as Map<String, dynamic>,
      );

      token.value = loginResponse.token;
      currentUser.value = loginResponse.user;

      // Save token to secure storage
      await _storageService.saveToken(token.value);

      // Fetch complete user data including area information
      print('Login successful, fetching complete user data...');
      await fetchCurrentUser();

      return true;
    } catch (e) {
      // TODO: Handle error properly
      print('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // Clear token from secure storage
    await _storageService.clearAll();
    token.value = '';
    currentUser.value = null;
  }

  bool get isLoggedIn => token.value.isNotEmpty && currentUser.value != null;

  Future<bool> fetchCurrentUser() async {
    try {
      print(
          '[AuthController] Fetching current user with token: ${token.value.isNotEmpty ? 'EXISTS' : 'EMPTY'}');

      final result = await _graphQLService.query(meQuery);
      print(
          '[AuthController] GraphQL query result - hasException: ${result.hasException}');

      if (result.hasException) {
        print('[AuthController] GraphQL exception: ${result.exception}');
        throw result.exception!;
      }

      print('[AuthController] GraphQL result data: ${result.data}');
      final userData = result.data?['me'];
      print('[AuthController] User data from response: $userData');

      if (userData == null) {
        print('[AuthController] User data is null');
        return false;
      }

      currentUser.value = User.fromJson(userData as Map<String, dynamic>);
      print(
          '[AuthController] User loaded successfully: ${currentUser.value?.fullName}');

      return true;
    } catch (e) {
      print('[AuthController] Fetch current user error: $e');
      return false;
    }
  }
}
