import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const RowPaginationScreen());
  }
}

class RowPaginationScreen extends StatefulWidget {
  const RowPaginationScreen({super.key});

  @override
  _RowPaginationScreenState createState() => _RowPaginationScreenState();
}

class _RowPaginationScreenState extends State<RowPaginationScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    var c = List<int>.generate(5, (index) => index).map((i) {
      return PlutoColumn(
        title: 'Column $i', //
        field: i.toString(),
        type: PlutoColumnType.number(),
      );
    }).toList();

    var r = List<int>.generate(10000, (index) => index).map((i) {
      return PlutoRow(
        cells: Map.fromEntries(
          c.map((col) {
            return MapEntry(col.field, PlutoCell(value: Random().nextDouble() * 1000000));
          }),
        ),
      );
    }).toList();

    columns.addAll(c);

    rows.addAll(r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row pagination')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(false);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        configuration: const PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
            rowHeight: 30, // Set row height here
            columnHeight: 30,
          ),
        ),
        createFooter: (stateManager) {
          stateManager.setPageSize(100, notify: false);
          return PlutoPagination(stateManager);
        },
      ),
    );
  }
}
