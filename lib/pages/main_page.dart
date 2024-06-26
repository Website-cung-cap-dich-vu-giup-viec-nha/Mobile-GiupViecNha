import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:giupviecnha/pages/hoadon_page.dart';
import 'package:giupviecnha/pages/home_page.dart';
import 'package:giupviecnha/pages/notification_page.dart';
import 'package:giupviecnha/pages/profile_page.dart';
import 'package:giupviecnha/config.dart'; // Import the config file

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RouteAware {
  int _selectedIndex = 0;
  int? idND;
  int soLgTB = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    setIdND();
    _pages = [
      const HomePage(),
      const HoaDonPage(),
      ThongBaoPage(refreshSoLgTB: refreshNotificationCount),
      TaiKhoanPage(refreshSoLgTB: resetNotificationCount),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when this route is exposed again
    setState(() {
      setIdND();
    });
  }

  void setIdND() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/auth/profile'), // Use the baseUrl
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        final json = jsonDecode(response.body);
        setState(() {
          idND = json["user"]["id"];
          setSoLgTB(); // Fetch notifications count after setting idND
        });
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    } else {
      print("Chưa đăng nhập");
    }
  }

  void setSoLgTB() async {
    if (idND != null) {
      final uri = Uri.parse('$baseUrl/api/laySoLgThongBaoByIdND/$idND'); // Use the baseUrl
      final response = await http.get(uri);
      final json = jsonDecode(response.body);
      setState(() {
        soLgTB = json;
      });
    }
  }

  void _navigationBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void refreshNotificationCount() {
    setSoLgTB();
  }

  void resetNotificationCount() {
    setState(() {
      soLgTB = 0;
    });
  }

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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Trang chủ",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Hóa đơn",
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Text(
                soLgTB.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.notifications_outlined),
              showBadge: soLgTB > 0,
            ),
            label: "Thông báo",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            label: "Tài khoản",
          ),
        ],
      ),
    );
  }
}
