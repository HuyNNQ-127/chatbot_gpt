// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'package:chatbot_gpt/screens/chat_screen.dart';
import 'package:chatbot_gpt/screens/home_screen.dart';
import 'package:chatbot_gpt/screens/summerize_screen.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _SelectedPageIndex = 1;

  void _selectPage(index) {
    setState(() {
      _SelectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomeScreen();
    var activePageTitle = 'Home';

    if (_SelectedPageIndex == 0) {
      //activePage = const ChatScreen();
      activePageTitle = 'Chatting';
    }

    if (_SelectedPageIndex == 2) {
//      activePage = const SummarizeScreen();
      activePageTitle = 'Summarize';
    }

    return Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _SelectedPageIndex,
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
            icon: Icon(Icons.message_outlined),
            label: 'Summarize',
          ),
        ],
      ),
    );
  }
}
