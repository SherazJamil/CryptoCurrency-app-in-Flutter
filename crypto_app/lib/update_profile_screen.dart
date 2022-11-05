import 'package:crypto_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfile extends StatelessWidget {
  UpdateProfile({Key? key}) : super(key: key);

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController age= TextEditingController();

  void saveUserDetail() async {
    await saveData('name', name.text.trim());
    await saveData('email', email.text.trim());
    await saveData('age', age.text.trim());
  }

  bool isDarkEnabled = AppTheme.isDarkEnabled;

  Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkEnabled ? const Color(0xFF1D1D35) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE9901),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Column(
        children: [
          customTextField(
              // Icon(FontAwesomeIcons.font,color: isDarkEnabled ? Colors.black : Colors.grey.shade800,),
              'Enter your Name', name, false),
          customTextField(
              // Icon(FontAwesomeIcons.envelope,color: isDarkEnabled ? Colors.black : Colors.grey.shade800,),
              'Enter your Email', email, false),
          customTextField(
              // Icon(FontAwesomeIcons.list12,color: isDarkEnabled ? Colors.black : Colors.grey.shade800,),
              'Enter your Age', age, true),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 50,
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFFE9901), // Background color
              ),
                onPressed: () {
                  saveUserDetail();
                  print('$email');
                  print('$name');
                  print('$age');
                },
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customTextField(String title, TextEditingController controller, bool isAge) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          //prefixIcon: icon,
          hintText: title,
          fillColor: Colors.grey.shade300,
          filled: true,
          hintStyle: TextStyle(
            color: isDarkEnabled ? Colors.grey.shade700 : null,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDarkEnabled ? Colors.black : Colors.grey,            ),
          ),
        ),
        keyboardType: isAge ? TextInputType.number : null,
      ),
    );
  }
}