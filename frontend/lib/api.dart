import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_chat/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as hp;
import 'package:app_chat/util.dart' as ut;
import 'package:web_socket_client/web_socket_client.dart';

class API {
  static API? _instance;

  static API ins() {
    _instance ??= API();
    return _instance!;
  }

  final baseUrl = "http://127.0.0.1:8080";

  Future<String?> getLoginToken(MyUser user) async {
    var res = await http.post(Uri.parse("$baseUrl/token"),
        body: {"username": user.username, "password": user.password});

    if (res.statusCode == 200) return jsonDecode(res.body)['access_token'];
    return null;
  }

  Future<String?> getUserPublickey(String username, String tkn) async {
    var res = await http.get(Uri.parse("$baseUrl/user/$username/publickey"),
        headers: {"Authorization": "Bearer $tkn"});

    debugPrint(res.body);
    if (res.statusCode == 200) return jsonDecode(res.body)['publicKey'];
    return null;
  }

  WebSocket connectSocket(String tkn) {
    return WebSocket(Uri.parse('http://127.0.0.1:8080?token=$tkn'));
  }

  Future<String?> uploadAttachment(String filePath, String tkn) async {
    Dio dio = Dio();

    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
    });
    var response = await dio.post("$baseUrl/attachment",
        data: formData,
        options: Options(
            headers: {"Authorization": "Bearer $tkn", 'accept': 'application/json'}));
    return response.data['id'];
  }

  Future<String?> uploadAttachmentFromBytes(Uint8List bytes, String tkn) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/attachment"));
    request.files.add(http.MultipartFile.fromBytes('file', bytes,
        contentType: hp.MediaType('image', 'png')));

    request.headers
        .addAll({"Authorization": "Bearer $tkn", 'accept': 'application/json'});
    var response = await request.send();

    if (response.statusCode != 200) return null;
    debugPrint(await response.stream.bytesToString());
    return jsonDecode(await response.stream.bytesToString())['imgId'];
  }

  Future<void> sendPostRequest(String filePath, String tkn) async {
    var url = Uri.parse('http://127.0.0.1:8080/attachment/');
    var file = File('path_to_your_file/a_1.jpg');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $tkn'
      ..headers['accept'] = 'application/json'
      ..files.add(await http.MultipartFile.fromPath('file', file.path,
          contentType: hp.MediaType('image', 'jpeg')));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Uploaded!');
    } else {
      print('Upload failed with status ${response.statusCode}');
    }
  }

  Future<Uint8List?> getAttachmentByte(String imgId, String tkn) async {
    var res = await http.get(Uri.parse("$baseUrl/attachment/$imgId"),
        headers: {"Authorization": "Bearer $tkn"});

    if (res.statusCode != 200) return null;
    return res.bodyBytes;
  }
}

// void main() async {
//   API a = API();

//   MyUser user = MyUser.fromPem("aab", "aab", ut.A, ut.B);
//   String token = await a.getLoginToken(user) ?? "";
//   print(token);
//   print(await a.getUserPublickey("bb", token));
// }
