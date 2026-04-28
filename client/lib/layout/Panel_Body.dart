import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speanmeas/page/Customer.dart';
import 'package:speanmeas/page/Dashboard.dart';
import 'package:speanmeas/page/Room.dart';
import 'package:speanmeas/layout/Variable.dart';
import 'package:speanmeas/page/Setting.dart';
import 'package:speanmeas/page/Staff.dart';
import 'package:speanmeas/page/User.dart';
import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Variable(), //
      child: const Body(),
    ),
  );
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body',
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: const Panel_Body_()),
    );
  }
}

class Panel_Body_ extends StatefulWidget {
  const Panel_Body_({super.key});

  @override
  State<Panel_Body_> createState() => _Panel_Body_State();
}

class _Panel_Body_State extends State<Panel_Body_> {
  //
  String body = "Dashboard";

  //
  Map<String, Widget> pages = {
    "Dashboard": Dashboard_(), //
    "Room": Room_(), //
    "Setting": Setting_(),
    "Customer": Customer_(),
    "User": User_(),
    "Staff": Staff_(),
  };

  @override
  Widget build(BuildContext context) {
    final v = context.watch<Variable>();

    // validate body
    if (pages.containsKey(v.body)) {
      body = v.body;
    }

    return IndexedStack(
      index: pages.keys.toList().indexOf(body), //
      children: pages.values.toList(), //
    );
  }
}
