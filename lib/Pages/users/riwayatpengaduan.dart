import 'package:flutter/material.dart';
import 'package:pdam_mobile/Backend/pengaduan_service.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';

class RiwayatPengaduanPage extends StatefulWidget {
  const RiwayatPengaduanPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPengaduanPage> createState() => _RiwayatPengaduanPageState();
}

class _RiwayatPengaduanPageState extends State<RiwayatPengaduanPage>
    with TickerProviderStateMixin {
  final PengaduanService _pengaduanService = PengaduanService();
  final int _limit = 20;

  List<Map<String, dynamic>> _riwayatPengaduan = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadRiwayatPengaduan();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayatPengaduan({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _riwayatPengaduan.clear();
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await _pengaduanService.getRiwayatPengaduan(
        context,
        limit: _limit,
        offset: _currentPage * _limit,
      );

      setState(() {
        if (refresh) {
          _riwayatPengaduan = data;
        } else {
          _riwayatPengaduan.addAll(data);
        }
        _isLoading = false;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat riwayat pengaduan: $e';
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'diterima':
      case 'proses':
        return const Color(0xff4CAF50);
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return 'Pengaduan diterima';
      case 'proses':
        return 'Pengaduan diproses';
      case 'selesai':
        return 'Pengaduan selesai';
      default:
        return 'Pengaduan diproses';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return "${date.day.toString().padLeft(2, '0')} "
          "${months[date.month]} "
          "${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: RefreshIndicator(
                          onRefresh: () => _loadRiwayatPengaduan(refresh: true),
                          child: _buildBody(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        _buildHeaderBackground(),
        _buildHeaderOverlay(),
        _buildHeaderButtons(),
        const Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: Center(
            child: TextPoppins(
              text: "Riwayat Pengaduan",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const Positioned(
          top: 125,
          left: 0,
          right: 0,
          child: Center(
            child: TextPoppins(
              text:
                  "Lihat riwayat keluhan Anda dan status\npenanganannnya di bawah ini.",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBackground() => Container(
    width: double.infinity,
    height: 200,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/kantorpdam.jpeg'),
        fit: BoxFit.cover,
      ),
    ),
  );

  Widget _buildHeaderOverlay() => Container(
    width: double.infinity,
    height: 200,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
      ),
    ),
  );

  Widget _buildHeaderButtons() => Positioned.fill(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(Icons.arrow_back, () => Navigator.pop(context)),
          _circleButton(
            Icons.refresh,
            () => _loadRiwayatPengaduan(refresh: true),
          ),
        ],
      ),
    ),
  );

  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.black),
    ),
  );

  Widget _buildBody() {
    if (_isLoading && _riwayatPengaduan.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xff4CAF50)),
      );
    }
    if (_errorMessage.isNotEmpty && _riwayatPengaduan.isEmpty) {
      return _errorView();
    }
    if (_riwayatPengaduan.isEmpty) {
      return _emptyView();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _riwayatPengaduan.length + 1,
      itemBuilder: (context, index) {
        if (index == _riwayatPengaduan.length) {
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xff4CAF50)),
                  ),
                )
              : const SizedBox.shrink();
        }
        return _buildPengaduanCard(_riwayatPengaduan[index]);
      },
    );
  }

  Widget _errorView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        TextPoppins(
          text: _errorMessage,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade600,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _loadRiwayatPengaduan(refresh: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const TextPoppins(
            text: 'Coba Lagi',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        TextPoppins(
          text: 'Belum ada pengaduan',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ],
    ),
  );

  Widget _buildPengaduanCard(Map<String, dynamic> pengaduan) {
    final status = pengaduan['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(pengaduan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(pengaduan),
              const SizedBox(height: 8),
              _statusBadge(status),
              const SizedBox(height: 12),
              const TextPoppins(
                text: 'Detail:',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              const SizedBox(height: 4),
              Text(
                pengaduan['isi_pengaduan'] ?? 'Tidak ada detail',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const TextPoppins(
                text: 'Foto:',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              const SizedBox(height: 4),
              _fotoSection(pengaduan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardHeader(Map<String, dynamic> pengaduan) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextPoppins(
          text: pengaduan['judul'] ?? 'Tanpa Judul',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        _formatDate(pengaduan['tanggal'] ?? ''),
        style: TextStyle(color: Colors.grey[600], fontSize: 11),
      ),
    ],
  );

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _statusColor(status),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      _statusLabel(status),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _fotoSection(Map<String, dynamic> pengaduan) {
    final fotoUrl = pengaduan['foto_url'];
    if (fotoUrl == null || fotoUrl.toString().isEmpty) {
      return const Text(
        "Tidak Ada Foto",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    final fileName = fotoUrl.toString().split('/').last;
    return GestureDetector(
      onTap: () => _showDetailDialog(pengaduan),
      child: Text(
        fileName,
        style: TextStyle(
          color: Colors.blue[600],
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> pengaduan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: TextPoppins(
            text: pengaduan['judul'] ?? 'Detail Pengaduan',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Status', pengaduan['status'] ?? ''),
                _detailRow('Jenis User', pengaduan['status_user'] ?? ''),
                _detailRow('No. Telepon', pengaduan['no_telepon'] ?? ''),
                _detailRow('Tanggal', _formatDate(pengaduan['tanggal'] ?? '')),
                _detailRow(
                  'User ID',
                  pengaduan['user_customer_id']?.toString() ?? '',
                ),
                const SizedBox(height: 12),
                const TextPoppins(
                  text: 'Isi Pengaduan:',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  pengaduan['isi_pengaduan'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                if (pengaduan['foto_url'] != null &&
                    pengaduan['foto_url'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const TextPoppins(
                    text: 'Foto:',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pengaduan['foto_url'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Gagal memuat foto')),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff4CAF50),
              ),
              child: const TextPoppins(
                text: 'Tutup',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff4CAF50),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: TextPoppins(
            text: '$label:',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
