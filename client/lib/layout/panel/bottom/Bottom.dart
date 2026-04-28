import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:speanmeas/layout/Variable.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Variable(), //
      child: const Panel_Bottom(),
    ),
  );
}

class Panel_Bottom extends StatelessWidget {
  const Panel_Bottom({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(body: const Panel_Bottom_()),
    );
  }
}

class Panel_Bottom_ extends StatefulWidget {
  const Panel_Bottom_({super.key});

  @override
  State<Panel_Bottom_> createState() => _Panel_Bottom_State();
}

class _Panel_Bottom_State extends State<Panel_Bottom_> {
  String VERSION = '0.0.0+0';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final info = await PackageInfo.fromPlatform();
    VERSION = '${info.version}+${info.buildNumber}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final v = context.watch<Variable>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, //
      children: [
        SizedBox(width: 16),
        // Text("MUY Sengly - 011358858"), //
        // Spacer(),
        Text("Version: $VERSION"),
        Spacer(),
        Text("Copyright © 2026"), //
        SizedBox(width: 16),
      ],
    );
  }
}
