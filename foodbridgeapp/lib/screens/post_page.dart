import 'package:flutter/material.dart';
import 'nav_bar.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('This is post page')),
      bottomNavigationBar: NavBar(),
    );
  }
}
