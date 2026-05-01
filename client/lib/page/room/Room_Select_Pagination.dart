import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Pagination());
}

class Room_Select_Pagination extends StatelessWidget {
  Room_Select_Pagination({super.key});

  final int rowPerPage = 10;
  final int totalRows = 10000;
  final int currentPage = 1;
  final int totalPages = 100;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Select_Pagination_(
        rowPerPage: rowPerPage, //
        totalRows: totalRows,
        currentPage: currentPage,
        totalPages: totalPages,
      ),
    );
  }
}

class Room_Select_Pagination_ extends StatefulWidget {
  Room_Select_Pagination_({
    super.key, //
    required this.rowPerPage,
    required this.totalRows,
    required this.currentPage,
    required this.totalPages,
  });

  final int rowPerPage;
  final int totalRows;
  final int currentPage;
  final int totalPages;

  @override
  State<Room_Select_Pagination_> createState() => _Room_Select_Pagination_State();
}

class _Room_Select_Pagination_State extends State<Room_Select_Pagination_> {
  //
  //

  // var totalPage = widget.totalPages;

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
          itemCount: [10, 25, 50, 100].length,
          itemBuilder: (context, index) {
            final option = [10, 25, 50, 100][index];
            final isSelected = option == widget.rowPerPage;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.toString()),
              leading: isSelected ? Icon(Icons.check, color: Colors.blue) : SizedBox(width: 24),
              onTap: () {
                Navigator.of(context).pop(option);
              },
            );
          },
        ),
      ),
    );
  }
}
