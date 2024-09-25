import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final VoidCallback onClose; // 用於關閉選單的回調函數

  const DrawerMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // 背景濾鏡顏色
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: onClose, // 點擊濾鏡區域時關閉選單
            child: Container(
              color: Colors.black54,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // 選單寬度
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('個人檔案'),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  ListTile(
                    title: const Text('使用說明'),
                    onTap: () {
                      Navigator.pushNamed(context, '/help');
                    },
                  ),
                  ListTile(
                    title: const Text('通知設定'),
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  ListTile(
                    title: const Text('歷史紀錄'),
                    onTap: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  ListTile(
                    title: const Text('系統設定'),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}