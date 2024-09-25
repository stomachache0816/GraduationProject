import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';  // 用於解析 JSON 響應

Future<void> uploadAudioFile(String filePath) async {
  var uri = Uri.parse('http://192.168.254.156:5000/app_voice');

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

  return result;
}