import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen/i18n/app_localizations.dart';
import 'package:sen/cubit/settings_cubit/settings_cubit.dart';

class JavaScriptCategoryConfiguration extends StatelessWidget {
  const JavaScriptCategoryConfiguration({super.key});

  void _onChangeDialog(bool value, BuildContext context) {
    BlocProvider.of<SettingsCubit>(context).setShowConfirmDialog(value);
  }

  void _onChangeLauncher(bool value, BuildContext context) {
    BlocProvider.of<SettingsCubit>(context).setRunAsLauncher(value);
  }

  @override
  Widget build(BuildContext context) {
    final los = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsCubit>().state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            los.show_confirm_dialog,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            los.show_confirm_dialog_description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          value: settingsState.jsShowConfirmDialog,
          onChanged: (value) => _onChangeDialog(value, context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            los.run_as_launcher,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            los.run_as_launcher_description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          value: settingsState.jsRunAsLauncher,
          onChanged: (value) => _onChangeLauncher(value, context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ],
    );
  }
}
