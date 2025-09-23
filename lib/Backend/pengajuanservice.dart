// lib/Backend/pengajuanservice.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'authservice.dart';

class PengajuanService {
  final SupabaseClient _client = Supabase.instance.client;
  final AuthService _authService;

  static const String bucketName = 'photos';

  PengajuanService(this._authService);

  /// 🔹 Upload file ke Supabase Storage
  Future<String?> _uploadFile({
    required int customerId,
    required int pengajuanId,
    required String fileName,
    required File file,
  }) async {
    try {
      final ext = path.extension(file.path).replaceFirst('.', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newName = '${fileName}_$timestamp.$ext';
      final filePath = 'pengajuan/$customerId/$pengajuanId/$newName';

      await _client.storage.from(bucketName).upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      return _client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print('❌ Error uploadFile: $e');
      return null;
    }
  }

  /// 🔹 Hapus semua file dalam folder pengajuan tertentu
  Future<void> _cleanupFiles(int customerId, int pengajuanId) async {
    try {
      final folderPath = 'pengajuan/$customerId/$pengajuanId/';
      final files =
          await _client.storage.from(bucketName).list(path: folderPath);
      if (files.isNotEmpty) {
        final paths = files.map((f) => '$folderPath${f.name}').toList();
        await _client.storage.from(bucketName).remove(paths);
      }
    } catch (e) {
      print('❌ Error cleanup: $e');
    }
  }

  /// ==================================================
  /// 🔹 CREATE Pengajuan Baru
  Future<Map<String, dynamic>?> createPengajuan({
    required String namaLengkap,
    required String nomorTelepon,
    required File ktp,
    required File kk,
    required File rekeningTetangga,
    required File imb,
    required File denahRumah,
    required File fotoRumah,
  }) async {
    final customerId = _authService.userId;
    if (customerId == null) {
      print('❌ Error: User tidak login atau userId null');
      return null;
    }

    Map<String, dynamic>? newRow;
    try {
      // 1️⃣ Insert kosong dulu untuk ambil ID
      newRow = await _client
          .from('pengajuan')
          .insert({
            'customer_id': customerId,
            'nama_lengkap': namaLengkap,
            'nomor_telepon': nomorTelepon,
            'url_ktp': '',
            'url_kk': '',
            'url_rekening_tetangga': '',
            'url_imb': '',
            'url_denah_rumah': '',
            'url_foto_rumah': '',
          })
          .select()
          .single();

      final pengajuanId = newRow['id'] as int;

      // 2️⃣ Upload semua file
      final urlKtp = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "ktp",
          file: ktp);
      final urlKk = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "kk",
          file: kk);
      final urlRekening = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "rekening_tetangga",
          file: rekeningTetangga);
      final urlImb = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "imb",
          file: imb);
      final urlDenah = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "denah_rumah",
          file: denahRumah);
      final urlFoto = await _uploadFile(
          customerId: customerId,
          pengajuanId: pengajuanId,
          fileName: "foto_rumah",
          file: fotoRumah);

      if ([urlKtp, urlKk, urlRekening, urlImb, urlDenah, urlFoto]
          .any((url) => url == null)) {
        throw Exception("Upload salah satu file gagal");
      }

      // 3️⃣ Update row dengan URL final
      final updated = await _client
          .from('pengajuan')
          .update({
            'url_ktp': urlKtp,
            'url_kk': urlKk,
            'url_rekening_tetangga': urlRekening,
            'url_imb': urlImb,
            'url_denah_rumah': urlDenah,
            'url_foto_rumah': urlFoto,
            'status': 'pending',
          })
          .eq('id', pengajuanId)
          .select()
          .single();

      return updated;
    } catch (e) {
      print('❌ Error createPengajuan: $e');
      if (newRow != null) {
        final pengajuanId = newRow['id'] as int;
        await _cleanupFiles(customerId, pengajuanId);
        await _client.from('pengajuan').delete().eq('id', pengajuanId);
      }
      return null;
    }
  }

  /// ==================================================
  /// 🔹 GET Pengajuan milik user login
  Future<List<Map<String, dynamic>>> getMyPengajuan() async {
    final customerId = _authService.userId;
    if (customerId == null) return [];
    try {
      final data = await _client
          .from('pengajuan')
          .select('*')
          .eq('customer_id', customerId)
          .order('id', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ Error getMyPengajuan: $e');
      return [];
    }
  }

  /// 🔹 GET detail pengajuan by id
  Future<Map<String, dynamic>?> getPengajuanById(int id) async {
    try {
      return await _client.from('pengajuan').select('*').eq('id', id).single();
    } catch (e) {
      print('❌ Error getPengajuanById: $e');
      return null;
    }
  }

  /// 🔹 Update status pengajuan
  Future<bool> updateStatus(int id, String status) async {
    try {
      await _client.from('pengajuan').update({'status': status}).eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error updateStatus: $e');
      return false;
    }
  }

  /// 🔹 Delete pengajuan + file
  Future<bool> deletePengajuan(int id) async {
    try {
      final row = await getPengajuanById(id);
      if (row == null) return false;
      final customerId = row['customer_id'] as int;
      await _cleanupFiles(customerId, id);
      await _client.from('pengajuan').delete().eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error deletePengajuan: $e');
      return false;
    }
  }

  /// 🔹 Cek apakah user punya pengajuan
  Future<bool> hasExistingPengajuan() async {
    final customerId = _authService.userId;
    if (customerId == null) return false;
    try {
      final data = await _client
          .from('pengajuan')
          .select('id')
          .eq('customer_id', customerId)
          .limit(1);
      return data.isNotEmpty;
    } catch (e) {
      print('❌ Error hasExistingPengajuan: $e');
      return false;
    }
  }
}
