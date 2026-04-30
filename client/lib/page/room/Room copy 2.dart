import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/Environment.dart';
import 'package:speanmeas/page/room/Room_Select_Row_Per_Page.dart';

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
    {"key": "room_number", "label": "Room No.", "visible": true},
    {"key": "room_type", "label": "Room Type", "visible": true},
    {"key": "capacity", "label": "Capacity", "visible": true},
    {"key": "price", "label": "Price", "visible": true},
    {"key": "status", "label": "Status", "visible": true},
  ];

  List<Map<String, dynamic>> data = [];

  int total = 0;
  int currentPage = 1;
  final int itemsPerPage = 100;

  int get totalPages => (total / itemsPerPage).ceil();

  // @override
  // void initState() {
  //   super.initState();
  //   init();
  // }

  // void loadPage(int page) async {
  //   final offset = (page - 1) * itemsPerPage;
  //   await dio
  //       .post(
  //         '/room/read', //
  //         data: {
  //           "query": query, //
  //           "sort_by": sort_by,
  //           "sort_order": sort_order,
  //           "offset": offset,
  //           "limit": itemsPerPage,
  //         },
  //       )
  //       .then((r) {
  //         setState(() {
  //           data = List<Map<String, dynamic>>.from(r.data);
  //           currentPage = page;
  //         });
  //       });
  // }

  // void init() async {
  //   // get total count first
  //   await dio.post('/room/count').then((r) {
  //     setState(() {
  //       total = r.data is int ? r.data : 0;
  //     });
  //   });
  //   loadPage(1);
  // }

  // double get_width() {
  //   return headers.where((e) => e["visible"] == true).length * 120.0;
  // }

  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  var total_row = 10000;
  var row_per_page = 100;
  var page = 1;

  String query = "";
  String sort_by = "created_at";
  int sort_order = 1; // 1 for ascending, -1 for descending

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'Room No.', //
        field: 'room_no',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Room Type', //
        field: 'room_type',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Action', //
        field: 'action',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableSorting: false,
        enableAutoEditing: false,
        enableRowDrag: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        enableHideColumnMenuItem: false,
        cellPadding: const EdgeInsets.all(0),
        // frozen: PlutoColumnFrozen.end,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        width: 80,
        readOnly: true,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  rendererContext.row.cells.forEach((key, cell) {
                    print('$key: ${cell.value}');
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  rendererContext.row.cells.forEach((key, cell) {
                    print('$key: ${cell.value}');
                  });
                },
              ),
            ],
          );
        },
      ),
    ]);

    rows.addAll([
      PlutoRow(
        cells: {
          'room_no': PlutoCell(value: 'Room 0'),
          'room_type': PlutoCell(value: 'Type 0'),
          'action': PlutoCell(value: ''),
        },
      ),
      PlutoRow(
        cells: {
          'room_no': PlutoCell(value: 'Room 1'),
          'room_type': PlutoCell(value: 'Type 1'),
          'action': PlutoCell(value: ''),
        },
      ),
    ]);
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
                onSubmitted: (v) {
                  setState(() {
                    query = v;
                  });
                  // init();
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
      body: Column(
        children: [
          Expanded(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                // event.stateManager.setShowColumnFilter(false);
                // event.stateManager.setShowHeaderFilter(false);
                // event.stateManager.setMode(PlutoGridMode.select);
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                if (event.column?.field != null) {
                  print(event.column?.field);
                }
              },
              configuration: const PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  rowHeight: 40, // Set row height here
                  columnHeight: 40,
                ),
              ),
            ),
          ),

          // Pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 8),

              Text("$row_per_page Rows/Page"),

              Spacer(),

              // row per page button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return Room_Select_Row_Per_Page_(
                        input: {
                          "options": [10, 25, 50, 100],
                          "selected": 10,
                        },
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        row_per_page = value;
                      });
                    }
                  });
                },
                icon: const Icon(Icons.table_rows_outlined),
              ),

              // first button
              IconButton(onPressed: () {}, icon: const Icon(Icons.first_page)),

              // previous button
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),

              // page dropdown (dropup)
              OutlinedButton(
                onPressed: () {},
                style: ButtonStyle(minimumSize: WidgetStateProperty.all(const Size(60, 40))),
                child: const Text("90"),
              ),

              Text(" / $totalPages"),

              // next button
              IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),

              // last button
              IconButton(onPressed: () {}, icon: const Icon(Icons.last_page)),
            ],
          ),
        ],
      ),
    );
  }
}
