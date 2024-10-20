import 'package:flutter/material.dart';
import 'package:index/main.dart';

class CorrectPage extends StatelessWidget {
  final Map analysis;
  const CorrectPage({super.key, required this.analysis});
  @override
  Widget build(BuildContext context) {
    String main_sentence = analysis["main_sentence"];

    List<dynamic> correct_info_list = analysis["correct_info_list"];
    //correct_info_list.length是字的數量
    String text = "";
    for (var correct_info in correct_info_list) {
      text += correct_info.join(', ') + "\n";
    }
    text = text.substring(0 , text.length-1);

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
                text: TextSpan(
                  text: main_sentence,
                  style: const TextStyle(fontSize: 24),
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
              child: Text(
                text,
                style: const TextStyle(fontSize: 24),
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
