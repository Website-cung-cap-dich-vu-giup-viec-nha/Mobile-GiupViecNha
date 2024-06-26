import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MayLanhPage extends StatefulWidget {
  const MayLanhPage({super.key, required this.idDiaChi});

  final String idDiaChi;

  @override
  State<MayLanhPage> createState() => _MayLanhPageState();
}

class _MayLanhPageState extends State<MayLanhPage> {
  final _formKey = GlobalKey<FormState>();
  String? idChiTietDV;
  String? idKieuDV;
  int? idKH;
  TimeOfDay gioBatDau = TimeOfDay(hour: TimeOfDay.now().hour, minute: 0);
  String ghiChu = "";
  int tongTien = 0;
  DateTime selectedDate = DateTime.now();
  List<dynamic> kieuDichVus = [];
  List<dynamic> chiTietDichVus = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: const Locale("vi", "VN"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        calculateTongTien();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: gioBatDau,
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale("vi", "VN"),
          child: child,
        );
      },
    );

    if (picked != null) {
      setState(() {
        gioBatDau = picked.minute == 0
            ? picked
            : TimeOfDay(hour: picked.hour, minute: 0);
      });
    }
  }

  void calculateTongTien() {
    if (idChiTietDV != null) {
      final selectedService = chiTietDichVus.firstWhere(
          (item) => item['idChiTietDichVu'].toString() == idChiTietDV,
          orElse: () => null);
      if (selectedService != null) {
        setState(() {
          tongTien = selectedService['GiaTien'];
          int ngay = selectedDate.weekday;
          if (ngay == DateTime.saturday || ngay == DateTime.sunday) {
            tongTien = (1.2 * tongTien).ceil();
          }
        });
      }
    }
  }

  void setIdKhachHang() async {
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
        setState(() {
          idKH = json2[0];
        });
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    } else {
      print("Chưa đăng nhập");
    }
  }

  @override
  void initState() {
    super.initState();
    loadKieuDichVu();
    setIdKhachHang();
  }

  void loadKieuDichVu() async {
    final uri = Uri.parse('$baseUrl/api/layKieuDVByIdDV/5');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      kieuDichVus = json;
    });
  }

  void loadChiTietDichVu() async {
    final uri = Uri.parse(
        '$baseUrl/api/layChiTietDVTheoIdKieuDV/${idKieuDV!}');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      chiTietDichVus = json;
    });
  }

  void handleDatDichVu() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      String gioPhut = gioBatDau.toString().split('(')[1].split(')')[0];
      String ngayBD = selectedDate.toString().split(' ')[0];
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/phieudichvu'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'Tongtien': tongTien.toString(),
            'NgayBatDau': ngayBD,
            'GioBatDau': gioPhut,
            'GhiChu': ghiChu,
            'idKhachHang': idKH.toString(),
            'idChiTietDichVu': idChiTietDV.toString(),
            'idDiaChi': widget.idDiaChi,
          }),
        );
        final ketqua = jsonDecode(response.body);
        if (ketqua["status"]) {
          Navigator.pushReplacementNamed(context, "/");
        } else {
          print('Đăng nhập thất bại: ${response.body}');
        }
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    }
  }

  int laySoGio(String text) {
    final RegExp regex = RegExp(r'/(\d+)\s*giờ');
    final match = regex.firstMatch(text);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt dịch vụ'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vệ sinh máy lạnh',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                const Text("Chọn loại máy lạnh"),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  isExpanded: true,
                  value: idKieuDV,
                  onChanged: (value) {
                    setState(() {
                      idKieuDV = value!;
                      idChiTietDV = null;
                      chiTietDichVus = [];
                      loadChiTietDichVu();
                    });
                  },
                  items: kieuDichVus
                      .map<DropdownMenuItem<String>>(
                        (item) => DropdownMenuItem<String>(
                          value: item['idKieuDichVu'].toString(),
                          child: Text(item['tenKieuDichVu']),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại máy lạnh!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text("Chọn loại vệ sinh"),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  isExpanded: true,
                  value: idChiTietDV,
                  onChanged: (value) {
                    setState(() {
                      idChiTietDV = value!;
                      calculateTongTien();
                    });
                  },
                  items: chiTietDichVus
                      .map<DropdownMenuItem<String>>(
                        (item) => DropdownMenuItem<String>(
                          value: item['idChiTietDichVu'].toString(),
                          child: Text(item['tenChiTietDichVu']),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại vệ sinh!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ngày bắt đầu"),
                          SizedBox(
                            height: 58,
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 11),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.black45,
                                    style: BorderStyle.solid,
                                    width: 1.15,
                                  ),
                                ),
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                child: Text(
                                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Giờ bắt đầu"),
                          SizedBox(
                            height: 58,
                            child: GestureDetector(
                              onTap: () => _selectTime(context),
                              // Corrected here
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 11),
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.black45,
                                    style: BorderStyle.solid,
                                    width: 1.15,
                                  ),
                                ),
                                child: Text(
                                  gioBatDau.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Ghi chú"),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            minLines: 4,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onChanged: (value) {
                              setState(() {
                                ghiChu = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: 'Tổng tiền: ',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: NumberFormat.currency(locale: 'vi')
                            .format(tongTien),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: handleDatDichVu,
                  child: const Text('Xác nhận'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
