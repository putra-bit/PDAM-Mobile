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

      // Hitung total untuk setiap tagihan berdasarkan pakai * tarif
      List<Map<String, dynamic>> tagihanWithTotal = [];
      for (var tagihan in response) {
        Map<String, dynamic> item = Map<String, dynamic>.from(tagihan);
        final pakai = (item['pakai'] ?? 0) as int;
        item['total'] = pakai * tarifPerM3;
        tagihanWithTotal.add(item);
      }

      return tagihanWithTotal;
    } catch (e) {
      throw Exception("Gagal mengambil data tagihan: $e");
    }
  }

  /// Hitung total tagihan dari seluruh periode yang belum lunas
  Future<int> getTotalTagihan(int customerId) async {
    final tagihanList = await getTagihan(customerId);

    if (tagihanList.isEmpty) return 0;

    int total = 0;
    for (var t in tagihanList) {
      // Hanya hitung tagihan yang belum lunas
      final statusPembayaran = (t['status_pembayaran'] ?? '')
          .toString()
          .toLowerCase();
      if (statusPembayaran != 'lunas') {
        final pakai = (t['pakai'] ?? 0) as int;
        total += pakai * tarifPerM3;
      }
    }

    return total;
  }

  /// Ambil detail lengkap: pelanggan + daftar tagihan + total bayar
  Future<Map<String, dynamic>> cekTagihanLengkap(int connectionNumber) async {
    try {
      // 1. Cari pelanggan
      final pelanggan = await cekPelanggan(connectionNumber);

      if (pelanggan == null) {
        return {"status": false, "message": "Nomor sambungan tidak ditemukan"};
      }

      // 2. Cari daftar tagihan
      final tagihanList = await getTagihan(pelanggan['id']);
      final totalBayar = await getTotalTagihan(pelanggan['id']);

      if (tagihanList.isEmpty) {
        return {
          "status": false,
          "message": "Tidak ada data tagihan untuk nomor sambungan ini",
        };
      }

      return {
        "status": true,
        "pelanggan": pelanggan,
        "tagihan": tagihanList,
        "total_bayar": totalBayar,
      };
    } catch (e) {
      return {"status": false, "message": "Terjadi kesalahan: ${e.toString()}"};
    }
  }

  /// Proses pembayaran tagihan - update status menjadi lunas
  Future<Map<String, dynamic>> bayarTagihan(
    int customerId,
    String paymentMethod,
    double totalAmount,
  ) async {
    try {
      // 1. Ambil semua tagihan yang belum lunas
      final tagihanBelumLunas = await supabase
          .from('rekening_tagihan')
          .select('id, periode, pakai')
          .eq('customer_id', customerId)
          .eq('status_pembayaran', 'belum lunas');

      if (tagihanBelumLunas.isEmpty) {
        return {
          "status": false,
          "message": "Tidak ada tagihan yang perlu dibayar",
        };
      }

      // 2. Update semua tagihan menjadi lunas
      final List<int> tagihanIds = tagihanBelumLunas
          .map<int>((t) => t['id'] as int)
          .toList();

      // Update status pembayaran menjadi lunas
      await supabase
          .from('rekening_tagihan')
          .update({'status_pembayaran': 'lunas'})
          .filter('id', 'in', tagihanIds);

      // 3. Buat record pembayaran (jika ingin menyimpan log pembayaran)
      // Ini opsional, bisa dibuat tabel terpisah untuk log pembayaran
      try {
        // Cek apakah tabel payment_logs ada
        await supabase.from('payment_logs').insert({
          'customer_id': customerId,
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
          'payment_date': DateTime.now().toIso8601String(),
          'tagihan_count': tagihanIds.length,
          'tagihan_periods': tagihanBelumLunas
              .map((t) => t['periode'].toString())
              .join(', '),
        });
      } catch (e) {
        // Jika tabel payment_logs tidak ada, skip saja
        print("Payment log tidak tersimpan (tabel mungkin tidak ada): $e");
      }

      return {
        "status": true,
        "message": "Pembayaran berhasil diproses",
        "total_paid": totalAmount,
        "tagihan_count": tagihanIds.length,
        "periods_paid": tagihanBelumLunas
            .map((t) => t['periode'].toString())
            .toList(),
      };
    } catch (e) {
      return {
        "status": false,
        "message": "Gagal memproses pembayaran: ${e.toString()}",
      };
    }
  }

  /// Update status pembayaran tagihan tertentu
  Future<Map<String, dynamic>> updateStatusTagihan(
    int tagihanId,
    String status,
  ) async {
    try {
      await supabase
          .from('rekening_tagihan')
          .update({'status_pembayaran': status})
          .eq('id', tagihanId);

      return {"status": true, "message": "Status tagihan berhasil diupdate"};
    } catch (e) {
      return {
        "status": false,
        "message": "Gagal update status tagihan: ${e.toString()}",
      };
    }
  }

  /// Get statistik pembayaran untuk customer
  Future<Map<String, dynamic>> getStatistikPembayaran(int customerId) async {
    try {
      final response = await supabase
          .from('rekening_tagihan')
          .select('status_pembayaran, pakai')
          .eq('customer_id', customerId);

      int totalTagihan = response.length;
      int tagihanLunas = 0;
      int tagihanBelumLunas = 0;
      int totalPemakaianLunas = 0;
      int totalPemakaianBelumLunas = 0;

      for (var tagihan in response) {
        final status = tagihan['status_pembayaran'].toString().toLowerCase();
        final pakai = (tagihan['pakai'] ?? 0) as int;

        if (status == 'lunas') {
          tagihanLunas++;
          totalPemakaianLunas += pakai;
        } else {
          tagihanBelumLunas++;
          totalPemakaianBelumLunas += pakai;
        }
      }

      return {
        "total_tagihan": totalTagihan,
        "tagihan_lunas": tagihanLunas,
        "tagihan_belum_lunas": tagihanBelumLunas,
        "total_pemakaian_lunas": totalPemakaianLunas,
        "total_pemakaian_belum_lunas": totalPemakaianBelumLunas,
        "total_nilai_lunas": totalPemakaianLunas * tarifPerM3,
        "total_nilai_belum_lunas": totalPemakaianBelumLunas * tarifPerM3,
      };
    } catch (e) {
      return {"error": "Gagal mengambil statistik: ${e.toString()}"};
    }
  }

  /// Format currency untuk tampilan
  String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Format periode untuk tampilan
  String formatPeriode(String periode) {
    try {
      final date = DateTime.parse(periode);
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${months[date.month]} ${date.year}';
    } catch (e) {
      return periode;
    }
  }
}
