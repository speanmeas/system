import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/page/Room_Add.dart';
import 'package:speanmeas/page/Room_Column_Visibility.dart';
import 'package:speanmeas/page/Room_Edit.dart';
import 'package:speanmeas/page/Room_View.dart';
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

  String? _sortKey;
  bool _sortAscending = true;

  // late final Map<String, Type> allHeader = {'Room No.': String, 'Type': String, 'Fan/AC': String, 'Meal': String, 'Capacity': String, 'Price': String, 'Status': String, 'Contact': String};

  late Map<String, bool> column_visibility = {
    'Room No.': true, //
    'Type': true, //
    'Fan/AC': true, //
    'Meal': true, //
    'Capacity': true, //
    'Price': true, //
    'Status': true, //
    'Contact': false,
  };

  List<Map<String, dynamic>> data = [
    {"Room No.": "101", "Type": "Single", "Fan/AC": "AC", "Meal": "Breakfast", "Capacity": "1", "Price": "100.0", "Status": "Available", "Contact": "1234567890"},
    {"Room No.": "102", "Type": "Double", "Fan/AC": "Fan", "Meal": "All Meals", "Capacity": "2", "Price": "150.0", "Status": "Occupied", "Contact": "0987654321"},
    {"Room No.": "103", "Type": "Suite", "Fan/AC": "AC", "Meal": "All Meals", "Capacity": "4", "Price": "300.0", "Status": "Cleaning", "Contact": "1122334455"},
    {"Room No.": "104", "Type": "Single", "Fan/AC": "Fan", "Meal": "Breakfast", "Capacity": "1", "Price": "80.0", "Status": "Occupied", "Contact": "5566778899"},
    {"Room No.": "105", "Type": "Double", "Fan/AC": "AC", "Meal": "All Meals", "Capacity": "2", "Price": "200.0", "Status": "Available", "Contact": "6677889900"},
    {"Room No.": "106", "Type": "Suite", "Fan/AC": "Fan", "Meal": "All Meals", "Capacity": "4", "Price": "250.0", "Status": "Maintenance", "Contact": "7788990011"},
  ];

  late List<Map<String, dynamic>> search_data = List.from(data);

  void on_search(v) {
    print("search: $v");
    setState(() {
      search_data = data.where((room) => room.values.any((value) => value.toString().toLowerCase().contains(v.toString().toLowerCase()))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleColumns = column_visibility.entries.where((e) => e.value).map((e) => e.key).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 40,
              width: 160,
              child: TextField(
                onChanged: on_search,
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
                          input: column_visibility.keys.toList(), //
                        ); //
                      },
                    ),
                  ).then((v) {
                    if (v != null) {
                      setState(() {
                        search_data.add(Map<String, dynamic>.from(v));
                      });
                    }
                  });
                },
                icon: Icon(Icons.add),
              ),

            // button column visibility
            IconButton(
              onPressed: () {
                Navigator.push(
                  context, //
                  MaterialPageRoute(
                    builder: (c) {
                      return Room_Column_(
                        input: column_visibility, //
                      ); //
                    },
                  ),
                ).then((v) {
                  if (v != null) {
                    setState(() {
                      column_visibility = Map<String, bool>.from(v);
                    });
                  }
                });
              },
              icon: const Icon(Icons.view_column_outlined),
            ),

            // button export
            IconButton(onPressed: () {}, icon: Icon(Icons.download)),
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
          width: is_admin ? visibleColumns.length * 100 + 80 : visibleColumns.length * 100,
          child: Column(
            children: [
              Row(
                children: [
                  for (var key in visibleColumns)
                    SizedBox(
                      height: 40, //
                      width: 100, //
                      child: InkWell(
                        onTap: () {
                          print(key);
                          // toggle sort data by key
                          setState(() {
                            if (_sortKey == key) {
                              _sortAscending = !_sortAscending;
                            } else {
                              _sortKey = key;
                              _sortAscending = true;
                            }
                            search_data.sort((a, b) {
                              int cmp = a[key].toString().compareTo(b[key].toString());
                              return _sortAscending ? cmp : -cmp;
                            });
                          });
                        },
                        child: Row(
                          children: [
                            Spacer(),
                            Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 4), //
                            Icon(
                              _sortKey == key ? (_sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down) : Icons.unfold_more, //
                              size: 16,
                            ), //
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (search_data.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: search_data.length + 1,
                    itemBuilder: (context, index) {
                      if (index < search_data.length) {
                        return InkWell(
                          child: Container(
                            height: 40, //
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.black12, width: 2)),
                            ),
                            child: Row(
                              children: [
                                for (var key in visibleColumns)
                                  if (key == "Status")
                                    Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${search_data[index][key]}",
                                        style: TextStyle(fontWeight: FontWeight.w600, color: {"Available": Colors.green, "Occupied": Colors.red, "Cleaning": Colors.blue, "Maintenance": Colors.orange}[search_data[index][key]] ?? Colors.black87),
                                      ),
                                    )
                                  else if (key == "Price")
                                    Container(width: 100, alignment: Alignment.center, child: Text("\$${search_data[index][key]}"))
                                  else
                                    Container(width: 100, alignment: Alignment.center, child: Text("${search_data[index][key]}")),

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
                                                input: Map<String, String>.from(search_data[index]), //
                                              ); //
                                            },
                                          ),
                                        ).then((v) {
                                          if (v != null) {
                                            setState(() {
                                              search_data[index] = Map<String, dynamic>.from(v);
                                            });
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
                                        setState(() {
                                          search_data.removeAt(index);
                                        });
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
                                    data: search_data[index], //
                                  ); //
                                },
                              ),
                            );
                            print('Tapped on row $index');
                          },
                        );
                      } else {
                        return Container(
                          height: 40, //
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.black12, width: 2)),
                          ),
                          child: Text("Total: ${search_data.length} Rooms"),
                        );
                      }
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
