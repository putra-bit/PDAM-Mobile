import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/Backend/pembayaran_service.dart';

class BayarTagihanPage extends StatefulWidget {
  const BayarTagihanPage({super.key});

  @override
  State<BayarTagihanPage> createState() => _BayarTagihanPageState();
}

class _BayarTagihanPageState extends State<BayarTagihanPage>
    with TickerProviderStateMixin {
  // Controllers & Services
  final TextEditingController _connectionNumberController =
      TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  final PembayaranService _service = PembayaranService();

  // State Variables
  Map<String, dynamic>? _tagihan;
  bool _isLoading = false;
  bool _isPelangganFound = false;
  String _selectedPaymentMethod = '';
  bool _showPaymentSuccess = false;

  // Animation & Tab
  late AnimationController _animationController;
  late AnimationController _successAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _successFadeAnimation;
  late Animation<double> _successScaleAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _tabController = TabController(length: 3, vsync: this);
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

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _successFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  void _disposeControllers() {
    _animationController.dispose();
    _successAnimationController.dispose();
    _tabController.dispose();
    _connectionNumberController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
  }

  // ==================== BUSINESS LOGIC ====================

  Future<void> _handleCekPelanggan() async {
    if (!_validateInput()) return;

    await _fetchPelangganData();
  }

  bool _validateInput() {
    if (_connectionNumberController.text.trim().isEmpty) {
      _showSnackBar('Masukkan nomor sambungan', SnackBarType.info);
      return false;
    }
    return true;
  }

  Future<void> _fetchPelangganData() async {
    _setLoadingState(true);

    try {
      final connectionNumber = int.parse(
        _connectionNumberController.text.trim(),
      );
      final result = await _service.cekTagihanLengkap(connectionNumber);

      setState(() {
        _tagihan = result;
        _isPelangganFound = result['status'] == true;
      });

      if (result['status'] == true) {
        _populatePelangganFields(result['pelanggan']);
        _showSnackBar('Data pelanggan ditemukan', SnackBarType.success);
      } else {
        _clearPelangganFields();
        _showSnackBar(
          result['message'] ?? 'Data tidak ditemukan',
          SnackBarType.error,
        );
      }
    } catch (e) {
      _clearPelangganFields();
      _showSnackBar('Nomor sambungan harus berupa angka', SnackBarType.warning);
    } finally {
      _setLoadingState(false);
    }
  }

  void _populatePelangganFields(Map<String, dynamic> pelanggan) {
    _namaController.text = pelanggan['nama'] ?? '-';
    _alamatController.text = pelanggan['alamat'] ?? '-';
  }

  void _clearPelangganFields() {
    _namaController.clear();
    _alamatController.clear();
    setState(() {
      _tagihan = null;
      _isPelangganFound = false;
    });
  }

  void _setLoadingState(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _showSnackBar(String message, SnackBarType type) {
    MySnackBar.show(context, message: message, type: type);
  }

  Future<void> _handleBayarTagihan() async {
    if (!_isPelangganFound) {
      _showSnackBar('Cek data pelanggan terlebih dahulu', SnackBarType.warning);
      return;
    }

    _showPaymentMethodBottomSheet();
  }

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPaymentMethodBottomSheet(),
    );
  }

  Widget _buildPaymentMethodBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const TextPoppins(
            text: 'Pilih Metode Pembayaran',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPaymentMethodItem(
                    'QRIS',
                    Icons.qr_code,
                    const Color(0xff4CAF50),
                    () => _handlePaymentMethodSelected('QRIS'),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodItem(
                    'Transfer Virtual Account',
                    Icons.account_balance,
                    const Color(0xff2196F3),
                    () => _handlePaymentMethodSelected('VA'),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodItem(
                    'Bank Mandiri',
                    Icons.credit_card,
                    const Color(0xffFF9800),
                    () => _handlePaymentMethodSelected('Mandiri'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextPoppins(
                text: title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _handlePaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
    Navigator.pop(context);
    _showQRCodeBottomSheet();
  }

  void _showQRCodeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => _buildQRCodeBottomSheet(),
    );
  }

  Widget _buildQRCodeBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextPoppins(
                    text: '$_selectedPaymentMethod Pembayaran',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // QR Code
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/qrcode.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextPoppins(
                  text:
                      'Nominal: Rp ${_service.formatCurrency((_tagihan!['total_bayar'] ?? 0) + 1000)}',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Catatan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextPoppins(
                  text: 'Catatan:',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1976D2),
                ),
                SizedBox(height: 8),
                TextPoppins(
                  text:
                      'Pastikan nominal transaksi sudah sesuai.\nTransaksi dengan QRIS akan langsung memotong dari rekening Anda.',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff1976D2),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Dummy Bayar Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDummyPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4CAF50),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const TextPoppins(
                        text: 'Bayar Sekarang',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDummyPayment() async {
    // Tutup QR bottom sheet
    Navigator.pop(context);

    // Show loading
    _setLoadingState(true);

    try {
      if (_tagihan != null && _tagihan!['pelanggan'] != null) {
        final customerId = _tagihan!['pelanggan']['id'] as int;
        final totalAmount =
            (_tagihan!['total_bayar'] ?? 0) + 1000.0; // termasuk denda

        // Proses pembayaran di database
        final result = await _service.bayarTagihan(
          customerId,
          _selectedPaymentMethod,
          totalAmount,
        );

        if (result['status'] == true) {
          // Refresh data tagihan setelah pembayaran berhasil
          await _fetchPelangganData();

          // Show success animation
          _ShowPaymentSuccess();

          _showSnackBar(
            'Pembayaran berhasil! ${result['tagihan_count']} tagihan telah lunas.',
            SnackBarType.success,
          );
        } else {
          _showSnackBar(
            result['message'] ?? 'Pembayaran gagal',
            SnackBarType.error,
          );
        }
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}', SnackBarType.error);
    } finally {
      _setLoadingState(false);
    }
  }

  void _ShowPaymentSuccess() {
    setState(() {
      _showPaymentSuccess = true;
    });

    _successAnimationController.forward().then((_) {
      // Hide success overlay after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _successAnimationController.reverse().then((_) {
            setState(() {
              _showPaymentSuccess = false;
            });

            // Reset form setelah pembayaran berhasil
            _resetPaymentForm();
          });
        }
      });
    });
  }

  void _resetPaymentForm() {
    setState(() {
      _selectedPaymentMethod = '';
      // Tidak reset data pelanggan, biarkan tetap terisi
      // tapi refresh data tagihan sudah dilakukan di _fetchPelangganData
    });
  }

  // ==================== UI BUILDERS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [_buildHeader(), _buildBody()]),
            if (_showPaymentSuccess) _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successAnimationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _successFadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _successScaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xff4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TextPoppins(
                      text: 'Pembayaran Berhasil!',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    const TextPoppins(
                      text: 'Tagihan Anda telah berhasil dibayar',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          text: "Bayar Tagihan",
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInformasiPelangganSection(),
                      const SizedBox(height: 20),
                      if (_isPelangganFound) ...[
                        _buildInformasiTagihanSection(),
                        const SizedBox(height: 20),
                        _buildAlertInfo(),
                        const SizedBox(height: 20),
                        _buildBayarButton(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformasiPelangganSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Informasi Pelanggan',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          'Nomor Sambungan',
          _connectionNumberController,
          keyboardType: TextInputType.number,
          readOnly: false,
          suffixWidget: _buildCekButton(),
        ),
        _buildInputField('Nama Pelanggan', _namaController, readOnly: true),
        _buildInputField('Alamat', _alamatController, readOnly: true),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? suffixWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForField(label),
                  color: const Color(0xff4CAF50),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              TextPoppins(
                text: label,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: readOnly ? '-' : 'Masukkan $label',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: suffixWidget,
                fillColor: readOnly ? Colors.grey[50] : Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xff4CAF50),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCekButton() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCekPelanggan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2196F3),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: const Color(0xff2196F3).withOpacity(0.3),
          minimumSize: const Size(70, 44),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  TextPoppins(
                    text: 'Cek',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInformasiTagihanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Informasi Tagihan',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 16),
        _buildTabBar(),
        _buildTabBarView(),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff4CAF50), Color(0xff66BB6A)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4CAF50).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 16),
                SizedBox(width: 6),
                Text('Tagihan'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 16),
                SizedBox(width: 6),
                Text('Detail'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 16),
                SizedBox(width: 6),
                Text('Riwayat'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 16),
      child: TabBarView(
        controller: _tabController,
        children: [_buildTagihanTab(), _buildDetailTab(), _buildRiwayatTab()],
      ),
    );
  }

  Widget _buildTagihanTab() {
    if (_tagihan == null || _tagihan!['status'] != true) {
      return const Center(
        child: TextPoppins(
          text: 'Tidak ada data tagihan',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      );
    }

    final allTagihan = _tagihan!['tagihan'] as List;
    final belumLunas = allTagihan.where(
      (t) => (t['status_pembayaran'] ?? '').toString().toLowerCase() != 'lunas',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xffF5F5F5)),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Keterangan',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Jumlah',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Biaya',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Rekening Air',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextPoppins(
                      text: '${belumLunas.length}',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextPoppins(
                      text:
                          'Rp ${_service.formatCurrency(_tagihan!['total_bayar'] ?? 0)}',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Denda',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: '1',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Rp 1.000',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Materai',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: '0',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Rp 0',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Angsuran',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: '0',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Rp 0',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Color(0xffE3F2FD)),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: TextPoppins(
                      text: 'Total Tagihan',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1976D2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextPoppins(
                      text: '${belumLunas.length + 1}',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1976D2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextPoppins(
                      text:
                          'Rp ${_service.formatCurrency((_tagihan!['total_bayar'] ?? 0) + 1000)}',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1976D2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    if (_tagihan == null || _tagihan!['status'] != true) {
      return const Center(
        child: TextPoppins(
          text: 'Tidak ada data tagihan',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      );
    }

    final allTagihan = _tagihan!['tagihan'] as List;

    return ListView.builder(
      itemCount: allTagihan.length,
      itemBuilder: (context, index) {
        final tagihan = allTagihan[index];
        return _buildTagihanCard(tagihan);
      },
    );
  }

  Widget _buildRiwayatTab() {
    if (_tagihan == null || _tagihan!['status'] != true) {
      return const Center(
        child: TextPoppins(
          text: 'Tidak ada data riwayat',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      );
    }

    final allTagihan = _tagihan!['tagihan'] as List;
    final riwayatLunas = allTagihan
        .where(
          (t) =>
              (t['status_pembayaran'] ?? '').toString().toLowerCase() ==
              'lunas',
        )
        .toList();

    if (riwayatLunas.isEmpty) {
      return const Center(
        child: TextPoppins(
          text: 'Belum ada tagihan yang lunas',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      );
    }

    return ListView.builder(
      itemCount: riwayatLunas.length,
      itemBuilder: (context, index) {
        final tagihan = riwayatLunas[index];
        return _buildTagihanCard(tagihan);
      },
    );
  }

  Widget _buildTagihanCard(Map<String, dynamic> tagihan) {
    final statusInfo = _getStatusInfo(
      tagihan['status_pembayaran'] ?? 'Pending',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPoppins(
                text: 'Periode: ${tagihan['periode'] ?? '-'}',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextPoppins(
                  text: statusInfo['text'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusInfo['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPoppins(
                text: 'Pakai: ${tagihan['pakai'] ?? 0} m³',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              TextPoppins(
                text: 'Rp ${_service.formatCurrency(tagihan['total'] ?? 0)}',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffFFF3CD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xffF57C00), size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: TextPoppins(
              text: 'Bayar tagihan Anda sebelum tanggal 15!',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xffF57C00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBayarButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleBayarTagihan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4CAF50),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const TextPoppins(
                text: 'Bayar Tagihan',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  IconData _getIconForField(String label) {
    switch (label.toLowerCase()) {
      case 'nomor sambungan':
        return Icons.numbers;
      case 'nama pelanggan':
        return Icons.person;
      case 'alamat':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return {'color': Colors.green, 'text': 'Lunas'};
      case 'belum lunas':
        return {'color': Colors.red, 'text': 'Belum Lunas'};
      default:
        return {'color': Colors.orange, 'text': 'Pending'};
    }
  }
}
