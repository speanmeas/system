import 'package:flutter/material.dart';
import 'package:speanmeas/theme/Theme_Data.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  runApp(const Room());
}

class Room extends StatelessWidget {
  const Room({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room', //
      theme: Theme_Data(),
      debugShowCheckedModeBanner: false,
      home: const Room_(),
    );
  }
}

class Room_ extends StatefulWidget {
  const Room_({super.key});

  @override
  State<Room_> createState() => _Room_State();
}

class _Room_State extends State<Room_> {
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 120 * 10,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _column_builder("Column 0"), //
                        _column_builder("Column 1"), //
                        _column_builder("Column 2"), //
                        _column_builder("Column 3"), //
                        _column_builder("Column 4"),
                        _column_builder("Column 5"),
                        _column_builder("Column 6"),
                        _column_builder("Column 7"),
                        _column_builder("Column 8"),
                        _column_builder("Column 9"),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 1000,
                        itemBuilder: (context, index) {
                          return _row_builder(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _column_builder(String text) {
    return Container(height: 40, width: 120, alignment: Alignment.center, child: Text(text));
  }

  _row_builder(int index) {
    return Row(
      children: [
        _cell_builder("Data $index-0"), //
        _cell_builder("Data $index-1"), //
        _cell_builder("Data $index-2"),
        _cell_builder("Data $index-3"),
        _cell_builder("Data $index-4"),
        _cell_builder("Data $index-5"),
        _cell_builder("Data $index-6"),
        _cell_builder("Data $index-7"),
        _cell_builder("Data $index-8"),
        _cell_builder("Data $index-9"),
      ],
    );
  }

  _cell_builder(String text) {
    return Container(height: 40, width: 120, alignment: Alignment.center, child: Text(text));
  }
}
