//pengadualservice
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authservice.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PengaduanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Submit pengaduan baru
  Future<bool> submitPengaduan(
    BuildContext context, {
    required String statusUser,
    required String judul,
    required String isiPengaduan,
    required String noTelepon,
    String? fotoUrl, // tambah param foto
  }) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final currentUserId = auth.userId;

      print('=== SUBMIT PENGADUAN DEBUG ===');
      print('Current User ID: $currentUserId');
      print('Status User: $statusUser');
      print('Judul: $judul');
      print('Foto URL: $fotoUrl');

      if (currentUserId == null) {
        print("Error: User belum login.");
        return false;
      }

      // Validate required fields
      if (statusUser.isEmpty ||
          judul.isEmpty ||
          isiPengaduan.isEmpty ||
          noTelepon.isEmpty) {
        print("Error: Ada field yang kosong.");
        return false;
      }

      // Validate status user
      if (!isValidStatusUser(statusUser)) {
        print("Error: Status user tidak valid.");
        return false;
      }

      final insertData = {
        'user_customer_id': currentUserId,
        'status_user': statusUser,
        'judul': judul,
        'isi_pengaduan': isiPengaduan,
        'status': 'pending',
        'no_telepon': noTelepon,
        if (fotoUrl != null) 'foto_url': fotoUrl, // ⬅️ simpan foto_url
      };

      print('Data to insert: $insertData');

      await _supabase.from('pengaduan').insert(insertData);

      print('Pengaduan berhasil disubmit!');
      print('=== END SUBMIT DEBUG ===');

      return true;
    } catch (e) {
      print('Error submitting pengaduan: $e');
      return false;
    }
  }

  // Upload foto pengaduan
  Future<String?> uploadPengaduanPhoto(
    String filePath,
    String extension,
  ) async {
    try {
      final uniqueName = generateUniqueFileName(extension);
      final file = File(filePath);

      if (!file.existsSync()) {
        print('Error: File tidak ditemukan: $filePath');
        return null;
      }
      final compressedFile = await compressImage(file);
      final uploadFile = compressedFile ?? file;
      await _supabase.storage
          .from('photos')
          .upload(
            'complaints/$uniqueName',
            uploadFile,
            fileOptions: const FileOptions(upsert: false),
          );

      final publicUrl = _supabase.storage
          .from('photos')
          .getPublicUrl('complaints/$uniqueName');

      return publicUrl;
    } catch (e) {
      print('Error uploading pengaduan photo: $e');
      return null;
    }
  }

  // Ambil riwayat pengaduan berdasarkan user ID dari AuthService
  Future<List<Map<String, dynamic>>> getRiwayatPengaduan(
    BuildContext context, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final currentUserId = auth.userId;

      print('=== GET RIWAYAT PENGADUAN DEBUG ===');
      print('Current User ID: $currentUserId');

      if (currentUserId == null) {
        print("Error: User belum login.");
        return [];
      }

      final response = await _supabase
          .from('pengaduan')
          .select('*')
          .eq('user_customer_id', currentUserId)
          .order('tanggal', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting riwayat pengaduan: $e');
      return [];
    }
  }

  // Overload method untuk backward compatibility
  Future<List<Map<String, dynamic>>> getRiwayatPengaduanById(
    int userCustomerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('pengaduan')
          .select('*')
          .eq('user_customer_id', userCustomerId)
          .order('tanggal', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting riwayat pengaduan: $e');
      return [];
    }
  }

  // Get detail pengaduan by unique combination (tanggal + judul)
  Future<Map<String, dynamic>?> getDetailPengaduan(
    String tanggal,
    String judul,
  ) async {
    try {
      final response = await _supabase
          .from('pengaduan')
          .select('*')
          .eq('tanggal', tanggal)
          .eq('judul', judul)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting detail pengaduan: $e');
      return null;
    }
  }

  // Update status pengaduan (untuk admin)
  Future<bool> updateStatusPengaduan(
    String tanggal,
    String judul,
    String newStatus,
  ) async {
    try {
      await _supabase
          .from('pengaduan')
          .update({'status': newStatus})
          .eq('tanggal', tanggal)
          .eq('judul', judul);
      return true;
    } catch (e) {
      print('Error updating status pengaduan: $e');
      return false;
    }
  }

  // Delete pengaduan
  Future<bool> deletePengaduan(String tanggal, String judul) async {
    try {
      await _supabase
          .from('pengaduan')
          .delete()
          .eq('tanggal', tanggal)
          .eq('judul', judul);
      return true;
    } catch (e) {
      print('Error deleting pengaduan: $e');
      return false;
    }
  }

  // Validasi status user
  bool isValidStatusUser(String statusUser) {
    const validStatusUsers = ['pelanggan', 'umum'];
    return validStatusUsers.contains(statusUser.toLowerCase());
  }

  // Generate unique file name
  String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = DateTime.now().microsecond.toString();
    return '${timestamp}_$randomString.$extension';
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^08\d{8,12}$').hasMatch(phoneNumber);
  }

  // Get pengaduan statistics
  Future<Map<String, int>> getPengaduanStatistics(BuildContext context) async {
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final currentUserId = auth.userId;

      if (currentUserId == null) {
        return {'total': 0, 'pending': 0, 'proses': 0, 'selesai': 0};
      }

      final response = await _supabase
          .from('pengaduan')
          .select('status')
          .eq('user_customer_id', currentUserId);

      final data = List<Map<String, dynamic>>.from(response);

      int total = data.length;
      int pending = data.where((item) => item['status'] == 'pending').length;
      int proses = data.where((item) => item['status'] == 'proses').length;
      int selesai = data.where((item) => item['status'] == 'selesai').length;

      return {
        'total': total,
        'pending': pending,
        'proses': proses,
        'selesai': selesai,
      };
    } catch (e) {
      print('Error getting pengaduan statistics: $e');
      return {'total': 0, 'pending': 0, 'proses': 0, 'selesai': 0};
    }
  }

  //kompress foto
  Future<File?> compressImage(File file) async {
    final targetPath =
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final xfile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // kualitas (0-100), makin kecil makin ringan
      minWidth: 800, // resolusi maksimal
      minHeight: 800,
      format: CompressFormat.jpeg,
    );

    return xfile != null ? File(xfile.path) : null;
  }
}
