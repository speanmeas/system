import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(const Dashboard());
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Dashboard")), //
        body: const Dashboard_(),
      ),
    );
  }
}

class Dashboard_ extends StatefulWidget {
  const Dashboard_({super.key});

  @override
  State<Dashboard_> createState() => _Dashboard_State();
}

class _Dashboard_State extends State<Dashboard_> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                OutlinedButton(onPressed: () {}, child: Text("701")),
                OutlinedButton(onPressed: () {}, child: Text("702")),
              ],
            ),
            Column(
              children: [
                OutlinedButton(onPressed: () {}, child: Text("703")),
                OutlinedButton(onPressed: () {}, child: Text("704")),
              ],
            ),
            Expanded(
              child: SizedBox(
                height: 110,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(10, (index) {
                      final hour = (8 + index).toString().padLeft(2, '0');
                      final label = '$hour:00';
                      final isLast = index == 9;

                      return Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(label),
                            ],
                          ),
                          if (!isLast) Container(width: 60, height: 2, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.grey.shade400),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum RoomStatus { available, booked, maintenance }

class RoomItem {
  final String number;
  final String type;
  final double pricePerNight;
  RoomStatus status;
  String? guestName;

  RoomItem({required this.number, required this.type, required this.pricePerNight, required this.status, this.guestName});
}

class HotelDashboardModel extends ChangeNotifier {
  final List<RoomItem> rooms = [RoomItem(number: '701', type: 'Deluxe', pricePerNight: 65, status: RoomStatus.booked, guestName: 'Sokha'), RoomItem(number: '702', type: 'Deluxe', pricePerNight: 65, status: RoomStatus.available), RoomItem(number: '703', type: 'Suite', pricePerNight: 95, status: RoomStatus.available), RoomItem(number: '704', type: 'Suite', pricePerNight: 95, status: RoomStatus.maintenance), RoomItem(number: '705', type: 'Standard', pricePerNight: 45, status: RoomStatus.available), RoomItem(number: '706', type: 'Standard', pricePerNight: 45, status: RoomStatus.booked, guestName: 'Dara')];

  String _search = '';
  RoomStatus? _filter;

  String get search => _search;
  RoomStatus? get filter => _filter;

  int get totalRooms => rooms.length;
  int get availableRooms => rooms.where((r) => r.status == RoomStatus.available).length;
  int get bookedRooms => rooms.where((r) => r.status == RoomStatus.booked).length;
  int get maintenanceRooms => rooms.where((r) => r.status == RoomStatus.maintenance).length;

  List<RoomItem> get visibleRooms {
    return rooms.where((room) {
      final bySearch = _search.isEmpty || room.number.toLowerCase().contains(_search.toLowerCase());
      final byFilter = _filter == null || room.status == _filter;
      return bySearch && byFilter;
    }).toList();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilter(RoomStatus? value) {
    _filter = value;
    notifyListeners();
  }

  void bookRoom(String number, String guestName) {
    final room = rooms.firstWhere((r) => r.number == number);
    if (room.status == RoomStatus.available) {
      room.status = RoomStatus.booked;
      room.guestName = guestName;
      notifyListeners();
    }
  }

  void checkoutRoom(String number) {
    final room = rooms.firstWhere((r) => r.number == number);
    if (room.status == RoomStatus.booked) {
      room.status = RoomStatus.available;
      room.guestName = null;
      notifyListeners();
    }
  }
}

class HotelManagementDashboard extends StatelessWidget {
  const HotelManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => HotelDashboardModel(), child: const _HotelDashboardView());
  }
}

class _HotelDashboardView extends StatelessWidget {
  const _HotelDashboardView();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HotelDashboardModel>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Total Rooms', value: model.totalRooms.toString(), color: Colors.blue),
              _StatCard(label: 'Available', value: model.availableRooms.toString(), color: Colors.green),
              _StatCard(label: 'Booked', value: model.bookedRooms.toString(), color: Colors.orange),
              _StatCard(label: 'Maintenance', value: model.maintenanceRooms.toString(), color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: model.setSearch,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search room number', border: OutlineInputBorder(), isDense: true),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<RoomStatus?>(
                value: model.filter,
                hint: const Text('Filter'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: RoomStatus.available, child: Text('Available')),
                  DropdownMenuItem(value: RoomStatus.booked, child: Text('Booked')),
                  DropdownMenuItem(value: RoomStatus.maintenance, child: Text('Maintenance')),
                ],
                onChanged: model.setFilter,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: model.visibleRooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.8),
              itemBuilder: (_, i) => _RoomCard(room: model.visibleRooms[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomItem room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final model = context.read<HotelDashboardModel>();
    final color = switch (room.status) {
      RoomStatus.available => Colors.green,
      RoomStatus.booked => Colors.orange,
      RoomStatus.maintenance => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room ${room.number}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${room.type} • \$${room.pricePerNight.toStringAsFixed(0)}/night'),
            const Spacer(),
            Row(
              children: [
                Chip(
                  label: Text(room.status.name),
                  side: BorderSide.none,
                  backgroundColor: color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (room.status == RoomStatus.available) ElevatedButton(onPressed: () => model.bookRoom(room.number, 'Walk-in Guest'), child: const Text('Book')) else if (room.status == RoomStatus.booked) OutlinedButton(onPressed: () => model.checkoutRoom(room.number), child: const Text('Checkout')) else const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
