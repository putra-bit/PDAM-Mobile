// lib/Backend/profileservice.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bcrypt/bcrypt.dart';
import 'authservice.dart';

class ProfileService with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  final AuthService _authService;

  ProfileService(this._authService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  

  /// ✅ UPDATE PROFILE DATA (nama dan email)
  Future<bool> updateProfile({
    required String newName,
    required String newEmail,
  }) async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Cek apakah email baru sudah digunakan user lain
      if (newEmail != _authService.email) {
        final existingUser = await supabase
            .from('user_customers')
            .select('id')
            .eq('email', newEmail)
            .neq('id', userId)
            .maybeSingle();

        if (existingUser != null) {
          throw Exception('Email sudah digunakan pengguna lain');
        }
      }

      // Update data di database
      await supabase
          .from('user_customers')
          .update({'name': newName, 'email': newEmail})
          .eq('id', userId);

      // Update data di AuthService
      _authService.username = newName;
      _authService.email = newEmail;
      await _authService.saveUserToPrefs();
      _authService.notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Gagal memperbarui profil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ CHANGE PASSWORD
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Ambil password lama dari database
      final userData = await supabase
          .from('user_customers')
          .select('password')
          .eq('id', userId)
          .single();

      // Verifikasi password lama
      if (!BCrypt.checkpw(oldPassword, userData['password'])) {
        throw Exception('Password lama salah');
      }

      // Hash password baru
      final hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      // Update password di database
      await supabase
          .from('user_customers')
          .update({'password': hashedNewPassword})
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      throw Exception('Gagal mengubah password: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ UPLOAD PROFILE PHOTO
  Future<String?> uploadProfilePhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      _setLoading(true);

      // Generate unique filename
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Path struktur: photos/profile/{user_id}/filename.jpg
      final filePath = 'profile/$userId/$fileName';

      // Upload file ke Supabase Storage bucket 'photos'
      await supabase.storage.from('photos').upload(filePath, imageFile);

      // Dapatkan public URL
      final publicUrl = supabase.storage.from('photos').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      throw Exception('Gagal mengunggah foto: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ UPDATE PROFILE PHOTO
  Future<bool> updateProfilePhoto(File imageFile) async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Hapus foto lama terlebih dahulu jika ada
      await _deleteOldProfilePhoto(userId.toString());

      // Upload foto baru
      final photoUrl = await uploadProfilePhoto(
        imageFile: imageFile,
        userId: userId.toString(),
      );

      if (photoUrl == null) {
        throw Exception('Gagal mengunggah foto');
      }

      // Update photo_profile di database dan AuthService
      await _authService.updatePhotoProfile(photoUrl);

      return true;
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      throw Exception('Gagal memperbarui foto profil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ DELETE PROFILE PHOTO
  Future<bool> deleteProfilePhoto() async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      // Hapus file foto dari storage terlebih dahulu
      await _deleteOldProfilePhoto(userId.toString());

      // Set photo_profile menjadi null di database
      await _authService.updatePhotoProfile(null);

      return true;
    } catch (e) {
      debugPrint('Error deleting profile photo: $e');
      throw Exception('Gagal menghapus foto profil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ DELETE OLD PROFILE PHOTO FROM STORAGE
  Future<void> _deleteOldProfilePhoto(String userId) async {
    try {
      // Get current user profile to check if there's an existing photo
      final currentPhotoUrl = _authService.photoProfile;

      if (currentPhotoUrl == null || currentPhotoUrl.isEmpty) {
        return; // No photo to delete
      }

      // Extract the file path from the URL
      // URL format: https://...supabase.co/storage/v1/object/public/photos/profile/{user_id}/filename.jpg
      final uri = Uri.parse(currentPhotoUrl);
      final pathSegments = uri.pathSegments;

      // Find the path after 'photos' bucket
      int photosIndex = pathSegments.indexOf('photos');
      if (photosIndex != -1 && photosIndex < pathSegments.length - 1) {
        final filePath = pathSegments.skip(photosIndex + 1).join('/');

        // Delete the file from storage
        await supabase.storage.from('photos').remove([filePath]);

        debugPrint('Old profile photo deleted: $filePath');
      } else {
        // Alternative method: delete all files in user's profile folder
        await _deleteAllUserProfilePhotos(userId);
      }
    } catch (e) {
      // Don't throw error if deletion fails, just log it
      debugPrint('Error deleting old profile photo: $e');
      // Try alternative method
      try {
        await _deleteAllUserProfilePhotos(userId);
      } catch (alternativeError) {
        debugPrint('Alternative deletion also failed: $alternativeError');
      }
    }
  }

  /// ✅ DELETE ALL PROFILE PHOTOS FOR A USER (Alternative method)
  Future<void> _deleteAllUserProfilePhotos(String userId) async {
    try {
      // List all files in user's profile folder
      final userProfilePath = 'profile/$userId';
      final files = await supabase.storage
          .from('photos')
          .list(path: userProfilePath);

      if (files.isNotEmpty) {
        // Create list of file paths to delete
        final filePaths = files
            .map((file) => '$userProfilePath/${file.name}')
            .toList();

        // Delete all files
        await supabase.storage.from('photos').remove(filePaths);

        debugPrint(
          'Deleted ${filePaths.length} profile photos for user $userId',
        );
      }
    } catch (e) {
      debugPrint('Error deleting all user profile photos: $e');
    }
  }

  /// ✅ PICK IMAGE FROM GALLERY
  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      throw Exception('Gagal memilih gambar: ${e.toString()}');
    }
  }

  /// ✅ PICK IMAGE FROM CAMERA
  Future<File?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      throw Exception('Gagal mengambil foto: ${e.toString()}');
    }
  }

  /// ✅ GET USER PROFILE DATA
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _authService.userId;
      if (userId == null) return null;

      final userData = await supabase
          .from('user_customers')
          .select('id, name, email, photo_profile')
          .eq('id', userId)
          .maybeSingle();

      return userData;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// ✅ VALIDATE EMAIL FORMAT
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// ✅ VALIDATE PASSWORD STRENGTH
  Map<String, dynamic> validatePassword(String password) {
    bool hasMinLength = password.length >= 8;
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    bool isStrong = hasMinLength && hasUpperCase && hasLowerCase && hasNumber;

    return {
      'isValid': isStrong,
      'hasMinLength': hasMinLength,
      'hasUpperCase': hasUpperCase,
      'hasLowerCase': hasLowerCase,
      'hasNumber': hasNumber,
      'hasSpecialChar': hasSpecialChar,
    };
  }

  /// ✅ SET LOADING STATE
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

    /// ✅ REGISTER CUSTOMER CONNECTION (Nomor Sambungan ke Akun User)
  Future<bool> registerCustomerConnection(int connectionNumber) async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) {
        throw Exception("User tidak ditemukan");
      }

      // 1. Cek apakah nomor sambungan ada di tabel customers
      final customer = await supabase
          .from('customers')
          .select('id, connection_number, nama, alamat')
          .eq('connection_number', connectionNumber)
          .maybeSingle();

      if (customer == null) {
        throw Exception("Nomor sambungan tidak ditemukan");
      }

      final customerId = customer['id'] as int;

      // 2. Cek apakah sudah pernah didaftarkan user ini
      final existing = await supabase
          .from('customer_rekening')
          .select('id')
          .eq('user_customer_id', userId)
          .eq('customer_id', customerId)
          .maybeSingle();

      if (existing != null) {
        throw Exception("Nomor sambungan sudah terdaftar di akun ini");
      }

      // 3. Insert ke customer_rekening
      await supabase.from('customer_rekening').insert({
        'user_customer_id': userId,
        'customer_id': customerId,
      });

      return true;
    } catch (e) {
      debugPrint("Error registering connection: $e");
      throw Exception("Gagal mendaftarkan nomor sambungan: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ GET ALL REGISTERED CONNECTIONS FOR USER
  Future<List<Map<String, dynamic>>> getUserConnections() async {
    try {
      final userId = _authService.userId;
      if (userId == null) return [];

      // Join customer_rekening dengan customers untuk dapat detail
      final data = await supabase
          .from('customer_rekening')
          .select('id, customers(id, connection_number, nama, alamat)')
          .eq('user_customer_id', userId);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Error getting user connections: $e");
      return [];
    }
  }

  /// ✅ REMOVE CONNECTION (Unlink nomor sambungan dari akun)
  Future<bool> removeUserConnection(int rekeningId) async {
    try {
      _setLoading(true);

      final userId = _authService.userId;
      if (userId == null) throw Exception("User tidak ditemukan");

      await supabase
          .from('customer_rekening')
          .delete()
          .eq('id', rekeningId)
          .eq('user_customer_id', userId);

      return true;
    } catch (e) {
      debugPrint("Error removing connection: $e");
      throw Exception("Gagal menghapus sambungan: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }


  AuthService get authService => _authService;
  int? get userId => _authService.userId;
  String? get userEmail => _authService.email;
  String? get username => _authService.username;
  String? get photoProfile => _authService.photoProfile;
}
