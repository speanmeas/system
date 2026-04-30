import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Row_Per_Page());
}

class Room_Select_Row_Per_Page extends StatelessWidget {
  Room_Select_Row_Per_Page({super.key});

  dynamic input = {
    "total": 10000, //
    "selected": 10, //
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Select_Row_Per_Page_(input: input),
    );
  }
}

class Room_Select_Row_Per_Page_ extends StatefulWidget {
  Room_Select_Row_Per_Page_({super.key, required this.input});

  final dynamic input;

  @override
  State<Room_Select_Row_Per_Page_> createState() => _Room_Select_Row_Per_Page_State();
}

class _Room_Select_Row_Per_Page_State extends State<Room_Select_Row_Per_Page_> {
  //
  //

  dynamic output;

  @override
  Widget build(BuildContext context) {
    final options = widget.input["options"] ?? [10, 25, 50, 100];
    final selected = widget.input["selected"] ?? 10;

    return AlertDialog(
      title: Center(
        child: Text("Select Rows/Page", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      content: SizedBox(
        width: 600,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option == selected;
            return ListTile(
              title: Text(option.toString()),
              leading: isSelected ? Icon(Icons.check, color: Colors.blue) : SizedBox(width: 24),
              onTap: () {
                setState(() {
                  widget.input["selected"] = option;
                });
                Navigator.of(context).pop(option);
              },
            );
          },
        ),
      ),
    );
  }
}
