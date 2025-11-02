import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodbridgeapp/screens/post_page.dart';
import 'package:foodbridgeapp/screens/create_post.dart';
// import 'other_profile_page.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodbridgeapp/verified_service.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  List<Map<String, String>> allFreePosts = [];
  bool loadingFreePosts = true;
  List<Map<String, String>> allSalePosts = [];
  bool loadingSalePosts = true;
  final _storage = const FlutterSecureStorage();
  String? currentProvince;
  LatLng? _currentUserPosition;
  // Map<String, dynamic>? userData;

  final categories_4 = [
    {'icon': 'assets/images/meal.png', 'label': 'ของคาว'},
    {'icon': 'assets/images/dessert.png', 'label': 'ของหวาน'},
    {'icon': 'assets/images/meat.png', 'label': 'เนื้อสด'},
    {'icon': 'assets/images/veggies.png', 'label': 'ผัก'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserProvinceAndPosition();
    await fetchAllFreePosts();
  }

  Future<void> _loadUserProvinceAndPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        currentProvince = placemarks.isNotEmpty
            ? placemarks.first.administrativeArea ?? "No Where"
            : "No Where";
        _currentUserPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Error reverse geocoding: $e");
      if (!mounted) return;
      setState(() {
        currentProvince = "No Where";
        _currentUserPosition = LatLng(13.7563, 100.5018);
      });
    }
  }

  Future<double?> calculateDistance(double postLat, double postLng) async {
    if (_currentUserPosition == null) return null;

    final distanceInMeters = Geolocator.distanceBetween(
      _currentUserPosition!.latitude,
      _currentUserPosition!.longitude,
      postLat,
      postLng,
    );

    return distanceInMeters / 1000; // km
  }

  Future<void> fetchAllFreePosts() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return;

    final urls = [
      'https://foodbridge1.onrender.com/posts?status=CLOSED',
      'https://foodbridge1.onrender.com/posts',
    ];

    try {
      List<Map<String, String>> itemFree = [];
      List<Map<String, String>> itemSale = [];
      // List<Map<String, String>> mergedPosts = [];

      for (String url in urls) {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) continue;

        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        final futures = items.map<Future<Map<String, String>>>((item) async {
          final images = item['images'] ?? [];
          final imageUrl = (images.isNotEmpty && images.first is String)
              ? images.first as String
              : 'https://genconnect.com.sg/cdn/shop/files/Display.jpg?v=1684741232&width=1445';

          final createdAt = item['created_at'];
          DateTime createdAtDate;
          if (createdAt is int) {
            createdAtDate = DateTime.fromMillisecondsSinceEpoch(
              createdAt * 1000,
            );
          } else if (createdAt is String) {
            createdAtDate = DateTime.tryParse(createdAt) ?? DateTime(0);
          } else {
            createdAtDate = DateTime(0);
          }

          double? lat = item['lat'];
          double? lng = item['lng'];
          String kiloText;

          if (lat == null || lng == null) {
            kiloText = '- km';
          } else {
            final distance = await calculateDistance(
              lat.toDouble(),
              lng.toDouble(),
            );

            if (distance == null) {
              kiloText = 'Null';
            } else {
              final clampedDistance = distance > 999 ? 999 : distance;
              kiloText = distance > 999
                  ? '999+ km'
                  : "${clampedDistance.toStringAsFixed(2)} km";
            }
          }

          Map<String, dynamic> ownerData = {};
          final responseUser = await http.get(
            Uri.parse(
              'https://foodbridge1.onrender.com/users/${item['provider_id']}',
            ),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (responseUser.statusCode == 200) {
            ownerData = jsonDecode(responseUser.body);
          } else {
            debugPrint('Failed to load user: ${responseUser.statusCode}');
          }

          String shop;
          if (item['categories'] == null || item['categories'] == []) {
            shop = 'No categories';
          } else {
            shop = item['categories']?.join(', ');
          }

          final postMap = {
            'image': imageUrl.toString(),
            'title': item['title'].toString(),
            'location':
                (item['address'] == null || item['address'].toString().isEmpty)
                ? 'ไม่ระบุสถานที่'
                : item['address'].toString(),
            'kilo': kiloText,
            'owner': ownerData['full_name'].toString(),
            'created_at': createdAtDate.toIso8601String(),
            'shop': shop,
            'price': "฿${item['price']}",
          };

          // Separate into free vs sale
          if ((item['price'] ?? 0) == 0 || item['price'] == null) {
            itemFree.add(postMap);
          } else {
            itemSale.add(postMap);
          }

          return postMap;
        }).toList();

        await Future.wait(futures);
      }

      // Sort both lists newest first
      itemFree.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      itemSale.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        allFreePosts = itemFree;
        allSalePosts = itemSale;
        loadingFreePosts = false;
      });
    } catch (e) {
      debugPrint("Error fetching posts: $e");

      if (!mounted) return;
      setState(() {
        loadingFreePosts = false;
        loadingSalePosts = false;
      });
    }
  }

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
                  BoxShadow(color: Colors.black12, blurRadius: 10),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example Section
            if (loadingFreePosts)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(name: 'โพสต์ของฉัน'),
                  PostPreviewSmall(items: allFreePosts),
                ],
              ),

            const SizedBox(height: 20),

            // Flash Sale Section
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
                itemCount: allSalePosts.length,
                itemBuilder: (context, index) {
                  final flashItem = allSalePosts[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
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
                          child: Image.network(
                            flashItem['image']!,
                            width: 160,
                            height: 140,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://genconnect.com.sg/cdn/shop/files/Display.jpg?v=1684741232&width=1445',
                                width: 160,
                                height: 140,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 140, // or whatever width fits your layout
                                child: Text(
                                  flashItem['title']!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                                  SizedBox(
                                    width: 130, // or whatever width fits your layout
                                    child: Text(
                                      flashItem['location']!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xff828282),
                                      ),
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
            const SizedBox(height: 20),
            Text(
              "หมวดหมู่แนะนำ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: categories_4.map((cat) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => CategoryPage(categoryLabel: cat['label']!),
                    //   ),
                    // );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        cat['icon']!, 
                        width: 50,
                        height: 50,
                      ),
                      // SvgPicture.asset(
                      //   cat['icon']!,
                      //   width: 50,
                      //   height: 50,
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        cat['label']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 245, 131, 25),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

class _HeaderRow extends StatelessWidget {
  final String name;

  const _HeaderRow({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
            color: Color.fromARGB(255, 244, 243, 243),
            size: 12,
          ),
        ),
      ],
    );
  }
}

class PostPreviewSmall extends StatelessWidget {
  final List<Map<String, String>> items;

  const PostPreviewSmall({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 12),
          items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "ยังไม่มีโพสต์",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _ItemCard(item: items[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, String> item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // MaterialPageRoute(builder: (_) => const PostPage(PostId: item['id'])),
          MaterialPageRoute(builder: (_) => const PostPage()),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImage(), const SizedBox(height: 8), _buildDetails()],
        ),
      ),
    );
  }

  Widget _buildImage() => ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
    child: Image.network(
      item['image']!,
      width: 160,
      height: 80,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          'https://genconnect.com.sg/cdn/shop/files/Display.jpg?v=1684741232&width=1445',
          width: 160,
          height: 80,
          fit: BoxFit.cover,
        );
      },
    ),
  );

  Widget _buildDetails() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140, // or whatever width fits your layout
          child: Text(
            item['title']!,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/location.svg',
              width: 12,
              height: 12,
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: 130, // or whatever width fits your layout
              child: Text(
                item['location']!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset('assets/icons/bike.svg', width: 10, height: 10),
            const SizedBox(width: 3),
            Text(
              item['kilo']!,
              // double.tryParse(item['kilo']?.replaceAll(' km', '') ?? '0') !=
              //         null
              //     ? "${double.parse(item['kilo']!.replaceAll(' km', '')).clamp(0, 999).toStringAsFixed(0)} km"
              //     : item['kilo']!,
              style: const TextStyle(fontSize: 10, color: Color(0xff828282)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '|',
                style: TextStyle(fontSize: 10, color: Color(0xff828282)),
              ),
            ),
            SvgPicture.asset('assets/icons/owner.svg', width: 10, height: 10),
            const SizedBox(width: 3),
            Text(
              item['owner']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Color(0xff828282)),
            ),
          ],
        ),
      ],
    ),
  );
}
