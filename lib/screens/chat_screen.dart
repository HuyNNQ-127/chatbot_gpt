// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_gpt/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  bool _speaking = false;
  late SpeechToText _speechTransform;
  String _checkconnect = "true";

  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    _speechTransform = SpeechToText();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    OpenAI.apiKey = data["API_Key"];

    if (textEditingController.text.trim().isEmpty) {
      return;
    }
    if (_speaking) {
      setState(() {
        _speaking = false;
        _speechTransform.stop();
      });
    }

    String msg = textEditingController.text;
    _isTyping = true;
    textEditingController.clear();

    FirebaseFirestore.instance.collection("Conversation").add({
      "text": msg,
      "Index": 0,
      "Timestamp": Timestamp.now(),
    });

    OpenAIChatCompletionModel chatgpt = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, content: msg)
      ],
    );
    print(chatgpt.choices[0].message.content);
    _isTyping = false;
    FirebaseFirestore.instance.collection("Conversation").add({
      "text": chatgpt.choices[0].message.content,
      "Index": 1,
      "Timestamp": Timestamp.now(),
    });

    String conversation = data["ChatScreen"].toString();
    FirebaseFirestore.instance
        .collection("ChatGPT")
        .doc("test_instance")
        .update(
      {
        "ChatScreen": conversation +
            "\nHuman: " +
            msg +
            "\nGPT: " +
            chatgpt.choices[0].message.content,
      },
    );
  }

  void _Listen() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    _checkconnect = data["Connection"];
    if (!_speaking) {
      bool availability = await _speechTransform.initialize(
        onStatus: (value) {
          print("OnStatus: $value");
          if (value == "done") {
            setState(() {
              _speaking = false;
              _speechTransform.stop();
            });
          }
        },
        onError: (value) => print("error: $value"),
      );

      if (availability) {
        setState(() {
          _speaking = true;
        });

        _speechTransform.listen(
          localeId: "vi_VN",
          listenFor: const Duration(seconds: 60),
          onResult: (value) => setState(() {
            textEditingController.text = value.recognizedWords;
            if (_isTyping == true) {
              textEditingController.clear();
            }
          }),
        );
      } else {
        setState(() {
          _speaking = false;
          _speechTransform.stop();
        });
      }
    }
  }

  void _newHomeScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Conversation")
          .orderBy(
            "Timestamp",
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
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: loadedMessages.length,
                    itemBuilder: (context, index) {
                      final chatMessage = loadedMessages[index].data();
                      return ChatWidget(
                        message: chatMessage["text"],
                        chatIndex: chatMessage["Index"],
                      );
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
                          onPressed: () => _Listen(),
                          icon: Icon(
                            _speaking ? Icons.mic : Icons.mic_off,
                            color: _speaking
                                ? const Color.fromARGB(255, 19, 164, 232)
                                : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _submitMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
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
