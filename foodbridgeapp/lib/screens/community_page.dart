import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ===================================================================
/// 1) SERVICE สำหรับ token + /me
/// ===================================================================
class VerifiedService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  /// ดึง token ที่เราเซฟไว้ตอน login
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// ดึง user ปัจจุบันจาก backend: GET /me
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    final res = await http.get(
      Uri.parse('https://foodbridge1.onrender.com/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}

/// ===================================================================
/// 2) API SERVICE หลัก (posts / users / likes / comments)
/// ===================================================================
class ApiService {
  static const String baseUrl = 'https://foodbridge1.onrender.com';

  /// ดึงโพสต์ทั้งหมด แล้วกรองเฉพาะ post_type = COMMUNITY
  static Future<List<Map<String, dynamic>>> getCommunityPosts(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/posts');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final items = (data['items'] as List?) ?? [];

      return items
          .where(
            (e) =>
                (e['post_type'] ?? '').toString().toUpperCase() == 'COMMUNITY',
          )
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      print('getCommunityPosts error: ${res.statusCode} ${res.body}');
      return [];
    }
  }

  /// GET /users/:id
  static Future<Map<String, dynamic>?> getUser(String token, int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return null;
    } else {
      print('getUser error: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  /// GET /posts/:post_id/likes
  static Future<Map<String, dynamic>?> getPostLikes(
    String token,
    int postId,
  ) async {
    final url = Uri.parse('$baseUrl/posts/$postId/likes');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } else {
      print('getPostLikes error: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  /// GET /posts/:post_id/comments?include_children=true
  static Future<Map<String, dynamic>?> getPostComments(
    String token,
    int postId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/posts/$postId/comments?include_children=true',
    );

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data is Map<String, dynamic> ? data : null;
    } else {
      print('getPostComments error: ${res.statusCode} ${res.body}');
      return null;
    }
  }

  /// ใช้บนหน้า list: ดึงโพสต์ชุมชน + ดึง owner + like_count + comment_count
  static Future<List<Map<String, dynamic>>> getCommunityFeedWithExtras(
    String token,
  ) async {
    final posts = await getCommunityPosts(token);
    final List<Future<Map<String, dynamic>>> jobs = [];
    for (final post in posts) {
      jobs.add(_enrichPostWithExtras(token, post));
    }
    return await Future.wait(jobs);
  }

  /// enrich โพสต์ 1 อัน: เพิ่ม owner + like_count + comment_count
  static Future<Map<String, dynamic>> _enrichPostWithExtras(
    String token,
    Map<String, dynamic> post,
  ) async {
    final int postId = post['post_id'] as int;
    final int providerId = post['provider_id'] as int;

    final results = await Future.wait([
      getUser(token, providerId),
      getPostLikes(token, postId),
      getPostComments(token, postId),
    ]);

    final Map<String, dynamic> owner =
        (results[0] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> likes =
        (results[1] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic>? commentsResp =
        results[2] as Map<String, dynamic>?;

    final int commentCount =
        ((commentsResp?['comments'] as List?) ?? []).length;

    return {
      'post': post,
      'owner': owner,
      'like_count': (likes['like_count'] ?? 0) as int,
      'comment_count': commentCount,
    };
  }

  /// ดึงโพสต์เดี่ยว + owner + likes + comments + (ดึง user ของคนที่เมนต์ด้วย)
  static Future<Map<String, dynamic>> getFullPostBundle({
    required String token,
    required Map<String, dynamic> post,
  }) async {
    final int postId = post['post_id'] as int;
    final int providerId = post['provider_id'] as int;

    // ยิง 3 endpoint หลักก่อน
    final results = await Future.wait([
      getUser(token, providerId),
      getPostLikes(token, postId),
      getPostComments(token, postId),
    ]);

    final Map<String, dynamic> owner =
        (results[0] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> likes =
        (results[1] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic>? commentsResp =
        results[2] as Map<String, dynamic>?;

    // ดึง comments ดิบจาก backend
    final List<dynamic> commentsRaw =
        (commentsResp?['comments'] as List?) ?? [];

    // --- ดึง user ของคนคอมเมนต์เพิ่ม ---
    final List<int> commenterIds = [];
    for (final c in commentsRaw) {
      if (c is Map && c['user_id'] != null) {
        final int uid = c['user_id'] as int;
        if (!commenterIds.contains(uid)) {
          commenterIds.add(uid);
        }
      }
    }

    final List<Future<Map<String, dynamic>?>> userJobs = commenterIds
        .map((uid) => getUser(token, uid))
        .toList();

    final List<Map<String, dynamic>?> userResults = await Future.wait(userJobs);

    final Map<int, Map<String, dynamic>> commentUsersById = {};
    for (int i = 0; i < commenterIds.length; i++) {
      final uid = commenterIds[i];
      final user = userResults[i];
      if (user != null) {
        commentUsersById[uid] = user;
      }
    }

    final List<Map<String, dynamic>> commentsEnriched =
        commentsRaw.map<Map<String, dynamic>>((c) {
      final m = Map<String, dynamic>.from(c as Map);
      final uid = m['user_id'];
      if (uid is int && commentUsersById.containsKey(uid)) {
        m['user'] = commentUsersById[uid];
      }
      return m;
    }).toList();

    return {
      'post': post,
      'owner': owner,
      'likes': likes,
      'comments': commentsEnriched,
    };
  }
}

/// ===================================================================
/// 3) POST DETAIL PAGE
/// ===================================================================
class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  final String token;
  final Map<String, dynamic>? currentUser; // จาก /me

  const PostDetailPage({
    super.key,
    required this.post,
    required this.token,
    required this.currentUser,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getFullPostBundle(
      token: widget.token,
      post: widget.post,
    );
  }

  // แสดงรูปแบบฉลาด
  Widget _buildPostImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      path,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  // format iso -> ไทย
  String _formatIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const thMonths = [
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];
      final day = dt.day;
      final m = thMonths[dt.month - 1];
      final y = dt.year % 100;
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$day $m $y, $hh:$mm';
    } catch (_) {
      return iso;
    }
  }

  Widget _currentUserAvatar() {
    final me = widget.currentUser;
    if (me == null) {
      return const CircleAvatar(
        backgroundImage: AssetImage('assets/images/profile1.png'),
        radius: 20,
      );
    }
    final avatarUrl = me['avatar_url'] as String?;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('http')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 20,
      );
    }
    return const CircleAvatar(
      backgroundImage: AssetImage('assets/images/profile1.png'),
      radius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('โหลดโพสต์ไม่สำเร็จ'));
            }

            final bundle = snapshot.data!;
            final post = bundle['post'] as Map<String, dynamic>;
            final Map<String, dynamic> owner =
                (bundle['owner'] as Map<String, dynamic>?) ?? {};
            final Map<String, dynamic> likes =
                (bundle['likes'] as Map<String, dynamic>?) ?? {};
            final List comments = (bundle['comments'] as List?) ?? <dynamic>[];

            final List images = (post['images'] as List?) ?? [];
            final String? firstImage =
                images.isNotEmpty ? images.first.toString() : null;

            final String displayName =
                (owner['display_name'] ?? owner['full_name'] ?? 'ผู้ใช้หมายเลข ${post['provider_id']}')
                    .toString();

            final String? avatarUrl = owner['avatar_url'] as String?;
            final Widget avatarWidget = (avatarUrl != null &&
                    avatarUrl.isNotEmpty &&
                    avatarUrl.startsWith('http'))
                ? CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                    radius: 25,
                  )
                : const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile1.png'),
                    radius: 25,
                  );

            // เวลาสร้างโพสต์ (ของ post เป็น unix seconds)
            final createdAt = post['created_at'];
            String createdAtStr = '';
            if (createdAt is int) {
              final dt = DateTime.fromMillisecondsSinceEpoch(
                createdAt * 1000,
                isUtc: true,
              ).toLocal();
              createdAtStr =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }

            final int likeCount = (likes['like_count'] ?? 0) as int;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 24,
                          height: 24,
                        ),
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
                ),

                // owner + เวลา
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      avatarWidget,
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff038263),
                            ),
                          ),
                          Text(
                            createdAtStr,
                            style: const TextStyle(
                              color: Color(0xFFF58319),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // caption/description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    post['description'] ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                // รูป (ถ้ามีเท่านั้น)
                if (firstImage != null && firstImage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildPostImage(firstImage),
                    ),
                  ),

                // likes count + comment count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/like.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('$likeCount'),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        'assets/icons/comment.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${comments.length}'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // แถวพิมพ์คอมเมนต์ (ใช้ user ที่ login อยู่)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _currentUserAvatar(),
                      const SizedBox(width: 8),
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
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          // TODO: ส่ง comment ไป backend
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // comments list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index] as Map<String, dynamic>;
                      final body = c['body']?.toString() ?? '';
                      final userId = c['user_id'];
                      final created = c['created_at']?.toString();

                      final Map<String, dynamic>? commentUser =
                          c['user'] as Map<String, dynamic>?;

                      final String cDisplayName =
                          (commentUser?['display_name'] ??
                                  commentUser?['full_name'] ??
                                  'user #$userId')
                              .toString();

                      final String? commentAvatar =
                          commentUser?['avatar_url'] as String?;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (commentAvatar != null &&
                                commentAvatar.isNotEmpty &&
                                commentAvatar.startsWith('http'))
                              CircleAvatar(
                                backgroundImage: NetworkImage(commentAvatar),
                                radius: 18,
                              )
                            else
                              const CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/profile1.png',
                                ),
                                radius: 18,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cDisplayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (created != null)
                                    Text(
                                      _formatIso(created),
                                      style: const TextStyle(
                                        color: Color(0xFFF58319),
                                        fontSize: 12,
                                      ),
                                    ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF2F2F2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(body),
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
              ],
            );
          },
        ),
      ),
    );
  }
}

/// ===================================================================
/// 4) COMMUNITY PAGE (list)
/// ===================================================================
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // เราจะโหลด 3 อย่างพร้อมกัน: token, me, feed
  late Future<({
    String token,
    Map<String, dynamic>? me,
    List<Map<String, dynamic>> feed,
  })> _futureAll;

  @override
  void initState() {
    super.initState();
    _futureAll = _loadAll();
  }

  Future<({
    String token,
    Map<String, dynamic>? me,
    List<Map<String, dynamic>> feed,
  })> _loadAll() async {
    final token = await VerifiedService.getToken();
    if (token == null) {
      // กรณีไม่มี token (ยังไม่ล็อกอิน)
      throw Exception('ยังไม่ได้ล็อกอิน');
    }

    final me = await VerifiedService.getCurrentUser();
    final feed = await ApiService.getCommunityFeedWithExtras(token);

    return (token: token, me: me, feed: feed);
  }

  String _formatFromUnix(dynamic v) {
    if (v == null) return '';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (v as int) * 1000,
        isUtc: true,
      ).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildMeAvatar(Map<String, dynamic>? me) {
    if (me == null) {
      return const CircleAvatar(
        backgroundImage: AssetImage('assets/images/profile1.png'),
        radius: 25,
      );
    }
    final avatarUrl = me['avatar_url'] as String?;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('http')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 25,
      );
    }
    return const CircleAvatar(
      backgroundImage: AssetImage('assets/images/profile1.png'),
      radius: 25,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<({
        String token,
        Map<String, dynamic>? me,
        List<Map<String, dynamic>> feed,
      })>(
        future: _futureAll,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;
          final token = data.token;
          final me = data.me;
          final feed = data.feed;

          return Column(
            children: [
              const SizedBox(height: 16),

              // กล่องโพสต์ใหม่
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      _buildMeAvatar(me),
                      const SizedBox(width: 8),
                      Text(
                        me?['display_name'] != null
                            ? 'โพสต์อะไรหน่อยไหม ${me!['display_name']}'
                            : 'เกิดอะไรขึ้น?',
                        style: const TextStyle(
                          color: Color(0xff828282),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Feed
              Expanded(
                child: ListView.separated(
                  itemCount: feed.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    final item = feed[index];

                    final Map<String, dynamic> post =
                        item['post'] as Map<String, dynamic>;
                    final Map<String, dynamic> owner =
                        (item['owner'] as Map<String, dynamic>?) ?? {};

                    final int likeCount = item['like_count'] as int? ?? 0;
                    final int commentCount =
                        item['comment_count'] as int? ?? 0;

                    final String displayName =
                        (owner['display_name'] ??
                                owner['full_name'] ??
                                'ผู้ใช้หมายเลข ${post['provider_id']}')
                            .toString();

                    final String? avatarUrl = owner['avatar_url'] as String?;
                    final Widget avatarWidget =
                        (avatarUrl != null &&
                                avatarUrl.isNotEmpty &&
                                avatarUrl.startsWith('http'))
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(avatarUrl),
                                radius: 25,
                              )
                            : const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/profile1.png'),
                                radius: 25,
                              );

                    final createdAtStr = _formatFromUnix(post['created_at']);

                    final List images = (post['images'] as List?) ?? [];
                    final String? firstImage =
                        images.isNotEmpty ? images.first.toString() : null;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(
                              post: post,
                              token: token,
                              currentUser: me,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: avatarWidget,
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff038263),
                                ),
                              ),
                              subtitle: Text(
                                createdAtStr,
                                style: const TextStyle(
                                  color: Color(0xFFF58319),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                post['description'] ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (firstImage != null && firstImage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    firstImage,
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
                                  Text('$likeCount'),
                                  const SizedBox(width: 16),
                                  SvgPicture.asset(
                                    'assets/icons/comment.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$commentCount'),
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
          );
        },
      ),
    );
  }
}
