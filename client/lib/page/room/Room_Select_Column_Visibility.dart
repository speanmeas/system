import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Column_View());
}

class Room_Select_Column_View extends StatelessWidget {
  const Room_Select_Column_View({super.key});

  static final List<Map<String, dynamic>> _demoInput = [
    {"key": "_id", "label": "ID", "visible": false},
    {"key": "room_number", "label": "Room No.", "visible": true},
    {"key": "room_type", "label": "Room Type", "visible": true},
    {"key": "capacity", "label": "Capacity", "visible": true},
    {"key": "price", "label": "Price", "visible": true},
    {"key": "status", "label": "Status", "visible": true},
    {"key": "created_at", "label": "Created At", "visible": true},
    {"key": "updated_at", "label": "Updated At", "visible": false},
    {"key": "deleted_at", "label": "Deleted At", "visible": false},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: Room_Select_Column_View_(input: _demoInput),
    );
  }
}

class Room_Select_Column_View_ extends StatefulWidget {
  const Room_Select_Column_View_({super.key, required this.input});

  final List<Map<String, dynamic>> input;

  @override
  State<Room_Select_Column_View_> createState() => _Room_Select_Column_View_State();
}

class _Room_Select_Column_View_State extends State<Room_Select_Column_View_> {
  static const Set<String> _hiddenKeys = {"_id", "created_at", "updated_at", "deleted_at"};

  late List<Map<String, dynamic>> _headers;

  @override
  void initState() {
    super.initState();
    _headers = List<Map<String, dynamic>>.from(widget.input.map((e) => Map<String, dynamic>.from(e)));
  }

  @override
  Widget build(BuildContext context) {
    final visibleHeaders = _headers.where((h) => !_hiddenKeys.contains(h["key"])).toList();

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(4),
      title: Row(
        children: [
          const Spacer(),
          const Text("Select Column Visibility", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(_headers),
            icon: const Icon(Icons.check, color: Colors.green),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: visibleHeaders.length,
          itemBuilder: (context, index) {
            final header = visibleHeaders[index];
            return CheckboxListTile(
              checkboxScaleFactor: 1.2,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(header["label"]),
              value: header["visible"] as bool?,
              onChanged: (value) {
                setState(() {
                  header["visible"] = value;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
