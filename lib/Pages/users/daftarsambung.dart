// daftarsambung.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:pdam_mobile/MyComponent/bottomtab.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user.dart';
import 'package:pdam_mobile/Backend/pengajuanservice.dart';
import 'package:pdam_mobile/Backend/authservice.dart';

class Daftarsambung extends StatefulWidget {
  const Daftarsambung({super.key});

  @override
  State<Daftarsambung> createState() => _DaftarsambungState();
}

class _DaftarsambungState extends State<Daftarsambung>
    with TickerProviderStateMixin {
  // Constants
  static const int _navIndex = 1;
  static const double _borderRadius = 10.0;
  static const double _cardBorderRadius = 20.0;
  static const Duration _animDuration = Duration(milliseconds: 800);
  static const Duration _pageDuration = Duration(milliseconds: 350);

  // Controllers & Services
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _picker = ImagePicker();
  late PengajuanService _pengajuanService;

  // State variables
  int _selectedIndex = _navIndex;
  File? _ktp, _kk, _rekening, _imb, _denah, _foto;
  bool _loading = false;
  bool _showSuccessDialog = false;
  bool _showHistoryDialog = false;
  List<Map<String, dynamic>> _historyData = [];
  bool _loadingHistory = false;

  // Animation controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  void _initServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _pengajuanService = PengajuanService(authService);
      _namaController.text = authService.username ?? '';
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  // Navigation
  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: _pageDuration,
          child: const Homeuser(),
        ),
      );
    }
  }

  // History functions
  void _showHistory() async {
    setState(() {
      _showHistoryDialog = true;
      _loadingHistory = true;
    });

    try {
      final data = await _pengajuanService.getMyPengajuan();
      setState(() {
        _historyData = data;
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _loadingHistory = false;
      });
      MySnackBar.show(
        context,
        message: "Gagal memuat riwayat: ${e.toString()}",
        type: SnackBarType.error,
      );
    }
  }

  void _closeHistory() {
    setState(() {
      _showHistoryDialog = false;
    });
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Permohonan Disetujui';
      case 'rejected':
        return 'Permohonan Ditolak';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xffFFC107);
      case 'approved':
        return const Color(0xff4CAF50);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      MySnackBar.show(
        context,
        message: "Tidak dapat membuka file",
        type: SnackBarType.error,
      );
    }
  }

  // File picker
  Future<void> _pickFile(Function(File) onPicked) async {
    final source = await _showImageSourceModal();
    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) onPicked(File(picked.path));
    }
  }

  Future<ImageSource?> _showImageSourceModal() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalHandle(),
              const SizedBox(height: 20),
              const TextPoppins(
                text: "Pilih Sumber Foto",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 20),
              _buildSourceTile(Icons.camera_alt, "Kamera", ImageSource.camera),
              _buildSourceTile(
                Icons.photo_library,
                "Galeri",
                ImageSource.gallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSourceTile(IconData icon, String title, ImageSource source) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff4CAF50)),
      title: TextPoppins(text: title, fontSize: 14),
      onTap: () => Navigator.pop(context, source),
    );
  }

  // Form actions
  void _resetForm() {
    _namaController.clear();
    _hpController.clear();
    final authService = Provider.of<AuthService>(context, listen: false);
    _namaController.text = authService.username ?? '';
    setState(() {
      _ktp = _kk = _rekening = _imb = _denah = _foto = null;
      _showSuccessDialog = false;
    });
  }

  void _ShowSuccessDialog() {
    setState(() => _showSuccessDialog = true);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateFiles()) return;
    if (!_validateAuth()) return;

    setState(() => _loading = true);

    try {
      final result = await _pengajuanService.createPengajuan(
        namaLengkap: _namaController.text,
        nomorTelepon: _hpController.text,
        ktp: _ktp!,
        kk: _kk!,
        rekeningTetangga: _rekening!,
        imb: _imb!,
        denahRumah: _denah!,
        fotoRumah: _foto!,
      );

      if (result != null) {
        _ShowSuccessDialog();
      } else {
        throw Exception("Gagal membuat pengajuan");
      }
    } catch (e) {
      MySnackBar.show(
        context,
        message: "Gagal mengirim pengajuan: ${e.toString()}",
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _validateFiles() {
    final files = [_ktp, _kk, _rekening, _imb, _denah, _foto];
    if (files.any((file) => file == null)) {
      MySnackBar.show(
        context,
        message: "Lengkapi semua dokumen!",
        type: SnackBarType.error,
      );
      return false;
    }
    return true;
  }

  bool _validateAuth() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn || authService.userId == null) {
      MySnackBar.show(
        context,
        message: "Anda harus login terlebih dahulu!",
        type: SnackBarType.error,
      );
      return false;
    }
    return true;
  }

  // UI Builders
  Widget _buildHeader() {
    return Stack(
      children: [
        _buildHeaderImage(),
        _buildHeaderOverlay(),
        _buildHeaderTitle(),
        _buildHistoryIcon(),
      ],
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 200,
      width: double.infinity,
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

  Widget _buildHeaderTitle() {
    return const Positioned(
      top: 105,
      left: 0,
      right: 0,
      child: Center(
        child: TextPoppins(
          text: "Daftar Sambungan Baru",
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHistoryIcon() {
    return Positioned(
      top: 50,
      right: 20,
      child: GestureDetector(
        onTap: _showHistory,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.history, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildHistoryDialog() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _closeHistory,
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xff4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: TextPoppins(
                  text: "Daftar Sambungan Baru",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const TextPoppins(
            text:
                "Lihat riwayat permohonan Anda\nsebelumnya dan statusnya di bawah ini.",
            fontSize: 14,
            color: Color(0xff0277BD),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _historyData.isEmpty
                ? const Center(
                    child: TextPoppins(
                      text: "Belum ada riwayat pengajuan",
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
                : ListView.builder(
                    itemCount: _historyData.length,
                    itemBuilder: (context, index) {
                      final item = _historyData[index];
                      return _buildHistoryItem(item, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, int number) {
    final status = item['status'] as String;
    final createdAt =
        DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPoppins(
                text: "Permohonan #$number",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              TextPoppins(
                text:
                    "${createdAt.day} ${_getMonthName(createdAt.month)} ${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                fontSize: 12,
                color: Colors.grey[600]!,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextPoppins(
              text: _getStatusText(status),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showDetailDialog(item),
            child: const TextPoppins(
              text: "Detail",
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xff0277BD),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xff0277BD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextPoppins(
                        text: "Detail Permohonan",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.close,
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextPoppins(
                            text: _getStatusText(item['status']),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Info Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                "Nama Lengkap",
                                item['nama_lengkap'],
                              ),
                              const Divider(height: 20),
                              _buildDetailRow(
                                "Nomor Telepon",
                                item['nomor_telepon'],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Documents Section
                        const TextPoppins(
                          text: "Dokumen Persyaratan",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildDocumentLink(
                                "Kartu Tanda Penduduk",
                                item['url_ktp'],
                              ),
                              _buildDocumentDivider(),
                              _buildDocumentLink(
                                "Kartu Keluarga",
                                item['url_kk'],
                              ),
                              _buildDocumentDivider(),
                              _buildDocumentLink(
                                "Rekening Air Tetangga",
                                item['url_rekening_tetangga'],
                              ),
                              _buildDocumentDivider(),
                              _buildDocumentLink("Surat IMB", item['url_imb']),
                              _buildDocumentDivider(),
                              _buildDocumentLink(
                                "Denah Lokasi Rumah",
                                item['url_denah_rumah'],
                              ),
                              _buildDocumentDivider(),
                              _buildDocumentLink(
                                "Foto Rumah",
                                item['url_foto_rumah'],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextPoppins(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600]!,
          ),
        ),
        const TextPoppins(text: ": ", fontSize: 14, color: Colors.grey),
        Expanded(
          flex: 3,
          child: TextPoppins(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentLink(String label, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff0277BD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description,
                color: Color(0xff0277BD),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextPoppins(
                    text: label,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 2),
                  TextPoppins(
                    text: "${label.toLowerCase().replaceAll(' ', '_')}.pdf",
                    fontSize: 12,
                    color: const Color(0xff0277BD),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: Color(0xff0277BD), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: Colors.grey[100],
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSuccessTitle(),
          const SizedBox(height: 24),
          _buildSuccessIcon(),
          const SizedBox(height: 24),
          _buildSuccessSubtext(),
          const SizedBox(height: 28),
          _buildNewSubmissionButton(),
          const SizedBox(height: 12),
          _buildHistoryLink(),
        ],
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return const TextPoppins(
      text:
          "Permohonan sambungan baru Anda telah berhasil dikirim. Terima kasih atas kepercayaan Anda!",
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xff0277BD),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xffFFC107),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.refresh, color: Colors.white, size: 50),
    );
  }

  Widget _buildSuccessSubtext() {
    return const TextPoppins(
      text:
          "Permohonan sambungan baru Anda sedang diproses. Mohon menunggu hingga proses selesai.",
      fontSize: 13,
      color: Colors.black87,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNewSubmissionButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: _resetForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4CAF50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const TextPoppins(
          text: "Buat Sambungan Baru",
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHistoryLink() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSuccessDialog = false;
        });
        _showHistory();
      },
      child: const TextPoppins(
        text: "Lihat Riwayat Permohonan",
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xff0277BD),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator:
              validator ?? (val) => val?.isEmpty == true ? "Wajib diisi" : null,
          decoration: _buildTextFieldDecoration(hint),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _buildTextFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _buildBorder(),
      enabledBorder: _buildBorder(),
      focusedBorder: _buildFocusedBorder(),
      errorBorder: _buildErrorBorder(),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: Color(0xff4CAF50), width: 2),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: Colors.red),
    );
  }

  Widget _buildFilePicker(
    String label,
    File? file,
    Function(File) onPicked, {
    String? description,
  }) {
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
        GestureDetector(
          onTap: _loading ? null : () => _pickFile(onPicked),
          child: Container(
            width: double.infinity,
            height: file != null ? 120 : 60,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(_borderRadius),
              color: Colors.grey[50],
            ),
            child: file != null
                ? _buildFilePreview(file)
                : _buildFileSelector(),
          ),
        ),
        if (description != null) _buildFileDescription(description),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilePreview(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Stack(
        children: [
          Image.file(
            file,
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xff4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const TextPoppins(
            text: "Choose File",
            fontSize: 12,
            color: Color(0xff4CAF50),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: TextPoppins(
            text: "No File Chosen",
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Icon(Icons.file_upload_outlined, color: Colors.grey),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildFileDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextPoppins(
        text: description,
        fontSize: 11,
        color: Colors.grey[600]!,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4CAF50),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const TextPoppins(
                text: "Kirim Pengajuan",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildCardDecoration(),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              const SizedBox(height: 24),
              _buildNameField(),
              _buildPhoneField(),
              _buildDocumentSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildFormHeader() {
    return const Center(
      child: TextPoppins(
        text:
            'Lengkapi form dibawah ini untuk\npermohonan sambungan baru Anda!',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xff4CAF50),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNameField() {
    return _buildStyledTextField(
      controller: _namaController,
      label: "Nama Lengkap",
      hint: "Masukkan Nama Lengkap...",
    );
  }

  Widget _buildPhoneField() {
    return _buildStyledTextField(
      controller: _hpController,
      label: "Nomor HP",
      hint: "Masukkan Nomor HP...",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Upload Dokumen Persyaratan',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        const SizedBox(height: 16),
        _buildFilePicker(
          "Kartu Tanda Penduduk (KTP)",
          _ktp,
          (f) => setState(() => _ktp = f),
          description:
              "Apabila KTP tidak sesuai dengan lokasi yang dimohonkan, mohon cantumkan surat keterangan dari RT setempat",
        ),
        _buildFilePicker(
          "Kartu Keluarga (KK)",
          _kk,
          (f) => setState(() => _kk = f),
        ),
        _buildFilePicker(
          "Rekening Air Tetangga Terdekat",
          _rekening,
          (f) => setState(() => _rekening = f),
        ),
        _buildFilePicker(
          "Surat Izin Mendirikan Bangunan (IMB)",
          _imb,
          (f) => setState(() => _imb = f),
          description:
              "Pastikan di depan rumah sudah tersedia pipa PVC ukuran 2'' s/d 4''",
        ),
        _buildFilePicker(
          "Denah Lokasi Rumah",
          _denah,
          (f) => setState(() => _denah = f),
        ),
        _buildFilePicker(
          "Foto Rumah (Tampak Depan + Nomor Rumah)",
          _foto,
          (f) => setState(() => _foto = f),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) => Scaffold(
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
                        child: _showSuccessDialog
                            ? _buildSuccessDialog(context)
                            : _showHistoryDialog
                            ? _buildHistoryDialog()
                            : _buildFormContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomTabBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onNavTapped,
        ),
      ),
    );
  }
}
