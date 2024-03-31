// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/pointycastle.dart';

class RemoteUser {
  String username;
  RSAPublicKey? publicKey;

  RemoteUser(this.username, {required this.publicKey});
  RemoteUser.fromPem(this.username, String publicPEMStr) {
    publicKey = CryptoUtils.rsaPublicKeyFromPem(publicPEMStr);
  }
}

class MyUser {
  String username;
  String password;
  RSAPublicKey? publicKey;
  RSAPrivateKey? privateKey;
  String? token;

  MyUser(this.username, this.password,
      {required this.publicKey, required this.privateKey});
  MyUser.fromPem(
      this.username, this.password, String publicPEMStr, String privatePEMStr) {
    publicKey = CryptoUtils.rsaPublicKeyFromPem(publicPEMStr);
    privateKey = CryptoUtils.rsaPrivateKeyFromPemPkcs1(privatePEMStr);
  }
}

class Message {
  String from;
  String to;
  String msg;
  DateTime timestamp;
  Message({
    required this.from,
    required this.to,
    required this.msg,
    required this.timestamp,
  });

  Message copyWith({
    String? from,
    String? to,
    String? msg,
    DateTime? timestamp,
  }) {
    return Message(
      from: from ?? this.from,
      to: to ?? this.to,
      msg: msg ?? this.msg,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'from': from,
      'to': to,
      'msg': msg,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      from: map['from'] as String,
      to: map['to'] as String,
      msg: map['msg'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(from: $from, to: $to, msg: $msg, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.from == from &&
        other.to == to &&
        other.msg == msg &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return from.hashCode ^ to.hashCode ^ msg.hashCode ^ timestamp.hashCode;
  }
}
