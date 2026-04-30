import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:speanmeas/utility/Dio.dart';

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
  PlutoGridStateManager? _stateManager;
  PlutoGridStateManager get stateManager => _stateManager!;

  final List<PlutoColumn> columns = [];

  // Pass an empty row to the grid initially.
  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();
    // Columns and rows will be loaded from API
  }

  /// Convert PlutoGrid filter format to API format
  List<Map<String, dynamic>> _convertFiltersToApiFormat(List<PlutoRow> filterRows) {
    final filters = <Map<String, dynamic>>[];

    if (filterRows.isEmpty) return filters;

    // Convert PlutoGrid filter rows to map format
    final filterMap = FilterHelper.convertRowsToMap(filterRows);

    // filterMap format: {column: [{filterType: value}, ...]}
    filterMap.forEach((column, conditions) {
      for (final condition in conditions) {
        condition.forEach((conditionType, value) {
          filters.add({'column': column, 'condition': conditionType.toString().toLowerCase(), 'value': value});
        });
      }
    });

    return filters;
  }

  /// Convert PlutoGrid sort to API format
  Map<String, dynamic>? _convertSortToApiFormat(PlutoColumn? sortColumn) {
    if (sortColumn == null || sortColumn.sort.isNone) return null;

    return {'column': sortColumn.field, 'ascending': sortColumn.sort.isAscending};
  }

  /// Build PlutoRow from API response
  PlutoRow _buildRowFromApiData(Map<String, dynamic> apiRow, List<PlutoColumn> columnDefs) {
    final cells = <String, PlutoCell>{};

    // Get the _id from apiRow top level (not in cells)
    final rowId = apiRow['_id']?.toString() ?? '';

    final cellsData = apiRow['cells'] as Map<String, dynamic>? ?? {};
    for (final col in columnDefs) {
      // For _id column, use the row id
      if (col.field == '_id') {
        cells[col.field] = PlutoCell(value: rowId);
      } else {
        final value = cellsData[col.field];
        cells[col.field] = PlutoCell(value: value);
      }
    }

    return PlutoRow(cells: cells);
  }

  Future<PlutoLazyPaginationResponse> fetch(PlutoLazyPaginationRequest request) async {
    try {
      // Wait for columns to be loaded first
      if (columns.isEmpty) {
        await _loadColumns();
      }

      // Build API request body (only include non-null values)
      final requestBody = <String, dynamic>{'page': request.page, 'page_size': 100, 'filters': _convertFiltersToApiFormat(request.filterRows)};

      // Only add sort if not null
      final sort = _convertSortToApiFormat(request.sortColumn);
      if (sort != null) {
        requestBody['sort'] = sort;
      }

      debugPrint('Fetching page ${request.page} with body: $requestBody');

      // Make API call to FastAPI backend using dio
      final response = await dio.post('/pluto/lazy-pagination', data: requestBody);

      debugPrint('Pagination response status: ${response.statusCode}');
      debugPrint('Pagination response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.data}');
      }

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final data = response.data as Map<String, dynamic>;

      // Build PlutoRows from API response
      final rowsData = data['rows'];
      if (rowsData == null || rowsData is! List) {
        debugPrint('Invalid rows data format: $rowsData');
        return PlutoLazyPaginationResponse(totalPage: data['total_page'] ?? 1, rows: []);
      }

      final List<PlutoRow> plutoRows = rowsData.map((rowData) {
        if (rowData is! Map<String, dynamic>) {
          return PlutoRow(cells: {});
        }
        return _buildRowFromApiData(rowData, stateManager.refColumns);
      }).toList();

      return PlutoLazyPaginationResponse(totalPage: data['total_page'] ?? 1, rows: plutoRows);
    } catch (e, stackTrace) {
      debugPrint('Error fetching data: $e');
      debugPrint('Stack trace: $stackTrace');
      // Return empty response on error
      return PlutoLazyPaginationResponse(totalPage: 1, rows: []);
    }
  }

  /// Load initial columns from API
  Future<void> _loadColumns() async {
    try {
      final response = await dio.post('/pluto/columns', data: {});

      debugPrint('Columns response status: ${response.statusCode}');
      debugPrint('Columns response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final columnsData = data['columns'];

        if (columnsData == null || columnsData is! List) {
          debugPrint('Invalid columns data format: $columnsData');
          throw Exception('Invalid columns format');
        }

        // Add _id column first (hidden, for reference)
        columns.add(
          PlutoColumn(
            title: 'ID',
            field: '_id',
            type: PlutoColumnType.text(),
            enableEditingMode: false,
            hide: true, // Hide the ID column
          ),
        );

        for (final colData in columnsData) {
          if (colData is! Map<String, dynamic>) continue;

          final field = colData['field']?.toString() ?? '';
          final title = colData['title']?.toString() ?? field;
          final type = colData['type']?.toString() ?? 'text';

          if (field.isEmpty) continue;

          PlutoColumnType columnType;
          switch (type) {
            case 'number':
              columnType = PlutoColumnType.number();
              break;
            case 'datetime':
              columnType = PlutoColumnType.date();
              break;
            case 'boolean':
              columnType = PlutoColumnType.text();
              break;
            default:
              columnType = PlutoColumnType.text();
          }

          columns.add(PlutoColumn(title: title, field: field, type: columnType, enableEditingMode: true));
        }

        // Refresh grid with loaded columns
        if (mounted && _stateManager != null) {
          _stateManager!.refColumns.clear();
          _stateManager!.refColumns.addAll(columns);
          _stateManager!.notifyListeners();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading columns: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback to default columns if API fails
      columns.clear();
      // Add hidden _id column
      columns.add(PlutoColumn(title: 'ID', field: '_id', type: PlutoColumnType.text(), enableEditingMode: false, hide: true));
      for (int i = 0; i < 5; i++) {
        columns.add(PlutoColumn(title: 'Column $i', field: 'column_$i', type: PlutoColumnType.number(), enableEditingMode: true));
      }
      if (mounted && _stateManager != null) {
        _stateManager!.refColumns.clear();
        _stateManager!.refColumns.addAll(columns);
        _stateManager!.notifyListeners();
      }
    }
  }

  /// Handle cell value changes and update server
  Future<void> _onCellChanged(PlutoGridOnChangedEvent event) async {
    try {
      final row = event.row;
      final column = event.column;
      final value = event.value;

      // Get the _id from the row's cells
      final rowId = row.cells['_id']?.value?.toString() ?? '';
      if (rowId.isEmpty) {
        debugPrint('Cannot update: row has no _id');
        return;
      }

      debugPrint('Updating row $rowId, column ${column.field}, value: $value');

      final response = await dio.post('/pluto/update', data: {'_id': rowId, 'field': column.field, 'value': value});

      if (response.statusCode == 200) {
        debugPrint('Update successful');
      } else {
        debugPrint('Update failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error updating cell: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pluto Grid')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) async {
          _stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);

          // Load columns from API first
          await _loadColumns();
        },
        onChanged: _onCellChanged,
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
