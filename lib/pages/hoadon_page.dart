import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:giupviecnha/pages/chitietngaylam_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HoaDonPage extends StatelessWidget {
  const HoaDonPage({super.key});

  Future<List<dynamic>> loadHoaDon() async {
    List<dynamic> dsHD = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/auth/profile'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        final json = jsonDecode(response.body);

        final response2 = await http.get(
          Uri.parse(
              '$baseUrl/api/layIdKhachHang/${json["user"]["id"]}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        final json2 = jsonDecode(response2.body);

        final uri = Uri.parse(
            '$baseUrl/api/layPhieuDichVuTheoIdKhachHang/${json2[0]}');
        final response3 = await http.get(uri);
        dsHD = jsonDecode(response3.body);
        return dsHD;
      } catch (error) {
        print('Lỗi khi gọi API: $error');
        return dsHD;
      }
    } else {
      print("Chưa đăng nhập");
      return dsHD;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Hóa đơn'),
      ),
      body: FutureBuilder(
        future: loadHoaDon(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic>? hoadons = snapshot.data;
            if (hoadons == null || hoadons.isEmpty) {
              return Center(child: Text('Không có hóa đơn!'));
            }
            return ListView.builder(
              itemCount: hoadons.length,
              itemBuilder: (context, index) {
                final hoadon = hoadons[index];
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        hoadon['tenDichVu'],
                        style: const TextStyle(
                          fontSize: 18.0, // Increase the font size
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Ngày bắt đầu: ${formatDate(hoadon['NgayBatDau'])}'),
                          Text(
                              'Giờ bắt đầu: ${formatTime(hoadon['GioBatDau'])}'),
                          Text(
                              'Tình trạng: ${getTinhTrang(hoadon['TinhTrang'])}'),
                          Text(
                              'Tình trạng thanh toán: ${getTinhTrangThanhToan(hoadon['TinhTrangThanhToan'])}'),
                          Align(
                            alignment: Alignment.centerRight,
                            child: RichText(
                              text: TextSpan(
                                text: 'Tổng tiền: ',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black, // Normal text style
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: NumberFormat.currency(locale: 'vi')
                                        .format(hoadon['Tongtien']),
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Colors.red, // Red and bold for value
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietNgayLamPage(
                                idPhieuDichVu: hoadon['idPhieuDichVu']),
                          ),
                        );
                      },
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

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(String timeStr) {
    final time = DateFormat('HH:mm:ss').parse(timeStr);
    return DateFormat('HH:mm').format(time);
  }

  String getTinhTrang(int tinhTrang) {
    switch (tinhTrang) {
      case 1:
        return 'Đang duyệt';
      case 2:
        return 'Đã duyệt';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  String getTinhTrangThanhToan(int tinhTrangThanhToan) {
    switch (tinhTrangThanhToan) {
      case 1:
        return 'Chưa thanh toán';
      case 2:
        return 'Đã thanh toán';
      default:
        return 'Không xác định';
    }
  }
}
