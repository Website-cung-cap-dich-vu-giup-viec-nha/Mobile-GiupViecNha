import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:giupviecnha/pages/danhgia_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChiTietNgayLamPage extends StatefulWidget {
  const ChiTietNgayLamPage({super.key, required this.idPhieuDichVu});

  final int idPhieuDichVu;

  @override
  State<ChiTietNgayLamPage> createState() => _ChiTietNgayLamPageState();
}

class _ChiTietNgayLamPageState extends State<ChiTietNgayLamPage> {
  List<dynamic> chiTietNgayLams = [];

  @override
  void initState() {
    super.initState();
    loadChiTietNgayLam();
  }

  void loadChiTietNgayLam() async {
    final uri = Uri.parse('$baseUrl/api/layChiTietNLTheoIdPDV/${widget.idPhieuDichVu}');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      chiTietNgayLams = json;
    });
  }

  String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ngày làm'),
      ),
      body: chiTietNgayLams.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chiTietNgayLams.length,
        itemBuilder: (context, index) {
          final chiTiet = chiTietNgayLams[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text(
                  'Ngày làm: ${formatDate(chiTiet['NgayLam'])}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tên nhân viên: ${chiTiet['name'] ?? 'Chưa có'}'),
                    if (chiTiet['TinhTrangDichVu'] == 3)
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DanhGiaPage(
                                  idChiTietNhanVienLamDichVu: chiTiet['idChiTietNhanVienLamDichVu'],
                                ),
                              ),
                            );
                          },
                          child: const Text('Đánh giá'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}