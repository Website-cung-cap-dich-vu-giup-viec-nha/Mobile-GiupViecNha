import 'package:flutter/material.dart';

class CamOnDaDanhGiaPage extends StatelessWidget {
  const CamOnDaDanhGiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cảm ơn bạn đã đánh giá!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ý kiến của bạn giúp chúng tôi cải thiện dịch vụ.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/");
                },
                child: const Text('Quay lại trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
