import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'image_page.dart';
import 'media_page.dart';
import 'sprite_page.dart';
import '../../i18n/app_localizations.dart';
import 'visual_helper.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({
    super.key,
    required this.sprite,
    required this.image,
    required this.media,
    required this.visualHelper,
    required this.staticController,
  });

  final List<String> sprite;

  final List<String> image;

  final List<String> media;

  final VisualHelper visualHelper;

  final AnimationController staticController;

  Widget _buildTab({required IconData icon, required String label}) {
    return Tab(icon: Icon(icon, size: 22), text: label);
  }

  @override
  Widget build(BuildContext context) {
    final los = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              labelColor: theme.colorScheme.onPrimaryContainer,
              dividerColor: Colors.transparent,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: <Widget>[
                _buildTab(icon: Symbols.folder, label: los.media),
                _buildTab(icon: Symbols.image, label: los.image),
                _buildTab(icon: Symbols.animation, label: los.sprite),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TabBarView(
                    children: <Widget>[
                      MediaPage(visualHelper: visualHelper, media: media),
                      ImagePage(visualHelper: visualHelper, image: image),
                      SpritePage(
                        staticController: staticController,
                        visualHelper: visualHelper,
                        sprite: sprite,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('sprite', sprite));
    properties.add(IterableProperty<String>('image', image));
    properties.add(IterableProperty<String>('media', media));
    properties.add(
      DiagnosticsProperty<VisualHelper>('visualHelper', visualHelper),
    );
    properties.add(
      DiagnosticsProperty<AnimationController>(
        'staticController',
        staticController,
      ),
    );
  }
}
