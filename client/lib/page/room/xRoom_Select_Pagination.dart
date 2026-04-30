import 'package:flutter/material.dart';

import 'package:speanmeas/theme/Theme_Data.dart';

void main() {
  runApp(Room_Select_Pagination());
}

class Room_Select_Pagination extends StatelessWidget {
  Room_Select_Pagination({super.key});

  dynamic input = {
    "total": 10000, //
    "selected": 10, //
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme_Data(), //
      debugShowCheckedModeBanner: false,
      home: Room_Select_Pagination_(input: input),
    );
  }
}

class Room_Select_Pagination_ extends StatefulWidget {
  Room_Select_Pagination_({super.key, required this.input});

  final dynamic input;

  @override
  State<Room_Select_Pagination_> createState() => _Room_Select_Pagination_State();
}

class _Room_Select_Pagination_State extends State<Room_Select_Pagination_> {
  //
  //

  dynamic output;

  dynamic options = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Pagination"), //
        centerTitle: true,
        toolbarHeight: 40,
        titleSpacing: 0,

        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.close, color: Colors.red),
          ),
          SizedBox(width: 8), //
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              if (options[index] == widget.input["selected"]) {
                return ListTile(
                  title: Text(options[index].toString()),
                  leading: Icon(Icons.check, color: Colors.blue),
                  onTap: () {
                    // widget.input["selected"] = widget.input["options"][index];
                  },
                );
              } else {
                return ListTile(
                  title: Text(options[index].toString()),
                  leading: const Icon(null),
                  onTap: () {
                    setState(() {
                      widget.input["selected"] = options[index];
                    });
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
