import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:sen/model/worldmap.dart';
import 'package:sen/cubit/map_editor_configuration_cubit/map_editor_configuration_cubit.dart';
import 'package:sen/screen/map_editor/bloc/canvas/canvas_bloc.dart';
import 'package:sen/screen/map_editor/bloc/item/item_bloc.dart';
import 'package:sen/screen/map_editor/bloc/stage/stage_bloc.dart';
import 'package:sen/screen/map_editor/bloc/ticker/ticker_bloc.dart';
import 'package:sen/screen/map_editor/include/painter.dart';
import 'package:sen/screen/map_editor/include/rectangle_box.dart';
import 'package:sen/screen/map_editor/models/config.dart';
import 'package:sen/screen/map_editor/models/game_resource.dart';
import 'package:sen/screen/map_editor/models/map_const.dart';

class BoxStage extends StatelessWidget {
  const BoxStage(
      {super.key,
      required this.mapGrid,
      required this.usePanTool,
      required this.useResizeTool,
      this.boundBackground = BorderBackground.color,
      this.boxStageColor = Colors.black,
      required this.children});

  final bool usePanTool;

  final bool useResizeTool;

  final bool mapGrid;

  final BorderBackground boundBackground;

  final Color boxStageColor;

  final List<Widget> children;

  Widget _resizeBox(BuildContext context) {
    const startPositionX = MapConst.safeAdditionalWidth / 2;
    const startPositionY = MapConst.safeAdditionalHeight / 2;
    final boundingRect = context.read<StageBloc>().state.boundingRect;
    return RectangleBox(
        minWidth: MapConst.minBoundingWidth.toDouble(),
        minHeight: MapConst.minBoundingHeight.toDouble(),
        boundingRect: Rect.fromLTWH(
            startPositionX - 4,
            startPositionY - 4,
            boundingRect.width.toDouble() + 8,
            boundingRect.height.toDouble() + 8),
        onScalingEnd: (updateRect) {
          final newX = boundingRect.x + (updateRect.left - startPositionX);
          final newY = boundingRect.y + (updateRect.top - startPositionY);
          final bound = BoundingRect(
            x: newX.round(),
            y: newY.round(),
            width: updateRect.width.round() - 8,
            height: updateRect.height.round() - 8,
          );
          context
              .read<StageBloc>()
              .add(UpdateBoundingRect(boundingRect: bound));
          context.read<ItemBloc>().add(const ItemStoreUpdated());
        });
  }

  @override
  Widget build(BuildContext context) {
    final transformationController = context
        .read<CanvasBloc>()
        .state
        .canvasController
        .transformationController;
    final stage = mapGrid
        ? GridPaper(
            interval: 200,
            divisions: 1,
            subdivisions: 5,
            child: InteractiveViewer.builder(
                panEnabled: usePanTool,
                scaleEnabled: usePanTool,
                minScale: 0.5,
                maxScale: 3,
                scaleFactor: 800,
                transformationController: transformationController,
                builder: (context, quad) {
                  final child = OverlayWithRectangleClipping(
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: children,
                    ),
                  );
                  if (useResizeTool) {
                    return Stack(
                      children: [
                        child,
                        _resizeBox(context),
                      ],
                    );
                  } else {
                    return child;
                  }
                }))
        : InteractiveViewer.builder(
            panEnabled: usePanTool,
            scaleEnabled: usePanTool,
            minScale: 0.5,
            maxScale: 3,
            scaleFactor: 800,
            transformationController: transformationController,
            builder: (context, quad) {
              final child = OverlayWithRectangleClipping(
                child: Stack(
                  fit: StackFit.passthrough,
                  children: children,
                ),
              );
              if (useResizeTool) {
                return Stack(
                  children: [
                    child,
                    _resizeBox(context),
                  ],
                );
              } else {
                return child;
              }
            });
    switch (boundBackground) {
      case BorderBackground.timeSpace:
        {
          final mainState = context.read<MapEditorConfigurationCubit>().state;
          final spaceSpiral =
              mainState.gameResource.commonImage[ImageCommonType.spaceSpiral]!;
          final spaceDust =
              mainState.gameResource.commonImage[ImageCommonType.spaceDust]!;
          return ColoredBox(
              color: boxStageColor,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  RotaionWidget(
                      rotationRate: 0.05,
                      scale: 1.9,
                      child: RawImage(
                        image: spaceSpiral,
                        fit: BoxFit.cover,
                      )),
                  RawImage(
                    image: spaceDust,
                    fit: BoxFit.cover,
                  ),
                  Column(children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black,
                                Colors.black54,
                                Colors.transparent
                              ],
                              stops: [0.4, 0.7, 0.9],
                              tileMode: TileMode.decal),
                        ),
                      ),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                Colors.black54,
                                Colors.transparent
                              ],
                              stops: [0.4, 0.7, 0.8],
                              tileMode: TileMode.decal),
                        ),
                      ),
                    )
                  ]),
                  stage,
                ],
              ));
        }
      case BorderBackground.senLogo:
        {
          final senLogo = context
              .read<MapEditorConfigurationCubit>()
              .state
              .editorResource
              .senLogo;
          return ColoredBox(
              color: boxStageColor,
              child: Stack(
                fit: StackFit.passthrough,
                children: [senLogo, stage],
              ));
        }
      default:
        {
          return ColoredBox(color: boxStageColor, child: stage);
        }
    }
  }
}

class OverlayWithRectangleClipping extends StatelessWidget {
  const OverlayWithRectangleClipping({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final boundingRect = BlocProvider.of<StageBloc>(context).state.boundingRect;
    final maxBoundWidth = MapConst.safeAdditionalWidth + boundingRect.width;
    final maxBoundHeight = MapConst.safeAdditionalHeight + boundingRect.height;
    final innerRect = Rect.fromLTWH(
        MapConst.safeAdditionalWidth / 2,
        MapConst.safeAdditionalHeight / 2,
        boundingRect.width.toDouble(),
        boundingRect.height.toDouble());
    final outlineRect =
        Rect.fromLTWH(0, 0, maxBoundWidth * 2, maxBoundHeight * 2);
    return SizedBox(
      width: maxBoundWidth.toDouble(),
      height: maxBoundHeight.toDouble(),
      child: CustomPaint(
          foregroundPainter:
              RectanglePainter(innerRect: innerRect, outlineRect: outlineRect),
          child: Stack(fit: StackFit.passthrough, children: [child])),
    );
  }
}

class RotaionWidget extends StatelessWidget {
  const RotaionWidget(
      {super.key,
      required this.scale,
      required this.rotationRate,
      required this.child});

  final Widget child;

  final double rotationRate;

  final double scale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickerBloc, TickerState>(
      builder: (context, state) {
        final rotateDeg = (state.tick * rotationRate * 1.7) % 360;
        return Transform(
            alignment: Alignment.center,
            transform: Matrix4Transform()
                .scale(scale)
                .rotateDegrees(
                  -rotateDeg,
                )
                .m,
            child: child);
      },
    );
  }
}
