// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/screens/enterAPI.dart';
import 'package:chatbot_gpt/screens/summerize_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredAPI = "";
  bool _isAPI = false;
  var screen_index = 0;
  var apikey = '';
  bool api_status = false;
  bool _newAPI = false;

  @override
  void initState() {
    apikey = _getAPI().toString();
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

  Future<void> _submitAPI() async {
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
      screen_index = 1;
    }
  }

  Future<String> _getAPI() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    apikey = data["API_Key"].toString();
    return apikey;
  }

  void _getAPI_status() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    api_status = data["previous_api_existed"];
  }

  Future<void> _deleteAPI() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    collection.doc("test_instance").update({
      "API_Key": '',
      "previous_api_existed": false,
    });
  }

  void _newChatScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const ChatScreen()));
  }

  void _newEnterAPI(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const EnterAPI()));
  }

  String _keyToken() {
    var usedKey = apikey;

    var key = usedKey.substring(0, 3) +
        '***********' +
        usedKey.substring(usedKey.length - 4, usedKey.length);
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 250,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                  ).image,
                ),
              ),
            ),
            const Text(
              'Current Key:',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            Text(
              apikey,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _deleteAPI();
                    setState(() {
                      _enteredAPI = '';
                      _isAPI = false;
                    });
                    _newEnterAPI(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text('New Key'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _newChatScreen(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text('Continue with current key'),
                ),
              ],
            ),
            const SizedBox(height: 140)
          ],
        ),
      ),
    );
  }
}
/*
StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("ChatGPT")
          .doc("test_instance")
          .snapshots(),
      builder: (ctx, snapshot) {
        final document = snapshot.data;
        Map<String, dynamic>? data = document?.data();
        if (data?["previous_api_existed"] == false) {
          _getAPI();
        } else {
          _previous_API();
        }
      },
    );
    */

