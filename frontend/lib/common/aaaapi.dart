import 'dart:convert';

import 'package:app_chat/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
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
}

void main() async {
  API a = API();

  MyUser user = MyUser.fromPem("aab", "aab", ut.A, ut.B);
  String token = await a.getLoginToken(user) ?? "";
  print(token);
  print(await a.getUserPublickey("bb", token));
}
