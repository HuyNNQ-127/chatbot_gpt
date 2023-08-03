// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
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
                child: Image.asset(
                  "assets/logo.png",
                  width: 200,
                  height: 200,
                ),
              ),
              Card(
                color: Colors.white,
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
                            decoration: const InputDecoration(
                                labelText: "Enter API key here!"),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) async {
                              final check = await checkApiKey(value);
                              setState(() => _isAPI = check);
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length != 51) {
                                return "Please enter a valid API key!";
                              }
                              if (_isAPI == false) {
                                return "API Key does not exist.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredAPI = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: const Text("Submit key"),
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
