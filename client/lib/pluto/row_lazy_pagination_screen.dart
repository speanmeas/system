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
    return MaterialApp(debugShowCheckedModeBanner: false, home: const RowLazyPaginationScreen());
  }
}

class RowLazyPaginationScreen extends StatefulWidget {
  const RowLazyPaginationScreen({super.key});

  @override
  State<RowLazyPaginationScreen> createState() => _RowLazyPaginationScreenState();
}

class _RowLazyPaginationScreenState extends State<RowLazyPaginationScreen> {
  late final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns = [];

  // Pass an empty row to the grid initially.
  final List<PlutoRow> rows = [];

  final List<PlutoRow> fakeFetchedRows = [];

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
            return MapEntry(col.field, PlutoCell(value: i));
          }),
        ),
      );
    }).toList();

    columns.addAll(c);

    rows.addAll(r);

    // Instead of fetching data from the server,
    // Create a fake row in advance.
    fakeFetchedRows.addAll(r);
  }

  Future<PlutoLazyPaginationResponse> fetch(PlutoLazyPaginationRequest request) async {
    List<PlutoRow> tempList = fakeFetchedRows;

    if (request.filterRows.isNotEmpty) {
      final filter = FilterHelper.convertRowsToFilter(request.filterRows, stateManager.refColumns);

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

    final page = request.page;
    const pageSize = 1000;
    final totalPage = (tempList.length / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;

    Iterable<PlutoRow> fetchedRows = tempList.getRange(max(0, start), min(tempList.length, end));

    await Future.delayed(const Duration(milliseconds: 500));

    return Future.value(PlutoLazyPaginationResponse(totalPage: totalPage, rows: fetchedRows.toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(false);
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
          return PlutoLazyPagination(
            // Determine the first page.
            // Default is 1.
            initialPage: 1,

            // First call the fetch function to determine whether to load the page.
            // Default is true.
            initialFetch: true,

            // Decide whether sorting will be handled by the server.
            // If false, handle sorting on the client side.
            // Default is true.
            fetchWithSorting: true,

            // Decide whether filtering is handled by the server.
            // If false, handle filtering on the client side.
            // Default is true.
            fetchWithFiltering: true,

            // Determines the page size to move to the previous and next page buttons.
            // Default value is null. In this case,
            // it moves as many as the number of page buttons visible on the screen.
            pageSizeToMove: 1,
            fetch: fetch,
            stateManager: stateManager,
          );
        },
      ),
    );
  }
}
