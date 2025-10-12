import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'nav_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> notifications = [
    AppNotification(
      status: 'รายการใหม่',
      title: 'แจกข้าวมันไก่ 30 ที่',
      summary: 'คุณได้รับรายการใหม่ แจกข้าวมันไก่ 30 ที่ สามารถกดดูรายละเอียดเพิ่มเติมได้',
      iconPath: 'assets/icons/gift.svg',
      dateTime: DateTime.now().subtract(const Duration(minutes: 10)),
      isUnread: true,
    ),
    AppNotification(
      status: 'หมดแล้ว',
      title: 'ไข่ไก่ฟรี',
      summary: 'รายการของคุณ ไข่ไก่ฟรี มีคนกดรับหมดแล้ว',
      iconPath: 'assets/icons/egg.svg',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      status: 'มีคนกดรับ',
      title: 'ไข่ไก่ฟรี',
      summary: 'Jinsujee Kongsadee กดรับรายการของคุณ ไข่ไก่ฟรี',
      iconPath: 'assets/icons/egg.svg',
      dateTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    ),
    AppNotification(
      status: 'หมดเวลาแล้ว',
      title: 'ข้าวขาหมูคุณชัย',
      summary: 'รายการที่คุณกดรับ ข้าวขาหมูคุณชัย หมดเวลาในการรับแล้ว',
      iconPath: 'assets/icons/clock.svg',
      dateTime: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  // Clear all notifications
  void _clearAll() {
    setState(() {
      notifications.clear();
    });
  }

  // Mark notification as read
  void _markAsRead(int index) {
    setState(() {
      notifications[index] = notifications[index].copyWith(isUnread: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_arrow.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('การแจ้งเตือน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAll,
          ),
        ],
      ),

      bottomNavigationBar: const NavBar(),

      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'ไม่มีการแจ้งเตือน',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(bottom: bottomPad),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 60, endIndent: 16),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return InkWell(
                  onTap: () => _markAsRead(index),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + unread dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              n.iconPath,
                              width: 36,
                              height: 36,
                            ),
                            if (n.isUnread)
                              const Positioned(
                                right: -1,
                                top: -1,
                                child: _UnreadDot(),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '[${n.status}] ${n.title}',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.summary,
                                style: TextStyle(color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),
                        Text(
                          formatDate(n.dateTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class AppNotification {
  final String status;
  final String title;
  final String summary;
  final String iconPath;
  final DateTime dateTime;
  final bool isUnread;

  AppNotification({
    required this.status,
    required this.title,
    required this.summary,
    required this.iconPath,
    required this.dateTime,
    this.isUnread = false,
  });

  AppNotification copyWith({
    String? status,
    String? title,
    String? summary,
    String? iconPath,
    DateTime? dateTime,
    bool? isUnread,
  }) {
    return AppNotification(
      status: status ?? this.status,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      iconPath: iconPath ?? this.iconPath,
      dateTime: dateTime ?? this.dateTime,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

String formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final sameDay = DateFormat('yyyy-MM-dd').format(now) ==
      DateFormat('yyyy-MM-dd').format(dateTime);

  if (sameDay) {
    return DateFormat('HH:mm').format(dateTime);
  }

  final difference = now.difference(dateTime);
  if (difference.inDays < 7) {
    return DateFormat('EEE').format(dateTime);
  }

  return DateFormat('d MMM').format(dateTime);
}
