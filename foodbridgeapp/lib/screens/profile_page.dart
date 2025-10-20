import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'edit_profile_page.dart';
import 'post_page.dart';
import 'nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>?> fetchUser() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('https://foodbridge1.onrender.com/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final successBoxWidth = (screenWidth - 56) / 3;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 243),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;
          final fullName = user['full_name'] ?? 'Username';
          final province = user['province'] ?? 'Bangkok, Thailand';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/no_profile.svg',
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fullName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          iconSize: 30,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 28),
                    const SizedBox(width: 4),
                    Text(
                      province,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 3, 130, 99),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(50, 245, 131, 25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'จำนวนสิทธิ์ที่เหลือ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'วันที่ 18 กันยายน 2568',
                            style: TextStyle(
                                color: Color.fromARGB(255, 237, 20, 41),
                                fontSize: 16),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          '1/2',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'รายการของฉัน',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PostPage()),
                        );
                      },
                      child: Text(
                        'ดูทั้งหมด',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // horizontal posts
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(80, 3, 130, 99),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        5,
                        (index) => PreviewPostBox(
                          status: index % 2 == 0 ? "ได้คิวแล้ว" : "ได้รับอาหารแล้ว",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ความสำเร็จ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SuccessBox(
                        width: successBoxWidth,
                        name: 'ประหยัดไป',
                        iconPath: 'assets/icons/coin.svg',
                        number: 1,
                        unit: 'บาท',
                      ),
                      SizedBox(width: 12),
                      SuccessBox(
                        width: successBoxWidth,
                        name: 'แบ่งบันไป',
                        iconPath: 'assets/icons/kindness_green.svg',
                        number: 2,
                        unit: 'ครั้ง',
                      ),
                      SizedBox(width: 12),
                      SuccessBox(
                        width: successBoxWidth,
                        name: 'รับน้ำใจ',
                        iconPath: 'assets/icons/kindness_orange.svg',
                        number: 3,
                        unit: 'ครั้ง',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}

// Horizontal success boxes
class SuccessBox extends StatelessWidget {
  final double width;
  final String name;
  final String iconPath;
  final int number;
  final String unit;

  const SuccessBox({
    super.key,
    required this.width,
    required this.name,
    required this.iconPath,
    required this.number,
    required this.unit,
  });

  Color getSuccessColor() {
    switch (name) {
      case "ประหยัดไป":
        return const Color.fromARGB(255, 237, 20, 41);
      case "แบ่งบันไป":
        return const Color.fromARGB(255, 3, 130, 99);
      case "รับน้ำใจ":
        return const Color.fromARGB(255, 245, 131, 25);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: getSuccessColor(),
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          SvgPicture.asset(iconPath, width: 47, height: 47),
          SizedBox(height: 10),
          Text(
            '$number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: getSuccessColor(),
            ),
          ),
          SizedBox(height: 5),
          Text(unit, style: TextStyle(color: getSuccessColor(), fontSize: 20)),
        ],
      ),
    );
  }
}

// Preview post box
class PreviewPostBox extends StatelessWidget {
  final String status;
  const PreviewPostBox({super.key, required this.status});

  Color getStatusColor() {
    switch (status) {
      case "ได้คิวแล้ว":
        return const Color.fromARGB(255, 245, 131, 25);
      case "ได้รับอาหารแล้ว":
        return const Color.fromARGB(255, 3, 130, 99);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210, // fixed width
      height: 100,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // status
          Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: getStatusColor()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: getStatusColor(), fontSize: 12),
            ),
          ),
          SizedBox(height: 8),
          // profile row
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/no_profile.svg',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'แจกข้าวมันไก่ฟ...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'เปิด 9.00 - 12.00',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          // countdown box
          CountdownBox(status: status),
        ],
      ),
    );
  }
}

// Countdown box with fixed height for 1 line
class CountdownBox extends StatefulWidget {
  final String status;
  const CountdownBox({super.key, required this.status});

  @override
  _CountdownBoxState createState() => _CountdownBoxState();
}

class _CountdownBoxState extends State<CountdownBox> {
  Duration duration = Duration(hours: 1);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (duration.inSeconds > 0) duration -= Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Color getColor() {
    switch (widget.status) {
      case "ได้คิวแล้ว":
        return Colors.green;
      case "ได้รับอาหารแล้ว":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, // fixed height to fit 1 line
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: getColor()),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'รับอาหารภายใน',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: getColor(),
            ),
          ),
          SizedBox(width: 4),
          Text(
            formatDuration(duration),
            style: TextStyle(
              color: getColor(),
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'นาที',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: getColor(),
            ),
          ),
        ],
      ),
    );
  }
}
