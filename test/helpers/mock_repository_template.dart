// TEMPLATE — copy this file for each new repository you add.
//
// 1. Create: test/helpers/mock_<feature>_repository.dart
// 2. Replace MyRepository with your real repository class
// 3. Use in tests: when(() => mock.getData()).thenAnswer((_) async => result);

import 'package:mocktail/mocktail.dart';

// ─── Example (delete when copying) ───────────────────────────
//
// import 'package:new_app/data/repositories/user_repository.dart';
//
// class MockUserRepository extends Mock implements UserRepository {}
//
// Usage in test:
//
//   late MockUserRepository mockRepo;
//
//   setUp(() {
//     mockRepo = MockUserRepository();
//     Get.put<UserRepository>(mockRepo);
//   });
//
//   test('loads profile', () async {
//     when(() => mockRepo.getProfile())
//         .thenAnswer((_) async => UserModel.fromJson(Fixtures.userProfile));
//
//     final controller = Get.put(ProfileController());
//     await controller.fetchProfile();
//
//     expect(controller.user.value?.name, equals('John Doe'));
//     verify(() => mockRepo.getProfile()).called(1);
//   });

// ignore_for_file: unused_element
class _MockRepositoryTemplate with Mock {}
