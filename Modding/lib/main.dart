import 'package:flutter/material.dart';
import 'package:modding/model/theme.dart';
import 'package:modding/provider/filter_provider.dart';
import 'package:modding/provider/log_provider.dart';
import 'package:modding/provider/manifest_provider.dart';
import 'package:modding/provider/recent_provider.dart';
import 'package:modding/provider/setting_provider.dart';
import 'package:modding/screen/root_screen.dart';
import 'package:provider/provider.dart';
import 'package:modding/provider/item_provider.dart';

Future<void> main(
  List<String> arguments,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ItemProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LogProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => FilterProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => RecentProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ManifestProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => SettingProvider(),
      ),
    ],
    child: const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sen: Modding Environment',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<SettingProvider>(context).themeData,
      home: const RootScreen(title: 'Sen: Modding Environment'),
    );
  }
}
