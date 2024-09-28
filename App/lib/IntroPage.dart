// import 'package:flutter/material.dart';
// import 'main.dart';
//
// // 引導畫面1
// class IntroPage1 extends StatelessWidget {
//   final VoidCallback onNext;
//
//   const IntroPage1({super.key, required this.onNext});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Column(
//         children: <Widget>[
//           const Expanded(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   '歡迎使用\n聽障人士說話矯正系統',
//                   style: TextStyle(fontSize: 24),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: ElevatedButton(
//               onPressed: onNext,
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Colors.blue,
//               ),
//               child: const Text('下一步'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // 引導畫面2
// class IntroPage2 extends StatelessWidget {
//   final VoidCallback onNext;
//
//   const IntroPage2({super.key, required this.onNext});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Column(
//         children: <Widget>[
//           const Expanded(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   '我們會為您的發音進行監測\n並提出改善建議',
//                   style: TextStyle(fontSize: 24),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: ElevatedButton(
//               onPressed: onNext,
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Colors.blue,
//               ),
//               child: const Text('下一步'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // 引導畫面3
// class IntroPage3 extends StatefulWidget {
//   const IntroPage3({super.key});
//
//   @override
//   _IntroPage3State createState() => _IntroPage3State();
// }
//
// class _IntroPage3State extends State<IntroPage3> {
//   bool _isChecked = false; //勾選框的狀態
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Column(
//         children: <Widget>[
//           // 中間的文字
//           const Expanded(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   '測試中會收集您的聲音\n請勾選下方同意欄位\n繼續使用',
//                   style: TextStyle(fontSize: 24),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//           // 隱私權勾選框和下一步按鈕
//           Padding(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Checkbox(
//                       value: _isChecked,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           _isChecked = value ?? false;
//                         });
//                       },
//                     ),
//                     const Text(
//                       '我同意收集聲音數據',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: _isChecked
//                       ? () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const HomePage()),
//                     );
//                   }
//                       : null, // 按鈕在未勾選時不可點擊
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.blue,
//                   ),
//                   child: const Text('下一步'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
