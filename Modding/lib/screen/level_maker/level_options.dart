import 'package:flutter/material.dart';
import 'package:sen/service/file_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LevelOptions extends StatefulWidget {
  const LevelOptions({
    super.key,
    required this.plants,
    required this.zombies,
    required this.gridItem,
    required this.onItemSelected,
  });

  final List<String> plants;
  final List<String> zombies;
  final List<String> gridItem;
  final ValueChanged<MemoryImage> onItemSelected;

  @override
  State<LevelOptions> createState() => _LevelOptionsState();
}

class _LevelOptionsState extends State<LevelOptions>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedImage = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _makeExpansionCard(String imagePath, int index) {
    final image = MemoryImage(
      FileService.readBuffer(source: imagePath),
    );
    final imageWidget = Image(
      image: image,
      width: 40,
      height: 40,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = _selectedImage == index ? -1 : index;
          if (_selectedImage != -1) {
            widget.onItemSelected(image);
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey<int>(_selectedImage == index ? index : -1),
          decoration: BoxDecoration(
            gradient: _selectedImage == index
                ? LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.6),
                      Colors.green.withOpacity(0.6),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Card(
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _makeScrollableTab(List<String> data) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: <Widget>[
              ...data.asMap().entries.map((entry) {
                final index = entry.key;
                final imagePath = entry.value;
                return _makeExpansionCard(imagePath, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final los = AppLocalizations.of(context)!;
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: los.plant),
            Tab(text: los.zombie),
            Tab(text: los.grid_item),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _makeScrollableTab(widget.plants),
              _makeScrollableTab(widget.zombies),
              _makeScrollableTab(widget.gridItem),
            ],
          ),
        ),
      ],
    );
  }
}
