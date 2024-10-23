import 'package:flutter/material.dart';
import 'package:index/main.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 220), // 調整上方間距
            Center(
              child: Column(
                children: [
                  const Text(
                    '發聲之旅',
                    style: TextStyle(fontSize: 48, color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '聽障人士發音輔助與矯正系統',
                    style: TextStyle(fontSize: 24, color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The Power of Pronouncement',
                    style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9E0FF), // 按鈕顏色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0), // 設定四角的弧度
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0), // 設定按鈕的內邊距
                    ),
                    child: const Text(
                      'START',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
