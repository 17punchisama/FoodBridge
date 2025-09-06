import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'nav_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // ตัวอย่างข้อมูลรายการแจกฟรี
  final List<Map<String, String>> items = [
    {
      'image': 'assets/images/item1.png',
      'title': 'แจกข้าวมันไก่ 30 ที่',
      'location': 'ลาดกระบัง',
      'kilo': '10.2km',
      'owner': 'Jinsujee',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'สินค้า 2',
      'location': 'ลาดพร้าว',
      'kilo': '10.2km',
      'owner': 'Jinsujee',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'สินค้า 3',
      'location': 'ลำปลาซิว',
      'kilo': '10.2km',
      'owner': 'Jinsujee',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'ฉลองกรุง 1',
      'location': 'รายละเอียดสั้น ๆ 4',
      'kilo': '10.2km',
      'owner': 'Jinsujee',
    },
    {
      'image': 'assets/images/item1.png',
      'title': 'สินค้า 5',
      'location': 'ประเทศไทย',
      'kilo': '10.2km',
      'owner': 'Jinsujee',
    },
  ];

  final List<Map<String, String>> flashSaleItems = [
    {
      'image': 'assets/images/item2.png',
      'title': 'สินค้า 1',
      'shop': 'ไข่หวานบ้านซูชิ',
      'location': 'ลาดกระบัง',
      'kilo': '4.7km',
      'price': '99฿',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'สินค้า 2',
      'shop': 'ไข่หวานบ้านซูชิ',
      'location': 'ลาดกระบัง',
      'kilo': '4.7km',
      'price': '99฿',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'สินค้า 3',
      'shop': 'ไข่หวานบ้านซูชิ',
      'location': 'ลาดกระบัง',
      'kilo': '4.7km',
      'price': '99฿',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'สินค้า 4',
      'shop': 'ไข่หวานบ้านซูชิ',
      'location': 'ลาดกระบัง',
      'kilo': '4.7km',
      'price': '99฿',
    },
    {
      'image': 'assets/images/item2.png',
      'title': 'สินค้า 5',
      'shop': 'ไข่หวานบ้านซูชิ',
      'location': 'ลาดกระบัง',
      'kilo': '4.7km',
      'price': '99฿',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
                colors: [
                  Color.fromARGB(90, 3, 130, 98),
                  Color.fromARGB(60, 244, 243, 243),
                  Color(0xFFF4F3F3),
                ],
              ),
            ),
          ),
          // Main scrollable content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "ตำแหน่งของคุณ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                "บ้านกลางสวน",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff038263), // พื้นหลัง
                            borderRadius: BorderRadius.circular(20), // มุมโค้ง
                          ),
                          child: const Text(
                            'สำหรับคุณ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(right: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffffffff), // พื้นหลัง
                            borderRadius: BorderRadius.circular(20), // มุมโค้ง
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // ให้ Container พอดีกับเนื้อหา
                            children: [
                              SvgPicture.asset(
                                            'assets/icons/commu_icon.svg',
                                            width: 15,
                                            height: 15,
                                          ),
                              
                              const SizedBox(
                                width: 6,
                              ), // เว้นระยะระหว่าง icon กับ text
                              const Text(
                                'ชุมชน',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search box
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
                    // รายการแจกฟรี
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'รายการแจกฟรีใกล้ฉัน',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  blurRadius: 8,         // ความเบลอของเงา
        spreadRadius: 2,       // ขยายเงาออกนอก container
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                                          const Text(
                                            "|",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff828282),
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
                    const SizedBox(height: 20),
                    // Flash Sale
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Flash Sale ลดเดือดชั่วโมงนี้ ⚡',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  blurRadius: 8,         // ความเบลอของเงา
        spreadRadius: 2,       // ขยายเงาออกนอก container
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        flashItem['title']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                                          fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 24),
                    const Text(
                      'หมวดหมู่แนะนำ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/savory_img.png',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ของคาว',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF58319),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/dessert_img.png',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ของหวาน',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF58319),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/raw_img.png',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ของสด',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF58319),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/vegetable_img.png',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ผักสด',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF58319),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 80), // เว้นล่างพอให้ปุ่มลอยไม่บัง
                  ],
                ),
              ),
            ),
          ),

          // Floating button
        ],
      ),
    );
  }
}
