import 'package:flutter/material.dart';
import 'package:foodbridgeapp/screens/login_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'post_page.dart';

class TemporaryScreen extends StatelessWidget {
  const TemporaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "หน้าแรกชั่วคราวให้ทุกคน\nกดเพจของตัวเองแล้วเขียนโค้ดได้เลย",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
              child: const Text('Home'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostPage()),
                );
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
