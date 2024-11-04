import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sen/screen/level_maker/level_exchanger.dart';
import 'package:sen/screen/level_maker/music_type.dart';

class CodePreview extends StatelessWidget {
  const CodePreview({
    super.key,
    required this.levelNameController,
    required this.levelDescriptionController,
    required this.levelStageController,
    required this.lawnMowerController,
    required this.hasSunFalling,
    required this.musicType,
  });

  final TextEditingController levelNameController;
  final TextEditingController levelDescriptionController;
  final TextEditingController levelStageController;
  final TextEditingController lawnMowerController;
  final bool hasSunFalling;

  final MusicType musicType;

  dynamic _buildPreview() {
    final levelExchanger = LevelExchanger(
      levelNameController: levelNameController,
      levelDescriptionController: levelDescriptionController,
      levelStageController: levelStageController,
      lawnMowerController: lawnMowerController,
      hasSunFalling: hasSunFalling,
      musicType: musicType,
    );
    return levelExchanger.buildLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              JsonEncoder.withIndent('\t').convert(_buildPreview()),
            ),
          ),
        ),
      ],
    );
  }
}
