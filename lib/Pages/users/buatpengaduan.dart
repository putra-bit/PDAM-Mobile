import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdam_mobile/Backend/MeterService.dart';
import 'package:pdam_mobile/Backend/pengaduan_service.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
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
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
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
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/kantorpdam.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
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
        ),
        Positioned(
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
        ),
        const Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: Center(
            child: TextPoppins(
              text: "Buat Pengaduan",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioSection() {
    Widget _radioTile(String value, String title) {
      return Expanded(
        child: RadioListTile<String>(
          title: Text(title),
          value: value,
          groupValue: _statusUser,
          onChanged: (val) {
            setState(() {
              _statusUser = val!;
              _namaController.clear();
              _alamatController.clear();
              _connectionController.clear();
            });
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextPoppins(
          text: 'Pilih Jenis',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _radioTile('pelanggan', 'Pelanggan PDAM'),
            _radioTile('umum', 'Umum'),
          ],
        ),
        const SizedBox(height: 16),
      ],
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
          validator: validator,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xff4CAF50)),
            ),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const TextPoppins(
                text: 'Kirim',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
      ),
    );
  }

  // === Build ===
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextPoppins(
                                  text:
                                      'Lengkapi form dibawah ini untuk menyampaikan keluhan Anda!',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                const SizedBox(height: 20),

                                _buildRadioSection(),

                                if (_statusUser == 'pelanggan')
                                  _buildStyledTextField(
                                    controller: _connectionController,
                                    label: 'Nomor Sambungan',
                                    hint: 'Masukkan nomor sambungan',
                                    keyboardType: TextInputType.number,
                                    suffix: IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: _cariPelanggan,
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Nomor sambungan wajib diisi'
                                        : null,
                                  )
                                else ...[
                                  _buildStyledTextField(
                                    controller: _namaController,
                                    label: 'Nama Pelanggan',
                                    hint: 'Masukkan nama',
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Nama wajib diisi'
                                        : null,
                                  ),
                                  _buildStyledTextField(
                                    controller: _alamatController,
                                    label: 'Alamat',
                                    hint: 'Masukkan alamat',
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'Alamat wajib diisi'
                                        : null,
                                  ),
                                ],

                                if (_statusUser == 'pelanggan') ...[
                                  _buildStyledTextField(
                                    controller: _namaController,
                                    label: 'Nama Pelanggan',
                                    hint: 'Nama akan terisi otomatis',
                                    readOnly: true,
                                  ),
                                  _buildStyledTextField(
                                    controller: _alamatController,
                                    label: 'Alamat',
                                    hint: 'Alamat akan terisi otomatis',
                                    readOnly: true,
                                  ),
                                ],

                                _buildStyledTextField(
                                  controller: _teleponController,
                                  label: 'Nomor Telepon',
                                  hint: 'Masukkan Nomor Telepon...',
                                  keyboardType: TextInputType.phone,
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

                                const TextPoppins(
                                  text: 'Gangguan',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedGangguan,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih Pengaduan...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xff4CAF50),
                                      ),
                                    ),
                                  ),
                                  items: _listGangguan
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedGangguan = val),
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'Pilih gangguan / keluhan'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                _buildStyledTextField(
                                  controller: _detailController,
                                  label:
                                      'Detail Pengaduan / Ancar - ancar Lokasi',
                                  hint: 'Masukkan Detail Pengaduan...',
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

                                const TextPoppins(
                                  text: 'Foto Pengaduan',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickPhoto,
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[50],
                                    ),
                                    child: _selectedPhoto != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.file(
                                              _selectedPhoto!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.file_upload_outlined,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Choose File',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                'No File Chosen',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 30),
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
            ),
          ],
        ),
      ),
    );
  }
}
