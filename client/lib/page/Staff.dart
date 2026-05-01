import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:speanmeas/utility/Dio.dart';

void main() {
  runApp(const MaterialApp(home: Staff()));
}

class Staff extends StatelessWidget {
  const Staff({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: StaffTable());
  }
}

class StaffTable extends StatefulWidget {
  const StaffTable({super.key});

  @override
  State<StaffTable> createState() => _StaffTableState();
}

class _StaffTableState extends State<StaffTable> {
  PlutoGridStateManager? stateManager;
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  // API endpoints
  static const String baseEndpoint = '/staff';

  @override
  void initState() {
    super.initState();
    _initColumns();
  }

  void _initColumns() {
    columns = [
      PlutoColumn(title: 'ID', field: '_id', type: PlutoColumnType.text(), enableEditingMode: false, hide: true),
      PlutoColumn(title: 'Name', field: 'name', type: PlutoColumnType.text(), enableEditingMode: true),
      PlutoColumn(title: 'Email', field: 'email', type: PlutoColumnType.text(), enableEditingMode: true),
      PlutoColumn(title: 'Phone', field: 'phone_number', type: PlutoColumnType.number(), enableEditingMode: true),
      PlutoColumn(title: 'Position', field: 'position', type: PlutoColumnType.text(), enableEditingMode: true),
      PlutoColumn(title: 'Department', field: 'department', type: PlutoColumnType.text(), enableEditingMode: true),
      PlutoColumn(
        title: 'Salary',
        field: 'salary',
        type: PlutoColumnType.currency(symbol: '\$'),
        enableEditingMode: true,
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 100,
        renderer: (rendererContext) {
          return IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () => _deleteStaff(rendererContext.cell.row),
          );
        },
      ),
    ];
  }

  Future<void> _loadStaff({String? query}) async {
    setState(() => isLoading = true);
    try {
      final formData = FormData.fromMap({if (query != null && query.isNotEmpty) 'query': query, 'offset': 0, 'limit': 1000});

      final response = await dio.post('$baseEndpoint/read', data: formData);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        setState(() {
          rows = data.map((item) => _buildRow(item)).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Error loading staff: $e', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  PlutoRow _buildRow(Map<String, dynamic> item) {
    return PlutoRow(
      cells: {
        '_id': PlutoCell(value: item['_id']?['\$oid'] ?? item['_id'] ?? ''),
        'name': PlutoCell(value: item['name'] ?? ''),
        'email': PlutoCell(value: item['email'] ?? ''),
        'phone_number': PlutoCell(value: item['phone_number'] != null ? (item['phone_number'] as num).toDouble() : null),
        'position': PlutoCell(value: item['position'] ?? ''),
        'department': PlutoCell(value: item['department'] ?? ''),
        'salary': PlutoCell(value: item['salary'] != null ? (item['salary'] as num).toDouble() : null),
        'actions': PlutoCell(value: ''),
      },
    );
  }

  Future<void> _createStaff() async {
    try {
      final response = await dio.post('$baseEndpoint/create');
      if (response.statusCode == 200) {
        _showSnackBar('Staff created successfully');
        _loadStaff();
      }
    } catch (e) {
      _showSnackBar('Error creating staff: $e', isError: true);
    }
  }

  Future<void> _updateCell(PlutoGridOnChangedEvent event) async {
    final row = event.row;
    final column = event.column;
    final value = event.value;
    final id = row.cells['_id']?.value?.toString();

    if (id == null || id.isEmpty) return;

    try {
      String endpoint;
      Map<String, dynamic> data = {'id': id};

      if (column.field == 'phone_number' || column.field == 'salary') {
        endpoint = '$baseEndpoint/update/${column.field}';
        data['value'] = value != null ? double.tryParse(value.toString()) : null;
      } else {
        endpoint = '$baseEndpoint/update/${column.field}';
        data['value'] = value?.toString();
      }

      final formData = FormData.fromMap(data);
      final response = await dio.post(endpoint, data: formData);

      if (response.statusCode == 200) {
        _showSnackBar('${column.title} updated');
      }
    } catch (e) {
      _showSnackBar('Error updating: $e', isError: true);
    }
  }

  Future<void> _deleteStaff(PlutoRow row) async {
    final id = row.cells['_id']?.value?.toString();
    if (id == null || id.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: const Text('Are you sure you want to delete this staff member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final formData = FormData.fromMap({'id': id});
      final response = await dio.post('$baseEndpoint/delete', data: formData);

      if (response.statusCode == 200) {
        _showSnackBar('Staff deleted');
        stateManager?.removeRows([row]);
      }
    } catch (e) {
      _showSnackBar('Error deleting staff: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: isLoading && rows.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (event) {
                    stateManager = event.stateManager;
                    stateManager?.setShowColumnFilter(true);
                    _loadStaff();
                  },
                  onChanged: _updateCell,
                  configuration: const PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(rowHeight: 40, columnHeight: 40, gridBorderColor: Colors.grey),
                    columnSize: PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _createStaff,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Staff'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () => _loadStaff(), icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search staff...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onSubmitted: (value) => _loadStaff(query: value),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _loadStaff(query: searchController.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
