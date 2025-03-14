import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:sen/extension/context.dart';
import 'package:sen/extension/platform.dart';
import 'package:sen/i18n/app_localizations.dart';
import 'package:sen/model/item.dart';
import 'package:sen/screen/animation_viewer/animation_viewer.dart';
import 'package:sen/screen/home_screen/configuration/javascript_category_configuration.dart';
import 'package:sen/screen/home_screen/configuration/level_maker_configuration.dart';
import 'package:sen/screen/home_screen/configuration/map_editor_configuration.dart';
import 'package:sen/screen/home_screen/configuration/shell_configuration.dart';
import 'package:sen/screen/home_screen/tab_item.dart';
import 'package:sen/screen/javascript_category/javascript_category.dart';
import 'package:sen/screen/level_maker/level_maker.dart';
import 'package:sen/screen/map_editor/map_editor.dart';
import 'package:sen/screen/shell_screen/shell_screen.dart';
import 'package:sen/service/ui_helper.dart';
import 'package:sen/widget/animated_floating.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<TabItem> _tabs;
  late int _tabIndex;

  @override
  void initState() {
    _tabIndex = 0;
    _tabs = [];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    if (CurrentPlatform.isDesktop) {
      return _buildDesktopLayout(context, items);
    }
    return _buildListView(items);
  }

  void _addTab(String title, Widget icon, Widget widget) {
    _tabs.add(TabItem(title: title, widget: widget, icon: icon));
    setState(() {});
  }

  void _closeTab(int index) {
    _tabs.removeAt(index);
    _tabIndex = 0;
    setState(() {});
  }

  Widget _buildDesktopLayout(BuildContext context, List<Item> items) {
    return DefaultTabController(
      length: _tabs.length + 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              _makeTab(
                title: context.los.home,
                icon: const Icon(Symbols.home, color: Colors.blueAccent),
              ),
              ...List.generate(_tabs.length, (index) {
                return _makeTab(
                  title: _tabs[index].title,
                  icon: _tabs[index].icon,
                  onPressed: () => _closeTab(index),
                  onSecondaryTapDown:
                      (details) => _showContextMenu(details, index),
                );
              }),
            ],
            onTap: (index) {
              _tabIndex = index;
              setState(() {});
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _buildGridView(context, items),
                ..._tabs.map((tab) => tab.widget),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(TapDownDetails details, int index) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Text("Close"),
          onTap: () => _closeTabByIndex(index),
        ),
        PopupMenuItem(
          child: const Text("Close All Tabs"),
          onTap: () => _closeAllTabs(),
        ),
        PopupMenuItem(
          child: const Text("Close Tabs to the Left"),
          onTap: () => _closeTabsToLeft(index),
        ),
        PopupMenuItem(
          child: const Text("Close Tabs to the Right"),
          onTap: () => _closeTabsToRight(index),
        ),
      ],
    );
  }

  void _closeTabByIndex(int index) {
    _tabs.removeAt(index);
    setState(() {
      if (_tabIndex >= _tabs.length) _tabIndex = 0;
    });
  }

  void _closeAllTabs() {
    _tabs.clear();
    setState(() {
      _tabIndex = 0;
    });
  }

  void _closeTabsToLeft(int index) {
    if (index == _tabIndex) {
      _tabIndex = 0;
    }
    _tabs.removeRange(0, index);
    setState(() {});
  }

  void _closeTabsToRight(int index) {
    if (index == _tabIndex) {
      _tabIndex = 0;
    }
    _tabs.removeRange(index + 1, _tabs.length);
    setState(() {});
  }

  Widget _makeTab({
    required Widget icon,
    required String title,
    void Function()? onPressed,
    void Function(TapDownDetails)? onSecondaryTapDown,
  }) {
    return GestureDetector(
      onSecondaryTapDown: onSecondaryTapDown,
      child: Tab(
        child: SizedBox(
          width: 200.0,
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: [icon, Text(title)],
              ),
              IconButton(icon: const Icon(Symbols.close), onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1800) return 7;
    if (width > 1400) return 5;
    if (width > 1000) return 4;
    if (width > 700) return 3;
    return 2;
  }

  double _calculateChildAspectRatio(BuildContext context, int crossAxisCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spacing = 4.0 * (crossAxisCount - 1);
    final availableWidth = (screenWidth - 18 - spacing) / crossAxisCount;
    final estimatedHeight = availableWidth * 1.1;
    final maxHeight = screenHeight * 0.42;
    final temporaryHeight = estimatedHeight.clamp(130, maxHeight);
    return availableWidth / temporaryHeight;
  }

  Widget _buildGridView(BuildContext context, List<Item> items) {
    final crossAxisCount = _calculateCrossAxisCount(context);
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: _calculateChildAspectRatio(context, crossAxisCount),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCard(context, items[index]),
    );
  }

  Widget _buildListView(List<Item> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12.0),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCard(context, items[index]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Item item) {
    final isDesktop = CurrentPlatform.isDesktop;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          if (isDesktop) {
            _addTab(
              item.title,
              Icon(item.icon, color: item.color),
              item.onWidget?.call() ?? const SizedBox(),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => item.onWidget?.call()),
            );
          }
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: _paddingOf(),
          child:
              isDesktop
                  ? _buildDesktopCardContent(context, item)
                  : _buildMobileCardContent(context, item),
        ),
      ),
    );
  }

  EdgeInsetsGeometry _paddingOf() {
    if (CurrentPlatform.isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0);
  }

  Widget _buildDesktopCardContent(BuildContext context, Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 15.0,
      children: [
        Align(
          alignment: Alignment.topRight,
          child:
              item.onSetting != null
                  ? IconButton(
                    icon: const Icon(Symbols.settings, size: 24.0),
                    onPressed: item.onSetting,
                    tooltip: context.los.settings,
                  )
                  : const SizedBox.shrink(),
        ),
        AnimatedFloating(child: Icon(item.icon, size: 50.0, color: item.color)),
        Text(
          item.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            item.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCardContent(BuildContext context, Item item) {
    final los = context.los;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(item.icon, size: 50.0, color: item.color),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 6.0),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  softWrap: true,
                ),
              ],
            ),
          ),
          if (item.onSetting != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Symbols.settings, size: 22),
              onPressed: item.onSetting,
              tooltip: los.settings,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showJsSettings(BuildContext context) async {
    final los = AppLocalizations.of(context)!;
    await UIHelper.showDetailDialog(
      context: context,
      title: Text(los.js_settings),
      content: const JavaScriptCategoryConfiguration(),
    );
  }

  Future<void> _onLoadLevelMakerConfiguration(BuildContext context) async {
    final los = AppLocalizations.of(context)!;
    await UIHelper.showDetailDialog(
      context: context,
      title: Text(los.level_maker),
      content: const LevelMakerConfiguration(),
    );
  }

  Future<void> _onLoadMapEditorConfiguration(BuildContext context) async {
    final los = AppLocalizations.of(context)!;
    await UIHelper.showDetailDialog(
      context: context,
      title: Text(los.map_editor),
      content: const MapEditorConfiguration(),
    );
  }

  Future<void> _onLoadShellConfiguration(BuildContext context) async {
    final los = AppLocalizations.of(context)!;
    await UIHelper.showDetailDialog(
      context: context,
      title: Text(los.shell_configuration),
      content: const ShellConfiguration(),
    );
  }

  List<Item> _buildItems(BuildContext context) {
    final los = context.los;
    return [
      Item(
        title: los.shell,
        description: los.shell_description,
        icon: Symbols.terminal_rounded,
        onWidget: () => const ShellScreen(),
        onSetting: () async => await _onLoadShellConfiguration(context),
        color: Colors.blueGrey.shade600,
      ),
      Item(
        title: los.js_execute,
        description: los.js_execute_description,
        icon: Symbols.javascript_rounded,
        onWidget: () => const JavaScriptCategory(),
        onSetting: () async => await _showJsSettings(context),
        color: Colors.yellow.shade600,
      ),
      Item(
        title: los.animation_viewer,
        description: los.animation_viewer_description,
        icon: Symbols.animated_images,
        onWidget: () => const AnimationViewer(),
        onSetting: () async => throw Exception('TODO'),
        color: Colors.green.shade700,
      ),
      Item(
        title: los.level_maker,
        description: los.level_maker_description,
        icon: Symbols.build,
        onWidget: () => const LevelMaker(),
        onSetting: () async => await _onLoadLevelMakerConfiguration(context),
        color: Colors.cyan.shade600,
      ),
      Item(
        title: los.map_editor,
        description: los.map_editor_description,
        icon: Symbols.map,
        onWidget: () => const MapEditor(),
        onSetting: () async => await _onLoadMapEditorConfiguration(context),
        color: Colors.lightBlue.shade600,
      ),
    ];
  }
}
