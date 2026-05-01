import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/Environment.dart';

import 'package:speanmeas/utility/Dio.dart';
import 'package:speanmeas/utility/Secure_Storage.dart';

import 'package:speanmeas/page/room/Room_Add.dart';
// import 'package:speanmeas/page/room/xRoom_Select_Column_Visibility.dart';
import 'package:speanmeas/page/room/Room_Edit.dart';
import 'package:speanmeas/page/room/Room_View.dart';
import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(const Room());
}

class Room extends StatelessWidget {
  const Room({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room', //
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: const Room_(),
    );
  }
}

class Room_ extends StatefulWidget {
  const Room_({super.key});

  @override
  State<Room_> createState() => _Room_State();
}

class _Room_State extends State<Room_> {
  //
  //

  bool is_admin = true;
  double column_width = 120.0;

  bool is_search = false;

  // this header
  List<Map<String, dynamic>> headers = [
    {"key": "_id", "label": "ID", "visible": true},
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

  List<Map<String, dynamic>> data = [];

  String query = "";
  String sort_by = "created_at";
  int sort_order = 1; // 1 for ascending, -1 for descending

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // await dio
    //     .post(
    //       '/room/read',
    //       data: {
    //         "query": query,
    //         "sort_by": sort_by, //
    //         "sort_order": sort_order,
    //         "limit": 100,
    //       },
    //     ) //
    //     .then((r) {
    //       setState(() {
    //         data = List<Map<String, dynamic>>.from(r.data);
    //         print(data);
    //       });
    //     });

    data = List<Map<String, dynamic>>.generate(
      1000,
      (index) => {
        "_id": {"\$oid": "${index + 1}"},
        "room_number": "10${index + 1}",
        "room_type": ["Single", "Double", "Triple", "Quad"][(index + 1) % 4],
        "ac_or_fan": ["Fan", "AC"][(index + 1) % 2],
        "capacity": ((index + 1) % 3) + 1,
        "price": (index + 1) * 100,
        "status": ["Available", "Occupied", "Maintenance"][(index + 1) % 3],
        "image_1": "image_1",
        "image_2": "image_2",
        "created_at": "2022-01-0${index + 1}",
        "updated_at": "2022-01-0${index + 1}",
        "deleted_at": "2022-01-0${index + 1}",
      },
    );
  }

  double get_width() {
    return headers.where((e) => e["visible"] == true).length * 120.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              // button add
              if (is_admin)
                IconButton(
                  onPressed: () {
                    setState(() {
                      is_search = !is_search;
                    });
                  },
                  icon: Icon(Icons.search),
                ),
              if (is_admin)
                IconButton(
                  onPressed: () {
                    //
                  },
                  icon: Icon(Icons.filter_alt_outlined),
                ),
              Spacer(),
              if (is_admin)
                IconButton(
                  onPressed: () {
                    //
                  },
                  icon: Icon(Icons.add),
                ),

              // button export
              IconButton(
                onPressed: () {
                  //
                },
                icon: Icon(Icons.download_outlined),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: is_admin ? get_width() + 90 : get_width(),
                child: Column(
                  children: [
                    // header
                    if (!is_search)
                      Row(
                        children: [
                          ...headers.where((row) => row["visible"]).map((row) {
                            return SizedBox(
                              height: 50, //
                              width: column_width, //
                              child: InkWell(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      row["label"], //
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Spacer(),
                                    Icon(Icons.unfold_more, size: 16), //
                                  ],
                                ),
                              ),
                            );
                          }),

                          if (is_admin)
                            SizedBox(
                              height: 50, //
                              width: 80, //
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text("Actions", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4), //
                                  Spacer(),
                                ],
                              ),
                            ),
                        ],
                      ),

                    // search
                    if (is_search)
                      Row(
                        children: [
                          ...headers.where((row) => row["visible"]).map((row) {
                            return Container(
                              height: 50, //
                              width: column_width, //
                              padding: const EdgeInsets.fromLTRB(1, 8, 1, 0),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(), //
                                  hintText: "Search",
                                  labelText: row["label"] as String?,
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                              ),
                            );
                          }),

                          if (is_admin)
                            SizedBox(
                              height: 50, //
                              width: 80, //
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text("Actions", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4), //
                                  Spacer(),
                                ],
                              ),
                            ),
                        ],
                      ),

                    // body
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            child: Container(
                              height: 40, //
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                              ),
                              child: Row(
                                children: [
                                  ...headers.where((row) => row["visible"]).map((row) {
                                    if (row["key"] == "_id") {
                                      return Container(
                                        width: column_width, //
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${data[index][row["key"]]["\$oid"] ?? ""}", //
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true,
                                        ),
                                      );
                                    }

                                    if (row["key"] == "price") {
                                      return Container(
                                        width: column_width, //
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${data[index][row["key"]].toStringAsFixed(2) ?? "0.00"} \$", //
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true,
                                        ),
                                      );
                                    }

                                    // general case
                                    return Container(
                                      width: column_width, //
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${data[index][row["key"]] ?? ""}", //
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: true,
                                      ),
                                    );
                                  }),

                                  if (is_admin) ...[
                                    // button edit
                                    SizedBox(
                                      width: 40, //
                                      child: IconButton(
                                        icon: const Icon(Icons.edit_outlined), //
                                        onPressed: () {
                                          print('Edit room ${data[index]["_id"]["\$oid"]}');
                                        },
                                      ),
                                    ),

                                    // button delete
                                    SizedBox(
                                      width: 40,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          print('Delete room ${data[index]["_id"]["\$oid"]}');
                                        },
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            onTap: () {
                              print('Tapped on row ${data[index]["_id"]["\$oid"]}');
                            },
                          );
                        },
                      ),
                    ),

                    // Pagination controls
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                SizedBox(width: 8),

                // view column
                IconButton(onPressed: () {}, icon: const Icon(Icons.view_column_outlined)),

                // view row
                IconButton(onPressed: () {}, icon: const Icon(Icons.table_rows_outlined)),

                Text("10 Rows/Page"),

                Spacer(),

                // first button
                IconButton(onPressed: () {}, icon: const Icon(Icons.first_page)),

                // previous button
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),

                // page dropdown (dropup)
                OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(minimumSize: WidgetStateProperty.all(const Size(60, 40))),
                  child: Text("1 / 5"),
                ),

                // next button
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),

                // last button
                IconButton(onPressed: () {}, icon: const Icon(Icons.last_page)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
