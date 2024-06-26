import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> dichvus = [];

  void _getDanhSachDichVu() async {
    final uri = Uri.parse('$baseUrl/api/dichvu');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        dichvus = json;
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _getDanhSachDichVu();
  }

  void _navigateToServicePage(BuildContext context, int? id) {
    Navigator.pushNamed(context, '/diachi', arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(
            dichvus.length,
            (index) {
              final dichvu = dichvus[index];
              final int? id = dichvu["idDichVu"];

              return GestureDetector(
                onTap: () {
                  _navigateToServicePage(context, id);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      // Điều chỉnh giá trị để đảm bảo bo tròn ở mức phù hợp
                      child: Image.asset(
                        'lib/images/${dichvu['Anh']}',
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    Text(dichvu["tenDichVu"]),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
