import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerResult {
  final LatLng latLng;
  final Placemark placemark;
  MapPickerResult(this.latLng, this.placemark);
}

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key, this.initial});
  final LatLng? initial;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _controller;
  LatLng _picked = const LatLng(13.7563, 100.5018); // default: Bangkok
  Marker _marker = const Marker(
    markerId: MarkerId('picked'),
    position: LatLng(13.7563, 100.5018),
  );
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _picked = widget.initial!;
      _marker = Marker(markerId: const MarkerId('picked'), position: _picked);
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        _picked.latitude,
        _picked.longitude,
        localeIdentifier: 'th_TH', // Thai labels where possible
      );
      final place = placemarks.isNotEmpty ? placemarks.first : Placemark();
      if (!mounted) return;
      Navigator.pop(context, MapPickerResult(_picked, place));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถระบุที่อยู่ได้: $e')),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกตำแหน่งบนแผนที่')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _picked, zoom: 15),
        onMapCreated: (c) => _controller = c,
        onTap: (pos) {
          setState(() {
            _picked = pos;
            _marker = Marker(markerId: const MarkerId('picked'), position: pos);
          });
        },
        markers: {_marker},
        myLocationButtonEnabled: true,
        myLocationEnabled: false, // enable if you add location permission flow
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirming ? null : _confirm,
        label: _confirming
            ? const Text('กำลังยืนยัน...')
            : const Text('ยืนยันตำแหน่ง'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
