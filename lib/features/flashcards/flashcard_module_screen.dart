import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/semantic_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module.dart';
import '../modules/module_providers.dart';

/// Full-screen visual picker for one main flashcard module.
class FlashcardModuleScreen extends ConsumerWidget {
  const FlashcardModuleScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return modules.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load module',
          message: 'The flashcard views could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
      ),
      data: (items) {
        final module = _moduleForId(items, moduleId);
        if (module == null) return const _MissingModuleScreen();
        return _FlashcardViewPicker(module: module);
      },
    );
  }
}

class _FlashcardViewPicker extends StatelessWidget {
  const _FlashcardViewPicker({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: IconButton(
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/flashcards');
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              shape: const CircleBorder(),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        titleSpacing: AppSpacing.xs,
        title: Text(
          module.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
          final rowCount = (_flashcardViews.length / crossAxisCount).ceil();
          final verticalGaps = AppSpacing.sm * (rowCount - 1);
          final availableHeight = constraints.maxHeight - (AppSpacing.md * 2);
          final compact = constraints.maxWidth < 160;
          final preferredHeight =
              (availableHeight - verticalGaps) / rowCount;
          final tileHeight = crossAxisCount == 2
              ? preferredHeight
                  .clamp(compact ? 220.0 : 276.0, compact ? 256.0 : 292.0)
                  .toDouble()
              : 280.0;

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: tileHeight,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: _flashcardViews.length,
            itemBuilder: (context, index) {
              return _FlashcardViewCard(
                module: module,
                view: _flashcardViews[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _FlashcardViewCard extends StatelessWidget {
  const _FlashcardViewCard({required this.module, required this.view});

  final Module module;
  final _FlashcardViewOption view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final (background, foreground) = _paletteFor(theme, semantic, view.tone);
    final iconColor = view.tone == _FlashcardViewTone.warning
        ? foreground
        : theme.colorScheme.onSurface;
    final tintOpacity = theme.brightness == Brightness.light ? 0.22 : 0.42;
    final cardColor = Color.alphaBlend(
      background.withValues(alpha: tintOpacity),
      theme.colorScheme.surface,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 160;
        final iconBoxSize = compact ? 56.0 : 82.0;
        final iconSize = compact ? 28.0 : 40.0;
        final contentPadding = compact ? AppSpacing.sm : AppSpacing.lg;
        final iconRadius = compact ? AppRadius.brMd : AppRadius.brLg;
        final cardRadius = BorderRadius.circular(compact ? 24 : 32);
        final titleStyle = theme.textTheme.titleLarge?.copyWith(
          fontSize: compact ? 18 : 24,
          color: theme.colorScheme.onSurface,
          height: 1.18,
        );
        final moduleStyle = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w500,
          height: 1.6,
        );
        final cardTheme = theme.cardTheme.copyWith(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: cardRadius,
            side: BorderSide(color: foreground.withValues(alpha: 0.42)),
          ),
        );

        return Theme(
          data: theme.copyWith(cardTheme: cardTheme),
          child: AppCard(
            padding: EdgeInsets.all(contentPadding),
            onTap: () => context.push('/flashcards/${module.id}/${view.id}'),
            semanticLabel: 'Open ${view.title} for ${module.title}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.86),
                          width: 1.5,
                        ),
                        borderRadius: iconRadius,
                      ),
                      child: Icon(view.icon, size: iconSize, color: iconColor),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_outward_rounded, color: iconColor),
                  ],
                ),
                SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
                Text(
                  view.title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  module.title.toUpperCase(),
                  style: moduleStyle,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Image surface for a module/view combination. The image assets will be
/// assigned here once the corresponding artwork is provided.
class FlashcardVisualScreen extends ConsumerWidget {
  const FlashcardVisualScreen({
    super.key,
    required this.moduleId,
    required this.viewId,
  });

  final String moduleId;
  final String viewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = _flashcardViewForId(viewId);
    if (view == null) return const _MissingViewScreen();

    final theme = Theme.of(context);
    final semantic = context.semantic;
    final module = ref.watch(moduleByIdProvider(moduleId));
    final (background, foreground) = _paletteFor(theme, semantic, view.tone);
    final imagePath = _flashcardImagePath(moduleId, view.id);

    return Scaffold(
      appBar: AppBar(title: Text(view.title)),
      body: imagePath == null
          ? _PendingFlashcardVisual(
              moduleTitle: module?.title ?? 'Flashcards',
              background: background,
              foreground: foreground,
              icon: view.icon,
            )
          : _ZoomableFlashcardImage(
              imagePath: imagePath,
              fallbackColor: background,
              fallbackIcon: view.icon,
              fallbackIconColor: foreground,
            ),
    );
  }
}

class _PendingFlashcardVisual extends StatelessWidget {
  const _PendingFlashcardVisual({
    required this.moduleTitle,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String moduleTitle;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: AppRadius.brLg,
                  ),
                  child: Icon(icon, size: 72, color: foreground),
                ),
              ),
              AppSpacing.gapLg,
              Text(
                moduleTitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSm,
              const StatusBadge(
                label: 'Image pending',
                icon: Icons.image_outlined,
                tone: BadgeTone.neutral,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomableFlashcardImage extends StatefulWidget {
  const _ZoomableFlashcardImage({
    required this.imagePath,
    required this.fallbackColor,
    required this.fallbackIcon,
    required this.fallbackIconColor,
  });

  final String imagePath;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final Color fallbackIconColor;

  @override
  State<_ZoomableFlashcardImage> createState() =>
      _ZoomableFlashcardImageState();
}

class _ZoomableFlashcardImageState extends State<_ZoomableFlashcardImage> {
  final _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _controller,
              minScale: 1,
              maxScale: 5,
              boundaryMargin: const EdgeInsets.all(AppSpacing.xxxl),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => DecoratedBox(
                    decoration: BoxDecoration(color: widget.fallbackColor),
                    child: Icon(
                      widget.fallbackIcon,
                      size: 72,
                      color: widget.fallbackIconColor,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: IconButton.filledTonal(
                tooltip: 'Reset image zoom',
                onPressed: _resetZoom,
                icon: const Icon(Icons.center_focus_strong_outlined),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MissingModuleScreen extends StatelessWidget {
  const _MissingModuleScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: const EmptyStateView(
        icon: Icons.folder_off_outlined,
        title: 'Module not found',
        message: 'This flashcard module is no longer available.',
      ),
    );
  }
}

class _MissingViewScreen extends StatelessWidget {
  const _MissingViewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: const EmptyStateView(
        icon: Icons.visibility_off_outlined,
        title: 'View not found',
        message: 'This flashcard view is no longer available.',
      ),
    );
  }
}

Module? _moduleForId(List<Module> modules, String id) {
  for (final module in modules) {
    if (module.id == id) return module;
  }
  return null;
}

_FlashcardViewOption? _flashcardViewForId(String id) {
  for (final view in _flashcardViews) {
    if (view.id == id) return view;
  }
  return null;
}

/// Associates each supplied artwork file with its main module and view.
String? _flashcardImagePath(String moduleId, String viewId) {
  return _flashcardImagePaths['$moduleId/$viewId'];
}

(Color, Color) _paletteFor(
  ThemeData theme,
  SemanticColors semantic,
  _FlashcardViewTone tone,
) {
  return switch (tone) {
    _FlashcardViewTone.primary => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
    _FlashcardViewTone.info => (
        semantic.infoContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
    _FlashcardViewTone.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
    _FlashcardViewTone.success => (
        semantic.successContainer,
        semantic.onSuccessContainer,
      ),
  };
}

enum _FlashcardViewTone { primary, info, warning, success }

class _FlashcardViewOption {
  const _FlashcardViewOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.tone,
  });

  final String id;
  final String title;
  final IconData icon;
  final _FlashcardViewTone tone;
}

const Map<String, String> _flashcardImagePaths = {
  'foundations/explode': 'assets/images/foundations/flashcard_explode_view.png',
  'foundations/xray': 'assets/images/foundations/flashcard_xray_view.png',
  'foundations/handwritten':
      'assets/images/foundations/flashcard_handwritten_view.png',
  'foundations/sticky-notes':
      'assets/images/foundations/flashcard_sticky_notes_view.png',
  'data_preprocessing/explode':
      'assets/images/data_preprocessing/flashcard_explode_view.png',
  'data_preprocessing/xray':
      'assets/images/data_preprocessing/flashcard_xray_view.png',
  'data_preprocessing/handwritten':
      'assets/images/data_preprocessing/flashcard_handwritten_view.png',
  'data_preprocessing/sticky-notes':
      'assets/images/data_preprocessing/flashcard_sticky_notes_view.png',
  'supervised_learning/explode':
      'assets/images/supervised_learning/flashcard_explode_view.png',
  'supervised_learning/xray':
      'assets/images/supervised_learning/flashcard_xray_view.png',
  'supervised_learning/handwritten':
      'assets/images/supervised_learning/flashcard_handwritten_view.png',
  'supervised_learning/sticky-notes':
      'assets/images/supervised_learning/flashcard_sticky_notes_view.png',
  'regression/explode': 'assets/images/regression/flashcard_explode_view.png',
  'regression/xray': 'assets/images/regression/flashcard_xray_view.png',
  'regression/handwritten':
      'assets/images/regression/flashcard_handwritten_view.png',
  'regression/sticky-notes':
      'assets/images/regression/flashcard_sticky_notes_view.png',
  'classification/explode':
      'assets/images/classification/flashcard_explode_view.png',
  'classification/xray': 'assets/images/classification/flashcard_xray_view.png',
  'classification/handwritten':
      'assets/images/classification/flashcard_handwritten_view.png',
  'classification/sticky-notes':
      'assets/images/classification/flashcard_sticky_notes_view.png',
  'unsupervised_learning/explode':
      'assets/images/unsupervised_learning/flashcard_explode_view.png',
  'unsupervised_learning/xray':
      'assets/images/unsupervised_learning/flashcard_xray_view.png',
  'unsupervised_learning/handwritten':
      'assets/images/unsupervised_learning/flashcard_handwritten_view.png',
  'unsupervised_learning/sticky-notes':
      'assets/images/unsupervised_learning/flashcard_sticky_notes_view.png',
  'model_evaluation/explode':
      'assets/images/model_evaluation/flashcard_explode_view.png',
  'model_evaluation/xray':
      'assets/images/model_evaluation/flashcard_xray_view.png',
  'model_evaluation/handwritten':
      'assets/images/model_evaluation/flashcard_handwritten_view.png',
  'model_evaluation/sticky-notes':
      'assets/images/model_evaluation/flashcard_sticky_notes_view.png',
  'feature_engineering/explode':
      'assets/images/feature_engineering/flashcard_explode_view.png',
  'feature_engineering/xray':
      'assets/images/feature_engineering/flashcard_xray_view.png',
  'feature_engineering/handwritten':
      'assets/images/feature_engineering/flashcard_handwritten_view.png',
  'feature_engineering/sticky-notes':
      'assets/images/feature_engineering/flashcard_sticky_notes_view.png',
  'ensemble_methods/explode':
      'assets/images/ensemble_methods/flashcard_explode_view.png',
  'ensemble_methods/xray':
      'assets/images/ensemble_methods/flashcard_xray_view.png',
  'ensemble_methods/handwritten':
      'assets/images/ensemble_methods/flashcard_handwritten_view.png',
  'ensemble_methods/sticky-notes':
      'assets/images/ensemble_methods/flashcard_sticky_notes_view.png',
};

const _flashcardViews = [
  _FlashcardViewOption(
    id: 'explode',
    title: 'Explode View',
    icon: Icons.account_tree_outlined,
    tone: _FlashcardViewTone.primary,
  ),
  _FlashcardViewOption(
    id: 'xray',
    title: 'Xray View',
    icon: Icons.center_focus_strong_outlined,
    tone: _FlashcardViewTone.info,
  ),
  _FlashcardViewOption(
    id: 'handwritten',
    title: 'HandWritten',
    icon: Icons.draw_outlined,
    tone: _FlashcardViewTone.warning,
  ),
  _FlashcardViewOption(
    id: 'sticky-notes',
    title: 'Stick Notes',
    icon: Icons.sticky_note_2_outlined,
    tone: _FlashcardViewTone.success,
  ),
];
