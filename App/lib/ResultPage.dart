import 'package:flutter/material.dart';
import 'package:index/CorrectPage.dart';
import 'package:index/main.dart';
import 'package:index/voice_API.dart';

class ResultPage extends StatelessWidget {
  final String result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFfff09a), Color(0xFFfaff9a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/sound.png'),
            const SizedBox(height: 20), // 頂部間距
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    '根據我們的偵測~', // 第一段文字
                    style: TextStyle(fontSize: 28, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10), // 兩段文字間距
                  Text(
                    '得到的結果為', // 第二段文字
                    style: TextStyle(fontSize: 28, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // 新增的文字與長方形間距
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  height: 150,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // 長方形背景顏色
                    borderRadius: BorderRadius.circular(15.0), // 四角弧度
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      result,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            // 按鈕區域
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Map<dynamic, dynamic> analysis = await getAnalysis();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CorrectPage(analysis: analysis)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8CB3FF), // 藍色
                      minimumSize: const Size(120, 50),
                      elevation: 4,
                    ),
                    child: const Text(
                      '是',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F61), // 紅色
                      minimumSize: const Size(120, 50),
                      elevation: 4,
                    ),
                    child: const Text(
                      '重新錄製',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // 下方圖片固定在最下方
            const SizedBox(height: 10), // 底部間距
            Image.asset('assets/images/sound.png'),
          ],
        ),
      ),
    );
  }
}
