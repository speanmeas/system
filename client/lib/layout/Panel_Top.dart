import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:speanmeas/Environment.dart';
import 'package:speanmeas/layout/Variable.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Variable(), //
      child: const Panel_Top(),
    ),
  );
}

class Panel_Top extends StatelessWidget {
  const Panel_Top({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(body: const Panel_Top_()),
    );
  }
}

class Panel_Top_ extends StatefulWidget {
  const Panel_Top_({super.key});

  @override
  State<Panel_Top_> createState() => _Panel_Top_State();
}

class _Panel_Top_State extends State<Panel_Top_> {
  String VERSION = '0.0.0+0';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final info = await PackageInfo.fromPlatform();
    VERSION = '${info.version}+${info.buildNumber}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < MOBILE_SCREEN_WIDTH;
    // final v = context.watch<Variable>();
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        //
        if (!isMobile) SizedBox(width: 4), //
        // logo
        SizedBox(width: 32, height: 32, child: Placeholder()), //
        SizedBox(width: 4), //
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Spean Meas"), //
            Text(VERSION, style: TextStyle(fontSize: 12, color: Colors.blue)), //
          ],
        ),

        Spacer(),

        // Notification Icon
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined)), //
        // Dark Mode Toggle
        // IconButton(onPressed: () {}, icon: Icon(Icons.dark_mode_outlined)), //
        // Search Icon
        // IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)), //
        // Dark Mode Toggle
        // IconButton(onPressed: () {}, icon: Icon(Icons.dark_mode_outlined)), //
        SizedBox(width: 4), //
        // DropdownButton<String>(
        //   value: 'En',
        //   items: ['En', 'Kh'].map((String value) {
        //     return DropdownMenuItem<String>(value: value, child: Text(value));
        //   }).toList(),
        //   onChanged: (String? newValue) {},
        // ),
        // SizedBox(width: 10),

        // Login Icon
        IconButton(onPressed: () {}, icon: Icon(Icons.login_outlined)), //
        // User Avatar
        InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text("A"), //
            ),
          ),
        ),

        SizedBox(width: 8), //
      ],
    );
  }
}
