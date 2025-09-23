import 'package:supabase_flutter/supabase_flutter.dart';

class PembayaranService {
  final supabase = Supabase.instance.client;

  /// Tarif dasar air per m³
  final int tarifPerM3 = 3500;

  /// Ambil data pelanggan berdasarkan nomor sambungan
  Future<Map<String, dynamic>?> cekPelanggan(int connectionNumber) async {
    try {
      final response = await supabase
          .from('customers')
          .select()
          .eq('connection_number', connectionNumber)
          .maybeSingle();

      if (response == null) {
        return null; // pelanggan tidak ditemukan
      }

      return response;
    } catch (e) {
      throw Exception("Gagal mengambil data pelanggan: $e");
    }
  }

  /// Ambil daftar tagihan rekening air berdasarkan customer_id
  Future<List<Map<String, dynamic>>> getTagihan(int customerId) async {
    try {
      final response = await supabase
          .from('rekening_tagihan')
          .select()
          .eq('customer_id', customerId)
          .order('periode', ascending: false);

      if (response == null || response.isEmpty) {
        return []; // tidak ada tagihan
      }

      return response;
    } catch (e) {
      throw Exception("Gagal mengambil data tagihan: $e");
    }
  }

  /// Hitung total tagihan dari seluruh periode (berdasarkan pakai * tarif)
  Future<int> getTotalTagihan(int customerId) async {
    final tagihanList = await getTagihan(customerId);

    if (tagihanList.isEmpty) return 0;

    int total = 0;
    for (var t in tagihanList) {
      final pakai = (t['pakai'] ?? 0) as int;
      total += pakai * tarifPerM3;
    }

    return total;
  }

  /// Ambil detail lengkap: pelanggan + daftar tagihan + total bayar
  Future<Map<String, dynamic>> cekTagihanLengkap(int connectionNumber) async {
    // 1. Cari pelanggan
    final pelanggan = await cekPelanggan(connectionNumber);

    if (pelanggan == null) {
      return {"status": false, "message": "Nomor sambungan tidak ditemukan"};
    }

    // 2. Cari daftar tagihan
    final tagihanList = await getTagihan(pelanggan['id']);
    final totalBayar = await getTotalTagihan(pelanggan['id']);

    return {
      "status": true,
      "pelanggan": pelanggan,
      "tagihan": tagihanList,
      "total_bayar": totalBayar,
    };
  }
}
