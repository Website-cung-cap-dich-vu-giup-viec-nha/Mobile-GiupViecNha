import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThongBaoPage extends StatefulWidget {
  final Function refreshSoLgTB;

  const ThongBaoPage({Key? key, required this.refreshSoLgTB})
      : super(key: key);

  @override
  _ThongBaoPageState createState() => _ThongBaoPageState();
}

class _ThongBaoPageState extends State<ThongBaoPage> {
  Future<List<dynamic>> loadThongBao() async {
    List<dynamic> dsTB = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      try {
        final response1 = await http.get(
          Uri.parse('$baseUrl/api/auth/profile'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        final json1 = jsonDecode(response1.body);
        int idND = json1["user"]["id"];

        final uri =
        Uri.parse('$baseUrl/api/layThongBaoByIdND/$idND');
        final response2 = await http.get(uri);
        final json2 = jsonDecode(response2.body);
        dsTB = json2;
        return dsTB;
      } catch (error) {
        print('Lỗi khi gọi API: $error');
        return dsTB;
      }
    } else {
      print("Chưa đăng nhập");
      return dsTB;
    }
  }

  Future<void> updateThongBaoDaDoc(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/thongbao/$id'),
      );
      if (response.statusCode == 200) {
        print('Cập nhật trạng thái đã đọc thành công');
      } else {
        print('Không thể cập nhật trạng thái đã đọc');
      }
    } catch (error) {
      print('Lỗi khi gọi API cập nhật trạng thái đã đọc: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Thông Báo'),
      ),
      body: FutureBuilder(
        future: loadThongBao(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic>? notifications = snapshot.data;
            if (notifications == null || notifications.isEmpty) {
              return const Center(child: Text('Không có thông báo!'));
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                String ngayTao = DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.parse(notification['NgayTao']!));
                bool daDoc = notification['DaDoc'] == 1;
                return GestureDetector(
                  onTap: () async {
                    if (!daDoc) {
                      int idND = notification['idThongBao'];
                      await updateThongBaoDaDoc(idND);
                      setState(() {
                        notification['DaDoc'] = 1;
                      });
                      widget.refreshSoLgTB();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: daDoc ? Colors.white : Colors.greenAccent[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  ngayTao,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              notification['TieuDe']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['NoiDung']!,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
