import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Edit());
}

class Room_Edit extends StatelessWidget {
  Room_Edit({super.key});

  Map<String, String> input = {
    "Room No.": "101", //
    "Type": "Single", //
    "Fan/AC": "AC", //
    "Meal": "Breakfast", //
    "Capacity": "1", //
    "Price": "100", //
    "Status": "Available", //
    "Contact": "123456789",
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Edit_(input: input),
    );
  }
}

class Room_Edit_ extends StatefulWidget {
  Room_Edit_({super.key, required this.input});

  Map<String, String> input;

  @override
  State<Room_Edit_> createState() => _Room_Edit_State();
}

class _Room_Edit_State extends State<Room_Edit_> {
  //
  //

  late List<String> all_key = widget.input.keys.toList();

  late Map<String, String> output = Map.from(widget.input);

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Room"), //
        toolbarHeight: 40,
        titleSpacing: 0,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.save_outlined, color: Colors.blue),
            label: const Text("Save"),
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
            SizedBox(height: 4),
            for (final key in all_key)
              Container(
                width: 600,
                padding: const EdgeInsets.all(4),
                child: Autocomplete<String>(
                  optionsMaxHeight: 210,
                  optionsViewOpenDirection: OptionsViewOpenDirection.down,
                  optionsBuilder: (v) {
                    final options = auto_correct[key] ?? const <String>[];
                    if (v.text.isEmpty) return options;
                    return options.where((t) => t.toLowerCase().contains(v.text.toLowerCase()));
                  },
                  onSelected: (String value) {
                    output[key] = value;
                    setState(() {});
                  },
                  fieldViewBuilder: (c, t, f, o) {
                    if (t.text.isEmpty) {
                      final init = output[key]?.toString() ?? "";
                      t.value = TextEditingValue(
                        text: init,
                        selection: TextSelection.collapsed(offset: init.length),
                      );
                    }

                    return TextField(
                      controller: t,
                      focusNode: f,
                      onChanged: (value) => output[key] = value,
                      decoration: InputDecoration(
                        labelText: key, //
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 4),

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
