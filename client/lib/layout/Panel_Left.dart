import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speanmeas/Environment.dart';
import 'package:speanmeas/layout/Variable.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Variable(), //
      child: const Panel_Left(),
    ),
  );
}

class Panel_Left extends StatelessWidget {
  const Panel_Left({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(body: const Panel_Left_()),
    );
  }
}

class Panel_Left_ extends StatefulWidget {
  const Panel_Left_({super.key});

  @override
  State<Panel_Left_> createState() => _Panel_Left_State();
}

class _Panel_Left_State extends State<Panel_Left_> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < MOBILE_SCREEN_WIDTH;
    final v = context.watch<Variable>();
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(Icons.dashboard_outlined),
                title: Text("Dashboard"),
                onTap: () {
                  if (v.body != "Dashboard") {
                    v.body = "Dashboard";
                    v.notifyListeners();
                  }
                  if (isMobile) Navigator.pop(context);
                }, //
              ),

              // Occupancy
              ListTile(
                leading: Icon(Icons.bar_chart_outlined),
                title: Text("Occupancy"),
                onTap: () {}, //
              ),
              ListTile(
                leading: Icon(Icons.hotel_outlined),
                title: Text("Room"),
                onTap: () {
                  if (v.body != "Room") {
                    v.body = "Room";
                    v.notifyListeners();
                  }
                  if (isMobile) Navigator.pop(context);
                }, //
              ),

              ListTile(
                leading: Icon(Icons.people_outline),
                title: Text("Guest"),
                onTap: () {
                  if (v.body != "Guest") {
                    v.body = "Guest";
                    v.notifyListeners();
                  }
                  if (isMobile) Navigator.pop(context);
                }, //
              ),

              // Booking
              ExpansionTile(
                leading: Icon(Icons.table_bar_outlined),
                title: Text('Front Desk'),
                children: [
                  ListTile(
                    leading: Icon(Icons.login_outlined), //
                    title: Text('Check In/Out', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.app_registration), //
                    title: Text('Registration', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Currency Exchange', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined), //
                    title: Text('Guest Complaint', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Booking
              ExpansionTile(
                leading: Icon(Icons.book_online_outlined),
                title: Text('Booking'),
                children: [
                  ListTile(
                    leading: Icon(Icons.login_outlined), //
                    title: Text('All Bookings', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.app_registration), //
                    title: Text('Edit Booking', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Cancel Booking', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined), //
                    title: Text('Group Reservations', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined), //
                    title: Text('Waiting List', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Guest
              ExpansionTile(
                leading: Icon(Icons.people_outline), //
                title: Text('Guests'),
                children: [
                  ListTile(
                    leading: Icon(Icons.people_outline), //
                    title: Text('All Guests', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.edit_outlined), //
                    title: Text('Edit Guest', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Rooms
              ExpansionTile(
                leading: Icon(Icons.hotel_outlined), //
                title: Text('Rooms'),
                children: [
                  ListTile(
                    leading: Icon(Icons.hotel_outlined), //
                    title: Text('All Rooms', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),

                  ListTile(
                    leading: Icon(Icons.edit_outlined), //
                    title: Text('Edit Room', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),

                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Rate & Price', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Housekeeping
              ExpansionTile(
                leading: Icon(Icons.cleaning_services_outlined), //
                title: Text('Housekeeping'),
                children: [
                  ListTile(
                    leading: Icon(Icons.cleaning_services_outlined), //
                    title: Text('Room Cleaning', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.school_outlined), //
                    title: Text('Laundry Service', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.edit_outlined), //
                    title: Text('Cleaning Schedule', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.category_outlined), //
                    title: Text('Room Status Board', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Rate & Price', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Lost & Found', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.attach_money), //
                    title: Text('Inspection Checklist', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Staff
              ExpansionTile(
                leading: Icon(Icons.hotel_outlined), //
                title: Text('Restaurant'),
                children: [
                  ListTile(
                    leading: Icon(Icons.room_service_outlined), //
                    title: Text('Menu', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.school_outlined), //
                    title: Text('Table Management', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Staff
              ExpansionTile(
                leading: Icon(Icons.hotel_outlined), //
                title: Text('Staff'),
                children: [
                  ListTile(
                    leading: Icon(Icons.room_service_outlined), //
                    title: Text('All Staff', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {
                      if (v.body != "Staff") {
                        v.body = "Staff";
                        v.notifyListeners();
                      }
                      if (isMobile) Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.school_outlined), //
                    title: Text('Manager Staff', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Departments
              ExpansionTile(
                leading: Icon(Icons.hotel_outlined), //
                title: Text('Departments'),
                children: [
                  ListTile(
                    leading: Icon(Icons.room_service_outlined), //
                    title: Text('All Departments', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.school_outlined), //
                    title: Text('Manager Departments', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),
              // Departments
              ExpansionTile(
                leading: Icon(Icons.hotel_outlined), //
                title: Text('Wellness & Concierge'),
                children: [
                  ListTile(
                    leading: Icon(Icons.room_service_outlined), //
                    title: Text('Spa & Wellness', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),
              // Assets
              ExpansionTile(
                leading: Icon(Icons.inventory_2_outlined), //
                title: Text('Assets'),
                children: [
                  ListTile(
                    leading: Icon(Icons.inventory_2_outlined), //
                    title: Text('All Assets', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.edit_outlined), //
                    title: Text('Manager Assets', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),

              // Reports
              ExpansionTile(
                leading: Icon(Icons.assessment_outlined), //
                title: Text('Reports'),
                children: [
                  ListTile(
                    leading: Icon(Icons.inventory_2_outlined), //
                    title: Text('Stocks', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment_outlined), //
                    title: Text('Expenses', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment_outlined), //
                    title: Text('Revenue', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment_outlined), //
                    title: Text('Occupancy', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.assessment_outlined), //
                    title: Text('Bookings', overflow: TextOverflow.ellipsis, maxLines: 1),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // Settings
        ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text("Setting"),
          onTap: () {
            if (v.body != "Setting") {
              v.body = "Setting";
              v.notifyListeners();
            }
            if (isMobile) Navigator.pop(context);
          }, //
        ),

        // // User Profile
        // ListTile(
        //   leading: Icon(Icons.person_outline),
        //   title: Text("User"),
        //   onTap: () {
        //     if (v.body != "User") {
        //       v.body = "User";
        //       v.notifyListeners();
        //     }
        //     if (isMobile) Navigator.pop(context);
        //   }, //
        // ),
      ],
    );
  }
}
