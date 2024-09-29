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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          // 背景圖片
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroundMain.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // 開始使用 (左上)
                Positioned(
                  right: -155,
                  top: 48,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecordingPage(),
                          )
                      );
                    },
                    child: Image.asset(
                      'assets/images/Start.png',
                      width: 700,
                      height: 700,
                    ),
                  ),
                ),
                // 歷史紀錄 (右上)
                Positioned(
                  right: -155,
                  top: 48,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryPage(),
                          )
                      );
                    },
                    child: Image.asset(
                      'assets/images/History.png',
                      width: 700,
                      height: 700,
                    ),
                  ),
                ),
                // 使用教學 (左下)
                Positioned(
                  left: -155,
                  bottom: 30,
                  child: GestureDetector(
                    onTap: () {
                      // 導向頁面3
                    },
                    child: Image.asset(
                      'assets/images/Teaching.png',
                      width: 700,
                      height: 700,
                    ),
                  ),
                ),
                // 設定 (右下)
                Positioned(
                  right: -155,
                  bottom: 30,
                  child: GestureDetector(
                    onTap: () {
                      // 導向頁面4
                    },
                    child: Image.asset(
                      'assets/images/Setting.png',
                      width: 700,
                      height: 700,
                    ),
                  ),
                ),
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
      MaterialPageRoute(builder: (context) => const ResultPage()), // 導向結果頁面
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