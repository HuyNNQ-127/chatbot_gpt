// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot_gpt/screens/summerize_screen.dart';
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/models/api_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var _initIDKey;
  var _selectedIndex = 0;
  var _enteredKey = '';
  var _initOpenAIKey = '';
  var _isNewKey = false;
  final _form = GlobalKey<FormState>();
  bool? _API;

  Future<bool> check_API(String api) async {
    final response = await http.get(
        Uri.parse("https://api.openai.com/v1/models"),
        headers: {"Authorization": "Bearer $api"});
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    print(data["previous_api_existed"]);
    if (response.statusCode == 200) {
      _API = true;
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
    if (_API == true) {
      collection
          .doc("test_instance")
          .update({"API_Key": _enteredKey, "previous_api_existed": "true"});
    }
  }

/*
  void _deleteAPI() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
    }
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    if (_API == true) {
      collection
          .doc("test_instance")
          .update({"API_Key": "", "previous_api_existed": "false"});
    }
  }
*/
  void _newChatScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatScreen(
          openaikey: openAIKey,
        ),
      ),
    );
  }

  void _selectedPage(int index) {
    if (index == 1 && _initOpenAIKey == '' && _enteredKey == '') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid OpenAI API key!'),
          content: const Text(
            'Please make sure you have entered the correct key!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget isReturn = Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: Image.asset('assets/logo.png').image),
            ),
          ),
          const Text(
            'OpenAi Key: ',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: TextFormField(
              maxLength: 51,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Insert your OpenAPI key...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length <= 1 ||
                    value.trim().length > 55) {
                  return 'Wrong key';
                }
                return null;
              },
              onSaved: (value) {
                _enteredKey = value!;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _submitAPI();
                    if (_form.currentState!.validate()) {
                      _newChatScreen(context);
                    }
                  },
                  child: const Text('Submit')),
            ],
          ),
          const SizedBox(
            height: 140,
          )
        ],
      ),
    );

    if (_initOpenAIKey != '' && _isNewKey == false ||
        (_selectedIndex == 0 && _enteredKey != '')) {
      isReturn = Form(
        key: _form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset(
                  'assets/logo.png',
                ).image),
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
              _initOpenAIKey,
              style: const TextStyle(fontSize: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initOpenAIKey = '';
                        _enteredKey = '';
                        _isNewKey = true;
                      });
                    },
                    child: const Text('New Key')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: const Text('Continue with current key')),
              ],
            ),
            const SizedBox(height: 140)
          ],
        ),
      );
    }

    Widget activePage = SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: isReturn),
    );

    if (_selectedIndex == 0) {
      if (_initOpenAIKey != '' || _enteredKey != '') {
        final activeKey = _initOpenAIKey != '' ? _initOpenAIKey : _enteredKey;
        activePage = ChatScreen(
          openaikey: activeKey,
        );
      }
    }

    if (_selectedIndex == 2) {
      if (_initOpenAIKey != '' || _enteredKey != '') {
        final activeKey = _initOpenAIKey != '' ? _initOpenAIKey : _enteredKey;
        activePage = SummarizeScreen(
          openAIKey: activeKey,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 111, 189),
        elevation: 0.0,
        title: Container(
          margin: EdgeInsets.zero,
          child: const Row(
            children: [
              SizedBox(
                width: 8,
              ),
              Text(
                'ChatGPT',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            _selectedPage(value);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.type_specimen_sharp),
              label: 'Chatting',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.house),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'Summarize',
            ),
          ]),
    );
  }
}
