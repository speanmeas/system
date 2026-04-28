import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Add());
}

class Room_Add extends StatelessWidget {
  Room_Add({super.key});

  List<String> input = [
    "Room No.", //
    "Type", //
    "Fan/AC", //
    "Meal", //
    "Capacity", //
    "Price", //
    "Status", //
    "Contact",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Add_(input: input),
    );
  }
}

class Room_Add_ extends StatefulWidget {
  Room_Add_({super.key, required this.input});

  final List<String> input;

  @override
  State<Room_Add_> createState() => _Room_Add_State();
}

class _Room_Add_State extends State<Room_Add_> {
  //
  //

  late Map<String, String> output = Map.fromEntries(widget.input.map((key) => MapEntry(key, "")));

  Map<String, List<String>> auto_correct = {
    "Room No.": ["101", "102", "103", "104", "105", "201", "202", "203", "204", "205"],
    "Type": ["Single", "Double", "Suite", "Deluxe", "Executive", "Family", "Twin", "King", "Queen", "Studio", "Presidential", "Connecting", "Accessible"],
    "Fan/AC": ["AC", "Fan"],
    "Meal": ["Breakfast", "Lunch", "Dinner"],
    "Capacity": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
    "Price": ["100", "200", "300", "400", "500", "600", "700", "800", "900", "1000"],
    "Status": ["Available", "Occupied", "Maintenance"],
    "Contact": ["123456789", "987654321", "555555555"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Room"), //
        toolbarHeight: 40,
        titleSpacing: 0,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.save, color: Colors.blue),
            label: const Text("Save"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.pop(context, output);
            },
          ),
          SizedBox(width: 8), //
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4), //

            for (final key in widget.input)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(4),
                  child: Autocomplete<String>(
                    optionsMaxHeight: 210,
                    initialValue: TextEditingValue(text: output[key] ?? ""),
                    optionsViewOpenDirection: OptionsViewOpenDirection.down,
                    optionsBuilder: (v) {
                      final options = auto_correct[key] ?? const <String>[];
                      if (v.text.isEmpty) return options;
                      return options.where((t) => t.toLowerCase().contains(v.text.toLowerCase()));
                    },
                    onSelected: (value) => output[key] = value,
                    fieldViewBuilder: (context, controller, focusNode, _) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) => output[key] = value,
                        decoration: InputDecoration(labelText: key, floatingLabelBehavior: FloatingLabelBehavior.always, suffixIcon: const Icon(Icons.arrow_drop_down)),
                      );
                    },
                  ),
                ),
              ),

            SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height - 100),
          ],
        ),
      ),
    );
  }
}
