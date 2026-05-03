import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(const User());
}

class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User',
      theme: Theme_Data(),
      home: Scaffold(body: const User_()),
    );
  }
}

class User_ extends StatefulWidget {
  const User_({super.key});

  @override
  State<User_> createState() => _User_State();
}

class _User_State extends State<User_> {
  List<String> header = [
    "ID", //
    "Name", //
    "Email", //
    "Phone", //
    "Role", //
  ];

  List<List<String>> data = [
    ["1", "John Doe", "john.doe@example.com", "123-456-7890", "Admin"],
    ["2", "Jane Smith", "jane.smith@example.com", "098-765-4321", "User"],
    ["3", "Alice Johnson", "alice.johnson@example.com", "555-1234", "User"],
    ["4", "Bob Brown", "bob.brown@example.com", "555-5678", "User"],
  ];

  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(header[0]), //
            SizedBox(width: 8),
            Text(header[1]), //
            SizedBox(width: 8),
            Text(header[2]), //
            SizedBox(width: 8),
            Text(header[3]), //
            SizedBox(width: 8),
            Text(header[4]), //
          ],
        ),

        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Text("$index"), //
                  SizedBox(width: 8),
                  Text(data[1][1]), //
                  SizedBox(width: 8),
                  Text(data[1][2]), //
                  SizedBox(width: 8),
                  Text(data[1][3]), //
                  SizedBox(width: 8),
                  Text(data[1][4]), //
                ],
              );
            },
            itemCount: 1000,
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center, //
          children: [
            IconButton(
              onPressed: () {
                isSearching = !isSearching;
                setState(() {});
              },
              icon: Icon(Icons.search),
            ),

            SizedBox(width: 8),
            Expanded(
              child: isSearching
                  ? SizedBox(
                      height: 32,
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true, //
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
          ],
        ),
      ],
    );
    // floatingActionButtonLocation: .centerFloat,
    // floatingActionButton: Padding(
    //   padding: .symmetric(horizontal: 8),
    //   child: Row(
    //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       SizedBox(width: 8),

    //       FloatingActionButton(
    //         child: Icon(Icons.add),
    //         onPressed: () {}, //
    //       ),
    //     ],
    //   ),
    // ),
  }
}
