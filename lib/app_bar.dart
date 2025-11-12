import 'package:flutter/material.dart';
import 'package:project/screens/splash_screen.dart';

class GroceriesApp extends StatelessWidget {
  const GroceriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: const TextStyle(color: Colors.black),
              prefixIconColor: Colors.grey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black,width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF53B175),
                    width: 2,
                  )
              )
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(350, 55),
                backgroundColor: const Color(0xFF53B175),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
            ),
          )
      ),
    );
  }
}
