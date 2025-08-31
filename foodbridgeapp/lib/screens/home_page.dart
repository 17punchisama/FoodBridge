import 'package:flutter/material.dart';
import 'nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: Text('This is home page'),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}