import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/makeup_service.dart';

class DetailMakeupScreen extends StatefulWidget {
  final int makeupId;

  const DetailMakeupScreen({super.key, required this.makeupId});

  @override
  State<DetailMakeupScreen> createState() => _DetailMakeupScreenState();
}

class _DetailMakeupScreenState extends State<DetailMakeupScreen> {
  MakeupTypeModel? _makeup;
  bool _isLoading = true;
  String? _error;

  List<MakeupTypeModel> _related = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadRelated();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await MakeupService.getMakeupDetail(widget.makeupId);
      setState(() {
        _makeup = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail makeup';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRelated() async {
    try {
      final all = await MakeupService.getMakeupTypes();
      all.removeWhere((m) => m.id == widget.makeupId);
      all.shuffle();
      setState(() {
        _related = all.take(6).toList();
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() => _isLoadingRelated = false);
    }
  }

  List<String> get _tipsList => (_makeup?.tips ?? '')
      .split('\n')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _error != null
              ? _buildErrorState()
              : _makeup == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.primary, size: 40),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadDetail,
              child: const Text('Coba lagi', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final makeup = _makeup!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(makeup),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Makeup & Garis Dekoratif Indikator Tengah
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    makeup.nama,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDeskripsiCard(makeup),
                  const SizedBox(height: 28),
                  _buildTipsSection(),
                  const SizedBox(height: 32),
                  _buildRelatedSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(MakeupTypeModel makeup) {
    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          makeup.fullImageUrl != null
              ? Image.network(
                  makeup.fullImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _buildImagePlaceholder();
                  },
                )
              : _buildImagePlaceholder(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black12,
                ],
                stops: const [0.0, 0.4, 1.0], // const dipindahkan ke sini
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.secondary,
      child: const Center(
        child: Icon(
          Icons.face_retouching_natural_outlined,
          size: 64,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildDeskripsiCard(MakeupTypeModel makeup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              const Text(
                'TENTANG LOOK INI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            makeup.deskripsi,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppTheme.textSecondary,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = _tipsList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.brush_rounded, size: 16, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            const Text(
              'LANGKAH & TIPS APLIKASI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (tips.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              'Belum ada tips aplikasi untuk gaya makeup ini.',
              style: const TextStyle(fontSize: 14, color: AppTheme.textHint, fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, i) {
              final isLast = i == tips.length - 1;
              return _TipStep(
                number: i + 1,
                text: tips[i],
                showConnector: !isLast,
              );
            },
          ),
      ],
    );
  }

  Widget _buildRelatedSection() {
    if (_isLoadingRelated) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
        ),
      );
    }
    if (_related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspirasi Gaya Lainnya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _related.length,
            padding: const EdgeInsets.only(bottom: 5),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final item = _related[i];
              return _RelatedCard(
                makeup: item,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailMakeupScreen(makeupId: item.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 4), // Center penyesuaian ikon chevron
            child: Icon(icon, color: AppTheme.textPrimary, size: 16),
          ),
        ),
      ),
    );
  }
}

class _TipStep extends StatelessWidget {
  final int number;
  final String text;
  final bool showConnector;

  const _TipStep({
    required this.number,
    required this.text,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Struktur Alur Garis Panduan (Timeline)
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Kontainer teks langkah instruksi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider.withOpacity(0.4)),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textPrimary,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
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

class _RelatedCard extends StatelessWidget {
  final MakeupTypeModel makeup;
  final VoidCallback onTap;

  const _RelatedCard({required this.makeup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 125,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: AppTheme.divider.withOpacity(0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: makeup.fullImageUrl != null
                    ? Image.network(
                        makeup.fullImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                makeup.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.secondary.withOpacity(0.5),
      child: const Icon(
        Icons.face_retouching_natural,
        color: AppTheme.primary,
        size: 26,
      ),
    );
  }
}