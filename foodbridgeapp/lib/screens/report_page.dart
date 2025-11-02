import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportPage extends StatefulWidget {
  final int postId;
  const ReportPage({super.key, required this.postId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final List<String> selectedTypes = [];
  final List<String> imageUrls = [];
  bool isLoading = false;

  Future<void> submitReport() async {
    if (titleController.text.isEmpty || detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
      );
      return;
    }

    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบ')),
      );
      return;
    }

    final body = {
      "title": titleController.text.trim(),
      "types": selectedTypes,
      "detail": detailController.text.trim(),
      "images": imageUrls,
    };

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://foodbridge1.onrender.com/posts/${widget.postId}/reports"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ส่งรายงานสำเร็จ!')),
        );
        Navigator.pop(context);
      } else {
        String message = 'ส่งรายงานไม่สำเร็จ';
        try {
          final data = jsonDecode(response.body);
          message = data['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddImageDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เพิ่ม URL รูปภาพ'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'เช่น https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() => imageUrls.add(urlController.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, String value) {
    final isChecked = selectedTypes.contains(value);
    return CheckboxListTile(
      title: Text(label),
      value: isChecked,
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            selectedTypes.add(value);
          } else {
            selectedTypes.remove(value);
          }
        });
      },
      activeColor: Colors.orange,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'รายงานปัญหา',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ID bar
              Container(
                width: double.infinity,
                color: Colors.green[800],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'หมายเลขรายการ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      widget.postId.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text('ปัญหาที่เกิด',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('รูปภาพประกอบ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _showAddImageDialog,
                icon: const Icon(Icons.add, color: Colors.orange),
                label: const Text(
                  'เพิ่มรูปภาพ',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 1,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),

              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: imageUrls.map((url) {
                    return Image.network(
                      url,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),
              const Text('ประเภท',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              _buildCheckbox('ปัญหาการใช้งาน', 'USABILITY'),
              _buildCheckbox('การละเมิดความเป็นส่วนตัวและข้อมูล', 'PRIVACY'),
              _buildCheckbox('Spam / Scam / Fraud', 'SPAM'),
              _buildCheckbox('อื่นๆ', 'OTHER'),

              const SizedBox(height: 20),
              const Text('รายละเอียด',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: detailController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ยืนยัน',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
