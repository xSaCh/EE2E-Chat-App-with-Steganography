import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_chat/api.dart';
import 'package:app_chat/global.dart';
import 'package:app_chat/model.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:app_chat/util.dart' as ut;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_client/web_socket_client.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.name});

  final String name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // final socket = WebSocket(Uri.parse('ws://localhost:8080')); // if run on Windows/Web
  // final socket = WebSocket(Uri.parse('ws://0.tcp.ap.ngrok.io:17306')); // If use ngrok
  var socket = WebSocket(Uri.parse('ws://127.0.0.1:8080/wss')); // If using emulator
  // late WebSocket? socket;
  final List<model.Message> _messages = [];
  final List<types.Message> _messagesApp = [
    // types.ImageMessage(
    //   author: const types.User(id: "bbb", firstName: "bbb"),
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   height: 420,
    //   id: "1",
    //   name: "banner",
    //   size: 77613,
    //   uri: "/mnt/c/Users/Samarth/b.png",
    //   width: 720,
    // ),
    // types.TextMessage(
    //   id: "0",
    //   text: "Doing SGP",
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   author: const types.User(id: "bbb", firstName: "bbb"),
    // ),
    // types.TextMessage(
    //   id: "I`m Fine",
    //   text: "I`m Fine",
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   author: const types.User(id: "bbb", firstName: "bbb"),
    // ),
    // types.TextMessage(
    //   id: "I`m Fine",
    //   text: "How are you?",
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   author: types.User(id: gMe!.username, firstName: gMe!.username),
    // ),
    // types.TextMessage(
    //   id: "Hello",
    //   text: "Hello",
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   author: types.User(id: gMe!.username, firstName: gMe!.username),
    // ),
  ];
  model.RemoteUser? otherUser;
  model.MyUser? me;
  types.User? meAuthor;

  @override
  void initState() {
    super.initState();
    // socket.send("HELLO");
  }

  Future<void> asynCall() async {
    if (me != null && otherUser != null) return;

    me = gMe;
    meAuthor = types.User(id: me!.username, firstName: me!.username);
    // String token = await API.ins().getLoginToken(me!) ?? "";
    String? oPubKe = await API.ins().getUserPublickey(widget.name, me?.token ?? "");

    if (oPubKe == null) Navigator.of(context).pop();
    otherUser = model.RemoteUser.fromPem(widget.name, oPubKe!);

    socket.close();
    socket = WebSocket(Uri.parse('ws://127.0.0.1:8080/ws?token=${me?.token}'));

    // Listen to messages from the server.
    socket.messages.listen((incomingMessage) {
      if ((incomingMessage as String).startsWith("PING")) {
        debugPrint(incomingMessage);
        return;
      }
      debugPrint(model.Message.fromJson(incomingMessage).toJson());
      onMessageReceived(incomingMessage);
    });
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void onMessageReceived(String message) async {
    var rawJson = jsonDecode(message);
    debugPrint((await getTemporaryDirectory()).path);

    if (rawJson['type'] == 'image') {
      var bytes = await API.ins().getAttachmentByte(rawJson['msg'], me!.token ?? "");
      if (bytes == null) return;
      var a = File(
        "${(await getTemporaryDirectory()).path}/${rawJson['msg']}.png",
      );
      a.writeAsBytesSync(bytes);

      var imgMsg = types.ImageMessage(
          id: rawJson['msg'],
          createdAt: rawJson['createdAt'],
          size: bytes.length,
          author: types.User(id: rawJson['from'], firstName: rawJson['from']),
          name: rawJson['msg'],
          uri: "${(await getTemporaryDirectory()).path}/${rawJson['msg']}.png");

      setState(() {
        _messagesApp.insert(0, imgMsg);
      });
    } else
      _addMessage(model.Message.fromJson(message));
  }

  void _addMessage(model.Message message) {
    setState(() {
      _messages.insert(0, message);
      _messagesApp.insert(
          0,
          types.TextMessage(
              id: "${_messagesApp.length}",
              createdAt: message.timestamp.millisecondsSinceEpoch,
              author: types.User(id: message.from, firstName: message.from),
              text: message.msg));
    });
  }

  void _handleSendPressed(model.Message message) {
    socket.send(message.toJson());

    _addMessage(message);
  }

  void _handleAttachment() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      // String? id = await API.ins().uploadAttachmentFromBytes(bytes, me!.token!);
      String id = "a1d537d766e822237b78cbd640fdd507";

      socket.send(jsonEncode({
        "from": me!.username,
        "to": otherUser!.username,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "type": 'image',
        "msg": id
      }));

      final message = types.ImageMessage(
        author: types.User(id: me!.username, firstName: me!.username),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: "$id",
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      setState(() => _messagesApp.insert(0, message));
      debugPrint(result.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: asynCall(),
        builder: (context, snapshot) {
          if (me == null) return Container();
          return Scaffold(
            appBar: AppBar(
              title: Text('Chat with ${widget.name}'),
            ),
            body: Chat(
                messages: _messagesApp,
                user: meAuthor!,
                theme: DefaultChatTheme(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                onSendPressed: (types.PartialText t) => _handleSendPressed(model.Message(
                    to: otherUser!.username,
                    from: me!.username,
                    msg: t.text,
                    timestamp: DateTime.now())),
                onAttachmentPressed: _handleAttachment),
          );
        });
  }

  @override
  void dispose() {
    // Close the connection.
    socket.close();
    super.dispose();
  }
}
