import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeterService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static Map<String, dynamic>? _customerData;
  static Map<String, dynamic>? get customerData => _customerData;

  // Cari customer berdasarkan nomor sambungan
  Future<Map<String, dynamic>?> findCustomerByConnectionNumber(
    int connectionNumber,
  ) async {
    if (connectionNumber <= 0) return null;
    try {
      final response = await _supabase
          .from('customers')
          .select('id, connection_number, nama, alamat')
          .eq('connection_number', connectionNumber)
          .maybeSingle();

      if (response != null) _customerData = response;
      return response;
    } catch (e) {
      print('Error finding customer: $e');
      return null;
    }
  }

  // Submit meter reading
  Future<bool> submitMeterReading({
    required int customerId,
    required int connectionNumber,
    required double standMeter,
    required String photoPath,
  }) async {
    if (standMeter <= 0 || photoPath.isEmpty) return false;
    try {
      final response = await _supabase.from('meter_readings').insert({
        'customer_id': customerId,
        'connection_number': connectionNumber,
        'stand_meter': standMeter,
        'foto_url': photoPath,
        'reading_date': DateTime.now().toIso8601String(),
        'status': 'diterima',
      }).select();

      return response.isNotEmpty;
    } catch (e) {
      print('Error submitting meter reading: $e');
      return false;
    }
  }

  // Upload foto meter
  Future<String?> uploadMeterPhoto(String filePath, String extension) async {
    final uniqueName = generateUniqueFileName(extension);
    try {
      final file = File(filePath);
      await _supabase.storage
          .from('photos')
          .upload(
            'meteran/$uniqueName',
            file,
            fileOptions: const FileOptions(upsert: false),
          );
      return _supabase.storage
          .from('photos')
          .getPublicUrl('meteran/$uniqueName');
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  void clearCustomerData() => _customerData = null;

  String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = DateTime.now().microsecond.toString();
    return '${timestamp}_$randomString.$extension';
  }
}
