import '../models/user_profile.dart';
import '../services/firebase_service.dart';

class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository(this._firebaseService);

  Future<UserProfile?> authenticateUser(String email, String password) async {
    try {
      print('Attempting to authenticate user: $email');

      // Lấy snapshot từ node users
      final snapshot = await _firebaseService.usersRef.get();

      print('Firebase snapshot exists: ${snapshot.exists}');
      print('Firebase snapshot value type: ${snapshot.value.runtimeType}');

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> users =
            snapshot.value as Map<dynamic, dynamic>;

        String? userId;
        Map<String, dynamic>? userData;

        // Duyệt qua tất cả users
        users.forEach((key, value) {
          if (value is Map) {
            final userEmail = value['email']?.toString();
            final userPassword = value['password']?.toString();

            print(
                'Checking user - Email: $userEmail, Password in DB: $userPassword, Input password: $password');

            if (userEmail == email && userPassword == password) {
              userId = key.toString();
              userData = Map<String, dynamic>.from(value);
              print('Found matching user with ID: $userId');
            }
          }
        });

        if (userId != null && userData != null) {
          userData!.remove('password');
          final user = UserProfile.fromMap({
            'id': userId,
            ...userData!,
          });
          print('Successfully created UserProfile: ${user.email}');
          return user;
        }
      }

      print('No matching user found');
      return null;
    } catch (e) {
      print('Error in authenticateUser: $e');
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firebaseService.getDataByValue(
        _firebaseService.usersRef,
        'email',
        email,
      );

      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value as Map;
        String? userId;
        Map<String, dynamic>? userData;

        value.forEach((key, val) {
          if (val is Map && val['email'] == email) {
            userId = key.toString();
            userData = Map<String, dynamic>.from(val);
          }
        });

        if (userId != null && userData != null) {
          userData!.remove('password'); // Không trả về mật khẩu
          return UserProfile.fromMap({
            'id': userId,
            ...userData!,
          });
        }
      }
    } catch (e) {
      print('Error in getUserByEmail: $e');
    }
    return null;
  }

  Future<UserProfile> createUser({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      // 1. Kiểm tra email đã tồn tại
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email đã được sử dụng');
      }

      // 2. Tạo dữ liệu user cơ bản
      final Map<String, dynamic> userData = {
        'email': email,
        'password': password,
        'name': name ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'age': null,
        'gender': null,
        'height': null,
        'weight': null,
        'goal': null,
        'activityLevel': null,
        'targetCalories': null,
        'targetProtein': null,
        'targetCarbs': null,
        'targetFat': null,
        'targetWater': null,
      };

      // 3. Kiểm tra và tạo node users nếu chưa tồn tại
      final usersSnapshot = await _firebaseService.usersRef.get();
      if (!usersSnapshot.exists) {
        await _firebaseService.usersRef.set({});
      }

      // 4. Lưu dữ liệu user vào node users
      final userId = await _firebaseService.pushData(
        _firebaseService.usersRef,
        userData,
      );

      // 5. Trả về đối tượng UserProfile (không bao gồm mật khẩu)
      userData.remove('password');
      return UserProfile.fromMap({
        'id': userId,
        ...userData,
      });
    } catch (e) {
      print('Error in createUser: $e');
      throw Exception('Không thể tạo người dùng: $e');
    }
  }

  Future<void> updateUser(UserProfile userProfile) async {
    if (userProfile.id == null) {
      throw Exception('Cannot update user without ID');
    }

    final userData = userProfile.toMap();
    userData.remove('id');

    await _firebaseService.updateData(
      _firebaseService.usersRef.child(userProfile.id!),
      userData,
    );
  }
}
