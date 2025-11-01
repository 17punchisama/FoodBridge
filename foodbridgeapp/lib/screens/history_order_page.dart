import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'nav_bar.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ไม่มี /v1 ตามที่บอก
  static const String baseUrl = 'https://foodbridge1.onrender.com';

  /// login แล้วคืน token
  static Future<String?> login({
    required String loginId,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "login": loginId,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // ถ้าแบ็กเอนด์ส่งชื่ออื่น เช่น access_token ให้เปลี่ยนตรงนี้
      final token = data['token'];
      return token is String ? token : null;
    } else {
      // ดู error ได้ตรงนี้
      print('login error: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  /// GET /bookings แบบแนบ token
  static Future<List<dynamic>> getBookings(String token) async {
    final url = Uri.parse('$baseUrl/bookings');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // สมมติ backend คืนเป็น array
      if (data is List) {
        return data;
      }
      // ถ้าคืน object แล้วมี field ชื่อ data ก็จับเอาออก
      if (data is Map && data['data'] is List) {
        return data['data'];
      }
      return [];
    } else {
      print('getBookings error: ${res.statusCode} ${res.body}');
      // ถ้า token หมดอายุจะเข้ามาตรงนี้ → invalid or expired jwt
      return [];
    }
  }

  /// POST /bookings
  static Future<bool> createBooking(String token, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/bookings');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      print('createBooking error: ${res.statusCode} ${res.body}');
      return false;
    }
  }
}


class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({super.key});

  @override
  State<HistoryOrderPage> createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ประวัติการทำรายการ',
                style: TextStyle(
                  color: Color(0xff2A2929),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
DefaultTabController(
  length: 3,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: TabBar(
      isScrollable: true,
      indicatorColor: Color(0xff038263),
      labelColor: Color(0xff038263),
      unselectedLabelColor: Color(0xff696969),
      labelStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'IBMPlexSansThai'
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'IBMPlexSansThai'
      ),
      tabs: const [
        Tab(text: 'กำลังทำ'),
        Tab(text: 'เสร็จแล้ว'),
        Tab(text: 'ยกเลิก/ล้มเหลว'),
      ],
    ),
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}
