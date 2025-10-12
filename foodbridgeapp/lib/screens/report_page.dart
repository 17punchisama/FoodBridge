import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  final String reportId; // e.g. FB-250831-00001

  const ReportPage({super.key, required this.reportId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final List<TextEditingController> _imageUrlControllers = [];

  final Map<String, bool> _types = {
    "USAGE": false,
    "PRIVACY": false,
    "SPAM": false,
    "OTHER": false,
  };

  bool _isSubmitting = false;

  void _addImageUrlField() {
    setState(() {
      _imageUrlControllers.add(TextEditingController());
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrlControllers.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final detail = _detailController.text.trim();

    final selectedTypes = _types.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final imageUrls = _imageUrlControllers
        .map((c) => c.text.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (title.isEmpty || selectedTypes.isEmpty) {
      _showDialog('ข้อมูลไม่ครบ', 'กรุณากรอกหัวข้อและเลือกประเภทอย่างน้อย 1 ประเภท');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reportUrl = Uri.parse('https://your-api-url.com/report'); // 👈 change this
      final response = await http.post(
        reportUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "types": selectedTypes,
          "detail": detail,
          "images": imageUrls,
          "referenceId": widget.reportId,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog('สำเร็จ', 'ส่งรายงานเรียบร้อยแล้ว', onClose: () {
          Navigator.pop(context);
        });
      } else {
        final errorMsg = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ?? 'ส่งรายงานไม่สำเร็จ'
            : 'ส่งรายงานไม่สำเร็จ';
        _showDialog('ผิดพลาด', errorMsg);
      }
    } catch (e) {
      _showDialog('ข้อผิดพลาด', 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้\n$e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showDialog(String title, String message, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeLabels = {
      "USAGE": "ปัญหาการใช้งาน",
      "PRIVACY": "การละเมิดความเป็นส่วนตัวและข้อมูล",
      "SPAM": "Spam / Scam / Fraud",
      "OTHER": "อื่นๆ",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานปัญหา'),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_arrow.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with report number
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.teal[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'หมายเลขรายการ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.reportId,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text('ปัญหาที่เกิด', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image URL "picker" section
            const Text('รูปภาพประกอบ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _addImageUrlField,
              child: Container(
                width: 150,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('เพิ่มรูปภาพ', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic URL fields
            Column(
              children: List.generate(_imageUrlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlControllers[index],
                          decoration: InputDecoration(
                            hintText: 'วางลิงก์รูปภาพที่นี่',
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _removeImageUrlField(index),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Types
            const Text('ประเภท', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Column(
              children: _types.keys.map((key) {
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: _types[key],
                  onChanged: (val) {
                    setState(() => _types[key] = val ?? false);
                  },
                  title: Text(typeLabels[key]!),
                  activeColor: Colors.orange,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Detail
            const Text('รายละเอียด', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _detailController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text(
                        'ยืนยัน',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
