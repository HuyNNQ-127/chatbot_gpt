// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chatbot_gpt/screens/summerize_screen.dart';
import 'package:chatbot_gpt/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var _isLoading;
  var _initIDKey;
  var _selectedIndex = 0;
  var _enteredOpenAiKey = '';
  var _initOpenAIKey = '';
  var _isNewKey = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _isLoading = false;
    _getOldOpenAIKey();
    super.initState();
  }

  Future<int> isCorrectKey(String value) async {
    final url = Uri.https('api.openai.com', 'v1/models');
    return await http
        .get(url, headers: {'Authorization': ' Bearer $value'}).then((result) {
      print('StatusCode: ______________________ ${result.statusCode}');
      return result.statusCode;
    }).catchError((error) => 0);
  }

  String _keyToken() {
    var usedKey = _initOpenAIKey != '' ? _initOpenAIKey : _enteredOpenAiKey;

    var key = usedKey.substring(0, 3) +
        '***********' +
        usedKey.substring(usedKey.length - 4, usedKey.length);
    return key;
  }

  void _addOpenAIKey() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          'test-firebase-3d494-default-rtdb.asia-southeast1.firebasedatabase.app',
          'openai-key.json');
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'OpenAIkey': _enteredOpenAiKey,
          }));

      setState(() {
        _isNewKey = false;
      });
    }
  }

  void _getOldOpenAIKey() async {
    final url = Uri.https(
        'test-firebase-3d494-default-rtdb.asia-southeast1.firebasedatabase.app',
        'openai-key.json');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> listData = json.decode(response.body);
      for (final itemData in listData.entries) {
        setState(() {
          _initIDKey = itemData.key;
          _initOpenAIKey = itemData.value['OpenAIkey'];
        });
      }
    } catch (e) {}
  }

  void _deleteOpenAIKey() async {
    final url = Uri.https(
        'test-firebase-3d494-default-rtdb.asia-southeast1.firebasedatabase.app',
        'openai-key.json');
    print(url);
    try {
      final response = await http.delete(url);
      print(response.statusCode);
    } catch (e) {}
  }

  void _newChatScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatScreen(
          openAIKey: _enteredOpenAiKey,
        ),
      ),
    );
  }

  void _selectedPage(int index) {
    if (index == 1 && _initOpenAIKey == '' && _enteredOpenAiKey == '') {
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
      key: _formKey,
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
                    value.trim().length > 55 ||
                    isCorrectKey(value).then((result) => result) == 200) {
                  return 'Wrong key';
                }
                return null;
              },
              onSaved: (value) {
                _enteredOpenAiKey = value!;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _addOpenAIKey();
                    if (_formKey.currentState!.validate()) {
                      _newChatScreen(context);
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Submit')),
            ],
          ),
          const SizedBox(
            height: 140,
          )
        ],
      ),
    );

    if (_initOpenAIKey != '' && _isNewKey == false ||
        (_selectedIndex == 0 && _enteredOpenAiKey != '')) {
      isReturn = Form(
        key: _formKey,
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
              _initOpenAIKey = _keyToken(),
              style: const TextStyle(fontSize: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _deleteOpenAIKey();
                      setState(() {
                        _initOpenAIKey = '';
                        _enteredOpenAiKey = '';
                        _isNewKey = true;
                      });
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('New Key')),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Continue with current key')),
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
      if (_initOpenAIKey != '' || _enteredOpenAiKey != '') {
        final activeKey =
            _initOpenAIKey != '' ? _initOpenAIKey : _enteredOpenAiKey;
        activePage = ChatScreen(
          openAIKey: activeKey,
        );
        _isLoading = false;
      }
    }

    if (_selectedIndex == 2) {
      if (_initOpenAIKey != '' || _enteredOpenAiKey != '') {
        final activeKey =
            _initOpenAIKey != '' ? _initOpenAIKey : _enteredOpenAiKey;
        activePage = SummarizeScreen(
          openAIKey: activeKey,
        );
        _isLoading = false;
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
