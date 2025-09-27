import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'nav_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // controllers
  final _usernameController = TextEditingController(text: "Pinpint");
  final _nameController = TextEditingController(text: "Parada");
  final _lastnameController = TextEditingController(text: "Poynok");
  final _bioController = TextEditingController(text: "กิน นอน");
  final _locationController = TextEditingController(text: "Bangkok, Thailand");
  final _postcodeController = TextEditingController(text: "30000");
  final _provinceController = TextEditingController(text: "Nakhon Ratchasima");
  final _phoneController = TextEditingController(text: "0912345678");

  final _formKey = GlobalKey<FormState>();

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    int? maxLines = 1,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                spreadRadius: 0,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color.fromARGB(255, 3, 130, 99), width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16), 
      ],
    );
  }

  void _openLocationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 243, 243),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "แก้ไขโปรไฟล์",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // avatar
              Center(
                child: Stack(
                  children: [
                    SvgPicture.asset('assets/icons/no_profile.svg', width: 180, height: 180),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 188, 188, 188),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // fields
              buildTextField("Username", _usernameController),
              buildTextField("ชื่อ", _nameController),
              buildTextField("นามสกุล", _lastnameController),
              buildTextField("Bio", _bioController, maxLines: 2),

              buildTextField(
                "ที่อยู่ / Location",
                _locationController,
                maxLines: null, 
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_pin, color: Colors.red),
                  onPressed: _openLocationPage,
                ),
                onTap: _openLocationPage,
              ),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: buildTextField("จังหวัด", _provinceController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: buildTextField(
                      "Postcode",
                      _postcodeController,
                      type: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรอก Postcode";
                        }
                        if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                          return "ต้องเป็นตัวเลข 5 หลัก";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              buildTextField(
                "เบอร์โทร",
                _phoneController,
                type: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("บันทึกโปรไฟล์เรียบร้อย ✅"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 130, 99),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3, 
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.25),
                  ),
                  child: const Text("บันทึก"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เลือก Location 📍")),
      body: const Center(child: Text("ไว้เลือก location ")),
    );
  }
}
