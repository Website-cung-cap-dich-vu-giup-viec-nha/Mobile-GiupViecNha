import 'dart:convert';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaoTuoiPage extends StatefulWidget {
  const CaoTuoiPage({super.key, required this.idDiaChi});

  final String idDiaChi;

  @override
  State<CaoTuoiPage> createState() => _CaoTuoiPageState();
}

class _CaoTuoiPageState extends State<CaoTuoiPage> {
  final _formKey = GlobalKey<FormState>();
  String? idChiTietDV;
  int? idKH;
  int soBuoi = 1;
  int soGio = 3;
  int soNguoi = 1;
  TimeOfDay gioBatDau = TimeOfDay(hour: TimeOfDay.now().hour, minute: 0);
  String ghiChu = "";
  int tongTien = 0;
  int minBuoi = 1;
  int soBuoiCuaThang = 4;
  DateTime selectedDate = DateTime.now();
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
          tongTien = selectedService['GiaTien'] * soBuoi * soGio;
          if (soNguoi >= 2) {
            tongTien += (0.3 * tongTien * (soNguoi - 1)).ceil();
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
          Uri.parse('$baseUrl/api/layIdKhachHang/${json["user"]["id"]}'),
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
    loadCombobox();
    setIdKhachHang();
  }

  void loadCombobox() async {
    final uri = Uri.parse('$baseUrl/api/layChiTietDVTheoIdDV/4');
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
      String thu = chiTietDichVus.firstWhere(
          (item) => item['idChiTietDichVu'].toString() == idChiTietDV,
          orElse: () => null)["BuoiDangKyDichVu"];
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/phieudichvu'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'Tongtien': tongTien.toString(),
            'NgayBatDau': ngayBD,
            'SoBuoi': soBuoi.toString(),
            'SoGio': soGio.toString(),
            'SoNguoiDuocChamSoc': soNguoi.toString(),
            'GioBatDau': gioPhut,
            'GhiChu': ghiChu,
            'idKhachHang': idKH.toString(),
            'Thu': thu,
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

  void setMinBuoi() {
    final selectedService = chiTietDichVus.firstWhere(
        (item) => item['idChiTietDichVu'].toString() == idChiTietDV,
        orElse: () => null);
    if (selectedService != null) {
      final buoiDangKy = selectedService['BuoiDangKyDichVu'] as String;
      final soBuoiTrongTuan = buoiDangKy.split(' - ').length;
      setState(() {
        minBuoi = soBuoiTrongTuan;
      });
    }
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
                  'Chăm sóc người cao tuổi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                const Text("Chọn ngày làm việc trong tuần"),
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
                      setMinBuoi();
                      soBuoi = soBuoiCuaThang * minBuoi;
                      calculateTongTien();
                    });
                  },
                  items: chiTietDichVus
                      .map<DropdownMenuItem<String>>(
                        (item) => DropdownMenuItem<String>(
                          value: item['idChiTietDichVu'].toString(),
                          child: Text(item['BuoiDangKyDichVu']),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày làm việc trong tuần!';
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
                          const Text("Số tháng"),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            isExpanded: true,
                            value: soBuoiCuaThang.toString(),
                            onChanged: (value) {
                              setState(() {
                                soBuoiCuaThang = int.parse(value!);
                                soBuoi = soBuoiCuaThang * minBuoi;
                                calculateTongTien();
                              });
                            },
                            items: <String>['4', '8', '12']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value == '4'
                                      ? '1 tháng'
                                      : value == '8'
                                          ? '2 tháng'
                                          : '3 tháng',
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng chọn số tháng!';
                              }
                              return null;
                            },
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
                          const Text("Số giờ làm việc"),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: soGio.toString(),
                            onChanged: (value) {
                              setState(() {
                                soGio = int.tryParse(value) ?? soGio;
                                calculateTongTien();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số giờ làm việc!';
                              }
                              return null;
                            },
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
                          const Text("Số người"),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: soNguoi.toString(),
                            onChanged: (value) {
                              setState(() {
                                soNguoi = int.tryParse(value) ?? soNguoi;
                                calculateTongTien();
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số trẻ!';
                              }
                              return null;
                            },
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
