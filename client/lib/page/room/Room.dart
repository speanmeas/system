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

  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  var total_row = 10000;
  var row_per_page = 100;
  var page = 1;

  String query = "";
  String sort_by = "created_at";
  int sort_order = 1; // 1 for ascending, -1 for descending

  PlutoGridStateManager? stateManager;
  bool isLoading = false;

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
        enableSorting: true,
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
        enableSorting: true,
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

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get total count
      final countResponse = await dio.post('/room/count');
      print('Count response: $countResponse');

      total_row = countResponse.data is int ? countResponse.data : 0;

      // Fetch paginated data with sorting
      final response = await dio.post('/room/read', data: {'query': query.isEmpty ? null : query, 'sort_by': sort_by, 'sort_order': sort_order, 'offset': (page - 1) * row_per_page, 'limit': row_per_page});

      final List<dynamic> data = response.data;

      // Map server fields to PlutoGrid fields
      final newRows = data.map((item) {
        return PlutoRow(
          cells: {
            'room_no': PlutoCell(value: item['room_number'] ?? ''),
            'room_type': PlutoCell(value: item['room_type'] ?? ''),
            'action': PlutoCell(value: ''),
            '_id': PlutoCell(value: item['_id'] ?? ''),
          },
        );
      }).toList();

      setState(() {
        rows.clear();
        rows.addAll(newRows);
      });
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // void handleSort(PlutoGridOnSortedEvent event) {
  //   final column = event.column;
  //   if (column == null) return;

  //   // Map PlutoGrid field to server field names
  //   final fieldMapping = {'room_no': 'name', 'room_type': 'type'};

  //   final serverField = fieldMapping[column.field] ?? column.field;

  //   setState(() {
  //     sort_by = serverField;
  //     sort_order = column.sort == PlutoColumnSort.ascending ? 1 : -1;
  //   });

  //   fetchData();
  // }

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
                    page = 1;
                  });
                  fetchData();
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
                stateManager = event.stateManager;
              },
              onSorted: (PlutoGridOnSortedEvent event) {
                print(event.column);
                print(event.column.sort);

                return;
              },
              // onChanged: (PlutoGridOnChangedEvent event) {
              //   if (event.column.field != null) {
              //     print(event.column.field);
              //   }
              // },
              // createFooter: (stateManager) {
              //   return isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
              // },
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
                        page = 1;
                      });
                      fetchData();
                    }
                  });
                },
                icon: const Icon(Icons.table_rows_outlined),
              ),

              // first button
              IconButton(
                onPressed: page > 1
                    ? () {
                        setState(() {
                          page = 1;
                        });
                        fetchData();
                      }
                    : null,
                icon: const Icon(Icons.first_page),
              ),

              // previous button
              IconButton(
                onPressed: page > 1
                    ? () {
                        setState(() {
                          page--;
                        });
                        fetchData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),

              // page dropdown (dropup)
              OutlinedButton(
                onPressed: () {},
                style: ButtonStyle(minimumSize: WidgetStateProperty.all(const Size(60, 40))),
                child: Text("$page"),
              ),

              Text(" / ${(total_row / row_per_page).ceil()}"),

              // next button
              IconButton(
                onPressed: page < (total_row / row_per_page).ceil()
                    ? () {
                        setState(() {
                          page++;
                        });
                        fetchData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),

              // last button
              IconButton(
                onPressed: page < (total_row / row_per_page).ceil()
                    ? () {
                        setState(() {
                          page = (total_row / row_per_page).ceil();
                        });
                        fetchData();
                      }
                    : null,
                icon: const Icon(Icons.last_page),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
