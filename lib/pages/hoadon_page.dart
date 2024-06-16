import 'package:flutter/material.dart';

class HoaDonPage extends StatelessWidget {
  const HoaDonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text('Đây là danh sách hóa đơn!'),
      ),
    );
  }
}
