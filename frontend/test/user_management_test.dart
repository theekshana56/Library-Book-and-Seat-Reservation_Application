import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblione/main.dart';
import 'package:biblione/user_management/controllers/auth_controller.dart';
import 'package:biblione/user_management/models/auth_session.dart';
import 'package:biblione/user_management/models/user_profile.dart';
import 'package:biblione/user_management/screens/login_screen.dart';
import 'package:biblione/user_management/screens/profile_screen.dart';
import 'package:biblione/user_management/screens/registration_screen.dart';
import 'package:biblione/user_management/services/auth_api_client.dart';
import 'package:biblione/user_management/services/auth_storage.dart';
import 'package:biblione/user_management/widgets/auth_gate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAuthApiClient extends AuthApiClient {
  UserProfile? mockProfile;
  AuthSession? mockSession;
  bool shouldThrow = false;
  String errorMessage = 'Mock error';

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockSession ??
        AuthSession(
          token: 'mock-token',
          user: mockProfile ??
              const UserProfile(
                id: 'u-1',
                universityId: 'IT23773158',
                fullName: 'Ravindu Weerasinghe',
                email: 'student@biblione.edu',
                role: 'STUDENT',
                department: 'CS Dept',
                active: true,
              ),
        );
  }

  @override
  Future<UserProfile> register({
    required String fullName,
    required String universityId,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return UserProfile(
      id: 'u-2',
      universityId: universityId,
      fullName: fullName,
      email: email,
      role: 'STUDENT',
      active: true,
    );
  }

  @override
  Future<UserProfile> getProfile(String token) async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockProfile ??
        const UserProfile(
          id: 'u-1',
          universityId: 'IT23773158',
          fullName: 'Ravindu Weerasinghe',
          email: 'student@biblione.edu',
          role: 'STUDENT',
          department: 'CS Dept',
          active: true,
        );
  }

  @override
  Future<UserProfile> updateProfile({
    required String token,
    required String fullName,
    required String email,
    String? department,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return UserProfile(
      id: 'u-1',
      universityId: 'IT23773158',
      fullName: fullName,
      email: email,
      department: department,
      role: 'STUDENT',
      active: true,
    );
  }

  @override
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> logout(String token) async {}
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });
  group('User Profile & Auth Session Models', () {
    test('UserProfile serialize and deserialize correctly', () {
      const user = UserProfile(
        id: 'u-1',
        universityId: 'IT20240001',
        fullName: 'John Doe',
        email: 'john@biblione.edu',
        role: 'STUDENT',
        department: 'CS',
        active: true,
      );

      final json = user.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson.id, 'u-1');
      expect(fromJson.universityId, 'IT20240001');
      expect(fromJson.fullName, 'John Doe');
      expect(fromJson.email, 'john@biblione.edu');
      expect(fromJson.role, 'STUDENT');
      expect(fromJson.active, isTrue);
    });

    test('AuthSession serialize and deserialize correctly', () {
      final session = AuthSession(
        token: 'token-abc',
        tokenType: 'Bearer',
        user: const UserProfile(
          id: 'u-1',
          fullName: 'John Doe',
          email: 'john@biblione.edu',
          role: 'STUDENT',
        ),
      );

      final json = session.toJson();
      final fromJson = AuthSession.fromJson(json);

      expect(fromJson.token, 'token-abc');
      expect(fromJson.tokenType, 'Bearer');
      expect(fromJson.user.fullName, 'John Doe');
    });
  });

  group('AuthStorage & AuthController', () {
    test('AuthStorage persists and clears session in memory fallback', () async {
      final storage = AuthStorage();
      const user = UserProfile(
        id: 'u-1',
        fullName: 'Jane Doe',
        email: 'jane@biblione.edu',
        role: 'STUDENT',
      );

      await storage.saveSession(token: 'test-token', user: user);
      expect(await storage.getToken(), 'test-token');
      expect((await storage.getUser())?.email, 'jane@biblione.edu');

      await storage.clearSession();
      expect(await storage.getToken(), isNull);
      expect(await storage.getUser(), isNull);
    });

    test('AuthController logs in, updates profile, and logs out', () async {
      final mockApi = MockAuthApiClient();
      final storage = AuthStorage();
      final controller = AuthController(apiClient: mockApi, storage: storage);

      expect(controller.isAuthenticated, isFalse);

      final loggedIn = await controller.login(
        identifier: 'IT23773158',
        password: 'password123',
      );
      expect(loggedIn, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.universityId, 'IT23773158');

      final updated = await controller.updateProfile(
        fullName: 'Ravindu Updated',
        email: 'student.new@biblione.edu',
        department: 'SE Dept',
      );
      expect(updated, isTrue);
      expect(controller.currentUser?.fullName, 'Ravindu Updated');
      expect(controller.currentUser?.email, 'student.new@biblione.edu');

      await controller.logout();
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });
  });

  group('User Management UI Widgets', () {
    testWidgets('LoginScreen renders inputs and validates required fields', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockApi = MockAuthApiClient();
      final controller = AuthController(apiClient: mockApi, storage: AuthStorage());

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authController: controller),
        ),
      );

      expect(find.text('Log In'), findsWidgets);
      expect(find.text('University ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);

      final loginBtn = find.widgetWithText(FilledButton, 'Log In');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump();

      expect(find.text('Please enter your University ID or Email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('RegistrationScreen validates form fields and matching passwords', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockApi = MockAuthApiClient();
      final controller = AuthController(apiClient: mockApi, storage: AuthStorage());

      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationScreen(authController: controller),
        ),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);

      final createBtn = find.widgetWithText(FilledButton, 'Create Account');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('University ID is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders user details and handles logout dialog', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockApi = MockAuthApiClient();
      final storage = AuthStorage();
      final controller = AuthController(apiClient: mockApi, storage: storage);

      await controller.login(identifier: 'IT23773158', password: 'password123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProfileScreen(authController: controller)),
        ),
      );
      await tester.pump();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Ravindu Weerasinghe'), findsOneWidget);
      expect(find.text('IT23773158'), findsOneWidget);
      expect(find.text('student@biblione.edu'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Confirm Logout'), findsOneWidget);
    });

    testWidgets('AuthGate routes to BiblioneShell when authenticated', (
      WidgetTester tester,
    ) async {
      final mockApi = MockAuthApiClient();
      final storage = AuthStorage();
      await storage.saveSession(
        token: 'test-token',
        user: const UserProfile(
          id: 'u-1',
          universityId: 'IT23773158',
          fullName: 'Ravindu Weerasinghe',
          email: 'student@biblione.edu',
          role: 'STUDENT',
        ),
      );

      final controller = AuthController(apiClient: mockApi, storage: storage);
      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: AuthGate(authController: controller),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BiblioneShell), findsOneWidget);
    });
  });
}
