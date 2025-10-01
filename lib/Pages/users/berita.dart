import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/bottomtab.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdam_mobile/Pages/users/daftarsambung.dart';
import 'package:pdam_mobile/Pages/users/user.dart';

class BeritaPDAMPage extends StatefulWidget {
  const BeritaPDAMPage({super.key});

  @override
  State<BeritaPDAMPage> createState() => _BeritaPDAMPageState();
}

class _BeritaPDAMPageState extends State<BeritaPDAMPage>
    with TickerProviderStateMixin {
  // Constants
  static const int _navIndex = 2;
  static const Duration _pageDuration = Duration(milliseconds: 350);
  static const Duration _animDuration = Duration(milliseconds: 800);

  // Controllers
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  int _selectedIndex = _navIndex;

  // Data berita dummy
  final List<Map<String, dynamic>> _beritaList = [
    {
      'judul':
          'Atasi Krisis Air Bersih, PTMB Balikpapan Aktifkan Sumur Lama dan Genjot Solusi Jangka Panjang',
      'tanggal': 'Selasa, 01 Juli 2025 12:00',
      'image': 'assets/image11.png',
      'kategori': 'Berita Utama',
    },
    {
      'judul':
          'PTMB Balikpapan Tekan Kebocoran dan Optimalkan Distribusi Air, Siapkan Solusi Jangka Panjang',
      'tanggal': 'Selasa, 01 Juli 2025 09:45',
      'image': 'assets/image7.png',
      'kategori': 'Infrastruktur',
    },
    {
      'judul':
          'Atasi Krisis Air Bersih, PTMB Balikpapan Aktifkan Sumur Lama dan Genjot Solusi Jangka Panjang',
      'tanggal': 'Selasa, 01 Juli 2025 12:00',
      'image': 'assets/image11.png',
      'kategori': 'Berita Utama',
    },
    {
      'judul':
          'PTMB Balikpapan Tekan Kebocoran dan Optimalkan Distribusi Air, Siapkan Solusi Jangka Panjang',
      'tanggal': 'Selasa, 01 Juli 2025 09:45',
      'image': 'assets/image7.png',
      'kategori': 'Infrastruktur',
    },
    {
      'judul':
          'Atasi Krisis Air Bersih, PTMB Balikpapan Aktifkan Sumur Lama dan Genjot Solusi Jangka Panjang',
      'tanggal': 'Selasa, 01 Juli 2025 12:00',
      'image': 'assets/image11.png',
      'kategori': 'Berita Utama',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: _animDuration,
      vsync: this,
    );
  }

  void _initializeAnimations() {
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    Widget? destination;
    if (index == 0) {
      destination = const Homeuser();
    } else if (index == 1) {
      destination = const Daftarsambung();
    }

    if (destination != null) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: _pageDuration,
          child: destination,
        ),
      );
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: BottomTabBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          _buildHeaderBackground(),
          _buildHeaderOverlay(),
          _buildHeaderTitle(),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/kantorpdam.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xff4CAF50),
            child: const Center(
              child: Icon(Icons.business, size: 80, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderOverlay() {
    return Positioned.fill(
      child: Container(
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
    );
  }

  Widget _buildHeaderTitle() {
    return const Positioned(
      top: 25,
      left: 0,
      right: 0,
      child: Center(
        child: TextPoppins(
          text: "Berita PDAM",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
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
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildTabBarView()),
                ],
              ),
            ),
          ),
        ),
      ),
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
          Tab(text: 'Semua'),
          Tab(text: 'Terbaru'),
          Tab(text: 'Populer'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBeritaList(_beritaList),
        _buildBeritaList(_beritaList.reversed.toList()),
        _buildBeritaList(_beritaList),
      ],
    );
  }

  Widget _buildBeritaList(List<Map<String, dynamic>> beritaList) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: beritaList.length,
      itemBuilder: (context, index) {
        return _buildBeritaCard(beritaList[index], index);
      },
    );
  }

  Widget _buildBeritaCard(Map<String, dynamic> berita, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle berita detail
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBeritaImage(berita),
                _buildBeritaContent(berita),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeritaImage(Map<String, dynamic> berita) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Image.asset(
          berita['image'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeritaContent(Map<String, dynamic> berita) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKategoriTag(berita['kategori']),
          const SizedBox(height: 12),
          TextPoppins(
            text: berita['judul'],
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1976D2),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTanggal(berita['tanggal']),
        ],
      ),
    );
  }

  Widget _buildKategoriTag(String kategori) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xff4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextPoppins(
        text: kategori,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xff4CAF50),
      ),
    );
  }

  Widget _buildTanggal(String tanggal) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: TextPoppins(
            text: tanggal,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600]!,
          ),
        ),
      ],
    );
  }
}
