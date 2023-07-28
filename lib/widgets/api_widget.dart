// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:chatbot_gpt/models/api_key.dart';
import 'package:http/http.dart' as http;

class ApiWidget {
  static Future<void> checkApiKey() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.openai.com/v1/models"),
        headers: {"Authorization": "Bearer $openAIKey"},
      );

      Map jsonResponse = jsonDecode(response.body);
      print('jsonResponse $jsonResponse');
    } catch (error) {
      print('error $error');
    }
  }
}
