import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:giupviecnha/pages/camondadanhgia_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DanhGiaPage extends StatefulWidget {
  const DanhGiaPage({super.key, required this.idChiTietNhanVienLamDichVu});

  final int idChiTietNhanVienLamDichVu;

  @override
  State<DanhGiaPage> createState() => _DanhGiaPageState();
}

class _DanhGiaPageState extends State<DanhGiaPage> {
  double soSao = 0;
  String yKien = "";
  dynamic danhgia;
  TextEditingController yKienController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDanhGia();
  }

  void loadDanhGia() async {
    final uri = Uri.parse(
        '$baseUrl/api/layDanhGiaByIdCTNVLDV/${widget.idChiTietNhanVienLamDichVu}');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    if (json.isNotEmpty) {
      setState(() {
        danhgia = json[0];
        soSao = double.parse(danhgia['SoSao'].toString());
        yKien = danhgia['YKien'] ?? '';
        yKienController.text = yKien;
      });
    }
  }

  void luuDanhGia() async {
    if (soSao == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao!'),
        ),
      );
      return;
    }
    try {
      final response;
      if (danhgia == null) {
        response = await http.post(
          Uri.parse('$baseUrl/api/danhgia/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'SoSao': soSao.toString(),
            'YKien': yKien,
            'idChiTietNhanVienLamDichVu':
                widget.idChiTietNhanVienLamDichVu.toString(),
          }),
        );
      } else {
        response = await http.put(
          Uri.parse('$baseUrl/api/danhgia/${danhgia['idDanhGia']}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'SoSao': soSao.toString(),
            'YKien': yKien,
            'idChiTietNhanVienLamDichVu':
                widget.idChiTietNhanVienLamDichVu.toString(),
          }),
        );
      }
      final ketqua = jsonDecode(response.body);
      if (ketqua["status"]) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CamOnDaDanhGiaPage()),
        );
      } else {
        print('Thêm địa chỉ thất bại: ${response.body}');
      }
    } catch (error) {
      print('Lỗi khi gọi API: $error');
    }
  }

  @override
  void dispose() {
    yKienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá dịch vụ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn số sao:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: soSao,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) => const Icon(
                Icons.star_border,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                setState(() {
                  soSao = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Ý kiến của bạn:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: yKienController,
              minLines: 4,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                yKien = value;
              },
              decoration: const InputDecoration(
                hintText: 'Nhập ý kiến của bạn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    luuDanhGia();
                  },
                  child: const Text('Lưu đánh giá'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}