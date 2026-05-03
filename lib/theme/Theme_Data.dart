import 'package:flutter/material.dart';

ThemeData Theme_Data() {
  return ThemeData(
    //
    //
    fontFamily: 'NotoSansKhmer',
    //
    //
    colorScheme: ColorScheme.fromSeed(
      // seedColor: Colors.yellow[800]!,
      seedColor: Colors.blue,
      // background: const Color(0xFFFFD700), // gold color
      // seedColor: const Color(0xFFC0C0C0), // silver color
      // primary: Colors.blueAccent, //
    ),

    // [APP BAR]
    //
    appBarTheme: AppBarTheme(
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      // backgroundColor: Colors.white, //
      // foregroundColor: Colors.blue, //
      // shape: const RoundedRectangleBorder(
      //   side: BorderSide(
      // color: Colors.grey,
      //     width: 1, //
      //   ),
      // ),
      // elevation: 0,
    ),
    //
    //

    // [TEXT]
    //
    textTheme: const TextTheme(
      // bodyMedium: TextStyle(fontSize: 12.0), //
      // textcolor
    ),
    //
    //

    // [OUTLINED BUTTON]
    //
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16.0), //
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), //
        ),
        minimumSize: Size(0, 36),
        // maximumSize: Size(double.infinity, 40),
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(fontSize: 16.0), //
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), //
        ),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.blue, //
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), //
        ),
      ),
    ),
    //
    //

    //
    //
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), //
      ),
    ),

    drawerTheme: DrawerThemeData(
      width: 300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), //
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      //
      border: const OutlineInputBorder(),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      sizeConstraints: const BoxConstraints.tightFor(width: 40, height: 40),
    ),

    // iconButtonTheme: IconButtonThemeData(
    //   style: IconButton.styleFrom(
    //     foregroundColor: Colors.blue, //
    //     backgroundColor: Colors.transparent,
    //   ),
    // ),
    //
    //
    // expansionTileTheme: ExpansionTileThemeData(
    //   iconColor: Colors.black,
    //   textColor: Colors.black,
    //   collapsedIconColor: Colors.black,
    //   collapsedTextColor: Colors.black, //
    // ),

    // listtile
    // listTileTheme: ListTileThemeData(
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(0), //
    //   ),
    //   textColor: Colors.blue,
    //   iconColor: Colors.blue,
    // ),
    // bottomAppBarTheme: BottomAppBarThemeData(color: Colors.amber),
    // scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      // backgroundColor: Colors.blue, //
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      // set border around
    ),

    // platform: TargetPlatform.iOS,
    useMaterial3: true,
  );
}

// usage: Themes_Data.theme
