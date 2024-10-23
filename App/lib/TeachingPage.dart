import 'main.dart';
import 'package:flutter/material.dart';

class TeachingPage extends StatelessWidget {
  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用教學'),
        backgroundColor: const Color(0xFFFFF09A),
      ),
      body: SingleChildScrollView(
        child: Image.asset(
          'assets/images/TeachPage.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
