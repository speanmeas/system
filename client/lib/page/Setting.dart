import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(const Setting());
}

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setting',
      theme: Theme_Data(),
      home: Scaffold(body: const Setting_()),
    );
  }
}

class Setting_ extends StatefulWidget {
  const Setting_({super.key});

  @override
  State<Setting_> createState() => _Setting_State();
}

class _Setting_State extends State<Setting_> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Setting"), //
      ],
    );
  }
}
