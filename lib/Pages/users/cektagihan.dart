import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/Backend/pembayaran_service.dart';

class CekTagihanPage extends StatefulWidget {
  const CekTagihanPage({super.key});

  @override
  State<CekTagihanPage> createState() => _CekTagihanPageState();
}

class _CekTagihanPageState extends State<CekTagihanPage>
    with TickerProviderStateMixin {
  // Controllers & Services
  final TextEditingController _connectionNumberController =
      TextEditingController();
  final PembayaranService _service = PembayaranService();

  // State Variables
  Map<String, dynamic>? _tagihan;
  bool _isLoading = false;
  String _selectedFilter = 'Semua'; // Filter dropdown

  // Animation
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ==================== INITIALIZATION ====================

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  void _disposeControllers() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _connectionNumberController.dispose();
  }

  // ==================== BUSINESS LOGIC ====================

  Future<void> _handleCekTagihan() async {
    if (!_validateInput()) return;

    await _fetchTagihanData();
  }

  bool _validateInput() {
    if (_connectionNumberController.text.trim().isEmpty) {
      _showSnackBar('Masukkan nomor sambungan', SnackBarType.info);
      return false;
    }
    return true;
  }

  Future<void> _fetchTagihanData() async {
    _setLoadingState(true);

    try {
      final connectionNumber = int.parse(
        _connectionNumberController.text.trim(),
      );
      final result = await _service.cekTagihanLengkap(connectionNumber);

      setState(() => _tagihan = result);

      if (result['status'] == true) {
        _cardAnimationController.forward();
      }

      if (result['status'] == false) {
        _showSnackBar(
          result['message'] ?? 'Data tidak ditemukan',
          SnackBarType.error,
        );
      }
    } catch (e) {
      _showSnackBar('Nomor sambungan harus berupa angka', SnackBarType.warning);
    } finally {
      _setLoadingState(false);
    }
  }

  void _setLoadingState(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _showSnackBar(String message, SnackBarType type) {
    MySnackBar.show(context, message: message, type: type);
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(child: Column(children: [_buildHeader(), _buildBody()])),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        _buildHeaderBackground(),
        _buildHeaderOverlay(),
        _buildBackButton(),
        _buildHeaderTitle(),
      ],
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/kantorpdam.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeaderOverlay() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return const Positioned(
      top: 25,
      left: 0,
      right: 0,
      child: Center(
        child: TextPoppins(
          text: "Cek Tagihan",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenWidth < 600;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructionText(),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildInputSection(),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildCekButton(),
                          _buildTagihanResults(),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildInformationCard(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return const TextPoppins(
      text: 'Isi nomor sambungan / nomor rekening air Anda dengan benar!',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Nomor Sambungan',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        _buildInputField(),
      ],
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _connectionNumberController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Masukkan nomor sambungan',
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.grey[500],
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.link, color: Colors.grey[600], size: 20),
        ),
        filled: true,
        fillColor: const Color(0xffF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff4CAF50), width: 2),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCekButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCekTagihan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4CAF50),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xff4CAF50).withOpacity(0.3),
        ),
        child: _isLoading ? _buildLoadingIndicator() : _buildButtonText(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
    );
  }

  Widget _buildButtonText() {
    return const TextPoppins(
      text: 'Cek Data',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  Widget _buildTagihanResults() {
    if (_tagihan == null || _tagihan!['status'] != true) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _cardFadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPelangganInfo(),
          _buildInfoCards(),
          const SizedBox(height: 24),
          _buildFilterSection(),
          _buildDetailTagihanSection(),
        ],
      ),
    );
  }

  Widget _buildPelangganInfo() {
    final pelanggan = _tagihan!['pelanggan'];
    return Column(
      children: [
        _buildReadOnlyField('Nama Pemilik', pelanggan['nama'] ?? '-'),
        _buildReadOnlyField('Alamat', pelanggan['alamat'] ?? '-'),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextPoppins(
          text: label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xffF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextPoppins(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoCards() {
    final tagihan = _tagihan!['tagihan'] as List;
    final tagihanAktif = tagihan
        .where(
          (t) =>
              (t['status_pembayaran'] ?? '').toString().toLowerCase() !=
              'lunas',
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        if (isSmallScreen) {
          return Column(
            children: [
              _buildInfoCard(
                'Tagihan Aktif',
                tagihanAktif.toString(),
                const Color(0xff2196F3),
                Icons.receipt_long,
                isFullWidth: true,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Total Jumlah Bayar',
                'Rp ${_service.formatCurrency(_tagihan!['total_bayar'] ?? 0)}',
                const Color(0xff4CAF50),
                Icons.payments,
                isFullWidth: true,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Tagihan Aktif',
                tagihanAktif.toString(),
                const Color(0xff2196F3),
                Icons.receipt_long,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Total Jumlah Bayar',
                'Rp ${_service.formatCurrency(_tagihan!['total_bayar'] ?? 0)}',
                const Color(0xff4CAF50),
                Icons.payments,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    Color color,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextPoppins(
                  text: title,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextPoppins(
            text: value,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextPoppins(
              text: 'Detail Tagihan',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            _buildFilterDropdown(),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
            size: 18,
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: ['Semua', 'Lunas', 'Belum Lunas', 'Pending'].map((
            String value,
          ) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedFilter = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailTagihanSection() {
    final allTagihan = _tagihan!['tagihan'] as List;
    final filteredTagihan = _getFilteredTagihan(allTagihan);

    if (filteredTagihan.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredTagihan
          .asMap()
          .entries
          .map((entry) => _buildTagihanCard(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          TextPoppins(
            text: 'Tidak ada tagihan untuk filter "$_selectedFilter"',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600]!,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTagihanCard(Map<String, dynamic> tagihan, int index) {
    final statusInfo = _getStatusInfo(
      tagihan['status_pembayaran'] ?? 'Pending',
    );

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTagihanHeader(tagihan, statusInfo),
            const SizedBox(height: 12),
            _buildTagihanDetails(tagihan),
          ],
        ),
      ),
    );
  }

  Widget _buildTagihanHeader(
    Map<String, dynamic> tagihan,
    Map<String, dynamic> statusInfo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextPoppins(
            text: 'Periode: ${tagihan['periode'] ?? '-'}',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        _buildStatusBadge(statusInfo),
      ],
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextPoppins(
        text: statusInfo['text'],
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: statusInfo['color'],
      ),
    );
  }

  Widget _buildTagihanDetails(Map<String, dynamic> tagihan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextPoppins(
            text: 'Pakai: ${tagihan['pakai'] ?? 0} m³',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          TextPoppins(
            text: 'Rp ${_service.formatCurrency(tagihan['total'] ?? 0)}',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xff4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xffE8F5E8), const Color(0xffF0F8F0)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff4CAF50).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xff4CAF50),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const TextPoppins(
                text: 'Informasi Tagihan',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff2E7D32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const TextPoppins(
            text:
                '• Masukkan nomor sambungan yang benar\n'
                '• Cek semua tagihan yang belum dibayar\n'
                '• Lakukan pembayaran sebelum tanggal jatuh tempo\n'
                '• Simpan bukti pembayaran untuk referensi',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  List<Map<String, dynamic>> _getFilteredTagihan(List tagihan) {
    if (_selectedFilter == 'Semua') {
      return List<Map<String, dynamic>>.from(tagihan);
    }

    return tagihan
        .where((t) {
          final status = (t['status_pembayaran'] ?? '')
              .toString()
              .toLowerCase();
          switch (_selectedFilter.toLowerCase()) {
            case 'lunas':
              return status == 'lunas';
            case 'belum lunas':
              return status == 'belum lunas';
            case 'pending':
              return status != 'lunas' && status != 'belum lunas';
            default:
              return true;
          }
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return {'color': const Color(0xff4CAF50), 'text': 'Lunas'};
      case 'belum lunas':
        return {'color': const Color(0xffF44336), 'text': 'Belum Lunas'};
      default:
        return {'color': const Color(0xffFF9800), 'text': 'Pending'};
    }
  }
}
