import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommunityPage extends StatelessWidget {
  // Mock data ของ user (ผู้ใช้)
  final Map<String, dynamic> currentUser = {
    'id': 1,
    'username': 'Jinsujee Kongsadee',
    'profile_img': 'assets/images/profile1.png',
  };

  // Mock data ของโพสต์
  final List<Map<String, dynamic>> posts = [
    {
      'id': 1,
      'user_id': 1, // อ้างอิงกับ user
      'caption':
          'โรงทานที่วัดลาดกระบังแจกข้าวกล่อง 30 ที่ใครสนใจมารับได้ถึงเวลา 13.00 นะคะ อยู่ตรงศาลา ได้คนละกล่องเท่านั้น',
      'post_img': 'assets/images/item1.png',
      'time': '2 ชั่วโมงที่แล้ว',
      'like': 25,
      'comment': 10,
      'isLiked': false,
    },
    {
      'id': 1,
      'user_id': 1, // อ้างอิงกับ user
      'caption':
          'โรงทานที่วัดลาดกระบังแจกข้าวกล่อง 30 ที่ใครสนใจมารับได้ถึงเวลา 13.00 นะคะ อยู่ตรงศาลา ได้คนละกล่องเท่านั้น',
      'post_img': 'assets/images/item1.png',
      'time': '2 ชั่วโมงที่แล้ว',
      'like': 25,
      'comment': 10,
      'isLiked': false,
    },
    {
      'id': 1,
      'user_id': 1, // อ้างอิงกับ user
      'caption':
          'โรงทานที่วัดลาดกระบังแจกข้าวกล่อง 30 ที่ใครสนใจมารับได้ถึงเวลา 13.00 นะคะ อยู่ตรงศาลา ได้คนละกล่องเท่านั้น',
      'post_img': 'assets/images/item1.png',
      'time': '2 ชั่วโมงที่แล้ว',
      'like': 25,
      'comment': 10,
      'isLiked': false,
    },
  ];

  CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              // เมื่อแตะ ให้เปิด popup / bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'โพสต์ใหม่',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'เกิดอะไรขึ้น?',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('โพสต์'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              // margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, // ความกว้าง
                    height: 50, // ความสูง
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(currentUser['profile_img']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Text(
                    'เกิดอะไรขึ้น?',
                    style: TextStyle(color: Color(0xff828282), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Feed
          Expanded(
  child: ListView.separated(
    itemCount: posts.length,
    separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1),
    itemBuilder: (context, index) {
      final post = posts[index];
      final user = currentUser;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(user['profile_img']),
                radius: 25,
              ),
              title: Text(
                user['username'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff038263),
                ),
              ),
              subtitle: Text(
                post['time'],
                style: const TextStyle(color: Color(0xFFF58319)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post['caption']),
            ),
            if (post['post_img'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    post['post_img'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/like.svg', width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text('${post['like']}'),
                  const SizedBox(width: 16),
                  SvgPicture.asset('assets/icons/comment.svg', width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text('${post['comment']}'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
),

        ],
      ),
    );
  }
}
