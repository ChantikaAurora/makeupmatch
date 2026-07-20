import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/services/recommend_service.dart';
import '../scan/pick_source_screen.dart';
import '../explore/explore_screen.dart';
import '../history/history_screen.dart';
import '../history/history_detail_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userName = '';

  final List<Widget> _screens = [
    const _HomeTab(),
    const PickSourceScreen(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    setState(() => _userName = user['nama'] ?? '');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.divider),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.face_outlined),
              activeIcon: Icon(Icons.face),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _userName = '';

  List<RecommendationModel> _recentHistory = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  // Mengatur URL Gambar -- reuse ApiConstants.baseUrl yang sudah benar
  // untuk kombinasi device+network yang sedang dipakai (jangan hardcode
  // localhost/10.0.2.2 lagi di sini, itu sumber bug sebelumnya).
  String get _imageBaseUrl => ApiConstants.imageBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRecentHistory();
  }

  Future<void> _loadData() async {
    final user = await StorageHelper.getUser();
    setState(() => _userName = user['nama'] ?? '');
  }

  Future<void> _loadRecentHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      final data = await RecommendService.getHistory();
      // urutkan terbaru dulu, ambil maksimal 3
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _recentHistory = data.take(3).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _historyError = 'Gagal memuat riwayat';
        _isLoadingHistory = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  int _scorePercent(double score) => (score * 100).round();

 String _buildFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';

  final serverUri = Uri.parse(ApiConstants.imageBaseUrl);
  final serverRoot = '${serverUri.scheme}://${serverUri.authority}';

  final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';

  return '$serverRoot$path';
}
  void _goToTab(int index) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.setState(() => homeState._currentIndex = index);
  }

  Widget _buildRecentHistory() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_historyError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              _historyError!,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loadRecentHistory,
              child: const Text(
                'Coba lagi',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    if (_recentHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.face_retouching_natural_outlined,
              size: 48,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada rekomendasi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Lakukan scan wajah untuk mendapatkan\nrekomendasi tipe makeup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Tampilkan 3 riwayat terbaru dengan gambar dinamis backend
    return Column(
      children: _recentHistory.map((item) {
        final imageUrl = item.fullImageUrl ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryDetailScreen(item: item),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  // WIDGET KOTAK GAMBAR DENGAN LOGIKA AUTOMATIC FALLBACK BACKEND
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.face_retouching_natural,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.top1Nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_scorePercent(item.top1Score)}% match · ${_formatDate(item.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('MakeupMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => _goToTab(3),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${_userName.isNotEmpty ? _userName.split(' ').first : 'Cantik'} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Temukan tipe makeup yang cocok untukmu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Carousel Banner (auto-scroll)
            _PromoCarousel(
              onScanTap: () => _goToTab(1),
              onExploreTap: () => _goToTab(2),
              onHistoryTap: () => _goToTab(3),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Cepat
                  const Text(
                    'Mulai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickMenuCard(
                          icon: Icons.face_retouching_natural,
                          title: 'Scan Wajah',
                          subtitle: 'Analisis fitur wajah',
                          onTap: () => _goToTab(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickMenuCard(
                          icon: Icons.explore_outlined,
                          title: 'Explore',
                          subtitle: '14 tipe makeup',
                          onTap: () => _goToTab(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Rekomendasi Terakhir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekomendasi Terakhir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildRecentHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data 1 slide carousel
class _PromoSlide {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String assetImage; // taruh file gambar di assets/images/
  final List<Color> gradient;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _PromoSlide({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.assetImage,
    required this.gradient,
    required this.fallbackIcon,
    required this.onTap,
  });
}

/// Carousel banner yang bergerak otomatis (auto-scroll) dengan dot indicator.
class _PromoCarousel extends StatefulWidget {
  final VoidCallback onScanTap;
  final VoidCallback onExploreTap;
  final VoidCallback onHistoryTap;

  const _PromoCarousel({
    required this.onScanTap,
    required this.onExploreTap,
    required this.onHistoryTap,
  });

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  late final PageController _controller;
  late final List<_PromoSlide> _slides;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);

    _slides = [
      _PromoSlide(
        title: 'Cari Tipe Makeup\nIdealmu Sekarang',
        subtitle: 'Scan wajahmu, dapatkan rekomendasi look terbaik',
        buttonLabel: 'Scan Wajah',
        assetImage: 'assets/images/banner_scan.jpg',
        gradient: AppTheme.heroGradient,
        fallbackIcon: Icons.face_retouching_natural,
        onTap: widget.onScanTap,
      ),
      _PromoSlide(
        title: '14 Look Makeup\nSiap Dijelajahi',
        subtitle: 'Temukan inspirasi dari berbagai tipe makeup',
        buttonLabel: 'Explore Sekarang',
        assetImage: 'assets/images/banner_explore.JPG',
        gradient: const [Color(0xFFCE9B84), Color(0xFFDF9F7B)],
        fallbackIcon: Icons.explore,
        onTap: widget.onExploreTap,
      ),
      _PromoSlide(
        title: 'Simpan Semua\nRekomendasimu',
        subtitle: 'Lihat kembali riwayat hasil scan wajahmu',
        buttonLabel: 'Lihat Riwayat',
        assetImage: 'assets/images/banner_history.jpg',
        gradient: const [Color(0xFFCBA6E8), Color(0xFF9B6FD1)],
        fallbackIcon: Icons.history,
        onTap: widget.onHistoryTap,
      ),
    ];

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _CarouselCard(slide: slide),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final _PromoSlide slide;

  const _CarouselCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: slide.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: slide.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: slide.gradient.last.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ornamen Dekoratif Lingkaran Transparan di Latar Belakang
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Gambar latar belakang banner dengan asuransi fallback ikon besar
            Positioned.fill(
              child: Image.asset(
                slide.assetImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      slide.fallbackIcon,
                      size: 90,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
            // Gradien warna overlay halus agar tulisan kontras dan jelas dibaca
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Konten teks, sub-judul, dan tombol di dalam Banner
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slide.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Tombol pemicu interaktif
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.buttonLabel,
                          style: TextStyle(
                            color: slide.gradient.last,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: slide.gradient.last,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}