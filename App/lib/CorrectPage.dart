import 'package:flutter/material.dart';
import 'package:index/main.dart';

class CorrectPage extends StatelessWidget {
  const CorrectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFa1c4fd),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 60,
              child: Image.asset(
                  'assets/images/sound.png'), // Placeholder for sound wave
            ),
            const Text(
              '根據錄音內容，較不標準的地方',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 24),
                  children: [
                    TextSpan(text: '「今天的天'),
                    TextSpan(
                      text: 'ㄑㄧˇ',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(text: '真好」'),
                  ],
                ),
              ),
            ),
            // 箭頭
            const Icon(Icons.arrow_downward, size: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: const Text(
                '氣, ㄑㄧˇ, qi4',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('重新測試', style: TextStyle(fontSize: 28)),
                ),
              ],
            ),
            SizedBox(
              height: 60,
              child: Image.asset(
                  'assets/images/sound.png'),
            ),
          ],
        ),
      ),
    );
  }
}
