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

  final dynamic input;

  @override
  State<Room_Select_Row_Per_Page_> createState() => _Room_Select_Row_Per_Page_State();
}

class _Room_Select_Row_Per_Page_State extends State<Room_Select_Row_Per_Page_> {
  //
  //

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(4),
      title: const Row(
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
          CloseButton(color: Colors.red),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.input['rowOptions'].length,
          itemBuilder: (context, index) {
            final value = widget.input['rowOptions'][index] as int;
            final isSelected = value == widget.input['rowPerPage'];

            return InkWell(
              onTap: () {
                setState(() {
                  widget.input['rowPerPage'] = value;
                });
                // Add small delay to show the tick before closing
                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.of(context).pop(widget.input);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.check : null, color: isSelected ? Theme.of(context).primaryColor : null, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(value.toString(), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
