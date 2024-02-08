import 'package:flutter/material.dart';
import 'grammar_page.dart';
import 'vocabulary_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9ae2de),
      body: TabBarView(
        controller: _tabController,
        children: [
          VocabularyPage(),
          GrammarPage(),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.white, // Set màu nền cho TabBar
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Màu của icon và text khi được chọn
          unselectedLabelColor:
              Color(0xFF9ae2de), // Màu của icon và text khi không được chọn
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF9ae2de)), // Màu của indicator
          tabs: [
            Tab(
              icon: Icon(Icons.text_format),
              text: "Từ vựng",
            ),
            Tab(
              icon: Icon(Icons.book),
              text: "Ngữ pháp",
            ),
          ],
        ),
      ),
    );
  }
}
