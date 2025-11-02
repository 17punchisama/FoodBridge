import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodbridgeapp/screens/notification_page.dart';
import 'home_page.dart';
import 'post_page.dart';
import 'profile_page.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final bool hasNotification;

  const NavBar({
    Key? key,
    this.currentIndex = 0,
    this.hasNotification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFFF58319);
    const Color inactiveColor = Colors.black;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12, // keep consistent
      unselectedFontSize: 12, // no text size jump
      onTap: (index) {
        Widget page;
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const PostPage();
            break;
          case 2:
            page = const NotificationPage();
            break;
          case 3:
            page = const ProfilePage();
            break;
          default:
            page = const HomePage();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/home_nav.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              currentIndex == 0 ? activeColor : inactiveColor,
              BlendMode.srcIn,
            ),
          ),
          label: 'หน้าแรก',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/order_nav.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              currentIndex == 1 ? activeColor : inactiveColor,
              BlendMode.srcIn,
            ),
          ),
          label: 'รายการ',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              SvgPicture.asset(
                'assets/icons/noti_nav.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  currentIndex == 2 ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              if (hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          label: 'แจ้งเตือน',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/profile_nav.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              currentIndex == 3 ? activeColor : inactiveColor,
              BlendMode.srcIn,
            ),
          ),
          label: 'โปรไฟล์',
        ),
      ],
    );
  }
}
