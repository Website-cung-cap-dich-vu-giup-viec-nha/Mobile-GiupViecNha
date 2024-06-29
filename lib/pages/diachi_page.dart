import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giupviecnha/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiaChiPage extends StatefulWidget {
  const DiaChiPage({super.key, required this.id});

  final int id;

  @override
  State<DiaChiPage> createState() => _DiaChiPageState();
}

class _DiaChiPageState extends State<DiaChiPage> {
  final TextEditingController txtDuong = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int? idND;
  String? idDiaChi;
  String? idProvince;
  String? idDistrict;
  String? idWard;
  String? duong;
  List<dynamic> dsDiaChi = [];
  List<dynamic> dsProvince = [];
  List<dynamic> dsDistrict = [];
  List<dynamic> dsWard = [];

  @override
  void dispose() {
    txtDuong.dispose();
    super.dispose();
  }

  void handleChonDiaChi() {
    if (_formKey1.currentState?.validate() ?? false) {
      _formKey1.currentState?.save();
      String routeName;
      switch (widget.id) {
        case 1:
          routeName = '/thuedichvu/1';
          break;
        case 2:
          routeName = '/thuedichvu/2';
          break;
        case 3:
          routeName = '/thuedichvu/3';
          break;
        case 4:
          routeName = '/thuedichvu/4';
          break;
        case 5:
          routeName = '/thuedichvu/5';
          break;
        case 6:
          routeName = '/thuedichvu/6';
          break;
        default:
          return;
      }
      Navigator.pushNamed(context, routeName, arguments: idDiaChi);
    }
  }

  void themDiaChi() async {
    if (_formKey2.currentState?.validate() ?? false) {
      _formKey2.currentState?.save();
      if (idND == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để thêm địa chỉ!'),
          ),
        );
        return;
      }
      final macDinhValue = dsDiaChi.length == 0 ? 1 : 0;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/diachi/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'Duong': duong.toString(),
            'Phuong': idWard.toString(),
            'idNguoiDung': idND.toString(),
            'MacDinh': macDinhValue.toString(),
          }),
        );
        final ketqua = jsonDecode(response.body);
        if (ketqua["status"]) {
          setState(() {
            loadDiaChi();
            idProvince = idDistrict = idWard = duong = null;
            dsDistrict = dsWard = [];
            txtDuong.clear();
          });
        } else {
          print('Thêm địa chỉ thất bại: ${response.body}');
        }
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await setIdNguoiDung();
    loadDiaChi();
    loadProvince();
  }

  Future<void> setIdNguoiDung() async {
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
        setState(() {
          idND = json["user"]["id"];
        });
      } catch (error) {
        print('Lỗi khi gọi API: $error');
      }
    } else {
      print("Chưa đăng nhập");
    }
  }

  void loadDiaChi() async {
    final uri = Uri.parse('$baseUrl/api/layDiaChiByIdNguoiDung/$idND');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      dsDiaChi = json;
    });
  }

  void loadProvince() async {
    final uri = Uri.parse('$baseUrl/api/province');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      dsProvince = json;
    });
  }

  void loadDistrict() async {
    final uri = Uri.parse('$baseUrl/api/layHuyenByProvinceId/$idProvince');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      idDistrict = null;
      idWard = null;
      dsWard = [];
      dsDistrict = json;
    });
  }

  void loadWard() async {
    final uri = Uri.parse('$baseUrl/api/layXaByDistrictId/$idDistrict');
    final response = await http.get(uri);
    final json = jsonDecode(response.body);
    setState(() {
      idWard = null;
      dsWard = json;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Chọn địa chỉ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        isExpanded: true,
                        value: idDiaChi,
                        onChanged: (value) {
                          setState(() {
                            idDiaChi = value!;
                          });
                        },
                        items: dsDiaChi
                            .map<DropdownMenuItem<String>>(
                              (item) => DropdownMenuItem<String>(
                                value: item['idDiaChi'].toString(),
                                child: Text(item['Duong'] +
                                    ", " +
                                    item['ward_name'] +
                                    ", " +
                                    item['district_name'] +
                                    ", " +
                                    item['province_name']),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn địa chỉ!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      OutlinedButton(
                        onPressed: handleChonDiaChi,
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey2, // Using a different form key
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Thêm địa chỉ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      const Text("Chọn tỉnh thành"),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        isExpanded: true,
                        value: idProvince,
                        onChanged: (value) {
                          setState(() {
                            idProvince = value!;
                            loadDistrict();
                          });
                        },
                        items: dsProvince
                            .map<DropdownMenuItem<String>>(
                              (item) => DropdownMenuItem<String>(
                                value: item['province_id'].toString(),
                                child: Text(item['province_name']),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn tỉnh thành!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Text("Chọn quận huyện"),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        isExpanded: true,
                        value: idDistrict,
                        onChanged: (value) {
                          setState(() {
                            idDistrict = value!;
                            loadWard();
                          });
                        },
                        items: dsDistrict
                            .map<DropdownMenuItem<String>>(
                              (item) => DropdownMenuItem<String>(
                                value: item['district_id'].toString(),
                                child: Text(item['district_name']),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn quận huyện!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Text("Chọn phường xã"),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        isExpanded: true,
                        value: idWard,
                        onChanged: (value) {
                          setState(() {
                            idWard = value!;
                          });
                        },
                        items: dsWard
                            .map<DropdownMenuItem<String>>(
                              (item) => DropdownMenuItem<String>(
                                value: item['ward_id'].toString(),
                                child: Text(item['ward_name']),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn phường xã!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const Text("Đường"),
                      TextFormField(
                        controller: txtDuong,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            duong = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập đường!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      OutlinedButton(
                        onPressed: themDiaChi,
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
