import 'package:flutter/material.dart';

class SummarizeScreen extends StatelessWidget {
  const SummarizeScreen({
    super.key,
    required this.openAIKey,
  });

  final openAIKey;
  static const index = 'summarize_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summarize conversation'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No context so far!',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            //'Press button below to summarize conversation!',
            'Press button below to go back!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
