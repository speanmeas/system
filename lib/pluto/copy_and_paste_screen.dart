import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:speanmeas/pluto/RowInfinityScrollScreenState.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const CopyAndPasteScreen());
  }
}

class CopyAndPasteScreen extends StatefulWidget {
  const CopyAndPasteScreen({super.key});

  @override
  _CopyAndPasteScreenState createState() => _CopyAndPasteScreenState();
}

class _CopyAndPasteScreenState extends State<CopyAndPasteScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(title: 'column 1', field: 'column_1', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column 2', field: 'column_2', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column 3', field: 'column_3', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column 4', field: 'column_4', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column 5', field: 'column_5', type: PlutoColumnType.text()),
    ]);

    rows.addAll(
      List<PlutoRow>.generate(30, (index) {
        return PlutoRow(
          cells: Map.fromEntries(
            columns.map((column) {
              return MapEntry(
                column.field, //
                PlutoCell(value: Random().nextInt(10000).toString()),
              );
            }),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Copy and Paste')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
