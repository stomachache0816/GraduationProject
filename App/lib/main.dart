import 'package:flutter/material.dart';
import 'IntroPage.dart'; //引導畫面
import 'MenuPage.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'voice_API.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, //移掉debug旗幟
      home: const FirstPage(), //開始畫面
    );
  }
}

// 開始畫面
class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  void _nextPage(BuildContext context) {
    Navigator.push(
      context,
      _customPageRoute1(IntroPage1(onNext: () {
        Navigator.push(
          context,
          _customPageRoute1(IntroPage2(onNext: () {
            Navigator.push(
              context,
              _customPageRoute1(const IntroPage3()),
            );
          })),
        );
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('發音矯正系統'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '測試畫面-開始使用',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () => _nextPage(context), // 呼叫 _nextPage 函數
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('下一步'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// 主畫面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50.0), // 調整位置
                  child: Text(
                    '歡迎使用!',
                    style: TextStyle(fontSize: 48, color: Colors.black),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40.0), // 調整位置
                  child: Text(
                    '聽障人士說話矯正系統',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset('assets/images/voicelines2.png'), // 圖片路徑，先去yaml新增
                const Spacer(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: _toggleMenu,
                  child: const Icon(Icons.menu, color: Colors.black),
                ),
                label: '選單',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                label: '主畫面',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications, color: Colors.black),
                label: '通知',
              ),
            ],
            currentIndex: 1,
            backgroundColor: const Color(0xFFA1B7CD),
            onTap: (index) {
              switch (index) {
                case 0: // 選單
                  _toggleMenu();
                  break;
                case 1: // 主畫面
                  break;
                case 2: // 通知
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const NotificationsPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // 從右側進入
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ));
                  break;
              }
            },
          ),
            floatingActionButton: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 130.0, left: 35.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RecordingPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA0C3E2),
                          side: const BorderSide(color: Colors.white, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ).copyWith(
                          elevation: MaterialStateProperty.resolveWith<double>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return 4.0; // 按下時的陰影
                              }
                              return 8.0; // 常態陰影
                            },
                          ),
                        ),
                        child: const Text(
                          '開始使用',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // 按鈕之間的間距
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // 導航到使用教學頁面
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8CB3FF),
                          side: const BorderSide(color: Colors.white, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ).copyWith(
                          elevation: MaterialStateProperty.resolveWith<double>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return 4.0; // 按下時的陰影
                              }
                              return 8.0; // 常態陰影
                            },
                          ),
                        ),
                        child: const Text(
                          '使用教學',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
            if (_isMenuOpen)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _isMenuOpen ? 0 : -MediaQuery.of(context).size.width * 0.8,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                if (_isMenuOpen) _toggleMenu();
              },
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: _isMenuOpen ? Colors.black.withOpacity(0.5) : Colors.transparent,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: DrawerMenu(
                        onClose: _toggleMenu,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}

//錄音介面

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool _isRecording = false;
  bool _hasStopped = false;

  //飛雷神

  FlutterSoundRecorder? _recorder;
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
  }

  // 印出麥克風是否有用
  Future<void> requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      print('microphone ok');
    } else {
      print('microphone not ok');
    }
  }

  // 開始錄音
  Future<void> _startRecording() async {
    requestPermissions(); // 印出麥克風是否有用
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/recorded.wav';
    setState(() {
      _filePath = tempPath;
    });
    await _recorder!.startRecorder(toFile: _filePath, codec: Codec.pcm16WAV);
  }

  // 停止錄音
  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    uploadAudioFile(_filePath);
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _startRecording();
    }
    else {
      _stopRecording();
    }
  }

  //飛雷神

  void _goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultPage()), // 導向下一頁
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFa1c4fd),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRecording ? '結束後按下停止鈕' : '請按下按鈕後開始說話',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 130),
                // 外層長方形背景 + 陰影和邊框
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F9FF),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFA0C3E2),
                      width: 2.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 外層較大的淺色圓形背景 + 邊框
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.red.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                          border: Border.all(
                            color: _isRecording
                                ? Colors.red.withOpacity(0.5)
                                : Colors.blue.withOpacity(0.5),
                            width: 4.0,
                          ),
                        ),
                      ),
                      // 內層的圓形背景 + 邊框
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.red
                              : Colors.blue,
                          border: Border.all(
                            color: _isRecording
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            width: 4.0,
                          ),
                        ),
                      ),
                      // 麥克風圖標
                      const Icon(
                        Icons.mic,
                        size: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  child: Text(_isRecording ? '停止錄製' : '開始錄製'),
                ),
                const SizedBox(height: 20), // 按鈕間距
                if (!_isRecording && _hasStopped) // 只在停止錄製且已按過停止鍵時顯示
                  ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 60),
                      textStyle: const TextStyle(fontSize: 24),
                    ),
                    child: const Text('下一步'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 錄音結束後

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/voicelines2.png'),
            const SizedBox(height: 20), // 頂部間距

            // 新增的兩段文字訊息
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
                  child: const Center(
                    child: Text(
                      '錄音結果!',
                      style: TextStyle(fontSize: 18, color: Colors.black),
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
                    onPressed: () {

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
            Image.asset('assets/images/voicelines2.png'),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人檔案'),
      ),
      body: const Center(
        child: Text(
          '個人檔案畫面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: const Center(
        child: Text(
          '通知畫面',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// 自定義過場動畫(不知道為什麼搬不過去IntroPage，不過沒差)
PageRouteBuilder _customPageRoute1(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut; // 讓過渡效果更平滑

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var reverseTween = Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)).chain(CurveTween(curve: curve));
      var reverseAnimation = secondaryAnimation.drive(reverseTween);

      return Stack(
        children: [
          SlideTransition(position: reverseAnimation, child: child), // 舊頁面向左移動
          SlideTransition(position: offsetAnimation, child: child), // 新頁面向中間移動
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 450), // 調整動畫時間，更加明顯
  );
}


