import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Column_Visibility());
}

class Room_Select_Column_Visibility extends StatelessWidget {
  Room_Select_Column_Visibility({super.key});

  // dynamic input = {
  //   'rowPerPage': 10,
  //   'rowOptions': [10, 25, 50, 100],
  // };

  dynamic input = [
    {"key": "_id", "label": "ID", "visible": false},
    {"key": "room_number", "label": "Room No.", "visible": true},
    {"key": "room_type", "label": "Room Type", "visible": true},
    // {"key": "ac_or_fan", "label": "Fan/AC", "visible": true},
    {"key": "capacity", "label": "Capacity", "visible": true},
    {"key": "price", "label": "Price", "visible": true},
    {"key": "status", "label": "Status", "visible": true},
    // {"key": "image_1", "label": "Image 1", "visible": false},
    // {"key": "image_2", "label": "Image 2", "visible": false},
    {"key": "created_at", "label": "Created At", "visible": false},
    {"key": "updated_at", "label": "Updated At", "visible": false},
    {"key": "deleted_at", "label": "Deleted At", "visible": false},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Select_Column_Visibility_(input: input),
    );
  }
}

class Room_Select_Column_Visibility_ extends StatefulWidget {
  Room_Select_Column_Visibility_({
    super.key, //
    required this.input,
  });

  dynamic input;

  @override
  State<Room_Select_Column_Visibility_> createState() => _Room_Select_Column_Visibility_State();
}

class _Room_Select_Column_Visibility_State extends State<Room_Select_Column_Visibility_> {
  //
  //

  late dynamic output;

  @override
  void initState() {
    super.initState();
    output = List.from(widget.input);
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
            "Select Column Visibility", //
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
        child: ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          padding: EdgeInsets.zero,
          itemCount: output.length,
          onReorder: (int oldIndex, int newIndex) {
            print("Reorder: $oldIndex -> $newIndex");
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = output.removeAt(oldIndex);
              output.insert(newIndex.clamp(0, output.length), item);
            });
          },

          itemBuilder: (context, index) {
            return InkWell(
              key: ValueKey(index),
              onTap: () {
                print("Tapped: ${output[index]['label']}");
                setState(() {
                  output[index]['visible'] = !output[index]['visible'];
                });
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Row(
                  children: [
                    //
                    if (output[index]['visible'])
                      Icon(Icons.check_box_outlined) //
                    else
                      Icon(Icons.check_box_outline_blank), //
                    //
                    SizedBox(width: 8),
                    Text("${output[index]['label']}"),

                    Spacer(),

                    //
                    ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.drag_indicator), //
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
