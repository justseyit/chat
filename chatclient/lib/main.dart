import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/service/chat_service.dart';
import 'package:chatapp/protos/service.pb.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginPage> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose a Username"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              TextField(
                controller: controller,
              ),
              MaterialButton(
                child: const Text("Submit"),
                onPressed: () {
                  User user = User();
                  user..clearName()..name = controller.text..clearId()..id = sha256.convert(utf8.encode(user.name)).toString();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MessagePage(
                        ChatService(user),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MessagePage extends StatefulWidget {
  final ChatService service;
  const MessagePage(this.service, {super.key});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late TextEditingController controller;

  late Set<Message> messages;

  @override
  void initState() {
    super.initState();
    messages = <Message>{};
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Page"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: controller,
              ),
            ),
            MaterialButton(
              child: const Text("Submit"),
              onPressed: () {
                widget.service.sendMessage(controller.text);
                controller.clear();
              },
            ),
            Flexible(
              child: StreamBuilder<Message>(
                  stream: widget.service.recieveMessage(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    messages.add(snapshot.data!);

                    return ListView(
                      children: messages
                          .map((msg) => ListTile(
                                leading: Text(msg.sender.name),
                                title: Text(msg.content),
                                subtitle: Text(msg.timestamp),
                              ))
                          .toList(),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
