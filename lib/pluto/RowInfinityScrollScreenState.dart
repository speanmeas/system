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
    return MaterialApp(debugShowCheckedModeBanner: false, home: const RowInfinityScrollScreen());
  }
}

class RowInfinityScrollScreen extends StatefulWidget {
  // static const routeName = 'feature/row-infinity-scroll';

  const RowInfinityScrollScreen({super.key});

  @override
  RowInfinityScrollScreenState createState() => RowInfinityScrollScreenState();
}

class RowInfinityScrollScreenState extends State<RowInfinityScrollScreen> {
  late final List<PlutoColumn> columns;
  late final List<PlutoRow> rows;
  late final List<PlutoRow> fakeFetchedRows;

  PlutoGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(title: 'column1', field: 'column1', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column2', field: 'column2', type: PlutoColumnType.text()), //
      PlutoColumn(title: 'column3', field: 'column3', type: PlutoColumnType.date()),
    ];

    rows = [];
    fakeFetchedRows = _generateRows(100000);
  }

  List<PlutoRow> _generateRows(int length) {
    final random = Random();

    return List<PlutoRow>.generate(length, (index) {
      final date = DateTime.now().subtract(Duration(days: random.nextInt(365)));

      return PlutoRow(
        cells: {
          'column1': PlutoCell(value: 'Item ${index + 1}'),
          'column2': PlutoCell(value: 'Value ${1000 + random.nextInt(9000)}'),
          'column3': PlutoCell(value: date),
        },
      );
    });
  }

  Future<PlutoInfinityScrollRowsResponse> fetch(PlutoInfinityScrollRowsRequest request) async {
    List<PlutoRow> tempList = fakeFetchedRows;

    if (request.filterRows.isNotEmpty && stateManager != null) {
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager!.refColumns);
      tempList = fakeFetchedRows.where(filter!).toList();
    }

    if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
      tempList = [...tempList];
      tempList.sort((a, b) {
        final sortA = request.sortColumn!.sort.isAscending ? a : b;
        final sortB = request.sortColumn!.sort.isAscending ? b : a;

        return request.sortColumn!.type.compare(sortA.cells[request.sortColumn!.field]!.valueForSorting, sortB.cells[request.sortColumn!.field]!.valueForSorting);
      });
    }

    Iterable<PlutoRow> fetchedRows = tempList.skipWhile((row) => request.lastRow != null && row.key != request.lastRow!.key);

    if (request.lastRow == null) {
      fetchedRows = fetchedRows.take(500);
    } else {
      fetchedRows = fetchedRows.skip(1).take(500);
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final bool isLast = fetchedRows.isEmpty || (tempList.isNotEmpty && tempList.last.key == fetchedRows.last.key);

    if (isLast && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Last Page!')));
    }

    return PlutoInfinityScrollRowsResponse(isLast: isLast, rows: fetchedRows.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row infinity scroll')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onChanged: (PlutoGridOnChangedEvent event) {
            debugPrint(event.toString());
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager!.setShowColumnFilter(false);
            // event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);
          },
          createFooter: (s) => PlutoInfinityScrollRows(initialFetch: true, fetchWithSorting: true, fetchWithFiltering: true, fetch: fetch, stateManager: s),
        ),
      ),
    );
  }
}
