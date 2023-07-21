import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  static const index = 'chat_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No conversation so far!',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            //'Begin chatting now!',
            'Press button below to go back!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
