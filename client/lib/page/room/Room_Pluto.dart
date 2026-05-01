import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:speanmeas/theme/Theme_Data.dart';
import 'package:speanmeas/utility/Dio.dart';

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
      home: const RoomPlutoScreen(),
    );
  }
}

class RoomPlutoScreen extends StatefulWidget {
  const RoomPlutoScreen({super.key});

  @override
  State<RoomPlutoScreen> createState() => _RoomPlutoScreenState();
}

class _RoomPlutoScreenState extends State<RoomPlutoScreen> {
  late final PlutoGridStateManager stateManager;
  final List<PlutoColumn> columns = [];
  final List<PlutoRow> rows = [];
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _initColumns();
  }

  void _initColumns() {
    columns.addAll([
      PlutoColumn(title: 'ID', field: '_id', type: PlutoColumnType.text(), width: 80, readOnly: true, enableColumnDrag: false, enableContextMenu: false),
      PlutoColumn(title: 'Room No.', field: 'room_number', type: PlutoColumnType.text(), width: 100),
      PlutoColumn(title: 'Type', field: 'room_type', type: PlutoColumnType.select(['Standard', 'Deluxe', 'Suite']), width: 100),
      PlutoColumn(title: 'Capacity', field: 'capacity', type: PlutoColumnType.number(), width: 80),
      PlutoColumn(
        title: 'Price',
        field: 'price',
        type: PlutoColumnType.currency(symbol: r'$'),
        width: 100,
      ),
      PlutoColumn(title: 'Status', field: 'status', type: PlutoColumnType.select(['Available', 'Occupied', 'Maintenance']), width: 100),
      PlutoColumn(title: 'Created At', field: 'created_at', type: PlutoColumnType.text(), width: 140, readOnly: true),
    ]);
  }

  Future<PlutoLazyPaginationResponse> fetch(PlutoLazyPaginationRequest request) async {
    const pageSize = 100;
    final offset = (request.page - 1) * pageSize;

    // Handle filtering - extract filter values from PlutoGrid filter rows
    String? query;
    if (request.filterRows.isNotEmpty) {
      final filterValues = <String>[];
      for (final row in request.filterRows) {
        // Iterate through all cell entries in the filter row
        for (final entry in row.cells.entries) {
          final value = entry.value.value?.toString();
          if (value != null && value.isNotEmpty) {
            filterValues.add(value);
          }
        }
      }
      if (filterValues.isNotEmpty) {
        query = filterValues.join(' ');
      }
    }

    // Handle sorting
    String? sortBy;
    int? sortOrder;
    if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
      sortBy = request.sortColumn!.field;
      sortOrder = request.sortColumn!.sort.isAscending ? 1 : -1;
    }

    try {
      final response = await dio.post('/room/read', data: {if (query != null && query.isNotEmpty) 'query': query, if (sortBy != null) 'sort_by': sortBy, if (sortOrder != null) 'sort_order': sortOrder, 'offset': offset, 'limit': pageSize});

      final List<dynamic> data = response.data;
      _totalCount = data.length < pageSize ? offset + data.length : await _fetchTotalCount();

      final plutoRows = data.map((item) => _createRow(item)).toList();
      final totalPage = (_totalCount / pageSize).ceil();

      return PlutoLazyPaginationResponse(totalPage: totalPage < 1 ? 1 : totalPage, rows: plutoRows);
    } catch (e) {
      return PlutoLazyPaginationResponse(totalPage: 1, rows: []);
    }
  }

  Future<int> _fetchTotalCount() async {
    try {
      final response = await dio.post('/room/count');
      return response.data as int;
    } catch (e) {
      return 0;
    }
  }

  PlutoRow _createRow(Map<String, dynamic> item) {
    return PlutoRow(
      cells: {
        '_id': PlutoCell(value: item['_id'] ?? ''),
        'room_number': PlutoCell(value: item['room_number'] ?? ''),
        'room_type': PlutoCell(value: item['room_type'] ?? ''),
        'capacity': PlutoCell(value: item['capacity'] ?? 0),
        'price': PlutoCell(value: item['price']?.toDouble() ?? 0.0),
        'status': PlutoCell(value: item['status'] ?? ''),
        'created_at': PlutoCell(value: item['created_at'] ?? ''),
      },
    );
  }

  Future<void> _handleCellUpdate(PlutoGridOnChangedEvent event) async {
    final row = event.row;
    final column = event.column;
    final newValue = event.value;

    // Skip update for read-only columns
    if (column.field == '_id' || column.field == 'created_at') return;

    // Get the _id from the row's _id cell
    final rowId = row.cells['_id']?.value?.toString();
    if (rowId == null || rowId.isEmpty) {
      print('Update failed: Missing row ID');
      return;
    }

    try {
      final response = await dio.post('/room/update', data: {'_id': rowId, column.field: newValue});
      print('Update success: ${response.data}');
    } catch (e) {
      print('Update failed: $e');
      // Optionally: revert the cell value on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Management'), toolbarHeight: 40, automaticallyImplyLeading: false),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          _handleCellUpdate(event);
        },
        configuration: const PlutoGridConfiguration(style: PlutoGridStyleConfig(rowHeight: 32, columnHeight: 32)),
        createFooter: (stateManager) {
          return PlutoLazyPagination(initialPage: 1, initialFetch: true, fetchWithSorting: true, fetchWithFiltering: true, pageSizeToMove: 1, fetch: fetch, stateManager: stateManager);
        },
      ),
    );
  }
}
