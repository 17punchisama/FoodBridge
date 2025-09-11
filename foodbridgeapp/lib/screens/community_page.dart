import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// สมมติว่ามีหน้า PostDetailPage
class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> user;

  const PostDetailPage({super.key, required this.post, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icons/back_arrow.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'โพสต์',
                    style: TextStyle(
                      color: Color(0xff2A2929),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),

              // Post Detail
              Material(
                color: Colors.transparent,
                child: ListTile(
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(post['caption']),
              ),
              if (post['post_img'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "ถูกใจ ${post['like']} คน และคอมเมนต์ ${post['comments']?.length ?? 0} รายการ",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // รูปโปรไฟล์ทางซ้าย
                    CircleAvatar(
                      backgroundImage: AssetImage(user['profile_img']),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    // TextField ขยายเต็มที่
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'แสดงความคิดเห็นของคุณ...',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // ปุ่มส่งข้อความ (optional)
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // ใส่ logic ส่ง comment
                      },
                    ),
                  ],
                ),
              ),
              // ตัวอย่าง comment
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (post["comments"] as List).map((comment) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // รูปโปรไฟล์
                        CircleAvatar(
                          backgroundImage: AssetImage(comment['profile_img']),
                          radius: 20,
                        ),
                        const SizedBox(width: 8),

                        // เนื้อหาคอมเมนต์
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['username'] ?? 'ไม่ทราบชื่อ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff038263),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                comment['time'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFFF58319),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // ✅ พื้นหลังเฉพาะข้อความคอมเมนต์
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xDDF58319),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomLeft:  Radius.circular(12),bottomRight:  Radius.circular(12) ),
                                ),
                                child: Text(
                                  comment["comment_caption"] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xffffffff),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
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
      'user_id': 1,
      'username': 'Jinsujee Kongsadee', // เพิ่มชื่อผู้โพสต์
      'profile_img': 'assets/images/profile1.png', // เพิ่มโปรไฟล์ผู้โพสต์
      'caption':
          'โรงทานที่วัดลาดกระบังแจกข้าวกล่อง 30 ที่ ใครสนใจมารับได้ถึงเวลา 13.00 นะคะ',
      'post_img': 'assets/images/item1.png',
      'time': '2 ชั่วโมงที่แล้ว',
      'like': 25,
      'comments': [
        {
          'user_id': 2,
          'username': 'Somchai',
          'profile_img': 'assets/images/profile1.png',
          'comment_caption': 'ขอบคุณมากครับ 🙏',
          'time': '1 ชั่วโมงที่แล้ว',
        },
        {
          'user_id': 3,
          'username': 'Suda',
          'profile_img': 'assets/images/item1.png',
          'comment_caption': 'จะรีบไปเลยค่ะ ❤️',
          'time': '45 นาทีที่แล้ว',
        },
      ],
      'isLiked': false,
    },
    {
      'id': 2,
      'user_id': 1,
      'username': 'Jinsujee Kongsadee',
      'profile_img': 'assets/images/profile1.png',
      'caption': 'วันนี้มีผักสดจากสวน มารับฟรีได้ครับ',
      'post_img': 'assets/images/item2.png',
      'time': '5 ชั่วโมงที่แล้ว',
      'like': 12,
      'comments': [
        {
          'user_id': 4,
          'username': 'Arthit',
          'profile_img': 'assets/images/item1.png',
          'comment_caption': 'สุดยอดเลยครับ!',
          'time': '4 ชั่วโมงที่แล้ว',
        },
        {
          'user_id': 5,
          'username': 'Test',
          'profile_img': 'assets/images/item1.png',
          'comment_caption':
              'ไปรับมาแล้วค่ะ เมื่อตอน 11 โมงนี่เอง ขอบคุณมากเลยนะคะที่แจ้งข่าว ขออนุญาตเอาไปแจกต่อนะคะ อนุโมธนา สาธุค่ะ ขอให้สุขภาพดีแข็งแรงนะคะ',
          'time': '4 ชั่วโมงที่แล้ว',
        },
      ],
      'isLiked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ส่วนโพสต์ใหม่
          GestureDetector(
            onTap: () {
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
                  CircleAvatar(
                    backgroundImage: AssetImage(currentUser['profile_img']),
                    radius: 25,
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
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.grey, height: 1),
              itemBuilder: (context, index) {
                final post = posts[index];
                // ใช้ user info จาก post
                final postUser = {
                  'username': post['username'],
                  'profile_img': post['profile_img'],
                };

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostDetailPage(post: post, user: postUser),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                              postUser['profile_img'],
                            ),
                            radius: 25,
                          ),
                          title: Text(
                            postUser['username'],
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/like.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 4),
                              Text('${post['like']}'),
                              const SizedBox(width: 16),
                              SvgPicture.asset(
                                'assets/icons/comment.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 4),
                              Text('${post['comments']?.length ?? 0}'),
                            ],
                          ),
                        ),
                      ],
                    ),
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
