import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String SDT = '';
  String password = '';
  String password_confirmed = '';

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'SDT': SDT,
            'password': password,
            'password_confirmation': password_confirmed
          }),
        );
        final ketqua = jsonDecode(response.body);
        if (ketqua["status"]) {
          // Xử lý thành công
          Navigator.pushNamed(context, "/dangnhap");
        } else {
          // Xử lý lỗi từ server
          print('Đăng nhập thất bại: ${response.body}');
        }
      } catch (error) {
        // Xử lý lỗi kết nối
        showErrorMessage(error.toString());
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Center(
            child: Text(message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
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
                      "Rất vui được gặp bạn",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Text("Tạo ngay tài khoản để trải nghiệm dịch vụ"),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ và tên!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Số điện thoại'),
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
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập xác nhận mật khẩu!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password_confirmed = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _login,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "Đăng ký",
                          style: TextStyle(
                              color: Colors.green[400],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("Đã có tài khoản?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Đăng nhập ngay",
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
