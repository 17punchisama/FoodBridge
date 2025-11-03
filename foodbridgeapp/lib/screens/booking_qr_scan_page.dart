import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class BookingQRScanPage extends StatefulWidget {
  const BookingQRScanPage({super.key});

  @override
  State<BookingQRScanPage> createState() => _BookingQRScanPageState();
}

class _BookingQRScanPageState extends State<BookingQRScanPage> {
  final _storage = const FlutterSecureStorage();
  final MobileScannerController _controller = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  bool _isHandling = false;

  static const String baseUrl = 'https://foodbridge1.onrender.com';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สแกน QR Booking')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) async {
          if (_isHandling) return;
          final barcode = capture.barcodes.first;
          final raw = barcode.rawValue;
          if (raw == null) return;

          setState(() => _isHandling = true);
          await _sendScan(raw);
          setState(() => _isHandling = false);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImageAndScan,
        label: const Text('เลือกรูป'),
        icon: const Icon(Icons.image),
      ),
    );
  }

  Future<void> _pickImageAndScan() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // ⬇⬇ จุดที่แก้: analyzeImage คืน BarcodeCapture?
      final BarcodeCapture? capture =
          await _controller.analyzeImage(image.path);

      if (capture == null || capture.barcodes.isEmpty) {
        _showMsg('ไม่พบ QR/Barcode ในรูปนี้');
        return;
      }

      final Barcode first = capture.barcodes.first;
      final String? raw = first.rawValue;

      if (raw == null) {
        _showMsg('อ่าน QR ไม่ได้');
        return;
      }

      if (_isHandling) return;
      setState(() => _isHandling = true);
      await _sendScan(raw);
      setState(() => _isHandling = false);
    } catch (e) {
      _showMsg('อ่านรูปไม่สำเร็จ: $e');
    }
  }

  Future<void> _sendScan(String bookingTokenFromQR) async {
    try {
      final jwt = await _storage.read(key: 'token');

      final url = Uri.parse('$baseUrl/bookings/scan');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (jwt != null) {
        headers['Authorization'] = 'Bearer $jwt';
      }

      final body = jsonEncode({
        'token': bookingTokenFromQR,
      });

      final res = await http.post(url, headers: headers, body: body);

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        String msg = 'สแกนสำเร็จ 🎉';
        try {
          final data = jsonDecode(res.body);
          if (data is Map && data['status'] != null) {
            msg = 'อัปเดตสถานะเป็น ${data['status']} แล้ว 🎉';
          }
        } catch (_) {}
        _showMsg(msg);
      } else {
        _showMsg('สแกนไม่สำเร็จ (${res.statusCode}) : ${res.body}');
      }
    } catch (e) {
      if (!mounted) return;
      _showMsg('Error: $e');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
