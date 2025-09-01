import 'package:flutter/material.dart';
import 'nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.2, 1.0], // 20% gradient, 80% สีล่าง
                colors: [
                  Color.fromARGB(90, 3, 130, 98), // เขียวเข้ม
                  Color.fromARGB(60, 244, 243, 243), // ขาวอมเทา
                  Color(0xFFF4F3F3), // ขาวอมเทา
                ],
              ),
            ),
          ),
          const Center(child: Text('This is home page')),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
