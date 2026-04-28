import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final isMobile = MediaQuery.of(context).size.width < 800;
    final v = context.watch<Variable>();
    return ListView(
      // shrinkWrap: true,
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

        // Reports
        ExpansionTile(
          leading: Icon(Icons.list_alt_outlined),
          title: Text('Reports'),
          children: [
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Report #1', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Report #2', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Report #3', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
          ],
        ),

        // Option
        ExpansionTile(
          leading: Icon(Icons.list_alt_outlined),
          title: Text('Options'),
          children: [
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Option #1', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Option #2', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.school_outlined), //
              title: Text('Option #3', overflow: TextOverflow.ellipsis, maxLines: 1),
              onTap: () {},
            ),
          ],
        ),

        ListTile(
          leading: Icon(Icons.people_outline),
          title: Text("Customer"),
          onTap: () {
            if (v.body != "Customer") {
              v.body = "Customer";
              v.notifyListeners();
            }
            if (isMobile) Navigator.pop(context);
          }, //
        ),

        // Spacer(),

        // Settings
        ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text("Setting"),
          onTap: () {
            if (v.body != "Setting") {
              v.body = "Setting";
              v.notifyListeners();
            }
          }, //
        ),

        // User Profile
        ListTile(
          leading: Icon(Icons.person_outline),
          title: Text("User"),
          onTap: () {
            if (v.body != "User") {
              v.body = "User";
              v.notifyListeners();
            }
            if (isMobile) Navigator.pop(context);
          }, //
        ),
      ],
    );
  }
}
