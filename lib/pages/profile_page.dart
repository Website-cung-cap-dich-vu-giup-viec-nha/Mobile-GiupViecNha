import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaiKhoanPage extends StatefulWidget {
  const TaiKhoanPage({super.key});

  @override
  State<TaiKhoanPage> createState() => _TaiKhoanPageState();
}

class _TaiKhoanPageState extends State<TaiKhoanPage> {
  Map user = {};
  bool isLogined = false;

  void getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.get(
            Uri.parse('http://127.0.0.1:8000/api/auth/profile'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            });
        final json = jsonDecode(response.body);
        setState(() {
          isLogined = true;
          user = json["user"];
        });
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    } else {
      print("Chua dang nhap");
    }
  }

  void handleDangXuat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/auth/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          });
      print(response.body);
      await prefs.remove('token');
      setState(() {
        isLogined = false;
        user = {};
      });
      Navigator.pushNamed(context, "/dangnhap");
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.deepOrangeAccent,
                    radius: 40,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          isLogined ? user["name"] : "Chào bạn",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            if (isLogined) {
                              handleDangXuat();
                            } else {
                              Navigator.pushNamed(context, "/dangnhap");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 80),
                            child: Text(
                              isLogined ? "Đăng xuất" : "Đăng nhập",
                              style: TextStyle(
                                  color: Colors.green[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}