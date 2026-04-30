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

  // Collection name to fetch data from
  final String collection = 'c_room';

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

    final cellsData = apiRow['cells'] as Map<String, dynamic>? ?? {};
    for (final col in columnDefs) {
      final value = cellsData[col.field];
      cells[col.field] = PlutoCell(value: value);
    }

    return PlutoRow(cells: cells);
  }

  Future<PlutoLazyPaginationResponse> fetch(PlutoLazyPaginationRequest request) async {
    try {
      // Build API request body
      final requestBody = {
        'collection': collection,
        'page': request.page,
        'page_size': 100, // Adjust as needed
        'filters': _convertFiltersToApiFormat(request.filterRows),
        'sort': _convertSortToApiFormat(request.sortColumn),
      };

      // Make API call to FastAPI backend using dio
      final response = await dio.post('/pluto/lazy-pagination', data: requestBody);

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      // Build PlutoRows from API response
      final List<dynamic> rowsData = data['rows'] ?? [];
      final List<PlutoRow> plutoRows = rowsData.map((rowData) {
        return _buildRowFromApiData(rowData as Map<String, dynamic>, stateManager.refColumns);
      }).toList();

      return PlutoLazyPaginationResponse(totalPage: data['total_page'] ?? 1, rows: plutoRows);
    } catch (e) {
      debugPrint('Error fetching data: $e');
      // Return empty response on error
      return PlutoLazyPaginationResponse(totalPage: 1, rows: []);
    }
  }

  /// Load initial columns from API
  Future<void> _loadColumns() async {
    try {
      final response = await dio.post('/pluto/columns', data: {'collection': collection});

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> columnsData = data['columns'] ?? [];

        for (final colData in columnsData) {
          final field = colData['field'] as String;
          final title = colData['title'] as String;
          final type = colData['type'] as String;

          PlutoColumnType columnType;
          switch (type) {
            case 'number':
              columnType = PlutoColumnType.number();
              break;
            case 'datetime':
              columnType = PlutoColumnType.date();
              break;
            case 'boolean':
              columnType = PlutoColumnType.text(); // PlutoGrid doesn't have boolean type
              break;
            default:
              columnType = PlutoColumnType.text();
          }

          columns.add(PlutoColumn(title: title, field: field, type: columnType));
        }

        // Refresh grid with loaded columns
        if (mounted && _stateManager != null) {
          _stateManager!.refColumns.clear();
          _stateManager!.refColumns.addAll(columns);
          _stateManager!.notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading columns: $e');
      // Fallback to default columns if API fails
      for (int i = 0; i < 5; i++) {
        columns.add(PlutoColumn(title: 'Column $i', field: i.toString(), type: PlutoColumnType.number()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row moving')),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) async {
          _stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);

          // Load columns from API first
          await _loadColumns();
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
