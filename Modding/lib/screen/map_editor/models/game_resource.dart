import 'dart:collection';
import 'package:sen/screen/map_editor/include/visual_animation.dart';
import 'package:sen/screen/map_editor/include/visual_image.dart';

enum ImageCommonType {
  buttonHudBackNormal,
  buttonHudBackSelected,
  freePinata,
  freePinataOpen,
  missingArtPiece,
  spaceSpiral,
  spaceDust,
  readySeedBank,
  readyPlant,
  sprout,
  keygateFlag,
  infoIcon,
  doodad,
  pathNode,
}

enum AnimationCommonType {
  giftBox,
  levelNode,
  levelNodeGargantuar,
  levelNodeMinigame,
  mapPath,
  yetiIcon,
  zombossNodeHologram,
  missingArtPieceAnimation,
  stargate,
  sodRoll,
  collectedUpgradeEffect
}

class GameResource {
  const GameResource(
      {required this.commonImage,
      required this.commonAnimation,
      required this.uiUniverse,
      required this.seedBank,
      required this.plant,
      required this.upgrade});

  final HashMap<ImageCommonType, VisualImage> commonImage;

  final HashMap<AnimationCommonType, VisualAnimation> commonAnimation;

  final HashMap<String, VisualImage> uiUniverse;

  final HashMap<String, VisualImage?> seedBank;

  final HashMap<String, VisualImage?> plant;

  // final HashMap<String, VisualImage> pinata;

  final HashMap<String, VisualImage?> upgrade;
}
