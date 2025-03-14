import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import '../../../cubit/map_editor_configuration_cubit/map_editor_configuration_cubit.dart';
import '../../../model/worldmap.dart';
import '../bloc/item/item_bloc.dart';
import '../bloc/resource/resource_bloc.dart';
import '../bloc/setting/setting_bloc.dart';
import '../bloc/stage/stage_bloc.dart';
import 'display_text.dart';
import 'uuid.dart';
import 'visual_animation.dart';
import 'visual_image.dart';
import '../models/event_node.dart';
import '../models/game_resource.dart';
import '../models/item_profile.dart';
import '../models/layer_node.dart';
import '../models/map_const.dart';
import '../widgets/animation_widget.dart';
import '../widgets/image_widget.dart';
import '../widgets/seedbank_widget.dart';

class ItemStoreView extends StatelessWidget {
  const ItemStoreView({
    super.key,
    required this.cubit,
    required this.stageBloc,
    required this.resourceBloc,
    required this.settingBloc,
  });

  final ResourceBloc resourceBloc;

  final StageBloc stageBloc;

  final SettingBloc settingBloc;

  final MapEditorConfigurationCubit cubit;

  (VisualImage, bool) _getVisualImage(int id) {
    final items = resourceBloc.state.islandImage;
    if (items.containsKey(id)) {
      return (items[id]!, true);
    } else {
      return (
        cubit.state.gameResource.commonImage[ImageCommonType.missingArtPiece]!,
        false,
      );
    }
  }

  (VisualAnimation, bool) _getVisualAnimation(int id) {
    final items = resourceBloc.state.islandAnimation;
    if (items.containsKey(id)) {
      return (items[id]!, true);
    } else {
      return (
        cubit.state.gameResource.commonAnimation[AnimationCommonType
            .missingArtPieceAnimation]!,
        false,
      );
    }
  }

  void _updateItemProfile(ItemProfile itemProfile, LockProperties status) {
    switch (status) {
      case LockProperties.visible:
        {
          break;
        }
      case LockProperties.lockVisible:
        {
          itemProfile.selectRect = Rect.zero;
          break;
        }
      case LockProperties.opacityVisible:
        {
          itemProfile.selectRect = Rect.zero;
          itemProfile.widget = Opacity(opacity: .5, child: itemProfile.widget);
          break;
        }
      case LockProperties.invisible:
        {
          itemProfile.selectRect = Rect.zero;
          itemProfile.widget = Visibility(
            visible: false,
            child: itemProfile.widget ?? const SizedBox.shrink(),
          );
          break;
        }
    }
  }

  double _getParallaxPos(int parallax) {
    return MapConst.baseParallaxOffsets[parallax] ?? 1;
  }

  Rect _makeRect(
    num width,
    num height, {
    num left = 0,
    top = 0,
    double viewPortScale = 1,
  }) {
    return Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      width * viewPortScale,
      height * viewPortScale,
    );
  }

  void _updatePiecesStatic({
    required double itemStartPositionX,
    required double itemStartPositionY,
    required List<MapEntry<String, MapPieceItem>> sortedEntries,
    required SplayTreeMap<int, ItemStore> pieceList,
    required SplayTreeMap<int, ItemStore> parallaxBottomList,
    required SplayTreeMap<int, ItemStore> parallaxTopList,
  }) {
    final rasterizedInAnimation = resourceBloc.state.rasterizedInAnimation;
    const imageScaleRatio = MapConst.scaleResolution / MapConst.imageResolution;
    const animationScaleRatio =
        MapConst.scaleResolution / MapConst.animationResolution;
    final editorSettingState = settingBloc.state;
    final hideMissingArt = editorSettingState.hideMissingArt;
    final filterQuality = editorSettingState.filterQuality;
    for (final entry in sortedEntries) {
      final piece = entry.value;
      final itemProfile = ItemProfile(isEvent: false);
      final isParallax = piece.parallax != 0;
      var additionalParallaxPos = 0.0;
      if (isParallax) {
        final parallaxSpeed = _getParallaxPos(piece.parallax);
        additionalParallaxPos = parallaxSpeed * 1;
      }
      if (piece.pieceType == PieceType.animation) {
        final visualAnimation = _getVisualAnimation(piece.imageID);
        if (hideMissingArt && !visualAnimation.$2) {
          continue;
        }
        final visual = visualAnimation.$1;
        final scaleXFactor = piece.isArtFlipped ? -piece.scaleX : piece.scaleX;
        final usesRasterizedImagesInAnim =
            rasterizedInAnimation[piece.imageID] ?? false;
        final posXFactor =
            -(MapConst.animationSizeCenter *
                scaleXFactor *
                animationScaleRatio *
                0.5);
        // final scaleYFactor = piece.isArtFlipped ? -piece.scaleY : piece.scaleY;
        final posYFactor =
            -(MapConst.animationSizeCenter *
                piece.scaleY *
                animationScaleRatio *
                0.5);
        final piecePosX =
            (itemStartPositionX + piece.position.x) + additionalParallaxPos;
        final piecePosY = itemStartPositionY + piece.position.y;
        const selectRect = Rect.zero;
        final rotateOrigin =
            usesRasterizedImagesInAnim
                ? const Offset(250, 250)
                : const Offset(195, 195);
        final destScale =
            usesRasterizedImagesInAnim ? imageScaleRatio : animationScaleRatio;
        final matrix =
            Matrix4Transform()
                .scaleBy(x: scaleXFactor, y: piece.scaleY)
                .scale(destScale)
                .translate(x: piecePosX + posXFactor, y: piecePosY + posYFactor)
                .rotate(-piece.rotationAngle.toDouble(), origin: rotateOrigin)
                .m;
        final rect = MatrixUtils.transformRect(matrix, selectRect);
        const itemRect = Rect.zero;
        itemProfile.matrix = matrix;
        itemProfile.selectRect = rect;
        itemProfile.widget = Transform(
          alignment: Alignment.topLeft,
          transform: matrix,
          child: AnimationWidget(
            visual: visual,
            labelPlay: const ['main'],
            borderRect: itemRect,
            borderColor: Colors.green,
            borderWidth: 0,
            filterQuality: filterQuality,
            playSingleFrame: true,
          ),
        );
      } else {
        final visualImage = _getVisualImage(piece.imageID);
        if (hideMissingArt && !visualImage.$2) {
          continue;
        }
        final image = visualImage.$1;
        final scaleXFactor = piece.isArtFlipped ? -piece.scaleX : piece.scaleX;
        final posXFactor = image.width * 0.5 * -scaleXFactor * imageScaleRatio;
        final piecePosX =
            (itemStartPositionX + piece.position.x + posXFactor) +
            additionalParallaxPos;
        final piecePosY = itemStartPositionY + piece.position.y;
        const selectRect = Rect.zero;
        final rotateFactor =
            piece.isArtFlipped
                ? piece.rotationAngle.toDouble()
                : -piece.rotationAngle.toDouble();
        final matrix =
            Matrix4Transform()
                .scale(imageScaleRatio)
                .scaleBy(x: scaleXFactor, y: piece.scaleY)
                .translate(x: piecePosX, y: piecePosY)
                .rotateDegrees(
                  rotateFactor,
                  origin: Offset(image.width / 2, image.height / 2),
                )
                .m;

        final rect = MatrixUtils.transformRect(matrix, selectRect);
        itemProfile.matrix = matrix;
        itemProfile.itemRect = Rect.zero;
        itemProfile.selectRect = rect;
        itemProfile.widget = ImageWidget(
          image: image,
          matrix: matrix,
          borderWidth: 0.0,
          filterQuality: filterQuality,
        );
      }
      final layer = piece.layer;
      final parallax = piece.parallax;
      if (isParallax) {
        final parallaxList =
            parallax < 0 ? parallaxTopList : parallaxBottomList;
        if (!parallaxList.containsKey(parallax)) {
          parallaxList[parallax] = {};
        }
        parallaxList[parallax]![entry.key] = itemProfile;
      } else {
        if (!pieceList.containsKey(layer)) {
          pieceList[layer] = {};
        }
        pieceList[layer]![entry.key] = itemProfile;
      }
      final property =
          stageBloc.state.pieceProperty[(layer, parallax)] ?? ItemProperty();
      _updateItemProfile(itemProfile, property.status);
    }
  }

  void _updateEventsStatic({
    required double itemStartPositionX,
    required double itemStartPositionY,
    required List<MapEntry<String, MapEventItem>> eventSortedEntries,
    required ItemStore pieceEventList,
    required ItemStore mapPathList,
    required ItemStore eventList,
  }) {
    var containBossEvent = false;
    const imageScaleRatio = MapConst.scaleResolution / MapConst.imageResolution;
    const animationScaleRatio =
        MapConst.scaleResolution / MapConst.animationResolution;
    final gameResource = cubit.state.gameResource;
    final missingArtPiece =
        gameResource.commonImage[ImageCommonType.missingArtPiece]!;
    final missingArtPieceAnimation =
        gameResource.commonAnimation[AnimationCommonType
            .missingArtPieceAnimation]!;
    final editorSettingState = settingBloc.state;
    final mapCompleted = editorSettingState.mapCompleted;
    final filterQuality = editorSettingState.filterQuality;
    // final playSingleFrame = editorSettingState.playSingleFrame;
    final hideOldEvent = editorSettingState.hideOldEvent;
    for (final entry in eventSortedEntries) {
      final event = entry.value;
      final itemProfile = ItemProfile(isEvent: true);
      switch (event.eventType) {
        case EventType.none:
        case EventType.island:
        case EventType.powerup:
          {
            debugPrint('unknown_event_type');
            break;
          }
        case EventType.doodad:
          {
            if (hideOldEvent) {
              continue;
            }
            // TODO(Hiep): unknown event
            final image = gameResource.commonImage[ImageCommonType.doodad]!;
            final posXFactor = -image.width * imageScaleRatio;
            final posYFactor = -image.height * imageScaleRatio;
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor;
            final matrix =
                Matrix4Transform()
                    .scale(imageScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            /*
            const selectRect = Rect.zero;
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = _makeRect(image.width, image.height);
            itemProfile.selectRect = rect;
            */
            itemProfile.widget = ImageWidget(
              image: image,
              matrix: matrix,
              borderColor: Colors.blue,
              borderWidth: editorSettingState.eventBorder ? 2.0 : 0.0,
              filterQuality: filterQuality,
            );
            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.path_node:
          {
            if (hideOldEvent) {
              continue;
            }
            final image = gameResource.commonImage[ImageCommonType.pathNode]!;
            final posXFactor = -image.width * imageScaleRatio;
            final posYFactor = -image.height * imageScaleRatio;
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor + 30;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor + 15;
            final matrix =
                Matrix4Transform()
                    .scale(imageScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            /*
            final selectRect = _makeRect(image.width, image.height,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = _makeRect(image.width, image.height);
            itemProfile.selectRect = rect;
            */
            itemProfile.widget = ImageWidget(
              image: image,
              matrix: matrix,
              borderColor: Colors.blue,
              borderWidth: 0.0,
              filterQuality: filterQuality,
            );
            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.star_gate:
          {
            if (hideOldEvent) {
              continue;
            }
            const posXFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            // final scaleYFactor = piece.isArtFlipped ? -piece.scaleY : piece.scaleY;
            const posYFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor + 5;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor - 40;
            final matrix =
                Matrix4Transform()
                    .scale(animationScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            final visual =
                gameResource.commonAnimation[AnimationCommonType.stargate]!;
            /*
            final itemRect = _makeEventRect(EventNodeType.stargate)!;
            final selectRect = _makeRect(itemRect.width, itemRect.height,
                top: itemRect.top,
                left: itemRect.left,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = itemRect;
            itemProfile.selectRect = rect;
            */
            final playLabelEvent =
                event.isArtFlipped ?? false
                    ? eventAnimationLabel[EventNodeType.stargateLeft]!
                    : eventAnimationLabel[EventNodeType.stargate]!;

            itemProfile.widget = Transform(
              alignment: Alignment.topLeft,
              transform: matrix,
              child: AnimationWidget(
                labelPlay: const [],
                forceLabelPlay:
                    mapCompleted
                        ? playLabelEvent.$2.first
                        : playLabelEvent.$1.first,
                borderRect: Rect.zero,
                visual: visual,
                borderColor: Colors.blue,
                borderWidth: 0,
                filterQuality: filterQuality,
                playSingleFrame: true,
              ),
            );

            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.key_gate:
          {
            if (hideOldEvent) {
              continue;
            }
            final visual =
                resourceBloc.state.resourceAnimation[ResourceAnimationType
                    .keyGate] ??
                missingArtPieceAnimation;
            const posXFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            const posYFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            final piecePosX = itemStartPositionX + event.position.x + 21;
            final piecePosY = itemStartPositionY + event.position.y + 1;

            final matrix =
                Matrix4Transform()
                    .scale(imageScaleRatio)
                    .translate(
                      x: piecePosX + posXFactor,
                      y: piecePosY + posYFactor,
                    )
                    .m;
            /*
            final itemRect = _makeEventRect(EventNodeType.keygate)!;
            final selectRect = _makeRect(itemRect.width, itemRect.height,
                top: itemRect.top,
                left: itemRect.left,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = itemRect;
            itemProfile.selectRect = rect;
            */
            final isArtFlipped = event.isArtFlipped ?? false;
            final playLabelEvent =
                isArtFlipped
                    ? eventAnimationLabel[EventNodeType.keygate]!
                    : eventAnimationLabel[EventNodeType.keyGateLeft]!;
            final image =
                gameResource.commonImage[ImageCommonType.keygateFlag]!;
            final text = (event.cost ?? 0).toString();
            final flag =
                isArtFlipped
                    ? ImageWidget(
                      image: image,
                      matrix: matrix.multiplied(
                        Matrix4Transform()
                            .flipHorizontally()
                            .translate(x: 147, y: 143)
                            .m,
                      ),
                      borderWidth: 0,
                      filterQuality: filterQuality,
                    )
                    : ImageWidget(
                      image: image,
                      matrix: matrix.multiplied(
                        Matrix4Transform().translate(x: 247, y: 143).m,
                      ),
                      borderWidth: 0,
                      filterQuality: filterQuality,
                    );
            final isFinished = editorSettingState.mapCompleted;

            final flagInfoImage =
                gameResource.commonImage[ImageCommonType.infoIcon]!;
            final costInfo =
                isFinished
                    ? (isArtFlipped
                        ? ImageWidget(
                          image: flagInfoImage,
                          matrix: matrix.multiplied(
                            Matrix4Transform()
                                .scale(animationScaleRatio)
                                .translate(x: 50, y: 160)
                                .m,
                          ),
                          borderWidth: 0,
                          filterQuality: filterQuality,
                        )
                        : ImageWidget(
                          image: flagInfoImage,
                          matrix: matrix.multiplied(
                            Matrix4Transform()
                                .scale(animationScaleRatio)
                                .translate(x: 290, y: 160)
                                .m,
                          ),
                          borderWidth: 0,
                          filterQuality: filterQuality,
                        ))
                    : (isArtFlipped
                        ? Transform(
                          alignment: Alignment.topLeft,
                          transform: matrix.multiplied(
                            Matrix4Transform()
                                .scale(1.6)
                                .translate(x: 60, y: 135)
                                .m,
                          ),
                          child: DisplayText(
                            displayText: text,
                            fontSize: 45,
                            strokeWidth: 3,
                            textColor: Colors.lightBlue.shade200,
                          ),
                        )
                        : Transform(
                          alignment: Alignment.topLeft,
                          transform: matrix.multiplied(
                            Matrix4Transform()
                                .scale(1.6)
                                .translate(x: 300, y: 135)
                                .m,
                          ),
                          child: DisplayText(
                            displayText: text,
                            fontSize: 45,
                            strokeWidth: 3,
                            textColor: Colors.lightBlue.shade200,
                          ),
                        ));
            const itemRect = Rect.zero;
            itemProfile.widget = Stack(
              fit: StackFit.passthrough,
              children: [
                flag,
                Transform(
                  alignment: Alignment.topLeft,
                  transform: matrix,
                  child: AnimationWidget(
                    labelPlay: const [],
                    forceLabelPlay:
                        mapCompleted
                            ? playLabelEvent.$2.first
                            : playLabelEvent.$1.first,
                    borderRect: itemRect,
                    visual: visual,
                    borderColor: Colors.blue,
                    borderWidth: editorSettingState.eventBorder ? 2.0 : 0,
                    filterQuality: filterQuality,
                    playSingleFrame: true,
                  ),
                ),
                costInfo,
              ],
            );
            eventList[entry.key] = itemProfile;
            break;
          }

        case EventType.upgrade:
          {
            final image =
                gameResource.upgrade[event.dataString] ?? missingArtPiece;
            final posXFactor = -image.width * 0.5 * imageScaleRatio;
            final posYFactor = -image.height * 0.34;
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor;
            final matrix =
                Matrix4Transform()
                    .scale(imageScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            /*
            final selectRect = _makeRect(image.width, image.height,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = _makeRect(image.width, image.height);
            itemProfile.selectRect = rect;
            */
            itemProfile.widget =
                editorSettingState.mapCompleted
                    ? Stack(
                      fit: StackFit.passthrough,
                      children: [
                        Transform(
                          alignment: Alignment.topLeft,
                          transform:
                              Matrix4Transform()
                                  .scale(animationScaleRatio)
                                  .translate(
                                    x: piecePosX - 67,
                                    y: piecePosY - 72,
                                  )
                                  .m,
                          child: AnimationWidget(
                            visual:
                                gameResource.commonAnimation[AnimationCommonType
                                    .collectedUpgradeEffect]!,
                            labelPlay: const ['main'],
                            borderWidth: 0,
                            filterQuality: filterQuality,
                            playSingleFrame: true,
                          ),
                        ),
                        ImageWidget(
                          image: image,
                          matrix: matrix,
                          borderColor: Colors.blue,
                          borderWidth: 0.0,
                          filterQuality: filterQuality,
                        ),
                      ],
                    )
                    : ImageWidget(
                      image: image,
                      matrix: matrix,
                      borderColor: Colors.blue,
                      borderWidth: 0.0,
                      filterQuality: filterQuality,
                    );
            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.plantbox:
        case EventType.plant:
          {
            final plantConfig = cubit.state.configModel.resource.plant;
            final plantType = event.dataString;
            if (editorSettingState.mapCompleted) {
              const posXFactor =
                  -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
              // final scaleYFactor = piece.isArtFlipped ? -piece.scaleY : piece.scaleY;
              const posYFactor =
                  -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
              final piecePosX =
                  itemStartPositionX + event.position.x + posXFactor - 1;
              final piecePosY =
                  itemStartPositionY + event.position.y + posYFactor - 17;
              final matrix =
                  Matrix4Transform()
                      .scale(animationScaleRatio)
                      .translate(x: piecePosX, y: piecePosY)
                      .m;
              final visual =
                  gameResource.plant[plantType] ??
                  gameResource.commonAnimation[AnimationCommonType.readyPlant]!;
              /*
              final itemRect = _makeEventRect(EventNodeType.plant)!;
              final selectRect = _makeRect(itemRect.width, itemRect.height,
                  top: itemRect.top,
                  left: itemRect.left,
                  viewPortScale: viewportScale);
              final rect = MatrixUtils.transformRect(matrix, selectRect);
              final isVisible = viewportRect.overlaps(rect);
              if (!isVisible && !onSelectedList.contains(entry.key)) {
                continue;
              }
              itemProfile.matrix = matrix;
              itemProfile.itemRect = itemRect;
              itemProfile.selectRect = rect;
              */
              itemProfile.widget = Stack(
                fit: StackFit.passthrough,
                children: [
                  ImageWidget(
                    image: gameResource.commonImage[ImageCommonType.sprout]!,
                    matrix: matrix.multiplied(
                      Matrix4Transform()
                          .scaleBy(x: 0.4, y: 0.5)
                          .translate(x: 150, y: 215)
                          .m,
                    ),
                    borderWidth: 0,
                    filterQuality: filterQuality,
                  ),
                  Transform(
                    alignment: Alignment.topLeft,
                    transform: matrix,
                    child: AnimationWidget(
                      labelPlay: getIdlePlay(plantType, visual.labelInfo.keys),
                      borderRect: Rect.zero,
                      visual: visual,
                      borderColor: Colors.blue,
                      borderWidth: editorSettingState.eventBorder ? 2.0 : 0,
                      filterQuality: filterQuality,
                      playSingleFrame: true,
                    ),
                  ),
                ],
              );

              eventList[entry.key] = itemProfile;
            } else {
              final plantImage =
                  gameResource.packet[plantType] ??
                  gameResource.commonImage[ImageCommonType.readyPacket]!;

              final seedBankImage =
                  gameResource.seedBank[plantConfig[plantType]] ??
                  gameResource.commonImage[ImageCommonType.readySeedBank]!;
              final piecePosX = itemStartPositionX + event.position.x - 27;
              final piecePosY = itemStartPositionY + event.position.y - 36;

              final matrix =
                  Matrix4Transform()
                      .scale(imageScaleRatio * 0.75)
                      .translate(x: piecePosX, y: piecePosY)
                      .m;
              /*
              final selectRect = _makeRect(
                  seedBankImage.width, seedBankImage.height,
                  viewPortScale: viewportScale);
              final rect = MatrixUtils.transformRect(matrix, selectRect);
              final isVisible = viewportRect.overlaps(rect);
              if (!isVisible && !onSelectedList.contains(entry.key)) {
                continue;
              }
              itemProfile.matrix = matrix;
              itemProfile.itemRect =
                  _makeRect(seedBankImage.width, seedBankImage.height);
              itemProfile.selectRect = rect;
              */
              itemProfile.widget = Stack(
                fit: StackFit.passthrough,
                children: [
                  ImageWidget(
                    image: gameResource.commonImage[ImageCommonType.sprout]!,
                    matrix: matrix.multiplied(
                      Matrix4Transform()
                          .scaleBy(x: 0.65, y: 0.8)
                          .translate(x: 40, y: 127)
                          .m,
                    ),
                    borderWidth: 0,
                    filterQuality: filterQuality,
                  ),
                  SeedBankWidget(
                    plant: plantImage,
                    seedtype: seedBankImage,
                    matrix: matrix,
                  ),
                ],
              );
              eventList[entry.key] = itemProfile;
            }
            break;
          }
        case EventType.giftbox:
          {
            const posXFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            // final scaleYFactor = piece.isArtFlipped ? -piece.scaleY : piece.scaleY;
            const posYFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor;
            final matrix =
                Matrix4Transform()
                    .scale(animationScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            final visual =
                gameResource.commonAnimation[AnimationCommonType.giftBox]!;
            /*
            final itemRect = _makeEventRect(EventNodeType.giftbox)!;
            final selectRect = _makeRect(itemRect.width, itemRect.height,
                top: itemRect.top,
                left: itemRect.left,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = itemRect;
            itemProfile.selectRect = rect;
            */
            const itemRect = Rect.zero;
            final playLabelEvent = eventAnimationLabel[EventNodeType.giftbox]!;
            itemProfile.widget = Transform(
              alignment: Alignment.topLeft,
              transform: matrix,
              child: AnimationWidget(
                labelPlay: mapCompleted ? playLabelEvent.$2 : playLabelEvent.$1,
                borderRect: itemRect,
                visual: visual,
                borderColor: Colors.blue,
                borderWidth: 0,
                filterQuality: filterQuality,
                playSingleFrame: true,
              ),
            );

            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.pinata:
          {
            final resourceImage = resourceBloc.state.resourceImage;
            final image =
                editorSettingState.mapCompleted
                    ? resourceImage[ResourceImageType.pinataSpineOpen] ??
                        gameResource.commonImage[ImageCommonType
                            .freePinataOpen]!
                    : resourceImage[ResourceImageType.pinataSpine] ??
                        gameResource.commonImage[ImageCommonType.freePinata]!;
            final posXFactor = -image.width * 0.5 * imageScaleRatio;
            final posYFactor = -image.height * imageScaleRatio * 0.8;
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor;
            final matrix =
                Matrix4Transform()
                    .scale(imageScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            /*
            final selectRect = _makeRect(image.width, image.height,
                viewPortScale: viewportScale);
            final rect = MatrixUtils.transformRect(matrix, selectRect);
            final isVisible = viewportRect.overlaps(rect);
            if (!isVisible && !onSelectedList.contains(entry.key)) {
              continue;
            }
            itemProfile.matrix = matrix;
            itemProfile.itemRect = _makeRect(image.width, image.height);
            itemProfile.selectRect = rect;
            */
            itemProfile.widget = ImageWidget(
              image: image,
              matrix: matrix,
              borderColor: Colors.blue,
              borderWidth: 0.0,
              filterQuality: filterQuality,
            );
            eventList[entry.key] = itemProfile;
            break;
          }
        case EventType.level:
          {
            const posXFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            // final scaleYFactor = piece.isArtFlipped ? -piece.scaleY : piece.scaleY;
            const posYFactor =
                -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
            final piecePosX =
                itemStartPositionX + event.position.x + posXFactor;
            final piecePosY =
                itemStartPositionY + event.position.y + posYFactor - 7;
            var levelNodeType = event.levelNodeType!;
            if (event.dataString != null &&
                event.dataString!.contains('danger')) {
              levelNodeType = LevelNodeType.danger;
            }
            if (containBossEvent && levelNodeType == LevelNodeType.boss) {
              levelNodeType = LevelNodeType.nonfinalboss;
            }
            final isFirstLevel = event.eventID == 1;
            final matrix =
                Matrix4Transform()
                    .scale(animationScaleRatio)
                    .translate(x: piecePosX, y: piecePosY)
                    .m;
            switch (levelNodeType) {
              case LevelNodeType.normal:
                {
                  final visual =
                      gameResource.commonAnimation[AnimationCommonType
                          .levelNode]!;
                  /*
                  final itemRect = _makeEventRect(EventNodeType.normal)!;
                  final selectRect = _makeRect(itemRect.width, itemRect.height,
                      top: itemRect.top,
                      left: itemRect.left,
                      viewPortScale: viewportScale);
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  itemProfile.matrix = matrix;
                  itemProfile.itemRect = itemRect;
                  itemProfile.selectRect = rect;
                  */
                  const itemRect = Rect.zero;
                  final text = event.displayText ?? '';
                  final textLength = text.length * 12;
                  final playLabelEvent =
                      isFirstLevel
                          ? eventAnimationLabel[EventNodeType.firstLevel]!
                          : eventAnimationLabel[EventNodeType.normal]!;
                  itemProfile.widget = Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix,
                        child: AnimationWidget(
                          labelPlay: const [],
                          forceLabelPlay:
                              mapCompleted
                                  ? playLabelEvent.$2.first
                                  : playLabelEvent.$1.first,
                          visual: visual,
                          borderRect: itemRect,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix.multiplied(
                          Matrix4Transform()
                              .translate(
                                x: (visual.visualSize.width / 2) - textLength,
                                y: visual.visualSize.height / 4,
                              )
                              .m,
                        ),
                        child: DisplayText(
                          displayText: text,
                          fontSize: 65,
                          strokeWidth: 4,
                        ),
                      ),
                    ],
                  );
                  eventList[entry.key] = itemProfile;
                  break;
                }
              case LevelNodeType.minigame:
                {
                  final visual =
                      gameResource.commonAnimation[AnimationCommonType
                          .levelNodeMinigame]!;
                  /*
                  final itemRect = _makeEventRect(EventNodeType.minigame)!;
                  final selectRect = _makeRect(
                    itemRect.width,
                    itemRect.height,
                    top: itemRect.top,
                    left: itemRect.left,
                    viewPortScale: viewportScale,
                  );
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  itemProfile.matrix = matrix;
                  itemProfile.itemRect = itemRect;
                  itemProfile.selectRect = rect;
                  */
                  const itemRect = Rect.zero;
                  final text = event.displayText ?? '';
                  final textLength = text.length * 12;
                  final playLabelEvent =
                      isFirstLevel
                          ? eventAnimationLabel[EventNodeType.firstLevel]!
                          : eventAnimationLabel[EventNodeType.minigame]!;
                  itemProfile.widget = Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix,
                        child: AnimationWidget(
                          labelPlay: const [],
                          forceLabelPlay:
                              mapCompleted
                                  ? playLabelEvent.$2.first
                                  : playLabelEvent.$1.first,
                          visual: visual,
                          borderRect: itemRect,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix.multiplied(
                          Matrix4Transform()
                              .translate(
                                x: (visual.visualSize.width / 2) - textLength,
                                y: visual.visualSize.height / 4,
                              )
                              .m,
                        ),
                        child: DisplayText(
                          displayText: text,
                          fontSize: 65,
                          strokeWidth: 4,
                        ),
                      ),
                    ],
                  );
                  eventList[entry.key] = itemProfile;
                  break;
                }
              case LevelNodeType.miniboss:
                {
                  final visual =
                      gameResource.commonAnimation[AnimationCommonType
                          .levelNodeGargantuar]!;
                  /*
                  final itemRect = _makeEventRect(EventNodeType.miniboss)!;
                  final selectRect = _makeRect(
                    itemRect.width,
                    itemRect.height,
                    top: itemRect.top,
                    left: itemRect.left,
                    viewPortScale: viewportScale,
                  );
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  itemProfile.matrix = matrix;
                  itemProfile.itemRect = itemRect;
                  itemProfile.selectRect = rect;
                  */
                  const itemRect = Rect.zero;
                  final text = event.displayText ?? '';
                  final textLength = text.length * 12;
                  final playLabelEvent =
                      eventAnimationLabel[EventNodeType.miniboss]!;
                  itemProfile.widget = Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix,
                        child: AnimationWidget(
                          labelPlay: const [],
                          forceLabelPlay:
                              mapCompleted
                                  ? playLabelEvent.$2.first
                                  : playLabelEvent.$1.first,
                          visual: visual,
                          borderRect: itemRect,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix.multiplied(
                          Matrix4Transform()
                              .translate(
                                x: (visual.visualSize.width / 2) - textLength,
                                y: visual.visualSize.height / 4,
                              )
                              .m,
                        ),
                        child: DisplayText(
                          displayText: text,
                          fontSize: 65,
                          strokeWidth: 4,
                        ),
                      ),
                    ],
                  );
                  eventList[entry.key] = itemProfile;
                  break;
                }
              case LevelNodeType.nonfinalboss:
                {
                  final visual =
                      gameResource.commonAnimation[AnimationCommonType
                          .levelNodeGargantuar]!;
                  /*
                  final itemRect = _makeEventRect(EventNodeType.nonfinalboss)!;
                  final selectRect = _makeRect(
                    itemRect.width,
                    itemRect.height,
                    top: itemRect.top,
                    left: itemRect.left,
                    viewPortScale: viewportScale,
                  );
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  itemProfile.matrix = matrix;
                  itemProfile.itemRect = itemRect;
                  itemProfile.selectRect = rect;
                  */
                  const itemRect = Rect.zero;
                  final playLabelEvent =
                      eventAnimationLabel[EventNodeType.nonfinalboss]!;
                  itemProfile.widget = Transform(
                    alignment: Alignment.topLeft,
                    transform: matrix,
                    child: AnimationWidget(
                      labelPlay:
                          mapCompleted ? playLabelEvent.$2 : playLabelEvent.$1,
                      visual: visual,
                      borderRect: itemRect,
                      borderColor: Colors.blue,
                      borderWidth: editorSettingState.eventBorder ? 2.0 : 0,
                      filterQuality: filterQuality,
                      playSingleFrame: true,
                    ),
                  );
                  eventList[entry.key] = itemProfile;
                  break;
                }
              case LevelNodeType.boss:
                {
                  final visualHologram =
                      gameResource.commonAnimation[AnimationCommonType
                          .zombossNodeHologram]!;
                  final visualTop =
                      gameResource.commonAnimation[AnimationCommonType
                          .levelNodeGargantuar]!;
                  final visual =
                      resourceBloc.state.resourceAnimation[ResourceAnimationType
                          .zombossNode] ??
                      missingArtPieceAnimation;
                  final matrixTop = matrix.clone();
                  /*
                  final selectRect = _makeRect(
                    visualTop.visualSize.width,
                    visualTop.visualSize.height,
                    viewPortScale: viewportScale,
                  );
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  */
                  matrix.scale(
                    MapConst.animationResolution / MapConst.imageResolution,
                  );
                  matrix.translate(50.0, 40.0);
                  /*
                  itemProfile.matrix = matrixTop;
                  itemProfile.itemRect = _makeRect(
                      visualTop.visualSize.width, visualTop.visualSize.height);
                  itemProfile.selectRect = rect;
                  */
                  final playLabelZombossNode =
                      eventAnimationLabel[EventNodeType.boss]!;
                  final playLabelHologram =
                      eventAnimationLabel[EventNodeType.hologramBoss]!;
                  final playLabelEvent =
                      eventAnimationLabel[EventNodeType.miniboss]!;
                  itemProfile.widget = Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrixTop.multiplied(
                          Matrix4Transform().translate(y: -205).m,
                        ),
                        child: AnimationWidget(
                          labelPlay:
                              mapCompleted
                                  ? playLabelHologram.$2
                                  : playLabelHologram.$1,
                          visual: visualHologram,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrixTop,
                        child: AnimationWidget(
                          labelPlay: const [],
                          forceLabelPlay:
                              mapCompleted
                                  ? playLabelEvent.$2.first
                                  : playLabelEvent.$1.first,
                          visual: visualTop,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                    ],
                  );
                  final zombossNodeProfile = ItemProfile(isEvent: false);
                  zombossNodeProfile.itemRect = Rect.zero;
                  zombossNodeProfile.selectRect = Rect.zero;
                  zombossNodeProfile.matrix = matrix;
                  zombossNodeProfile.widget = Transform(
                    alignment: Alignment.topLeft,
                    transform: matrix,
                    child: AnimationWidget(
                      labelPlay:
                          mapCompleted
                              ? playLabelZombossNode.$2
                              : playLabelZombossNode.$1,
                      visual: visual,
                      borderColor: Colors.blue,
                      borderWidth: editorSettingState.eventBorder ? 2.0 : 0,
                      filterQuality: filterQuality,
                      playSingleFrame: true,
                    ),
                  );
                  pieceEventList[uuid.v4()] = zombossNodeProfile;
                  eventList[entry.key] = itemProfile;
                  containBossEvent = true;
                  break;
                }
              case LevelNodeType.danger:
                {
                  final visual =
                      resourceBloc.state.resourceAnimation[ResourceAnimationType
                          .dangerNode] ??
                      missingArtPieceAnimation;
                  /*
                  final selectRect = _makeRect(
                    visual.visualSize.width,
                    visual.visualSize.height,
                    viewPortScale: viewportScale,
                  );
                  final rect = MatrixUtils.transformRect(matrix, selectRect);
                  final isVisible = viewportRect.overlaps(rect);
                  if (!isVisible && !onSelectedList.contains(entry.key)) {
                    continue;
                  }
                  */
                  itemProfile.matrix = matrix;
                  /*
                  itemProfile.itemRect = _makeRect(
                      visual.visualSize.width, visual.visualSize.height);
                  itemProfile.selectRect = rect;
                  */
                  final text = event.displayText ?? '';
                  final textLength = text.length * 8;
                  final mapCompleted = editorSettingState.mapCompleted;
                  final dangerLevelImage =
                      resourceBloc.state.resourceImage[ResourceImageType
                          .dangerLevel] ??
                      missingArtPiece;
                  final playLabelEvent =
                      eventAnimationLabel[EventNodeType.danger]!;
                  itemProfile.widget = Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Transform(
                        alignment: Alignment.topLeft,
                        transform: matrix,
                        child: AnimationWidget(
                          labelPlay:
                              mapCompleted
                                  ? playLabelEvent.$2
                                  : playLabelEvent.$1,
                          visual: visual,
                          borderColor: Colors.blue,
                          borderWidth: 0,
                          filterQuality: filterQuality,
                          playSingleFrame: true,
                        ),
                      ),
                      if (mapCompleted)
                        ImageWidget(
                          image: dangerLevelImage,
                          matrix: matrix.multiplied(
                            Matrix4Transform()
                                .scale(
                                  MapConst.animationResolution /
                                      MapConst.imageResolution,
                                )
                                .translate(x: 145, y: 255)
                                .m,
                          ),
                          borderWidth: 0,
                          filterQuality: filterQuality,
                        ),
                      if (mapCompleted)
                        Transform(
                          alignment: Alignment.topLeft,
                          transform: matrix.multiplied(
                            Matrix4Transform()
                                .translate(
                                  x: (visual.visualSize.width / 2) - textLength,
                                  y: visual.visualSize.height / 8,
                                )
                                .m,
                          ),
                          child: DisplayText(
                            displayText: text,
                            fontSize: 45,
                            strokeWidth: 3,
                          ),
                        ),
                    ],
                  );
                  eventList[entry.key] = itemProfile;
                  break;
                }
            }
          }
      }
      final eventProperty = stageBloc.state.eventProperty;
      _updateItemProfile(itemProfile, eventProperty.status);
    }
    if (settingBloc.state.mapPath) {
      final events = stageBloc.state.events;
      final mapPathVisual =
          gameResource.commonAnimation[AnimationCommonType.mapPath]!;
      final playLabelEvent = eventAnimationLabel[EventNodeType.mapPath]!;
      for (final e in eventList.entries) {
        final parentEvent = events[e.key]!.parentEvent;
        if (parentEvent == '') {
          continue;
        }
        final targetKey = eventList.keys.firstWhere(
          (e) => parentEvent == events[e]!.name,
          orElse: () => 'null_parent_key',
        );
        if (events[targetKey] != null &&
            parentEvent == events[targetKey]!.name) {
          final startEvent = events[targetKey]!;
          final endEvent = events[e.key]!;
          final deltaX = endEvent.position.x - startEvent.position.x;
          final deltaY = endEvent.position.y - startEvent.position.y;
          final distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2));
          final scaleXFactor = distance / 65;
          final posXFactor =
              -(MapConst.animationSizeCenter *
                  scaleXFactor *
                  animationScaleRatio *
                  0.5);
          const posYFactor =
              -(MapConst.animationSizeCenter * animationScaleRatio * 0.5);
          final piecePosX =
              itemStartPositionX +
              startEvent.position.x +
              (deltaX / 2) +
              2 +
              posXFactor;
          final piecePosY =
              itemStartPositionY +
              startEvent.position.y +
              (deltaY / 2) +
              posYFactor;
          final angle = atan2(deltaY, deltaX);
          final matrix =
              Matrix4Transform()
                  .scale(animationScaleRatio)
                  .scaleBy(x: scaleXFactor)
                  .translate(x: piecePosX, y: piecePosY)
                  .m;
          final itemRect = MatrixUtils.transformRect(
            matrix,
            _makeRect(
              mapPathVisual.visualSize.width,
              mapPathVisual.visualSize.height,
              //viewPortScale: viewportScale,
            ),
          );
          final itemProfile = ItemProfile(isEvent: true);
          itemProfile.itemRect = Rect.zero;
          itemProfile.selectRect = Rect.zero;
          itemProfile.matrix = matrix;
          itemProfile.widget = Transform.rotate(
            alignment: Alignment.topLeft,
            origin: itemRect.center,
            angle: angle,
            child: Transform(
              alignment: Alignment.topLeft,
              transform: matrix,
              child: AnimationWidget(
                labelPlay: mapCompleted ? playLabelEvent.$2 : playLabelEvent.$1,
                visual: mapPathVisual,
                borderWidth: 0,
                filterQuality: filterQuality,
                playSingleFrame: true,
              ),
            ),
          );
          mapPathList[uuid.v4()] = itemProfile;
        }
      }
    }
  }

  List<Widget> itemStoreStaticUpdate() {
    final stageState = stageBloc.state;
    final pieceList = SplayTreeMap<int, ItemStore>();
    final parallaxBottomList = SplayTreeMap<int, ItemStore>((a, b) => b - a);
    final parallaxTopList = SplayTreeMap<int, ItemStore>((a, b) => b - a);
    final ItemStore pieceEventList = {};
    final ItemStore mapPathList = {};
    final ItemStore eventList = {};
    final sortedEntries =
        stageState.pieces.entries.toList()
          ..sort((a, b) => a.value.position.y.compareTo(b.value.position.y));

    final itemStartPositionX = -stageState.boundingRect.x.toDouble();
    final itemStartPositionY = -stageState.boundingRect.y.toDouble();
    _updatePiecesStatic(
      itemStartPositionX: itemStartPositionX,
      itemStartPositionY: itemStartPositionY,
      sortedEntries: sortedEntries,
      pieceList: pieceList,
      parallaxBottomList: parallaxBottomList,
      parallaxTopList: parallaxTopList,
    );

    final eventSortedEntries =
        stageState.events.entries.toList()
          ..sort((a, b) => b.value.position.x.compareTo(a.value.position.x));
    _updateEventsStatic(
      itemStartPositionX: itemStartPositionX,
      itemStartPositionY: itemStartPositionY,
      eventSortedEntries: eventSortedEntries,
      pieceEventList: pieceEventList,
      mapPathList: mapPathList,
      eventList: eventList,
    );
    final ItemStore stackList = {};
    parallaxBottomList.values.forEach(stackList.addAll);
    pieceList.values.forEach(stackList.addAll);
    stackList.addAll(pieceEventList);
    parallaxTopList.values.forEach(stackList.addAll);
    if (settingBloc.state.mapPath) {
      stackList.addAll(mapPathList);
    }
    stackList.addAll(eventList);
    final list = <Widget>[];
    for (final e in stackList.values) {
      if (e.widget != null) {
        list.add(e.widget!);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: itemStoreStaticUpdate());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ResourceBloc>('resourceBloc', resourceBloc),
    );
    properties.add(DiagnosticsProperty<StageBloc>('stageBloc', stageBloc));
    properties.add(
      DiagnosticsProperty<SettingBloc>('settingBloc', settingBloc),
    );
    properties.add(
      DiagnosticsProperty<MapEditorConfigurationCubit>('cubit', cubit),
    );
  }
}
