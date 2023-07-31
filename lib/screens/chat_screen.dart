// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:chatbot_gpt/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot_gpt/widgets/api_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dart_openai/dart_openai.dart';
import "dart:io";
import "package:whisper_dart/scheme/scheme.dart";

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.openaikey,
  });

  final String openaikey;

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  String _checkconnect = "true";

  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    OpenAI.apiKey = widget.openaikey;
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    String msg = textEditingController.text;
    textEditingController.clear();
    OpenAIChatCompletionModel chatgpt = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, content: msg)
      ],
    );
    print(chatgpt.choices[0].message.content);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting &&
            _checkconnect == "true") {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/openai_logo.jpg"),
            ),
            title: const Text(
              "ChatGPT",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: loadedMessages.length,
                    itemBuilder: (context, index) {
                      /*
                      final chatMessage = loadedMessages[index].data();
                      return ChatWidget(
                        msg: chatMessage["text"],
                        chatIndext: chatMessage["Indext"],
                      );*/
                    },
                  ),
                ),
                if (_isTyping) ...[
                  const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 18,
                  ),
                ],
                const SizedBox(
                  height: 15,
                ),
                Material(
                  color: const Color(0xFF444654),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: textEditingController,
                            onSubmitted: (value) {
                              _submitMessage();
                            },
                            maxLines: null,
                            decoration: const InputDecoration.collapsed(
                                hintText: "Enter text here!",
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        IconButton(
                          onPressed: _submitMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
