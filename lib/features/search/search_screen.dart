import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import 'search_models.dart';
import 'search_providers.dart';
import 'study_search_index.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  var _query = '';
  var _filter = SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(studySearchIndexProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: index.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Search is unavailable',
          message: 'Learning content could not be indexed. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(studySearchIndexProvider),
          tone: EmptyStateTone.error,
        ),
        data: _buildSearch,
      ),
    );
  }

  Widget _buildSearch(StudySearchIndex index) {
    final results = index.search(_query, filter: _filter);
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 800
            ? AppSpacing.xl
            : AppSpacing.md;
        final compact = constraints.maxWidth < 600;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: BrandGradient.surface(Theme.of(context).brightness),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.lg,
                    horizontalPadding,
                    AppSpacing.md,
                  ),
                  child: _SearchControls(
                    controller: _controller,
                    filter: _filter,
                    compact: compact,
                    onChanged: (value) => setState(() => _query = value),
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onClear: () => _setQuery(''),
                  ),
                ),
              ),
            ),
            if (_query.trim().isEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.xl,
                  horizontalPadding,
                  AppSpacing.xxxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: _TopicSuggestions(onSelected: _setQuery),
                ),
              )
            else if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NoSearchResults(query: _query),
              )
            else ...[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.lg,
                  horizontalPadding,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        '${results.length} results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        _filter.label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.separated(
                  itemCount: results.length,
                  itemBuilder: (context, index) =>
                      _SearchResultCard(result: results[index], query: _query),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SearchControls extends StatelessWidget {
  const _SearchControls({
    required this.controller,
    required this.filter,
    required this.compact,
    required this.onChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final SearchFilter filter;
  final bool compact;
  final ValueChanged<String> onChanged;
  final ValueChanged<SearchFilter> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchField = TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search Machine Learning topics',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: const OutlineInputBorder(),
      ),
    );
    final filterMenu = DropdownButtonFormField<SearchFilter>(
      initialValue: filter,
      decoration: const InputDecoration(
        labelText: 'Content type',
        prefixIcon: Icon(Icons.filter_list_rounded),
        border: OutlineInputBorder(),
      ),
      items: SearchFilter.values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(item.icon, size: AppSizes.iconSm),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item.label),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onFilterChanged(value);
      },
    );

    if (compact) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: AppSpacing.sm),
          filterMenu,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(width: 220, child: filterMenu),
      ],
    );
  }
}

class _TopicSuggestions extends StatelessWidget {
  const _TopicSuggestions({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const topics = <(String, IconData)>[
      ('Data leakage', Icons.lock_outline_rounded),
      ('Cross-validation', Icons.fact_check_outlined),
      ('Random forest', Icons.account_tree_outlined),
      ('Feature scaling', Icons.tune_rounded),
      ('Class imbalance', Icons.balance_rounded),
      ('Gradient boosting', Icons.trending_up_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore a topic', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: topics
              .map(
                (topic) => ActionChip(
                  avatar: Icon(topic.$2, size: AppSizes.iconSm),
                  label: Text(topic.$1),
                  onPressed: () => onSelected(topic.$1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: AppSizes.iconLg,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            AppSpacing.gapMd,
            Text(
              'No results for "$query"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Try a broader topic or switch the content type.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result, required this.query});

  final StudySearchResult result;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _resultAccent(result.type);
    return Semantics(
      button: true,
      label: 'Open ${result.type.label}: ${result.title}',
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brSm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openResult(context, result),
          borderRadius: AppRadius.brSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              border: Border.all(color: accent.withValues(alpha: 0.38)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: AppRadius.brSm,
                    ),
                    child: Icon(result.type.icon, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                result.title,
                                style: theme.textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            StatusBadge(
                              label: result.type.label,
                              tone: _resultTone(result.type),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          result.subtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _SearchHighlight(text: result.excerpt, query: query),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: AppSizes.iconSm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHighlight extends StatelessWidget {
  const _SearchHighlight({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final queryLower = query.trim().toLowerCase();
    final index = text.toLowerCase().indexOf(queryLower);
    if (queryLower.isEmpty || index < 0) {
      return Text(
        text,
        style: style,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
    final end = index + queryLower.length;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, end),
            style: style?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

void _openResult(BuildContext context, StudySearchResult result) {
  switch (result.type) {
    case SearchResultType.module:
      context.go('/modules/${result.moduleId}');
    case SearchResultType.lesson:
      context.push('/lessons/${result.moduleId}/${result.lessonId}');
    case SearchResultType.quiz:
      context.push('/quizzes/${result.moduleId}/${result.difficultyId}');
    case SearchResultType.interview:
      context.push(
        '/interview/${result.trackId}?question=${(result.questionIndex ?? 0) + 1}',
      );
  }
}

Color _resultAccent(SearchResultType type) {
  return switch (type) {
    SearchResultType.module => const Color(0xFF18776F),
    SearchResultType.lesson => const Color(0xFF2466A3),
    SearchResultType.quiz => const Color(0xFF6357A6),
    SearchResultType.interview => const Color(0xFF8B5A1C),
  };
}

BadgeTone _resultTone(SearchResultType type) {
  return switch (type) {
    SearchResultType.module => BadgeTone.info,
    SearchResultType.lesson => BadgeTone.neutral,
    SearchResultType.quiz => BadgeTone.info,
    SearchResultType.interview => BadgeTone.warning,
  };
}
