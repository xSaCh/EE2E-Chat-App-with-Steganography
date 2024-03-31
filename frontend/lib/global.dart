import 'package:app_chat/api.dart';
import 'package:app_chat/model.dart';
import 'package:app_chat/util.dart' as ut;
import 'package:flutter/material.dart';

String username = "";
String passw = '';
MyUser? gMe;

Future<bool> connectMyUser(String username, String passw) async {
  var me = MyUser.fromPem(username, passw, ut.A, ut.B);
  me.token = await API.ins().getLoginToken(me);
  debugPrint("${me.username} ${me.token}");
  gMe = me;
  return me.token != null;
}
