import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// -------------------------------
/// Service เรียก API จริง
/// -------------------------------
class ApiService {
  static const String baseUrl = 'https://foodbridge1.onrender.com';

  /// 1) GET /bookings
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

      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'];

      return [];
    } else {
      print('getBookings error: ${res.statusCode} ${res.body}');
      return [];
    }
  }

  /// 2) GET /posts/{postId} → ดึงเฉพาะ price, is_giveaway, address
  static Future<Map<String, dynamic>?> getPostDetails(
    String token,
    int postId,
  ) async {
    final url = Uri.parse('$baseUrl/posts/$postId');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final map = (data is Map && data['data'] is Map)
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return {
        'title': map['title'],
        'price': map['price'],
        'is_giveaway': map['is_giveaway'],
        'address': map['address'],
      };
    } else {
      print('getPostDetails error: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  /// 3) ดึง bookings แล้ว “ผูก” post ของแต่ละ booking มาให้เลย
  ///
  /// ผลลัพธ์แต่ละตัวจะหน้าตาประมาณนี้
  /// {
  ///   ...bookingFields,
  ///   "post": {
  ///     "price": ...,
  ///     "is_giveaway": ...,
  ///     "address": ...
  ///   }
  /// }
  static Future<List<Map<String, dynamic>>> getBookingsWithPost(
    String token,
  ) async {
    final bookings = await getBookings(token);

    // ดึง post ของแต่ละ booking แบบขนาน (parallel) ด้วย Future.wait
    final futures = bookings.map<Future<Map<String, dynamic>>>((b) async {
      final postId = b['post_id'];
      Map<String, dynamic>? postData;

      if (postId != null) {
        postData = await getPostDetails(
          token,
          postId is int ? postId : int.parse(postId.toString()),
        );
      }

      // รวม booking เดิม + field post
      return {
        ...Map<String, dynamic>.from(b),
        'post': postData, // อาจเป็น null ถ้าเรียกไม่สำเร็จ
      };
    }).toList();

    final combined = await Future.wait(futures);
    return combined;
  }
}

/// -------------------------------
/// หน้า History
/// -------------------------------
class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({super.key});

  @override
  State<HistoryOrderPage> createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();

    // 👇 token ที่คุณ mock ไว้
    const hardcodedToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjIyMjc0MDksInJvbGUiOiJVU0VSIiwidWlkIjoyfQ.wgxcI6YlrWBQS0TILjijFUygE4X_ZTz1OcU8T632Ru0';

    // ใช้ฟังก์ชันที่ดึงทั้ง booking + post
    _future = ApiService.getBookingsWithPost(hardcodedToken);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: NavBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(left: 4), 
                child: const Text(
                  'ประวัติการทำรายการ',
                  style: TextStyle(
                    color: Color(0xff2A2929),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  
                  ),
                ),
                
                ),
                
                const SizedBox(height: 16),

                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: Color(0xff038263),
                    labelColor: Color(0xff038263),
                    unselectedLabelColor: Color(0xff696969),
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansThai',
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansThai',
                    ),
                    tabs: [
                      Tab(text: 'กำลังทำ'),
                      Tab(text: 'เสร็จแล้ว'),
                      Tab(text: 'ยกเลิก/ล้มเหลว'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('โหลดข้อมูลไม่สำเร็จ'));
                      }

                      final all = snapshot.data ?? [];

                      // แยกตาม status ที่ backend ส่งมา
                      final doing = all.where((e) {
                        final s = (e['status'] ?? '').toString().toUpperCase();
                        return s == 'PENDING' || s == 'QUEUED';
                      }).toList();

                      final done = all.where((e) {
                        final s = (e['status'] ?? '').toString().toUpperCase();
                        return s == 'COMPLETED';
                      }).toList();

                      final failed = all.where((e) {
                        final s = (e['status'] ?? '').toString().toUpperCase();
                        return s == 'CANCELLED' ||
                            s == 'FAILED' ||
                            s == 'REJECTED' ||
                            s == 'EXPIRED';
                      }).toList();

                      return TabBarView(
                        children: [
                          _BookingList(data: doing),
                          _BookingList(data: done),
                          _BookingList(data: failed),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------------------
/// Widget แสดงรายการในแต่ละแท็บ
/// -------------------------------
class _BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _BookingList({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('ยังไม่มีรายการ'));
    }

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = data[index];

        String formatThaiDateTime(String isoString) {
          if (isoString.isEmpty) return '-';
          try {
            // แปลงจาก ISO → DateTime แล้วแปลงเป็น local (ไทย)
            final dt = DateTime.parse(isoString).toLocal();

            const thMonths = [
              'ม.ค.',
              'ก.พ.',
              'มี.ค.',
              'เม.ย.',
              'พ.ค.',
              'มิ.ย.',
              'ก.ค.',
              'ส.ค.',
              'ก.ย.',
              'ต.ค.',
              'พ.ย.',
              'ธ.ค.',
            ];

            final day = dt.day; // 31
            final monthName = thMonths[dt.month - 1]; // ต.ค.
            final year2 = dt.year % 100; // 25
            final hh = dt.hour.toString().padLeft(2, '0');
            final mm = dt.minute.toString().padLeft(2, '0');

            return '$day $monthName $year2, $hh:$mm';
          } catch (e) {
            return isoString; // ถ้า parse ไม่ได้ ก็ส่งเดิมกลับไป
          }
        }

        final bookingId = item['booking_id']?.toString() ?? '-';
        final postId = item['post_id']?.toString() ?? '-';
        final status = (item['status'] ?? '').toString();
        final createdAtRaw = item['created_at']?.toString() ?? '';
        final createdAt = formatThaiDateTime(createdAtRaw);

        // 👇 post ที่ดึงมาเพิ่ม
        final post = item['post'] as Map<String, dynamic>?;

        final price = post?['price'];
        final isGiveaway = post?['is_giveaway'];
        final address = post?['address'];
        final postName = post?['title'];

        String text_status = '';

        if (status == 'QUEUED') {
          text_status = 'กำลังรอคิว';
        } else if (status == 'PENDING') {
          text_status = 'กำลังดำเนินการ';
        } else if (status == 'CANCELLED') {
          text_status = 'ยกเลิกรายการแล้ว';
        } else if (status == 'COMPLETED') {
          text_status = 'รายการสำเร็จแล้ว';
        } else {
          text_status = 'รายการหมดเวลาแล้ว';
        }

        return ListTile(
          leading: SizedBox(
            width: 45,
            height: 45,
            child: SvgPicture.asset(
              'assets/icons/order_list.svg',
              fit: BoxFit.contain,
            ),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ฝั่งซ้าย
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$createdAt'),
                    Text('$postName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/red_location.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "$address",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff828282),
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text('$text_status',
                    style: TextStyle(
                      color: Color(0xff038263),
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ฝั่งขวา
              Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // หรือ start ก็ได้
                  children: [
                    Text(""),
                    
                    if (isGiveaway != null)
                      Text(
                        isGiveaway == true ? 'ไม่มีค่าใช้จ่าย' : 'มีค่าใช้จ่าย',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xffF58319),
                        ),
                      ),
                    if (price != null) Text('$price฿', style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffED1429),
                    ),),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
