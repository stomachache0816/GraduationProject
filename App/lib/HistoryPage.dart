import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  // Remove 'const' from the class definition
  final List<dynamic> historyRecords;
  const HistoryPage({super.key, required this.historyRecords});

  // 模擬的歷史紀錄數據
  // final List<Map<String, String>> _historyRecords = [
  //   {'title': '今天是禮拜日', 'date': '2024/09/20', 'detail': 'pinyin\nbopomofo'},
  //   {'title': '紀錄 2', 'date': '2024/09/21', 'detail': '這是紀錄 2 的詳細內容。'},
  //   {'title': '紀錄 3', 'date': '2024/09/22', 'detail': '這是紀錄 3 的詳細內容。'},
  // ];

  // 彈出對話框來顯示詳細內容
  void _showDetailDialog(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(detail),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史紀錄'),
        backgroundColor: const Color(0xFFFFF09A),
      ),
      body: ListView.builder(
        itemCount: historyRecords.length,
        itemBuilder: (context, index) {
          final record = historyRecords[index];
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(record['title']!),
              trailing: ElevatedButton(
                onPressed: () {
                  _showDetailDialog(context, record['title']!, record['detail']!);
                },
                child: const Text('查看詳細'),
              ),
            ),
          );
        },
      ),
    );
  }
}
