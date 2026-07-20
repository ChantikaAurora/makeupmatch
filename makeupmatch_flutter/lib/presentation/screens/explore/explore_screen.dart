import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/makeup_service.dart';
import 'detail_makeup_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<MakeupTypeModel> _allMakeup = [];
  List<MakeupTypeModel> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filters = ['Semua', 'Natural', 'Bold', 'Korean', 'Glam'];

  // Mapping filter ke keyword
  final Map<String, List<String>> _filterKeywords = {
    'Natural': ['natural', 'clean', 'latte', 'peach'],
    'Bold': ['bold', 'smokey', 'baddie', 'artsy', 'graphic', 'latina'],
    'Korean': ['korean', 'douyin', 'igari', 'thai'],
    'Glam': ['glam', 'old money', 'soft glam'],
  };

  @override
  void initState() {
    super.initState();
    _loadMakeup();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMakeup() async {
    try {
      final data = await MakeupService.getMakeupTypes();
      setState(() {
        _allMakeup = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    _filterAndSearch();
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _filterAndSearch();
  }

  void _filterAndSearch() {
    List<MakeupTypeModel> result = _allMakeup;

    // Filter kategori
    if (_selectedFilter != 'Semua') {
      final keywords = _filterKeywords[_selectedFilter] ?? [];
      result = result.where((m) {
        final name = m.nama.toLowerCase();
        return keywords.any((k) => name.contains(k));
      }).toList();
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result.where((m) {
        return m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() => _filtered = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Explore'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '14 tipe makeup populer',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari tipe makeup...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textHint,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppTheme.textHint,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
          ),
          const SizedBox(height: 8),

          // Grid
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
                        onRefresh: _loadMakeup,
                        color: AppTheme.primary,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _MakeupCard(
                            item: _filtered[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailMakeupScreen(
                                  makeupId: _filtered[i].id,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada hasil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci lain',
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

class _MakeupCard extends StatelessWidget {
  final MakeupTypeModel item;
  final VoidCallback onTap;

  const _MakeupCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
               child: item.fullImageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      item.fullImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  )
                : _buildPlaceholder(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.deskripsi,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.face_retouching_natural_outlined,
        size: 40,
        color: AppTheme.accent,
      ),
    );
  }
}