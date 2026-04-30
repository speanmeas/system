import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/Environment.dart';

import 'package:speanmeas/utility/Dio.dart';
import 'package:speanmeas/utility/Secure_Storage.dart';

import 'package:speanmeas/page/room/Room_Add.dart';
import 'package:speanmeas/page/room/xRoom_Select_Column_Visibility.dart';
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

  // this header
  List<Map<String, dynamic>> headers = [
    {"key": "_id", "label": "ID", "visible": false},
    {"key": "name", "label": "Room No.", "visible": true},
    {"key": "type", "label": "Room Type", "visible": true},
    {"key": "ac_or_fan", "label": "Fan/AC", "visible": true},
    {"key": "capacity", "label": "Capacity", "visible": false},
    {"key": "price", "label": "Price", "visible": true},
    {"key": "status", "label": "Status", "visible": false},
    {"key": "image_1", "label": "Image 1", "visible": false},
    {"key": "image_2", "label": "Image 2", "visible": false},
    {"key": "created_at", "label": "Created At", "visible": true},
    {"key": "updated_at", "label": "Updated At", "visible": false},
    {"key": "deleted_at", "label": "Deleted At", "visible": false},
  ];

  List<Map<String, dynamic>> data = [];

  String query = "";
  String sort_by = "created_at";
  int sort_order = -1; // 1 for ascending, -1 for descending

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await dio
        .post(
          '/room/read',
          data: {
            "query": query,
            "sort_by": sort_by, //
            "sort_order": sort_order,
            "limit": 100,
          },
        ) //
        .then((r) {
          setState(() {
            data = List<Map<String, dynamic>>.from(r.data);
          });
        });
  }

  double get_width() {
    return headers.where((e) => e["visible"] == true).length * 120.0;
  }

  @override
  Widget build(BuildContext context) {
    // final visibleColumns = column_visibility.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 40,
              width: 160,
              child: TextField(
                onChanged: (v) {
                  setState(() {
                    query = v;
                  });
                  init();
                },
                decoration: InputDecoration(
                  hintText: "Search...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
                ),
              ),
            ),

            Spacer(),

            // button add
            if (is_admin)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context, //
                    MaterialPageRoute(
                      builder: (c) {
                        return Room_Add_(
                          input: headers.map((e) => e["key"] as String).toList(), //
                        ); //
                      },
                    ),
                  ).then((v) {
                    if (v != null) {
                      setState(() {
                        // search_data.add(Map<String, dynamic>.from(v));
                      });
                    }
                  });
                },
                icon: Icon(Icons.add),
              ),

            // button column visibility
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context, //
                //   MaterialPageRoute(
                //     builder: (c) {
                //       return Room_Column_(
                //         input: column_width, //
                //       ); //
                //     },
                //   ),
                // ).then((v) {
                //   if (v != null) {
                //     setState(() {
                //       column_width = v;
                //     });
                //   }
                // });
              },
              icon: const Icon(Icons.view_column_outlined),
            ),

            // button export
            IconButton(onPressed: () {}, icon: Icon(Icons.download_outlined)),
          ],
        ),
        // backgroundColor: Colors.blueGrey,
        toolbarHeight: 40,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: is_admin ? get_width() + 80 : get_width(),
          child: Column(
            children: [
              Row(
                children: [
                  for (var row in headers)
                    if (row["visible"])
                      SizedBox(
                        height: 40, //
                        width: column_width, //
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              sort_by = row["key"];
                              sort_order = -sort_order;
                            });
                            init();
                          },
                          child: Row(
                            children: [
                              Spacer(),
                              Text(
                                row["label"], //
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 4), //
                              Icon(Icons.unfold_more, size: 16), //
                              Spacer(),
                            ],
                          ),
                        ),
                      ),

                  if (is_admin)
                    SizedBox(
                      height: 40, //
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
              Expanded(
                child: ListView.builder(
                  itemCount: data.length + 1,
                  itemBuilder: (context, index) {
                    if (index < data.length) {
                      return InkWell(
                        child: Container(
                          height: 40, //
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.black12, width: 2)),
                          ),
                          child: Row(
                            children: [
                              for (var row in headers)
                                if (row["visible"])
                                  Container(
                                    width: column_width, //
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${data[index][row["key"]] ?? ""}", //
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),

                              // button edit
                              if (is_admin)
                                SizedBox(
                                  width: 40, //
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined), //
                                    onPressed: () {
                                      Navigator.push(
                                        context, //
                                        MaterialPageRoute(
                                          builder: (c) {
                                            return Room_Edit_(
                                              input: Map<String, String>.from(data[index]), //
                                            ); //
                                          },
                                        ),
                                      ).then((v) {
                                        if (v != null) {
                                          setState(() {});
                                        }
                                      });
                                    },
                                  ),
                                ),

                              // button delete
                              if (is_admin)
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context, //
                            MaterialPageRoute(
                              builder: (c) {
                                return Room_View_(
                                  data: data[index], //
                                ); //
                              },
                            ),
                          );
                          print('Tapped on row $index');
                        },
                      );
                    } else {
                      if (index == data.length) {
                        dio
                            .post(
                              '/room/read',
                              data: {
                                "query": query,
                                "sort_by": sort_by, //
                                "sort_order": sort_order,
                                "offset": data.length,
                                "limit": 100,
                              },
                            )
                            .then((r) {
                              setState(() {
                                data.addAll(List<Map<String, dynamic>>.from(r.data));
                              });
                            });
                      }
                    }
                    return null;
                    // else {

                    //   return Container(
                    //     height: 40, //
                    //     alignment: Alignment.center,
                    //     decoration: const BoxDecoration(
                    //       border: Border(top: BorderSide(color: Colors.black12, width: 2)),
                    //     ),
                    //     child: Text("Total: ${data.length} Rooms"),
                    //   );
                    // }
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
