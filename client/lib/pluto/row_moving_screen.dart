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
    return MaterialApp(debugShowCheckedModeBanner: false, home: const RowMovingScreen());
  }
}

class RowMovingScreen extends StatefulWidget {
  const RowMovingScreen({super.key});

  @override
  _RowMovingScreenState createState() => _RowMovingScreenState();
}

class _RowMovingScreenState extends State<RowMovingScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(title: 'column1', field: 'column1', type: PlutoColumnType.text(), enableRowDrag: true), //
      PlutoColumn(title: 'column2', field: 'column2', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column3', field: 'column3', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column4', field: 'column4', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column5', field: 'column5', type: PlutoColumnType.text()),
    ]);

    rows.addAll(
      List<PlutoRow>.generate(15, (index) {
        return PlutoRow(
          cells: Map.fromEntries(
            columns.map((column) {
              return MapEntry(column.field, PlutoCell(value: Random().nextInt(10000).toString()));
            }),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row moving')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);

          stateManager = event.stateManager;
        },
        onRowsMoved: (PlutoGridOnRowsMovedEvent event) {
          // Moved index.
          // In the state of pagination, filtering, and sorting,
          // this is the index of the currently displayed row range.
          print(event.idx);

          // Shift (Control) + Click or Shift + Move keys
          // allows you to select multiple rows and move them at the same time.
          print(event.rows.first.cells['column1']!.value);
        },
      ),
    );
  }
}
