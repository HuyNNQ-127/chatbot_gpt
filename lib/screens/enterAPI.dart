import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnterAPI extends StatefulWidget {
  const EnterAPI({super.key});
  @override
  State<StatefulWidget> createState() {
    return EnterAPIState();
  }
}

class EnterAPIState extends State<EnterAPI> {
  final _form = GlobalKey<FormState>();
  var _enteredAPI = "";
  bool? _isAPI;
  var _submitComplete;

  Future<bool> checkApiKey(String apiKey) async {
    final response = await http.get(
      Uri.parse("https://api.openai.com/v1/models"),
      headers: {"Authorization": "Bearer $apiKey"},
    );
    if (response.statusCode == 200) {
      _isAPI = true;
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
    }
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    if (_isAPI == true) {
      collection
          .doc("test_instance")
          .update({"API_Key": _enteredAPI, "previous_api_existed": "true"});
      //  _submitComplete = true;
    }
  }

  void _newChatScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 500,
                child: Image.asset("assets/logo.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Api Key"),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) async {
                              final check = await checkApiKey(value);
                              setState(() => _isAPI = check);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "API key cannot be null!";
                              }

                              if (value.trim().length != 51) {
                                return "Invalid API key length!";
                              }
                              if (!_isAPI!) {
                                return "API Key does not exist!";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredAPI = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _submit;
                              _newChatScreen(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            child: const Text("Submit"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
