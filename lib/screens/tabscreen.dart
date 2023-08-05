// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot_gpt/screens/enterAPI.dart';
import 'dart:convert';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TabsScreenState();
  }
}

Widget test = EnterAPI();

class _TabsScreenState extends State<TabsScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredAPI = "";
  var _isAPI;
  var screen_index = 0;
  String apikey = '';
  bool api_status = false;
  var _newAPI = false;

  @override
  void initState() {
    apikey = _getAPI.toString();
    _isAPI = checkApiKey(apikey);
    super.initState();
  }

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

  Future<String> _getAPI() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    apikey = data["API_Key"].toString();
    return apikey;
  }

  @override
  Widget build(BuildContext context) {
    if (_isAPI == true && apikey != '') {
      test = const HomeScreen();
    } else {
      if (_isAPI == false || apikey != '') {
        test = EnterAPI();
      }
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: test,
    );
  }
}
