// home_user.dart - Fixed & Cleaned
import 'package:flutter/material.dart';
import 'package:pdam_mobile/Pages/loginpage.dart';
import 'package:pdam_mobile/Pages/users/berita.dart';
import 'package:pdam_mobile/Pages/users/daftarsambung.dart';
import 'package:pdam_mobile/Pages/users/pembayaran.dart';
import 'package:pdam_mobile/Pages/users/pengaduan.dart';
import 'package:pdam_mobile/Pages/users/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/MyComponent/bottomtab.dart';
import 'package:pdam_mobile/Backend/authservice.dart';
import 'catatmeter.dart';
import 'package:page_transition/page_transition.dart';

class Homeuser extends StatefulWidget {
  const Homeuser({super.key});

  @override
  State<Homeuser> createState() => _HomeuserState();
}

class _HomeuserState extends State<Homeuser> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 350),
          child: const Daftarsambung(), // halaman daftar sambungan
        ),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 350),
          child: const BeritaPDAMPage(), // halaman daftar sambungan
        ),
      );
    }
  }

  void _navigateToCatatMeter() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: CatatMeterMandiriPage(),
      ),
    );
  }

  void _navigateToPemabayaran() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: PembayaranPage(),
      ),
    );
  }

  void _signOutTrasisi() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: Loginpage(),
      ),
    );
  }

  void _navigateToPengaduan() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: const PengaduanPage(),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: const ProfilePage(),
      ),
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
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: _navigateToProfile,
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          final photo = authService.photoProfile;
                          return CircleAvatar(
                            radius: 18,
                            backgroundImage: (photo != null && photo.isNotEmpty)
                                ? NetworkImage(photo)
                                : const AssetImage('assets/profile-default.jpg')
                                      as ImageProvider,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 26,
                  right: 70,
                  child: Consumer<AuthService>(
                    builder: (context, authService, child) {
                      final username = authService.username ?? 'User';
                      return TextPoppins(
                        text: "Halo, $username! 👋",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Layanan
                    Transform.translate(
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
                                text: 'Layanan Pelanggan',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _serviceItem(
                                    Icons.speed_outlined,
                                    "Catat Meter\nMandiri",
                                    const Color(0xff4CAF50),
                                    const Color(0xffE8F5E8),
                                    onTap: _navigateToCatatMeter,
                                  ),
                                  _serviceItem(
                                    Icons.receipt_long_outlined,
                                    "Tagihan\nAir",
                                    const Color(0xff2196F3),
                                    const Color(0xffE3F2FD),
                                    onTap: _navigateToPemabayaran,
                                  ),
                                  _serviceItem(
                                    Icons.campaign_outlined,
                                    "Pengaduan\nPelanggan",
                                    const Color(0xffFF9800),
                                    const Color(0xffFFF3E0),
                                    onTap: _navigateToPengaduan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pengumuman
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                            Row(
                              children: const [
                                TextPoppins(
                                  text: 'Pengumuman Penting',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 5),
                                Text('📢', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const TextPoppins(
                              text: 'Bayar Tagihan Air Mudah',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff4CAF50),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Halo Warga Kota Balikpapan.\n'
                              'PTMB sudah menyiapkan berbagai Media Platform untuk bayar lewat mana aja yang kamu suka. '
                              'Bayar Tagihan Air tidak perlu ribet, karena sekarang kalian punya banyak pilihan 😊',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Aksi Cepat ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const TextPoppins(
                              text: 'AKSI CEPAT',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0277BD), // warna primary PDAM
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToProfile,
                                    icon: const Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    label: const TextPoppins(
                                      text: 'Kelola Profil',
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xff4CAF50,
                                      ), // hijau sukses
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          title: const TextPoppins(
                                            text: 'Konfirmasi Logout',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          content: const TextPoppins(
                                            text:
                                                'Apakah Anda yakin ingin keluar?',
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const TextPoppins(
                                                text: 'Batal',
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                try {
                                                  await context
                                                      .read<AuthService>()
                                                      .signOut();
                                                  if (mounted)
                                                    _signOutTrasisi();
                                                } catch (e) {
                                                  debugPrint(
                                                    "Logout error: $e",
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const TextPoppins(
                                                text: 'Logout',
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    label: const TextPoppins(
                                      text: 'Logout',
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
    );
  }

  // Widget layanan pelanggan
  Widget _serviceItem(
    IconData icon,
    String label,
    Color iconColor,
    Color backgroundColor, {
    VoidCallback? onTap,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      backgroundColor.withOpacity(0.9),
                      backgroundColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(3, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 4,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 28)),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
