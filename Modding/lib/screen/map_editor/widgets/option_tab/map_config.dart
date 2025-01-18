import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen/cubit/map_editor_configuration_cubit/map_editor_configuration_cubit.dart';
import 'package:sen/screen/map_editor/app/l10n/l10n.dart';
import 'package:sen/screen/map_editor/bloc/history/history_bloc.dart';
import 'package:sen/screen/map_editor/bloc/item/item_bloc.dart';
import 'package:sen/screen/map_editor/bloc/layer/layer_bloc.dart';
import 'package:sen/screen/map_editor/bloc/stage/stage_bloc.dart';
import 'package:sen/screen/map_editor/include/dropdown_button_field.dart';
import 'package:sen/screen/map_editor/include/number_text_field.dart';
import 'package:sen/screen/map_editor/include/readonly_box_field.dart';
import 'package:sen/screen/map_editor/include/text_string_field.dart';
import 'package:sen/screen/map_editor/models/action_model.dart';
import 'package:sen/screen/map_editor/models/action_service.dart';
import 'package:sen/screen/map_editor/models/map_const.dart';

class MapConfigTab extends StatelessWidget {
  const MapConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    final los = context.los;
    final stageBloc = context.read<StageBloc>();
    final itemBloc = context.read<ItemBloc>();
    final historyBloc = context.read<HistoryBloc>();

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: Theme.of(context).colorScheme.secondaryContainer,
          margin: const EdgeInsets.all(8),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: Center(
                child: Text(
              los.map_settings,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
        ),
        BlocBuilder<StageBloc, StageState>(builder: (context, state) {
          final boundingRect = state.boundingRect;
          final worldResourceList = context
              .read<MapEditorConfigurationCubit>()
              .state
              .gameResource
              .uiUniverse
              .keys
              .toList()
            ..sort((a, b) {
              if (a == 'none') {
                return -1;
              }
              return a.compareTo(b);
            });
          return Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                          width: 90,
                          child: ReadonlyBoxField(
                              label: los.width,
                              value: boundingRect.width.toString())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                          width: 90,
                          child: ReadonlyBoxField(
                              label: los.height,
                              value: boundingRect.height.toString())),
                    )
                  ]),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                          width: 90,
                          child: ReadonlyBoxField(
                              label: los.position_x,
                              value: boundingRect.x.toString())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                          width: 90,
                          child: ReadonlyBoxField(
                              label: los.position_y,
                              value: boundingRect.y.toString())),
                    ),
                  ]),
                  Row(children: [
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 90,
                          child: NumberTextField(
                            label: los.world_id,
                            controller: NumberEditingController(
                                value: state.worldId, isDouble: false),
                            range: const Range(
                                begin: 0, end: MapConst.intMaxValue),
                            useChangeButton: true,
                            onFieldSubmitted: (value) {
                              stageBloc.add(SetWorldId(worldId: value as int));
                              final actionService =
                                  ActionService<ActionModelType>(
                                      actionType: ActionType.mapChangeWorldID,
                                      data: {
                                        ActionModelType.int: value,
                                      },
                                      change: (data) {
                                        stageBloc.add(UpdateMapInformation(
                                          worldId: (data![ActionModelType.int]
                                              as int),
                                        ));
                                        itemBloc.add(const ItemStoreUpdated());
                                      });
                              historyBloc
                                  .add(CaptureState(state: actionService));
                            },
                          ),
                        )),
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 90,
                          child: NumberTextField(
                            label: los.res_id,
                            controller: NumberEditingController(
                                value: state.resGroupId, isDouble: false),
                            range: const Range(
                                begin: 0, end: MapConst.intMaxValue),
                            useChangeButton: true,
                            onFieldSubmitted: (value) {
                              stageBloc.add(SetResGroupId(resId: value as int));
                              final actionService =
                                  ActionService<ActionModelType>(
                                      actionType: ActionType.mapChangeResID,
                                      data: {
                                        ActionModelType.int: value,
                                      },
                                      change: (data) {
                                        stageBloc.add(UpdateMapInformation(
                                          resId: (data![ActionModelType.int]
                                              as int),
                                        ));
                                        itemBloc.add(const ItemStoreUpdated());
                                      });
                              historyBloc
                                  .add(CaptureState(state: actionService));
                            },
                          ),
                        )),
                  ]),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                      child: SizedBox(
                          width: double.infinity,
                          child: TextStringField(
                              label: 'World Name', //TODO: add locale
                              value: state.worldName,
                              onFieldSubmitted: (value) {
                                stageBloc.add(SetWorldName(worldName: value));
                                final actionService =
                                    ActionService<ActionModelType>(
                                        actionType: ActionType.mapChangeName,
                                        data: {
                                          ActionModelType.string: value,
                                        },
                                        change: (data) {
                                          stageBloc.add(UpdateMapInformation(
                                            worldName:
                                                (data![ActionModelType.string]
                                                    as String),
                                          ));
                                          itemBloc
                                              .add(const ItemStoreUpdated());
                                        });
                                historyBloc
                                    .add(CaptureState(state: actionService));
                              },
                              autovalidateMode: AutovalidateMode.always,
                              validator: (value) {
                                if (value != state.worldName) {
                                  return 'Enter to save'; //TODO: add locale
                                }
                                return null;
                              }))),
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 12, left: 12),
                          child: SizedBox(
                            width: 60,
                            child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: state.worldResource == 'none'
                                    ? const SizedBox()
                                    : RawImage(
                                        image: context
                                            .read<MapEditorConfigurationCubit>()
                                            .state
                                            .gameResource
                                            .uiUniverse[state.worldResource],
                                      )),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                          child: SizedBox(
                            width: 132,
                            child: DropdownButtonField<String>(
                              label: 'World Resource', // TODO : Localize
                              value: state.worldResource,
                              items: worldResourceList
                                  .map((e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<StageBloc>().add(
                                      ChangeResouceWorldEvent(
                                          worldResource: value,
                                          itemBloc: itemBloc,
                                          layerBloc: context.read<LayerBloc>(),
                                          stageBloc: stageBloc));
                                }
                              },
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        })
      ],
    );
  }
}
