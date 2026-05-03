import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const AddAndRemoveColumnRowScreen());
  }
}

class AddAndRemoveColumnRowScreen extends StatefulWidget {
  const AddAndRemoveColumnRowScreen({super.key});

  @override
  _AddAndRemoveColumnRowScreenState createState() => _AddAndRemoveColumnRowScreenState();
}

class _AddAndRemoveColumnRowScreenState extends State<AddAndRemoveColumnRowScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
        readOnly: true,
        titleSpan: const TextSpan(
          children: [
            WidgetSpan(child: Icon(Icons.lock_outlined, size: 17)),
            TextSpan(text: 'Id'),
          ],
        ),
      ),
      PlutoColumn(title: 'Name', field: 'name', type: PlutoColumnType.text()),
    ]);

    rows.addAll([
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user1'),
          'name': PlutoCell(value: 'user name 1'),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user2'),
          'name': PlutoCell(value: 'user name 2'),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user3'),
          'name': PlutoCell(value: 'user name 3'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add and remove column, row')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);

          stateManager.notifyListeners();
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(stateManager: stateManager),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.stateManager});

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  // final faker = Faker();

  int addCount = 1;

  int addedCount = 0;

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.stateManager.setSelectingMode(gridSelectingMode);
    });
  }

  void handleAddColumns() {
    final List<PlutoColumn> addedColumns = [];

    for (var i = 0; i < addCount; i += 1) {
      addedColumns.add(PlutoColumn(title: 'Column ${++addedCount}', field: 'column$addedCount', type: PlutoColumnType.text()));
    }

    widget.stateManager.insertColumns(widget.stateManager.bodyColumns.length, addedColumns);
  }

  void handleAddRows() {
    final newRows = widget.stateManager.getNewRows(count: addCount);

    widget.stateManager.appendRows(newRows);

    widget.stateManager.setCurrentCell(newRows.first.cells.entries.first.value, widget.stateManager.refRows.length - 1);

    widget.stateManager.moveScrollByRow(PlutoMoveDirection.down, widget.stateManager.refRows.length - 2);

    widget.stateManager.setKeepFocus(true);
  }

  void handleSaveAll() {
    widget.stateManager.setShowLoading(true);

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.stateManager.setShowLoading(false);
    });
  }

  void handleRemoveCurrentColumnButton() {
    final currentColumn = widget.stateManager.currentColumn;

    if (currentColumn == null) {
      return;
    }

    widget.stateManager.removeColumns([currentColumn]);
  }

  void handleRemoveCurrentRowButton() {
    widget.stateManager.removeCurrentRow();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(onPressed: handleAddColumns, child: const Text('Add columns')),
            ElevatedButton(onPressed: handleAddRows, child: const Text('Add rows')),
            ElevatedButton(onPressed: handleRemoveCurrentColumnButton, child: const Text('Remove Current Column')),
            ElevatedButton(onPressed: handleRemoveCurrentRowButton, child: const Text('Remove Current Row')),
            ElevatedButton(onPressed: handleSaveAll, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
