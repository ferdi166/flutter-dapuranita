import 'package:dapur_anita/konstanta.dart';
import 'package:dapur_anita/login/form_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapur_anita/widgets/custom_text_field.dart';

import 'package:dapur_anita/home_page.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/registerApi"),
        body: {"name": name, "email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body)['data'];
        // menyimpan data token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', user['id']);
        await prefs.setString('name', user['name']);
        await prefs.setString('email', user['email']);
        await prefs.setString('type', user['type']);

        int? id = user['id'];
        String? name = user['name'];
        String? email = user['email'];
        String? type = user['type'];

        // berpindah halaman
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(id: id, name: name, email: email, type: type),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error during login: $e");
      AlertDialog alert = AlertDialog(
        title: Text("Error"),
        content: Container(child: Text("Terjadi kesalahan: $e")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Ok"),
          ),
        ],
      );
      showDialog(context: context, builder: (context) => alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selamat Datang Di Dapur Anita"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text("Welcome 👋", style: TextStyle(fontSize: 24)),
            Text("Register Started!"),
            SizedBox(height: 16),
            // Nama lengkap
            CustomTextField(
              controller: nameController,
              label: "Nama Lengkap",
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              // validator: _validateName,
            ),
            SizedBox(height: 16),
            // Email Field
            CustomTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              // validator: _validateEmail,
            ),
            SizedBox(height: 16),
            // Password Field
            CustomTextField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock_outline,
              obscureText: true,
              // validator: _validatePassword,
            ),
            SizedBox(height: 24.0),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  print("Ok");
                  register(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sudah punya akun?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageLogin()),
                    );
                  },
                  child: Text(
                    "Login di sini",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
