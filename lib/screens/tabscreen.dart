// ignore_for_file: unused_local_variable, unused_field, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, non_constant_identifier_names, prefer_typing_uninitialized_variables
import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:chatbot_gpt/screens/summerize_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot_gpt/screens/enterAPI.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TabsScreenState();
  }
}

Widget test = const HomeScreen();

class _TabsScreenState extends State<TabsScreen> {
  final _form = GlobalKey<FormState>();
  final drawer = AdvancedDrawerController();
  var _enteredAPI = "";
  var _isAPI;
  var screen_index = 0;
  String apikey = '';
  bool api_status = false;
  var _newAPI = false;
  String item = 'chatting';
  BuildContext? dialog_context;
  dismissDailog() {
    if (dialog_context != null) {
      Navigator.pop(dialog_context!);
    }
  }

  @override
  void initState() {
    apikey = _getAPI.toString();
    _isAPI = false;
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

  Future<bool> _getAPIState() async {
    var collection = FirebaseFirestore.instance.collection('ChatGPT');
    var docSnapshot = await collection.doc('test_instance').get();
    Map<String, dynamic> data = docSnapshot.data()!;
    api_status = data["_isConnect"];
    return api_status;
  }

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    void _handleMenuButtonPressed() {
      drawer.showDrawer();
    }

    Widget _ChangePage() {
      if (item == "Summarize") {
        return const SummarizeScreen();
      }
      if (item == "Home") {
        return const HomeScreen();
      }
      return const ChatScreen();
    }

    Future alert() => showDialog(
        context: context,
        builder: (context) {
          dialog_context = context;
          return AlertDialog(
            title: const Text("Nhập API Key mới"),
            content: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    cursorColor: Colors.blueAccent,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        hintText: "Nhập API Key ở đây",
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey)),
                    onChanged: (value) async {
                      final check = await checkApiKey(value);
                      setState(() => _isAPI = check);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Không được để trống API key.";
                      }

                      if (value.trim().length != 51) {
                        return "Độ dài API Key không hợp lệ.";
                      }
                      if (!_isAPI!) {
                        return "API Key không tồn tại.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredAPI = value!;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: const Text("Sumbit"),
                  )
                ],
              ),
            ),
          );
        });

    /*
    if (_getAPIState() == false) {
      test = const EnterAPI();
    }
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: test,
    );*/

    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey, Colors.blueGrey.withOpacity(0.2)],
          ),
        ),
      ),
      controller: drawer,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 128.0,
                height: 128.0,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 64.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    item = "Home";
                  });
                },
                leading: const Icon(Icons.key),
                title: const Text('Home'),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    item = "chatting";
                  });
                },
                leading: const Icon(Icons.chat),
                title: const Text('Chatting'),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    item = "Summarize";
                  });
                },
                leading: const Icon(Icons.summarize),
                title: const Text('Summarize'),
              ),
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: const Text('Terms of Service | Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: (item == "chatting")
              ? const Text(
                  'Chatting',
                  style: TextStyle(color: Colors.white),
                )
              : const Text(
                  'Summarize',
                  style: TextStyle(color: Colors.white),
                ),
          actions: [
            (item == "chatting")
                ? IconButton(
                    onPressed: () async {
                      final instance = FirebaseFirestore.instance;
                      final batch = instance.batch();
                      var collection = instance.collection("Summarize");
                      var snapshots = await collection.get();
                      for (var doc in snapshots.docs) {
                        batch.delete(doc.reference);
                      }
                      await batch.commit();
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ))
                : IconButton(
                    onPressed: () async {
                      final instance = FirebaseFirestore.instance;
                      final batch = instance.batch();
                      var collection = instance.collection("Summarize");
                      var snapshots = await collection.get();
                      for (var doc in snapshots.docs) {
                        batch.delete(doc.reference);
                      }
                      await batch.commit();
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ))
          ],
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: drawer,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible
                        ? ((item == "chatting") ? Icons.chat : Icons.summarize)
                        : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: _ChangePage(),
      ),
    );
  }
}
