import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/domain/entities/announcement.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:smart_campus/features/announcements/presentation/pages/announcement_detail_page.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcement_category.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcements_category_chips.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcements_filter_sheet.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcements_loading_skeleton.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcements_search_field.dart';
import 'package:smart_campus/features/announcements/presentation/widgets/announcements_state_heroes.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  static const _searchDebounce = Duration(milliseconds: 300);

  final _searchController = TextEditingController();
  Timer? _searchDebouncer;

  String _searchQuery = '';
  AnnouncementCategory? _selectedCategory;
  SortOrder _sortOrder = SortOrder.newestFirst;

  @override
  void dispose() {
    _searchDebouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(_searchDebounce, () {
      if (mounted) setState(() => _searchQuery = value);
    });
  }

  void _onCategorySelect(AnnouncementCategory? category) {
    setState(() => _selectedCategory = category);
  }

  Future<void> _onOpenFilterSheet() async {
    final result = await showAnnouncementsFilterSheet(
      context,
      initialCategory: _selectedCategory,
      initialSort: _sortOrder,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result.category;
        _sortOrder = result.sortOrder;
      });
    }
  }

  void _onClearSearch() {
    _searchDebouncer?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
    });
  }

  Future<void> _onRefresh() async {
    context.read<AnnouncementsBloc>().add(const RefreshAnnouncements());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _onRetry() {
    context.read<AnnouncementsBloc>().add(const FetchAnnouncements());
  }

  void _openDetail(Announcement item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailPage(announcement: item),
      ),
    );
  }

  List<Announcement> _filterAndSort(List<Announcement> items) {
    final q = _searchQuery.toLowerCase();
    final filtered = items.where((a) {
      final matchesQuery = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
      final matchesCategory = _selectedCategory == null ||
          AnnouncementCategory.fromAnnouncement(a) == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    filtered.sort((a, b) => _sortOrder == SortOrder.newestFirst
        ? b.id.compareTo(a.id)
        : a.id.compareTo(b.id));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Announcements',
        rightIcon: const Icon(Icons.more_horiz_rounded),
        onRight: () {},
      ),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          if (state is AnnouncementsError) {
            return AnnouncementsErrorHero(
              title: 'Failed to Load',
              message: state.message,
              tone: HeroTone.error,
              onRetry: _onRetry,
            );
          }
          if (state is AnnouncementsOffline) {
            return AnnouncementsErrorHero(
              title: 'You are offline',
              message: state.message,
              tone: HeroTone.offline,
              onRetry: _onRetry,
            );
          }
          if (state is AnnouncementsInitial ||
              state is AnnouncementsLoading) {
            return const CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: [AnnouncementsLoadingSkeleton()],
            );
          }
          if (state is AnnouncementsLoaded) {
            final filtered = _filterAndSort(state.announcements);
            return _LoadedView(
              filtered: filtered,
              searchController: _searchController,
              selectedCategory: _selectedCategory,
              searchQuery: _searchQuery,
              onSearchChanged: _onSearchChanged,
              onCategorySelect: _onCategorySelect,
              onOpenFilterSheet: _onOpenFilterSheet,
              onClearSearch: _onClearSearch,
              onRefresh: _onRefresh,
              onTapItem: _openDetail,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.filtered,
    required this.searchController,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onCategorySelect,
    required this.onOpenFilterSheet,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onTapItem,
  });

  final List<Announcement> filtered;
  final TextEditingController searchController;
  final AnnouncementCategory? selectedCategory;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AnnouncementCategory?> onCategorySelect;
  final VoidCallback onOpenFilterSheet;
  final VoidCallback onClearSearch;
  final Future<void> Function() onRefresh;
  final ValueChanged<Announcement> onTapItem;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding.w,
              AppSpacing.paddingCard.h,
              AppSpacing.pagePadding.w,
              12.h,
            ),
            sliver: SliverToBoxAdapter(
              child: AnnouncementsSearchField(
                controller: searchController,
                onChanged: onSearchChanged,
                onFilterTap: onOpenFilterSheet,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnnouncementsCategoryChips(
              selected: selectedCategory,
              onSelect: onCategorySelect,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AnnouncementsEmptyHero(
                searchQuery: searchQuery,
                hasActiveFilter: selectedCategory != null,
                onClear: onClearSearch,
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding.w,
                0,
                AppSpacing.pagePadding.w,
                (AppSpacing.paddingCard + 24).h,
              ),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                itemBuilder: (context, index) => AnnouncementCard(
                  announcement: filtered[index],
                  onTap: () => onTapItem(filtered[index]),
                ),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
              ),
            ),
        ],
      ),
    );
  }
}
