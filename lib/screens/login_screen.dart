// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot_gpt/screens/enterAPI.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

Widget test = const ChatScreen();

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredAPI = "";
  bool _isAPI = false;
  var switchScreen = false;

  Future<bool> checkApiKey(String apiKey) async {
    final response = await http.get(
      Uri.parse("https://api.openai.com/v1/models"),
      headers: {"Authorization": "Bearer $apiKey"},
    );
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    if (response.statusCode == 200) {
      _isAPI = true;
      print(response.statusCode);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
    }
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    if (_isAPI == true) {
      collection.doc("test_instance").update({
        "API_Key": _enteredAPI,
        "previous_api_existed": true,
      });
      print('Submit success');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAPI == false) {
      test = ChatScreen();
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: test,
    );
  }
}
