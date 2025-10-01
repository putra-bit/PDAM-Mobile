import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdam_mobile/Backend/MeterService.dart';
import 'package:pdam_mobile/Backend/pengaduan_service.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';

class BuatPengaduanBaruPage extends StatefulWidget {
  const BuatPengaduanBaruPage({super.key});

  @override
  State<BuatPengaduanBaruPage> createState() => _BuatPengaduanBaruPageState();
}

class _BuatPengaduanBaruPageState extends State<BuatPengaduanBaruPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pengaduanService = PengaduanService();
  final _meterService = MeterService();

  // Controllers
  final _connectionController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _detailController = TextEditingController();

  String _statusUser = 'pelanggan';
  String? _selectedGangguan;
  File? _selectedPhoto;
  bool _loading = false;

  final _listGangguan = ['Matinya air', 'Bocor', 'Tagihan salah', 'Lainnya'];

  // Animation
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _connectionController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  // === Logic ===
  Future<void> _cariPelanggan() async {
    final nomor = int.tryParse(_connectionController.text);
    if (nomor == null) {
      return MySnackBar.show(
        context,
        message: 'Nomor sambungan tidak valid',
        type: SnackBarType.error,
      );
    }

    final data = await _meterService.findCustomerByConnectionNumber(nomor);
    if (data != null) {
      _namaController.text = data['nama'] ?? '';
      _alamatController.text = data['alamat'] ?? '';
      setState(() {});
    } else {
      MySnackBar.show(
        context,
        message: 'Maaf Pelanggan Tidak Ditemukan',
        type: SnackBarType.warning,
      );
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff4CAF50)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Color(0xff4CAF50),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Kamera',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xff4CAF50)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 32,
                              color: Color(0xff4CAF50),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _selectedPhoto = File(picked.path));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    String? fotoUrl;
    if (_selectedPhoto != null) {
      final ext = _selectedPhoto!.path.split('.').last;
      fotoUrl = await _pengaduanService.uploadPengaduanPhoto(
        _selectedPhoto!.path,
        ext,
      );
    }

    final success = await _pengaduanService.submitPengaduan(
      context,
      statusUser: _statusUser,
      judul: _selectedGangguan ?? 'Lainnya',
      isiPengaduan: _detailController.text,
      noTelepon: _teleponController.text,
      fotoUrl: fotoUrl,
    );

    setState(() => _loading = false);

    if (success) {
      MySnackBar.show(
        context,
        message: 'Pengaduan Berhasil Dikirim',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else {
      MySnackBar.show(
        context,
        message: 'Gagal mengirim pengaduan',
        type: SnackBarType.error,
      );
    }
  }

  // === Widgets ===
  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/kantorpdam.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            height: double.infinity,
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
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Buat Pengaduan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jenis Pelapor',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _statusUser = 'pelanggan';
                      _namaController.clear();
                      _alamatController.clear();
                      _connectionController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _statusUser == 'pelanggan'
                          ? const Color(0xff4CAF50).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusUser == 'pelanggan'
                            ? const Color(0xff4CAF50)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusUser == 'pelanggan'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _statusUser == 'pelanggan'
                              ? const Color(0xff4CAF50)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Pelanggan PDAM',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _statusUser = 'umum';
                      _namaController.clear();
                      _alamatController.clear();
                      _connectionController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _statusUser == 'umum'
                          ? const Color(0xff4CAF50).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusUser == 'umum'
                            ? const Color(0xff4CAF50)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusUser == 'umum'
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _statusUser == 'umum'
                              ? const Color(0xff4CAF50)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Masyarakat Umum',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffix,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[600], size: 20)
                : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Gangguan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGangguan,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Pilih jenis gangguan...',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              Icons.report_problem,
              color: Colors.grey[600],
              size: 20,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: _listGangguan
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) => setState(() => _selectedGangguan = val),
          validator: (val) =>
              val == null || val.isEmpty ? 'Pilih gangguan / keluhan' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Pengaduan (Opsional)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 2,
                style: BorderStyle.solid,
              ),
              color: Colors.grey[50],
            ),
            child: _selectedPhoto != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedPhoto!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPhoto = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Klik untuk pilih foto',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG (Max 5MB)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff4CAF50),
          disabledBackgroundColor: Colors.grey[300],
          elevation: 2,
          shadowColor: const Color(0xff4CAF50).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mengirim...',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Kirim Pengaduan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // === Build ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form Instructions
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xff4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xff4CAF50,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xff4CAF50),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Lengkapi form di bawah ini untuk menyampaikan keluhan Anda dengan detail',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff2E7D32),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Radio Section
                            _buildRadioSection(),
                            const SizedBox(height: 20),

                            // Conditional Fields
                            if (_statusUser == 'pelanggan') ...[
                              _buildStyledTextField(
                                controller: _connectionController,
                                label: 'Nomor Sambungan',
                                hint: 'Masukkan nomor sambungan',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.numbers,
                                suffix: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Color(0xff4CAF50),
                                  ),
                                  onPressed: _cariPelanggan,
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Nomor sambungan wajib diisi'
                                    : null,
                              ),
                              _buildStyledTextField(
                                controller: _namaController,
                                label: 'Nama Pelanggan',
                                hint:
                                    'Nama akan terisi otomatis setelah pencarian',
                                prefixIcon: Icons.person,
                                readOnly: true,
                              ),
                              _buildStyledTextField(
                                controller: _alamatController,
                                label: 'Alamat',
                                hint:
                                    'Alamat akan terisi otomatis setelah pencarian',
                                prefixIcon: Icons.location_on,
                                readOnly: true,
                              ),
                            ] else ...[
                              _buildStyledTextField(
                                controller: _namaController,
                                label: 'Nama Lengkap',
                                hint: 'Masukkan nama lengkap Anda',
                                prefixIcon: Icons.person,
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                              ),
                              _buildStyledTextField(
                                controller: _alamatController,
                                label: 'Alamat',
                                hint: 'Masukkan alamat lengkap',
                                prefixIcon: Icons.location_on,
                                maxLines: 2,
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Alamat wajib diisi'
                                    : null,
                              ),
                            ],

                            _buildStyledTextField(
                              controller: _teleponController,
                              label: 'Nomor Telepon',
                              hint: 'Contoh: 08123456789',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Nomor telepon wajib diisi';
                                }
                                if (!RegExp(r'^08\d+$').hasMatch(val)) {
                                  return 'Nomor telepon harus diawali 08';
                                }
                                return null;
                              },
                            ),

                            _buildDropdownField(),

                            _buildStyledTextField(
                              controller: _detailController,
                              label: 'Detail Pengaduan',
                              hint:
                                  'Jelaskan gangguan yang Anda alami secara detail...',
                              prefixIcon: Icons.description,
                              maxLines: 4,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Detail pengaduan wajib diisi';
                                }
                                if (val.length < 10) {
                                  return 'Minimal 10 karakter';
                                }
                                return null;
                              },
                            ),

                            _buildPhotoUpload(),

                            const SizedBox(height: 10),
                            _buildSubmitButton(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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
}
