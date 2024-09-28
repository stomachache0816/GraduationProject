import 'package:flutter/material.dart';
import 'package:index/IntroPage.dart';
import 'SettingPage.dart';
import 'ResultPage.dart';
import 'HistoryPage.dart';
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
      home: const IntroPage(), //開始畫面
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: _toggleMenu,
                  child: const Icon(Icons.history, color: Colors.black),
                ),
                label: '測驗紀錄',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                label: '主畫面',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings, color: Colors.black),
                label: '設定',
              ),
            ],
            currentIndex: 1,
            backgroundColor: const Color(0xFFA1B7CD),
            onTap: (index) {
              switch (index) {
                case 0: // 測驗紀錄
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => HistoryPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0); // 從右側進入
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                   ),
                  );
                  break;
                case 1: // 主畫面
                  break;
                case 2: // 設定
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SettingPage(),
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
                  )
                 );
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

  //串接部分--------------------------------------------------------------------

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
    var result = uploadAudioFile(_filePath);
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
    setState(() {
      _hasStopped = true ;
    });
  }

  // 切換錄製狀態
  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        // 停止錄製
        _isRecording = false;
        _hasStopped = true; // 停止錄製後設置為 true
        _stopRecording();
      } else {
        // 開始錄製
        _isRecording = true;
        _hasStopped = false; // 開始錄製時重設為 false
        _startRecording();
      }
    });
  }

  //串接部分-------------------------------------------------------------------

  void _goToResultPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultPage()), // 導向結果
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
                    onPressed: _goToResultPage,
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

// 自定義過場動畫
// PageRouteBuilder _customPageRoute1(Widget page) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(1.0, 0.0);
//       const end = Offset.zero;
//       const curve = Curves.easeInOut; // 讓過渡效果更平滑
//
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       var offsetAnimation = animation.drive(tween);
//
//       var reverseTween = Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)).chain(CurveTween(curve: curve));
//       var reverseAnimation = secondaryAnimation.drive(reverseTween);
//
//       return Stack(
//         children: [
//           SlideTransition(position: reverseAnimation, child: child), // 舊頁面向左移動
//           SlideTransition(position: offsetAnimation, child: child), // 新頁面向中間移動
//         ],
//       );
//     },
//     transitionDuration: const Duration(milliseconds: 450), // 調整動畫時間，更加明顯
//   );
// }


