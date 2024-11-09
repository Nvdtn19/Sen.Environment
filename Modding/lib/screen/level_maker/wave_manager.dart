import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:sen/model/wave.dart';
import 'package:sen/screen/level_maker/waves/low_tide_page.dart';
import 'package:sen/screen/level_maker/waves/regular_page.dart';
import 'package:sen/screen/level_maker/waves/storm_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WaveManager extends StatefulWidget {
  const WaveManager({
    super.key,
    required this.waves,
    required this.zombies,
  });

  final List<List<Wave>> waves;

  final List<String> zombies;

  @override
  State<WaveManager> createState() => _WaveManagerState();
}

class _WaveManagerState extends State<WaveManager> {
  late ScrollController _scrollController;

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _waveNavigate(
    Wave wave,
    int index,
  ) async {
    var state = null as Widget?;
    if (wave is RegularWave) {
      state = RegularPage(
        wave: wave,
        index: index,
      );
    } else if (wave is LowTide) {
      state = LowTidePage(
        zombies: widget.zombies,
        wave: wave,
        index: index,
      );
    } else if (wave is StormEvent) {
      state = StormPage(
        wave: wave,
        index: index,
        zombies: widget.zombies,
      );
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => state!,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var index = 1;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: widget.waves.map(
              (e) {
                return _ExpandedWave(
                  wave: e,
                  index: index++,
                  onNavigate: _waveNavigate,
                );
              },
            ).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.waves.add([RegularWave(zombies: [])]);
          });
          _scrollDown();
        },
        child: Icon(Symbols.add),
      ),
    );
  }
}

class _ExpandedWave extends StatefulWidget {
  const _ExpandedWave({
    required this.wave,
    required this.index,
    required this.onNavigate,
  });

  final List<Wave> wave;

  final void Function(Wave wave, int index) onNavigate;

  final int index;

  @override
  State<_ExpandedWave> createState() => __ExpandedWaveState();
}

class __ExpandedWaveState extends State<_ExpandedWave> {
  IconData _exchangeEvent(Wave wave) {
    if (wave is RegularWave) {
      return Symbols.circle;
    } else if (wave is StormEvent) {
      return Symbols.storm;
    }
    return Symbols.waves;
  }

  bool _isExpanded = false;

  String _exchangeEventName(MapEntry<int, Wave> e, int index) {
    final value = e.value;
    final los = AppLocalizations.of(context)!;
    if (value is RegularWave) {
      return '${los.wave} $index: ${los.regular_wave}';
    } else if (value is LowTide) {
      return '${los.wave} $index: ${los.low_tide}';
    } else if (value is StormEvent) {
      return '${los.wave} $index: ${los.storm_event}';
    } else {
      return '${los.wave} $index';
    }
  }

  @override
  Widget build(BuildContext context) {
    final los = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Symbols.waves),
              title: Text('${los.wave} ${widget.index}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String item) {},
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        child: Text(los.regular_wave),
                        onTap: () {
                          setState(() {
                            widget.wave.add(RegularWave(zombies: []));
                          });
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(los.low_tide),
                        onTap: () {
                          setState(() {
                            widget.wave.add(LowTide.withDefault());
                          });
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(los.sandstorm),
                        onTap: () {
                          setState(() {
                            widget.wave.add(StormEvent.withDefault());
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 15.0),
                  Tooltip(
                    message: los.expand,
                    child: ExpandIcon(
                      onPressed: (value) {
                        setState(() {
                          _isExpanded = !value;
                        });
                      },
                      isExpanded: _isExpanded,
                    ),
                  )
                ],
              ),
            ),
            if (_isExpanded)
              ...widget.wave.asMap().entries.map(
                (e) {
                  final index = e.key;
                  final element = e.value;
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: Icon(_exchangeEvent(element),
                          color: Colors.blueAccent),
                      title: Text(_exchangeEventName(e, widget.index)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: los.edit,
                            child: IconButton(
                              onPressed: () =>
                                  widget.onNavigate(element, widget.index),
                              icon: Icon(Symbols.edit),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Tooltip(
                            message: los.delete,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.wave.removeAt(index);
                                });
                              },
                              icon: Icon(Symbols.delete),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
