import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Row_Per_Page());
}

class Room_Select_Row_Per_Page extends StatelessWidget {
  Room_Select_Row_Per_Page({super.key});

  dynamic input = {
    "options": [10, 25, 50, 100],
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

  late dynamic output = widget.input;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
      titlePadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
      title: Row(
        children: [
          Spacer(),
          Text("Select Rows/Page", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close, color: Colors.red),
          ),
          // IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),

      content: SizedBox(
        width: 600,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: output["options"].length,
          itemBuilder: (context, index) {
            final option = output["options"][index];
            final isSelected = option == output["selected"];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.toString()),
              leading: isSelected ? Icon(Icons.check, color: Colors.blue) : SizedBox(width: 24),
              onTap: () {
                setState(() {
                  output["selected"] = option;
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
