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
  late AnimationController _cardAnimationController;
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
    _cardAnimationController.dispose();
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
      _cardAnimationController.reset();
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

      if (refresh) {
        _cardAnimationController.forward();
      }
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
        return const Color(0xFFFF9800); // Orange
      case 'diterima':
      case 'proses':
        return const Color(0xFF4CAF50); // Green
      case 'selesai':
        return const Color(0xFF2196F3); // Blue
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'proses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Diproses';
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
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: () => _loadRiwayatPengaduan(refresh: true),
                  color: const Color(0xFF4CAF50),
                  backgroundColor: Colors.white,
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: _buildBody(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/kantorpdam.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Safe Area Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Header Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildHeaderButton(
                        icon: Icons.refresh_rounded,
                        onTap: () => _loadRiwayatPengaduan(refresh: true),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Title Section
                  const TextPoppins(
                    text: "Riwayat Pengaduan",
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const TextPoppins(
                    text:
                        "Lihat riwayat keluhan Anda dan status\npenanganannya di bawah ini.",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _riwayatPengaduan.isEmpty) {
      return _buildLoadingState();
    }
    if (_errorMessage.isNotEmpty && _riwayatPengaduan.isEmpty) {
      return _buildErrorState();
    }
    if (_riwayatPengaduan.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _riwayatPengaduan.length + 1,
      itemBuilder: (context, index) {
        if (index == _riwayatPengaduan.length) {
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                      strokeWidth: 3,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }
        return _buildModernPengaduanCard(_riwayatPengaduan[index], index);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50), strokeWidth: 3),
          SizedBox(height: 16),
          TextPoppins(
            text: 'Memuat riwayat pengaduan...',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            TextPoppins(
              text: 'Oops! Terjadi Kesalahan',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextPoppins(
              text: _errorMessage,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _loadRiwayatPengaduan(refresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const TextPoppins(
                  text: 'Coba Lagi',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const TextPoppins(
              text: 'Belum Ada Pengaduan',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            TextPoppins(
              text: 'Anda belum memiliki riwayat\npengaduan apapun.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPengaduanCard(Map<String, dynamic> pengaduan, int index) {
    final status = pengaduan['status'] ?? 'pending';

    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimationController.value)),
          child: Opacity(opacity: _cardAnimationController.value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showModernDetailDialog(pengaduan),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(pengaduan),
                  const SizedBox(height: 16),
                  _buildModernStatusBadge(status),
                  const SizedBox(height: 16),
                  _buildCardDetail(pengaduan),
                  const SizedBox(height: 16),
                  _buildModernFotoSection(pengaduan),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> pengaduan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextPoppins(
            text: pengaduan['judul'] ?? 'Tanpa Judul',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(pengaduan['tanggal'] ?? ''),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor(status).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _statusLabel(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetail(Map<String, dynamic> pengaduan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Detail Pengaduan:',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        Text(
          pengaduan['isi_pengaduan'] ?? 'Tidak ada detail',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildModernFotoSection(Map<String, dynamic> pengaduan) {
    final fotoUrl = pengaduan['foto_url'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Lampiran Foto:',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        if (fotoUrl == null || fotoUrl.toString().isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  "Tidak ada foto",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => _showImagePreview(fotoUrl.toString()),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      fotoUrl.toString(),
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Gagal memuat foto')),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModernDetailDialog(Map<String, dynamic> pengaduan) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextPoppins(
                          text: pengaduan['judul'] ?? 'Detail Pengaduan',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailInfoSection(pengaduan),
                        const SizedBox(height: 24),
                        _buildDetailContentSection(pengaduan),
                        if (pengaduan['foto_url'] != null &&
                            pengaduan['foto_url'].toString().isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildDetailImageSection(pengaduan),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const TextPoppins(
                        text: 'Tutup',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailInfoSection(Map<String, dynamic> pengaduan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildModernDetailRow(
            'Status',
            _statusLabel(pengaduan['status'] ?? ''),
          ),
          const SizedBox(height: 12),
          _buildModernDetailRow('Jenis User', pengaduan['status_user'] ?? ''),
          const SizedBox(height: 12),
          _buildModernDetailRow('No. Telepon', pengaduan['no_telepon'] ?? ''),
          const SizedBox(height: 12),
          _buildModernDetailRow(
            'Tanggal',
            _formatDate(pengaduan['tanggal'] ?? ''),
          ),
          const SizedBox(height: 12),
          _buildModernDetailRow(
            'User ID',
            pengaduan['user_customer_id']?.toString() ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContentSection(Map<String, dynamic> pengaduan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Isi Pengaduan:',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            pengaduan['isi_pengaduan'] ?? 'Tidak ada detail',
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailImageSection(Map<String, dynamic> pengaduan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Foto Lampiran:',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            pengaduan['foto_url'],
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gagal memuat foto',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: TextPoppins(
            text: '$label:',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
