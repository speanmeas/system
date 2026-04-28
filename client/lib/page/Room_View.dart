import 'package:flutter/material.dart';
import 'package:speanmeas/page/Room_Edit.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_View());
}

class Room_View extends StatelessWidget {
  Room_View({super.key});

  Map<String, dynamic> data = {
    "Room No.": "101", //
    "Type": "Single", //
    "Fan/AC": "AC", //
    "Meal": "Breakfast", //
    "Capacity": 1, //
    "Price": 100, //
    "Status": "Available", //
    "Contact": "123456789",
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_View_(data: data),
    );
  }
}

class Room_View_ extends StatefulWidget {
  Room_View_({super.key, required this.data});

  Map<String, dynamic> data;

  @override
  State<Room_View_> createState() => _Room_View_State();
}

class _Room_View_State extends State<Room_View_> {
  //
  //

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Room"), //
        toolbarHeight: 40,
        titleSpacing: 0,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.close), //
            label: const Text('Close'), //
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200, //
              width: 200,
              child: Placeholder(),
            ),

            const SizedBox(height: 4), //
            for (final entry in widget.data.entries)
              Container(
                width: 600,
                padding: const EdgeInsets.all(4),
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: entry.value.toString()),
                  decoration: InputDecoration(labelText: entry.key, border: const OutlineInputBorder()),
                ),
              ),

            //
            Row(),
          ],
        ),
      ),
    );
  }
}
