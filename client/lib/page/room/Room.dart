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
  // Constants
  final double _rowHeight = 40.0;
  final double _colWidth = 120.0;
  final double _actionColWidth = 80.0;
  final double _actionBtnWidth = 40.0;
  final double _toolbarHeight = 40.0;
  final double _searchWidth = 160.0;
  final double _pageBtnWidth = 60.0;

  bool is_admin = true;

  final List<Map<String, dynamic>> headers = [
    {"key": "_id", "label": "ID", "visible": false},
    {"key": "room_number", "label": "Room No.", "visible": true},
    {"key": "room_type", "label": "Room Type", "visible": true},
    {"key": "capacity", "label": "Capacity", "visible": false},
    {"key": "price", "label": "Price", "visible": true},
    {"key": "status", "label": "Status", "visible": false},
    {"key": "created_at", "label": "Created At", "visible": true},
    {"key": "updated_at", "label": "Updated At", "visible": false},
    {"key": "deleted_at", "label": "Deleted At", "visible": false},
  ];

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final response = await dio.post('/room/read', data: {"limit": 100});
    setState(() {
      data = List<Map<String, dynamic>>.from(response.data);
    });
  }

  double get _totalWidth {
    final visibleCount = headers.where((h) => h["visible"] == true).length;
    return visibleCount * _colWidth + (is_admin ? _actionColWidth : 0);
  }

  List<Map<String, dynamic>> get _visibleHeaders => headers.where((h) => h["visible"] == true).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _totalWidth,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildDataList()),
                  ],
                ),
              ),
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        SizedBox(
          height: _toolbarHeight,
          width: _searchWidth,
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search...",
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
            ),
          ),
        ),
        const Spacer(),
        if (is_admin) IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.view_column_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined)),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        ..._visibleHeaders.map(_buildHeaderCell), //
        if (is_admin) _buildActionsHeader(),
      ],
    );
  }

  Widget _buildHeaderCell(Map<String, dynamic> header) {
    return SizedBox(
      height: _rowHeight,
      width: _colWidth,
      child: InkWell(
        onTap: () {
          print('Header tapped: ${header["label"]}');
        },
        child: Row(
          children: [
            const Spacer(),
            Text(
              header["label"],
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.unfold_more, size: 16),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsHeader() {
    return SizedBox(
      height: _rowHeight,
      width: _actionColWidth,
      child: Row(
        children: [
          Spacer(),
          Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return ListView.builder(
      itemCount: data.length, //
      itemBuilder: (context, index) => _buildDataRow(index),
    );
  }

  Widget _buildDataRow(int index) {
    final r = data[index];
    return InkWell(
      onTap: () {
        print('Tapped row ${data[index]["_id"]}');
      },
      child: Container(
        height: _rowHeight,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 2)),
        ),
        child: Row(
          children: [
            ..._visibleHeaders.map((h) => _buildDataCell(r, h)),
            if (is_admin) ...[
              _buildActionButton(Icons.edit_outlined, () {
                print('Edit row ${data[index]["_id"]}');
              }), //
              _buildActionButton(Icons.delete_outline, () {
                print('Delete row ${data[index]["_id"]}');
              }, color: Colors.red),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(Map<String, dynamic> row, Map<String, dynamic> header) {
    if (header["key"] == "price") {
      return SizedBox(
        width: _colWidth,
        child: Text(
          "${num.parse(row[header["key"]]?.toString() ?? "0.0").toStringAsFixed(2)} \$", //
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
      );
    }

    return SizedBox(
      width: _colWidth,
      child: Text(
        "${row[header["key"]] ?? ""}", //
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: _actionBtnWidth,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        IconButton(onPressed: () {}, icon: const Icon(Icons.table_rows_outlined)),
        const Text("10 Rows/Page"),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.first_page)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
        OutlinedButton(
          onPressed: () {},
          style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size(_pageBtnWidth, _toolbarHeight))),
          child: const Text("1 / 5"),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.last_page)),
      ],
    );
  }
}
