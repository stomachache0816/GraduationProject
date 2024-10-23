import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';  // 用於解析 JSON 響應

Future<String> uploadAudioFile(String filePath) async {
  var uri = Uri.parse('http://192.168.1.112:5000/app_voice');

  var request = http.MultipartRequest('POST', uri);

  // 將錄音文件添加到請求中
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: basename(filePath),
    ),
  );

  // 發送請求
  var response = await request.send();
  var responseData = await http.Response.fromStream(response);
  var jsonResponse = json.decode(responseData.body);
  var result = jsonResponse['message'];

  if (response.statusCode == 200) {
    print('File uploaded successfully');
    print('Message from server: $result');
  } else {
    print('File upload failed with status: ${response.statusCode}');
  }

  await Future.delayed(const Duration(seconds: 2));
  return result;
}

Future<Map<dynamic, dynamic>> getAnalysis() async {
  var uri = Uri.parse('http://192.168.1.112:5000/get_analysis');
  final response = await http.get(uri);

  Map<dynamic, dynamic> analysis = json.decode(response.body);

  var main_sentence = analysis["main_sentence"];
  var correct_info_list = analysis["correct_info_list"];

  if (response.statusCode == 200) {
    print('main_sentence: $main_sentence');
    print('correct_info_list: $correct_info_list');
  } else {
    print('failed with status: ${response.statusCode}');
  }

  await Future.delayed(const Duration(seconds: 2));
  return analysis;
}

Future<List<dynamic>> getHistory() async {
  var uri = Uri.parse('http://192.168.1.112:5000/get_history');
  final response = await http.get(uri);

  List<dynamic> historyRecords = json.decode(response.body);

  if (response.statusCode == 200) {
    print('main_sentence: $historyRecords');
  } else {
    print('failed with status: ${response.statusCode}');
  }

  await Future.delayed(const Duration(seconds: 2));
  return historyRecords;
}