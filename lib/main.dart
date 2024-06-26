import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:giupviecnha/pages/diachi_page.dart';
import 'package:giupviecnha/pages/LoginOrRegister.dart';
import 'package:giupviecnha/pages/caotuoi_page.dart';
import 'package:giupviecnha/pages/giupviec_page.dart';
import 'package:giupviecnha/pages/main_page.dart';
import 'package:giupviecnha/pages/maylanh_page.dart';
import 'package:giupviecnha/pages/sofa_page.dart';
import 'package:giupviecnha/pages/tongvesinh_page.dart';
import 'package:giupviecnha/pages/trongtre_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
      ],
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/dangnhap': (context) => const LoginOrRegister(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        if (uri.pathSegments.first == 'diachi') {
          final int id = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DiaChiPage(id: id),
          );
        }

        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'thuedichvu') {
          final id = uri.pathSegments[1];
          final String idDiaChi = settings.arguments as String;
          switch (id) {
            case '1':
              return MaterialPageRoute(
                  builder: (context) => GiupViecPage(idDiaChi: idDiaChi));
            case '2':
              return MaterialPageRoute(
                  builder: (context) => TongVeSinhPage(idDiaChi: idDiaChi));
            case '3':
              return MaterialPageRoute(
                  builder: (context) => TrongTrePage(idDiaChi: idDiaChi));
            case '4':
              return MaterialPageRoute(
                  builder: (context) => CaoTuoiPage(idDiaChi: idDiaChi));
            case '5':
              return MaterialPageRoute(
                  builder: (context) => MayLanhPage(idDiaChi: idDiaChi));
            case '6':
              return MaterialPageRoute(
                  builder: (context) => SofaPage(idDiaChi: idDiaChi));
            default:
              return MaterialPageRoute(builder: (context) => const MainPage());
          }
        }
        return null;
      },
    );
  }
}
