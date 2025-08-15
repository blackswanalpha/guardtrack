import 'package:flutter_test/flutter_test.dart';
import 'package:guardtrack/shared/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        id: '1',
        email: 'test@example.com',
        phone: '+254700000001',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        assignedSiteIds: ['site1', 'site2'],
      );
    });

    group('getters', () {
      test('fullName should return concatenated first and last name', () {
        expect(testUser.fullName, equals('John Doe'));
      });

      test('displayName should return fullName when available', () {
        expect(testUser.displayName, equals('John Doe'));
      });

      test('displayName should return email when fullName is empty', () {
        final userWithoutName = testUser.copyWith(
          firstName: '',
          lastName: '',
        );
        expect(userWithoutName.displayName, equals('test@example.com'));
      });

      test('isGuard should return true for guard role', () {
        expect(testUser.isGuard, isTrue);
      });

      test('isAdmin should return false for guard role', () {
        expect(testUser.isAdmin, isFalse);
      });

      test('isAdmin should return true for admin role', () {
        final adminUser = testUser.copyWith(role: UserRole.admin);
        expect(adminUser.isAdmin, isTrue);
      });

      test('isSuperAdmin should return true for superAdmin role', () {
        final superAdminUser = testUser.copyWith(role: UserRole.superAdmin);
        expect(superAdminUser.isSuperAdmin, isTrue);
        expect(superAdminUser.isAdmin, isTrue); // Super admin is also admin
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // Act
        final json = testUser.toJson();

        // Assert
        expect(json['id'], equals('1'));
        expect(json['email'], equals('test@example.com'));
        expect(json['phone'], equals('+254700000001'));
        expect(json['firstName'], equals('John'));
        expect(json['lastName'], equals('Doe'));
        expect(json['role'], equals('guard'));
        expect(json['isActive'], equals(true));
        expect(json['assignedSiteIds'], equals(['site1', 'site2']));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': '1',
          'email': 'test@example.com',
          'phone': '+254700000001',
          'firstName': 'John',
          'lastName': 'Doe',
          'role': 'guard',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'assignedSiteIds': ['site1', 'site2'],
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.id, equals('1'));
        expect(user.email, equals('test@example.com'));
        expect(user.phone, equals('+254700000001'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.role, equals(UserRole.guard));
        expect(user.isActive, equals(true));
        expect(user.assignedSiteIds, equals(['site1', 'site2']));
      });
    });

    group('copyWith', () {
      test('should create new instance with updated values', () {
        // Act
        final updatedUser = testUser.copyWith(
          firstName: 'Jane',
          role: UserRole.admin,
          isActive: false,
        );

        // Assert
        expect(updatedUser.firstName, equals('Jane'));
        expect(updatedUser.role, equals(UserRole.admin));
        expect(updatedUser.isActive, equals(false));
        
        // Original values should remain unchanged
        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.lastName, equals(testUser.lastName));
      });

      test('should keep original values when no updates provided', () {
        // Act
        final copiedUser = testUser.copyWith();

        // Assert
        expect(copiedUser.id, equals(testUser.id));
        expect(copiedUser.email, equals(testUser.email));
        expect(copiedUser.firstName, equals(testUser.firstName));
        expect(copiedUser.lastName, equals(testUser.lastName));
        expect(copiedUser.role, equals(testUser.role));
        expect(copiedUser.isActive, equals(testUser.isActive));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final user1 = UserModel(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.guard,
          isActive: true,
          createdAt: DateTime(2024, 1, 1),
        );

        final user2 = UserModel(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.guard,
          isActive: true,
          createdAt: DateTime(2024, 1, 1),
        );

        // Assert
        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final user1 = testUser;
        final user2 = testUser.copyWith(firstName: 'Jane');

        // Assert
        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });
    });
  });
}
