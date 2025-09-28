import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodbridgeapp/screens/post_page.dart';
import 'package:foodbridgeapp/screens/create_post.dart';

class ForYouPage extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'image': 'assets/images/item1.png',
      'title': 'ข้าวกล่องฟรี',
      'location': 'ลาดพร้าว',
      'kilo': '2km.',
      'owner': 'คุณเอ',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'ผลไม้สด',
      'location': 'บางกะปิ',
      'kilo': '3km.',
      'owner': 'คุณบี',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'น้ำดื่มฟรี',
      'location': 'รัชดา',
      'kilo': '1.5km.',
      'owner': 'คุณซี',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'ขนมปังโฮมเมด',
      'location': 'ห้วยขวาง',
      'kilo': '2.3km.',
      'owner': 'คุณดี',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'ไข่ต้ม',
      'location': 'ลาดกระบัง',
      'kilo': '4km.',
      'owner': 'คุณอี',
    },
  ];

  final List<Map<String, String>> flashSaleItems = [
    {
      'image': 'assets/images/item2.png',
      'title': 'เค้กช็อกโกแลต',
      'shop': 'ร้านหวานเย็น',
      'location': 'ห้วยขวาง',
      'kilo': '1.5km.',
      'price': '฿99',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'น้ำผลไม้รวม',
      'shop': 'ร้านสดชื่น',
      'location': 'รัชดา',
      'kilo': '2km.',
      'price': '฿59',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'กาแฟเย็น',
      'shop': 'ร้านกาแฟดี',
      'location': 'บางกะปิ',
      'kilo': '2.5km.',
      'price': '฿49',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'ช็อกโกแลตบาร์',
      'shop': 'ร้านหวานเย็น',
      'location': 'ลาดพร้าว',
      'kilo': '3km.',
      'price': '฿39',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'น้ำส้มคั้น',
      'shop': 'ร้านสดชื่น',
      'location': 'ห้วยขวาง',
      'kilo': '1.8km.',
      'price': '฿29',
    },
  ];

  ForYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔎 Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหาสิ่งที่คุณต้องการ',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/icons/search_icon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 รายการแจกฟรีใกล้ฉัน
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'รายการแจกฟรีใกล้ฉัน',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF58319),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            item['image']!,
                            width: 160,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/location.svg',
                                    width: 12,
                                    height: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    item['location']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bike.svg',
                                    width: 10,
                                    height: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    item['kilo']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xff828282),
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/owner.svg',
                                    width: 10,
                                    height: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    item['owner']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ⚡ Flash Sale
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Flash Sale ลดเดือดชั่วโมงนี้ ⚡',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF58319),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: flashSaleItems.length,
                itemBuilder: (context, index) {
                  final flashItem = flashSaleItems[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            flashItem['image']!,
                            width: 160,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flashItem['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                flashItem['shop']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff828282),
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/location.svg',
                                    width: 12,
                                    height: 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    flashItem['location']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/bike.svg',
                                    width: 10,
                                    height: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    flashItem['kilo']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                flashItem['price']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xffED1429),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 📂 หมวดหมู่แนะนำ
            const SizedBox(height: 24),
            const Text(
              'หมวดหมู่แนะนำ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCategory('assets/images/savory_img.png', 'ของคาว'),
                buildCategory('assets/images/dessert_img.png', 'ของหวาน'),
                buildCategory('assets/images/raw_img.png', 'ของสด'),
                buildCategory('assets/images/vegetable_img.png', 'ผักสด'),
              ],
            ),
            const SizedBox(height: 80), // กันปุ่มลอยบัง
          ],
        ),
      ),

      // 🟠 ปุ่มลอยมุมขวาล่าง
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // มุมบนขวา
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
        },
        backgroundColor: const Color(0xFFF58319),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  // helper method
  Widget buildCategory(String imagePath, String title) {
    return Column(
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(imagePath)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFFF58319)),
        ),
      ],
    );
  }
}
