import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _nickname = '使用者的暱稱'; // 初始暱稱

  // 彈出暱稱編輯對話框
  Future<void> _editNickname() async {
    TextEditingController nicknameController = TextEditingController(text: _nickname);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('編輯暱稱'),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(hintText: '輸入新的暱稱'),
          ),
          actions: <Widget>[
            // 取消按鈕：加上灰色樣式，表示關閉動作
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey, // 灰色字體表示取消動作
              ),
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
            ),
            // 儲存按鈕：主要按鈕樣式，表示確認操作
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // 藍色背景表示主要動作
              ),
              child: const Text('儲存'),
              onPressed: () {
                setState(() {
                  _nickname = nicknameController.text; // 更新暱稱
                });
                Navigator.of(context).pop(); // 關閉對話框
              },
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
        title: const Text('設定'),
        backgroundColor: const Color(0xFFFFF09A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 使用者個人資料
          const Text(
            '個人資料',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFFEE911)),
            title: const Text('暱稱'),
            subtitle: Text(_nickname),
            trailing: const Icon(Icons.edit),
            onTap: _editNickname, // 點擊時彈出編輯對話框
          ),
          const Divider(),

          // 系統通知設定
          const Text(
            '系統設定',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('通知'),
            subtitle: const Text('開啟或關閉系統通知'),
            value: true,
            onChanged: (bool value) {
              // 控制通知開關
            },
          ),
          SwitchListTile(
            title: const Text('音效'),
            subtitle: const Text('開啟或關閉應用程式音效'),
            value: true,
            onChanged: (bool value) {
              // 控制音效開關
            },
          ),
          const Divider(),

          // 隱私設定
          const Text(
            '隱私設定',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: const Text('隱私設定'),
            subtitle: const Text('管理隱私權限'),
            onTap: () {
              // 進入隱私設定畫面
            },
          ),
          const Divider(),
          // 關於我們
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('關於我們'),
            subtitle: const Text('查看應用程式資訊'),
            onTap: () {
              // 進入關於我們頁面
            },
          ),
          const Divider(),
          //刪除歷史紀錄
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('刪除歷史紀錄'),
            subtitle: const Text('清除裝置上的測試紀錄'),
            onTap: () {
              // 進入關於我們頁面
            },
          ),
        ],
      ),
    );
  }
}
