import 'package:android_posyandu/homepage.dart';
import 'package:android_posyandu/navigation_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController noKKController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final response = await http.post(
      Uri.parse('https://de38-182-1-184-177.ngrok-free.app/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'noKK': noKKController.text,
        'password': passwordController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final idOrangTua =
          responseData['user']['id_orang_tua']; // Ambil dari user

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_orang_tua', idOrangTua);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavExample()),
      );
    } else {
      setState(() {
        errorMessage = 'Login gagal, periksa kembali No KK dan Password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Latar belakang lembut
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite,
                  size: 80,
                  color: Color(0xFFE57373)), // Ikon lebih ramah & hangat
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang di Posyandu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: noKKController,
                decoration: InputDecoration(
                  labelText: 'No KK',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon:
                      const Icon(Icons.family_restroom, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage,
                    style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 10),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : ElevatedButton.icon(
                      onPressed: login,
                      icon: const Icon(Icons.login),
                      label: const Text('Masuk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 50),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
