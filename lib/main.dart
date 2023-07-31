import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF343541),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF444654),
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("ChatGPT")
              .doc("test_instance")
              .snapshots(),
          builder: (ctx, snapshot) {
            final document = snapshot.data;
            Map<String, dynamic>? data = document?.data();
            /*if (data?["previous_api_existed"] == "true") {
              return ChatScreen(openaikey: data?["API_Key"]);
            }*/
            return const HomeScreen();
          }),
      debugShowCheckedModeBanner: false,
    );
  }
}
