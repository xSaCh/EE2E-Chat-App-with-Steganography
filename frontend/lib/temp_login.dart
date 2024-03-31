import 'package:app_chat/global.dart';
import 'package:app_chat/screens/contacts_page.dart';
import 'package:flutter/material.dart';

class TempLogin extends StatefulWidget {
  const TempLogin({super.key});

  @override
  State<TempLogin> createState() => _TempLoginState();
}

class _TempLoginState extends State<TempLogin> {
  final TextEditingController nameCnt = TextEditingController();
  final TextEditingController passCnt = TextEditingController();

  var ispassVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCnt,
              decoration: const InputDecoration(
                labelText: 'UserName',
              ),
            ),
            TextField(
              controller: passCnt,
              obscureText: ispassVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                    icon: Icon(ispassVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => ispassVisible = !ispassVisible)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  // ignore empty fields
                  if (nameCnt.text.isEmpty || passCnt.text.isEmpty) {
                    return;
                  }
                  if (!await connectMyUser(nameCnt.text, passCnt.text)) return;
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const ContactsPage()));
                },
                // icon: const Icon(Icons.add),
                child: const Text('Log in'))
          ],
        ),
      ),
    );
  }
}
