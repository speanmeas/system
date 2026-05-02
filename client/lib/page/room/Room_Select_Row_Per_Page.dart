import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Row_Per_Page());
}

class Room_Select_Row_Per_Page extends StatelessWidget {
  Room_Select_Row_Per_Page({super.key});

  dynamic input = {
    'rowPerPage': 10,
    'rowOptions': [10, 25, 50, 100],
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
  Room_Select_Row_Per_Page_({
    super.key, //
    required this.input,
  });

  dynamic input;

  @override
  State<Room_Select_Row_Per_Page_> createState() => _Room_Select_Row_Per_Page_State();
}

class _Room_Select_Row_Per_Page_State extends State<Room_Select_Row_Per_Page_> {
  //
  //

  late dynamic output;

  @override
  void initState() {
    super.initState();
    output = Map.from(widget.input);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(4),
      title: Row(
        children: [
          Spacer(),
          Text(
            "Select Rows/Page", //
            style: TextStyle(
              fontSize: 16, //
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          OutlinedButton.icon(
            icon: Icon(Icons.save_outlined),
            label: Text("Save"),
            onPressed: () {
              //
              print(output);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: output['rowOptions'].length,
          itemBuilder: (context, index) {
            final value = output['rowOptions'][index] as int;
            final isSelected = value == output['rowPerPage'];

            return InkWell(
              onTap: () {
                setState(() {
                  output['rowPerPage'] = value;
                });
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                // decoration: BoxDecoration(color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check : null, //
                      // color: isSelected ? Theme.of(context).primaryColor : null,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value.toString(), //
                        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
