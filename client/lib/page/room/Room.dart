import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/Environment.dart';

import 'package:speanmeas/utility/Dio.dart';
import 'package:speanmeas/utility/Secure_Storage.dart';

import 'package:speanmeas/page/room/Room_Add.dart';
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

  double header_height = 40.0;

  double row_height = 40.0;
  double column_width = 120.0;
  double number_column_width = 60.0;

  bool is_search = false;

  // this header
  List<Map<String, dynamic>> headers = [
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

    setState(() {
      data = List<Map<String, dynamic>>.generate(
        100,
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
    });
  }

  void load_more() {
    setState(() {
      data.addAll(
        List<Map<String, dynamic>>.generate(
          100,
          (index) => {
            "_id": {"\$oid": "${data.length + index + 1}"},
            "room_number": "10${data.length + index + 1}",
            "room_type": ["Single", "Double", "Triple", "Quad"][(data.length + index + 1) % 4],
            "ac_or_fan": ["Fan", "AC"][(data.length + index + 1) % 2],
            "capacity": ((data.length + index + 1) % 3) + 1,
            "price": (data.length + index + 1) * 100,
            "status": ["Available", "Occupied", "Maintenance"][(data.length + index + 1) % 3],
            "image_1": "image_1",
            "image_2": "image_2",
            "created_at": "2022-01-0${data.length + index + 1}",
            "updated_at": "2022-01-0${data.length + index + 1}",
            "deleted_at": "2022-01-0${data.length + index + 1}",
          },
        ),
      );
    });
  }

  double get_width() {
    return number_column_width + headers.where((e) => e["visible"] == true).length * column_width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // button add
            IconButton(
              onPressed: () {
                setState(() {
                  is_search = !is_search;
                });
              },
              icon: Icon(Icons.search),
              tooltip: "Search",
            ),

            IconButton(
              onPressed: () {
                //
              },
              icon: Icon(Icons.filter_alt_outlined),
              tooltip: "Filter",
            ),

            IconButton(
              onPressed: () {
                //
              },
              icon: Icon(Icons.view_column_outlined),
              tooltip: "View Column",
            ),

            Spacer(),

            if (is_admin)
              IconButton(
                onPressed: () {
                  //
                },
                icon: Icon(Icons.add),
                tooltip: "Add",
              ),

            // button export
            IconButton(
              onPressed: () {
                //
              },
              icon: Icon(Icons.download_outlined),
              tooltip: "Export",
            ),
          ],
        ),
        toolbarHeight: header_height,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: is_admin ? get_width() + 90 : get_width(),
          child: Column(
            children: [
              // header
              if (!is_search)
                Row(
                  children: [
                    Container(
                      height: header_height, //
                      width: number_column_width, //
                      alignment: Alignment.center,
                      child: Text(
                        "No.", //
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...headers.where((row) => row["visible"]).map((row) {
                      return Container(
                        height: header_height, //
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
                      Container(
                        height: header_height, //
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
                    Container(
                      height: header_height, //
                      width: number_column_width, //
                      alignment: Alignment.center,
                      child: Text(
                        "No.", //
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    ...headers.where((row) => row["visible"]).map((row) {
                      return Container(
                        height: header_height, //
                        width: column_width, //
                        padding: const EdgeInsets.fromLTRB(1, 8, 1, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search", //
                            labelText: row["label"] as String?,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.fromLTRB(4, 4, 0, 4),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),

                    if (is_admin)
                      Container(
                        height: header_height, //
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
                  itemCount: data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == data.length) {
                      print("Last item");
                      Future.delayed(const Duration(milliseconds: 300), () {
                        load_more();
                      });
                      return Container(
                        height: row_height, //
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    return InkWell(
                      child: Container(
                        height: row_height, //
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: number_column_width, //
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}", //
                              ),
                            ),

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
                                width: row_height, //
                                child: IconButton(
                                  icon: const Icon(Icons.edit_outlined), //
                                  onPressed: () {
                                    print('Edit room ${data[index]["_id"]["\$oid"]}');
                                  },
                                  tooltip: "Edit",
                                ),
                              ),

                              // button delete
                              SizedBox(
                                width: row_height, //
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    print('Delete room ${data[index]["_id"]["\$oid"]}');
                                  },
                                  tooltip: "Delete",
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
            ],
          ),
        ),
      ),
    );
  }
}
