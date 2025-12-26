import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// 暂时占位符
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 三个主页面
  final List<Widget> _pages = [
    const HomeScreen(), // 首页
    const Center(child: Text("动作库(开发中)")), // 动作库
    const Center(child: Text("回顾(开发中)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(
        // 保持页面状态，切换不重置)
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4F75FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "首页"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: "动作库",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: "回顾",
          ),
        ],
      ),
    );
  }
}
