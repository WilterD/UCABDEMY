import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// SERVIDOR HEROKU
String url = 'https://ucabdemy.herokuapp.com';
// SERVIDOR DE PRUEBA
// String url = 'http://192.168.1.104:8383';

Future<http.Response> uploadVideo({required String pathVideo}) async {
  http.Response? response;
  try{
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
    };
    final request = http.MultipartRequest('POST',Uri.parse('$url/api/uploadVideo'));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('ucab',pathVideo));
    final streamedResponse = await request.send();
    response = await http.Response.fromStream(streamedResponse);
  }catch(ex){
    print(ex.toString());
  }

  return response!;
}