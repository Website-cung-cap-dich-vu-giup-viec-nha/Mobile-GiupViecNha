import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String SDT = '';
  String password = '';
  final sdt = TextEditingController();

  void setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }



  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'SDT': SDT,
            'password': password,
          }),
        );
        final ketqua = jsonDecode(response.body);
        if (ketqua["status"]) {
          // Xử lý thành công
          setToken(ketqua["token"]);
          Navigator.pushReplacementNamed(context, "/");
        } else {
          // Xử lý lỗi từ server
          print('Đăng nhập thất bại: ${response.body}');
        }
      } catch (error) {
        // Xử lý lỗi kết nối
        print('Lỗi khi gọi API: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset("lib/images/Logo.png", width: 140,),
                    const SizedBox(height: 20,),
                    const Text(
                      "Mừng bạn trở lại",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Text("Vui lòng đăng nhập để tiếp tục"),
                    const SizedBox(height: 20,),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Số điện thoại'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        SDT = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Mật khẩu'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bạn chưa có tài khoản?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Tạo tài khoản",
                          style: TextStyle(color: Colors.green[400]),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
