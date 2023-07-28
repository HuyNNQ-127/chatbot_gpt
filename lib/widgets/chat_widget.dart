import 'package:chatbot_gpt/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:chatbot_gpt/models/chat_message.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.message,
    required this.chatIndex,
  });

  final String message;
  final int chatIndex;

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
                Expanded(child: TextWidget(label: message))
              ],
            ),
          ),
        )
      ],
    );
  }
}
