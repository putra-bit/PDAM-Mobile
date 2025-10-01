//pembayaran.dart
import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdam_mobile/Pages/users/bayartagihan.dart';
import 'package:pdam_mobile/Pages/users/cektagihan.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER IMAGE WITH GRADIENT
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
                      text: "Tagihan Air",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // FORM & CONTENT
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
                            // Welcome Message
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.water_drop_rounded,
                                    color: Colors.blue.shade600,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  const TextPoppins(
                                    text:
                                        'Silahkan pilih layanan yang Anda ingin di bawah ini!',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff1565C0),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _enhancedServiceCard(
                                      context: context,
                                      title: 'Cek Tagihan',
                                      description:
                                          'Masukkan nomor sambungan dan lihat jumlah tagihan air dan jumlah kuitansi pemakaian Anda.',
                                      icon: Icons.bubble_chart,
                                      gradientColors: [
                                        const Color(0xff42A5F5),
                                        const Color(0xff64B5F6),
                                      ],
                                      badgeText: 'Cek',
                                      badgeColor: Colors.blue.shade600,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: CekTagihanPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _enhancedServiceCard(
                                      context: context,
                                      title: 'Bayar Tagihan',
                                      description:
                                          'Bayar langsung tagihan air Anda melalui QRIS atau VA.',
                                      icon: Icons.payment_rounded,
                                      gradientColors: [
                                        const Color(0xff66BB6A),
                                        const Color(0xff81C784),
                                      ],
                                      badgeText: 'Bayar',
                                      badgeColor: Colors.green.shade600,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child: BayarTagihanPage(),
                                          ),
                                        );
                                        print("Navigate to Bayar Tagihan");
                                      },
                                    ),
                                  ],
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _enhancedServiceCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Judul dan Deskripsi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextPoppins(
                                text: title,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff1a1a1a),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: badgeColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: TextPoppins(
                                text: badgeText,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      TextPoppins(
                        text: 'Ketuk untuk melanjutkan',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: gradientColors.first.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: gradientColors.first,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
