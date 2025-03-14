import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../extension/context.dart';

class IdleBar extends StatelessWidget {
  const IdleBar({super.key, required this.onLaunch});

  final void Function() onLaunch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 46.0,
        width: double.infinity,
        child: FloatingActionButton(
          onPressed: onLaunch,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10.0,
            children: [
              const Icon(Symbols.play_arrow),
              Text(context.los.launch_immediately),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<void Function()>.has('onLaunch', onLaunch),
    );
  }
}
