import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(const Customer());
}

class Customer extends StatelessWidget {
  const Customer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer',
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Customer")), //
        body: const Customer_(),
      ),
    );
  }
}

class Customer_ extends StatefulWidget {
  const Customer_({super.key});

  @override
  State<Customer_> createState() => _Customer_State();
}

class _Customer_State extends State<Customer_> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Customer"), //
      ],
    );
  }
}
