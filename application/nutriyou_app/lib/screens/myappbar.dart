import 'package:flutter/material.dart';
import 'package:nutriyou_app/app_colors.dart';
import 'package:nutriyou_app/screens/dashboard.dart';
import 'package:nutriyou_app/screens/eu.dart';
import 'package:nutriyou_app/screens/homepage.dart';

class MyAppBar extends StatefulWidget {
  MyAppBar({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> with SingleTickerProviderStateMixin {

  int _currentIndex = 0;

  List<Widget> _tabList = [
    HomeView(),
    Dashboard(),
    MeView()

  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabList.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _tabList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal.shade300,
        unselectedItemColor: Colors.grey.shade400,
        onTap: (currentIndex){

          setState(() {
            _currentIndex = currentIndex;
          });

            _tabController.animateTo(_currentIndex);

        },
        items: [
          BottomNavigationBarItem(
            label: "Início",
            icon: Icon(Icons.home_rounded)
          ),
          BottomNavigationBarItem(
            label: "Relatórios",
            icon: Icon(Icons.insert_chart_rounded)
          ),
          BottomNavigationBarItem(
            label: "Eu",
            icon: Icon(Icons.person_rounded)
          )
        ],
      ),
    );
  }
}

