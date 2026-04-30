import 'package:flutter/material.dart';
import 'package:speanmeas/page/room/Room_Edit.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Column());
}

class Room_Column extends StatelessWidget {
  Room_Column({super.key});

  Map<String, bool> input = {
    'Room No.': true, //
    'Type': true, //
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Column_(input: input),
    );
  }
}

class Room_Column_ extends StatefulWidget {
  Room_Column_({super.key, required this.input});

  final Map<String, bool> input;

  @override
  State<Room_Column_> createState() => _Room_Column_State();
}

class _Room_Column_State extends State<Room_Column_> {
  //
  //

  late Map<String, bool> output = Map.from(widget.input);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room Filter"), //
        toolbarHeight: 40,
        titleSpacing: 0,

        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.check_circle_outline), //
            label: const Text('Okay'), //
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context, output);
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (final key in output.keys.toList())
              Container(
                width: 600,
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(key),
                  value: output[key] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      output[key] = value ?? false;
                    });
                  },
                ),
              ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined), //
                  label: const Text('Cancel'), //
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
