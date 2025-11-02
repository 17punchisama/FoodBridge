import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final storage = const FlutterSecureStorage();
  late Future<List<Map<String, dynamic>>> _future;
  final Map<int, String> postTitleCache = {};

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  /// 🔐 Fetch notifications
  Future<List<Map<String, dynamic>>> fetchNotifications(String token) async {
    final url = Uri.parse('https://foodbridge1.onrender.com/notifications');
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map && data['items'] is List) {
        return List<Map<String, dynamic>>.from(data['items']);
      }
    }
    return [];
  }

  /// 🧩 Fetch post data — for title clarity
  Future<String?> fetchPostTitle(int postId, String token) async {
    // Use cache to avoid duplicate network calls
    if (postTitleCache.containsKey(postId)) {
      return postTitleCache[postId];
    }

    try {
      final url = Uri.parse('https://foodbridge1.onrender.com/posts/$postId');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final title = data['title'] ?? '-';
        postTitleCache[postId] = title;
        return title;
      }
    } catch (e) {
      debugPrint('fetchPostTitle error: $e');
    }
    return null;
  }

  void loadNotifications() async {
    // final token = await storage.read(key: 'token');
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjIyMjc0MDksInJvbGUiOiJVU0VSIiwidWlkIjoyfQ.wgxcI6YlrWBQS0TILjijFUygE4X_ZTz1OcU8T632Ru0';
    if (token == null) return;
    setState(() {
      _future = fetchNotifications(token);
    });
  }

  /// 🏷️ Normalize type name for display
  String normalizeType(String type) {
    if (type.isEmpty) return 'UNKNOWN';
    if (type.contains('.')) {
      final parts = type.split('.');
      if (parts.contains('cancelled')) return 'CANCELLED';
      return parts.length > 1 ? parts[1].toUpperCase() : parts.last.toUpperCase();
    }
    return type.toUpperCase();
  }

  /// 🖼️ Select icon
  String iconPathForType(String type) {
    switch (type.toUpperCase()) {
      case 'PENDING':
        return 'assets/icons/new_pending.svg';
      case 'CANCELLED':
        return 'assets/icons/new_cancelled.svg';
      case 'ACCEPTED':
        return 'assets/icons/new_excepted.svg';
      default:
        return 'assets/icons/new_expired.svg';
    }
  }

  /// 🕒 Format Thai date
  String formatThaiDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;

    if (sameDay) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    if (diff.inDays < 7) {
      const weekdays = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
      return weekdays[date.weekday - 1];
    }

    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff2A2929),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('โหลดข้อมูลไม่สำเร็จ'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('ยังไม่มีการแจ้งเตือน'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
            itemBuilder: (context, i) {
              final n = list[i];
              final int id = n['notification_id'] ?? 0;
              final String title = (n['title'] ?? '').toString();
              final String body = (n['body'] ?? '').toString();
              final bool isRead = (n['is_read'] ?? false) == true;
              final String type = normalizeType(n['type'] ?? '');
              final DateTime createdAt =
                  DateTime.tryParse(n['created_at'] ?? '') ?? DateTime.now();
              final int? postId = n['data']?['post_id'];

              final iconPath = iconPathForType(type);

              return InkWell(
                onTap: () {
                  // You could navigate to detail here
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(iconPath, width: 36, height: 36),
                          if (!isRead)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      /// 🧾 Notification Text Block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[${type.toUpperCase()}] $title',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              body,
                              style: const TextStyle(color: Colors.black87),
                            ),

                            /// 🎯 Fetch and display post title below
                            if (postId != null)
                              FutureBuilder<String?>(
                                future: storage.read(key: 'token').then(
                                  (token) => token != null
                                      ? fetchPostTitle(postId, token)
                                      : null,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      'กำลังโหลดโพสต์...',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    );
                                  }
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Text(
                                      'โพสต์: ${snapshot.data}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                      ),

                      // 🕒 Date/time
                      SizedBox(
                        width: 55,
                        child: Text(
                          formatThaiDate(createdAt),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}