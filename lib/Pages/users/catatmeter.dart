//catatmeter.dart
import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/Backend/MeterService.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user.dart'; // Import untuk navigasi kembali ke home

// Halaman untuk input nomor sambungan
class CatatMeterMandiriPage extends StatefulWidget {
  @override
  _CatatMeterMandiriPageState createState() => _CatatMeterMandiriPageState();
}

class _CatatMeterMandiriPageState extends State<CatatMeterMandiriPage>
    with TickerProviderStateMixin {
  final TextEditingController _connectionNumberController =
      TextEditingController();
  final MeterService _dataService = MeterService();
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize slide animation
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _connectionNumberController.dispose();
    super.dispose();
  }

  void _searchCustomer() async {
    if (_connectionNumberController.text.isEmpty) {
      MySnackBar.show(
        context,
        message: 'Masukkan nomor sambungan',
        type: SnackBarType.info,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final connectionNumber = int.parse(_connectionNumberController.text);
      final customer = await _dataService.findCustomerByConnectionNumber(
        connectionNumber,
      );

      if (customer != null) {
        // Navigasi ke halaman pengisian meter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeterInputPage(customerData: customer),
          ),
        );
      } else {
        MySnackBar.show(
          context,
          message: 'Nomer Sambungan Tidak Di Temukan!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      MySnackBar.show(
        context,
        message: 'Nomor sambungan harus berupa angka',
        type: SnackBarType.warning,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan background image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/kantorpdam.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
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
                      text: "Catat Meter Mandiri",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Form input dengan animasi
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextPoppins(
                              text:
                                  'Isi nomor sambungan / nomor rekening air Anda dengan benar!',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 20),
                            const TextPoppins(
                              text: 'Nomor Sambungan',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _connectionNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nomor sambungan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff4CAF50),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _searchCustomer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const TextPoppins(
                                        text: 'Cari',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Info cara catat meter
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextPoppins(
                                    text: '! Cara Catat Meter Mandiri !',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff4CAF50),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '1. Masukkan Nomor Sambungan yang benar\n'
                                    '2. Buka tutup meter air rumah Anda\n'
                                    '3. Catat angka yang tertera pada meter air\n'
                                    '4. Ambil foto meter sebagai bukti\n'
                                    '5. Kirim data tersebut',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text("Contoh :"),
                            const SizedBox(height: 2),
                            // Gambar meter
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/meteran.jpeg', // Ganti dengan path gambar meter Anda
                                  height: 80,
                                  width: 120,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
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

// Halaman untuk input meter dan foto
class MeterInputPage extends StatefulWidget {
  final Map<String, dynamic> customerData;

  const MeterInputPage({Key? key, required this.customerData})
    : super(key: key);

  @override
  _MeterInputPageState createState() => _MeterInputPageState();
}

class _MeterInputPageState extends State<MeterInputPage>
    with TickerProviderStateMixin {
  final TextEditingController _standMeterController = TextEditingController();
  final MeterService _dataService = MeterService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize slide animation
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _standMeterController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      MySnackBar.show(
        context,
        message: 'Gagal Mengambil Foto $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _submitMeterReading() async {
    if (_standMeterController.text.isEmpty) {
      MySnackBar.show(
        context,
        message: 'Masukkan stand meter',
        type: SnackBarType.warning,
      );
      return;
    }

    if (_selectedImage == null) {
      MySnackBar.show(
        context,
        message: 'Ambil foto meter terlebih dahulu',
        type: SnackBarType.info,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final standMeter = double.parse(_standMeterController.text);

      // Upload foto
      final fileName =
          'meter_${widget.customerData['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoUrl = await _dataService.uploadMeterPhoto(
        _selectedImage!.path,
        fileName,
      );

      if (photoUrl != null) {
        // Submit data
        final success = await _dataService.submitMeterReading(
          customerId: widget.customerData['id'],
          connectionNumber: widget.customerData['connection_number'],
          standMeter: standMeter,
          photoPath: photoUrl,
        );

        if (success) {
          MySnackBar.show(
            context,
            message: 'Data meter berhasil dikirim',
            type: SnackBarType.success,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Homeuser()),
            (route) => false,
          );
        } else {
          throw Exception('Gagal mengirim data');
        }
      } else {
        throw Exception('Gagal mengupload foto');
      }
    } catch (e) {
      MySnackBar.show(
        context,
        message: 'Terjadi Error $e',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/kantorpdam.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
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
                  top: 125,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TextPoppins(
                      text: "Pastikan data Anda sudah benar!",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Form dengan animasi
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Data Customer (Read Only)
                              _buildReadOnlyField(
                                'Nomor Sambungan',
                                widget.customerData['connection_number']
                                    .toString(),
                              ),
                              _buildReadOnlyField(
                                'Nama Pelanggan',
                                widget.customerData['nama'],
                              ),
                              _buildReadOnlyField(
                                'Alamat',
                                widget.customerData['alamat'],
                              ),

                              const SizedBox(height: 20),

                              // Stand Meter Input
                              const TextPoppins(
                                text: 'Stand Meter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _standMeterController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan angka stand meter',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xff4CAF50),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Foto Upload
                              const TextPoppins(
                                text: 'Foto Meter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[50],
                                  ),
                                  child: _selectedImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Tap untuk ambil foto meter',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _submitMeterReading,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4CAF50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const TextPoppins(
                                          text: 'Kirim',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Info tambahan
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xffFF9800),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Pastikan angka stand meter dan foto yang diambil sudah benar sebelum mengirim.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[800],
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}
