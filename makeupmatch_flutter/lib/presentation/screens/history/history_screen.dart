import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/services/recommend_service.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RecommendationModel> _history = [];
  List<RecommendationModel> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Bulan Ini', 'Lebih Lama'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await RecommendService.getHistory();
      setState(() {
        _history = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    final now = DateTime.now();
    if (filter == 'Semua') {
      setState(() => _filtered = _history);
    } else if (filter == 'Bulan Ini') {
      setState(() => _filtered = _history.where((r) {
            final date = DateTime.tryParse(r.createdAt);
            if (date == null) return false;
            return date.month == now.month && date.year == now.year;
          }).toList());
    } else {
      setState(() => _filtered = _history.where((r) {
            final date = DateTime.tryParse(r.createdAt);
            if (date == null) return false;
            return date.isBefore(
              DateTime(now.year, now.month, 1),
            );
          }).toList());
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  int _scorePercent(double score) => (score * 100).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Container(
            color: AppTheme.surface,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '${_history.length} rekomendasi tersimpan',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => _applyFilter(f),
                    selectedColor: AppTheme.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: AppTheme.surface,
                    side: BorderSide(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.divider,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  )
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppTheme.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _HistoryCard(
                            item: _filtered[i],
                            formatDate: _formatDate,
                            scorePercent: _scorePercent,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan scan wajah untuk mendapatkan\nrekomendasi tipe makeup',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RecommendationModel item;
  final String Function(String) formatDate;
  final int Function(double) scorePercent;

  const _HistoryCard({
    required this.item,
    required this.formatDate,
    required this.scorePercent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(item: item),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: AppTheme.secondary,
                child: item.fullImageUrl != null
                    ? Image.network(
                        item.fullImageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.face_retouching_natural,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.face_retouching_natural,
                        color: AppTheme.primary,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
  item.top1Nama,
  style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  ),
),
const SizedBox(height: 4),
Text(
  '${scorePercent(item.top1Score)}% match · ${formatDate(item.createdAt)}',
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
    );
  }
}