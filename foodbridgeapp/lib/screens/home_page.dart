import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'for_you_page.dart';
import 'community_page.dart';
import 'nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "forYou"; // ค่าเริ่มต้น

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavBar(),
      body: Stack(
        children: [
          // 🔹 พื้นหลัง Gradient
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

          // 🔹 เนื้อหาหลัก
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 ปุ่มเลือกแท็บ
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = "forYou";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selectedTab == "forYou"
                                ? const Color(0xff038263)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'สำหรับคุณ',
                            style: TextStyle(
                              color: selectedTab == "forYou"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = "community";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selectedTab == "community"
                                ? const Color(0xff038263)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/commu_icon.svg',
                                width: 15,
                                height: 15,
                                color: selectedTab == "community"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ชุมชน',
                                style: TextStyle(
                                  color: selectedTab == "community"
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔹 เนื้อหาเปลี่ยนตามแท็บ
                  Expanded(
                    child: selectedTab == "forYou"
                        ? ForYouPage()
                        : CommunityPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
