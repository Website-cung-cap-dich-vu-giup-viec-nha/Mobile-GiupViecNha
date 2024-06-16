import 'package:flutter/material.dart';
import 'package:giupviecnha/pages/hoadon_page.dart';
import 'package:giupviecnha/pages/home_page.dart';
import 'package:giupviecnha/pages/notification_page.dart';
import 'package:giupviecnha/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _navigationBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = const [
    HomePage(),
    HoaDonPage(),
    ThongBaoPage(),
    TaiKhoanPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigationBottomBar,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black45,
        selectedItemColor: Colors.deepOrange,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: "Hóa đơn"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: "Thông báo"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_outlined), label: "Tài khoản"),
        ],
      ),
    );
  }
}
