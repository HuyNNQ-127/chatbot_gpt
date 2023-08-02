// ignore_for_file: non_constant_identifier_names

import 'package:chatbot_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_gpt/models/chat_message.dart';
//import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatWidget extends StatelessWidget {
  ChatWidget({
    super.key,
    required this.message,
    required this.chatIndex,
  });

  final String message;
  final int chatIndex;
  FlutterTts tts = FlutterTts();
  bool _speaking = false;

  void chat_speaking() async {
    _speaking = !_speaking;
    if (_speaking) {
      await tts.speak(message);
    } else {
      tts.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0
              ? scaffoldBackgroundColor
              : const Color(0xFF444654),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatIndex == 0 ? 'assets/human.png' : 'assets/chat_logo.png',
                  width: 40,
                  height: 40,
                ),
                Expanded(child: TextWidget(label: message)),
                if (chatIndex == 1)
                  IconButton(
                      onPressed: chat_speaking,
                      icon: const Icon(Icons.volume_up_rounded))
              ],
            ),
          ),
        )
      ],
    );
  }
}
