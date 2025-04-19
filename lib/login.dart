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
      Uri.parse('https://b67b-182-1-210-225.ngrok-free.app/api/login'),
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
      final nama = responseData['user']['name'];
      final idOrangTua =
          responseData['user']['id_orang_tua']; // Ambil dari user

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_orang_tua', idOrangTua);
      await prefs.setString('name', nama);

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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Posyandu
                Image.asset(
                  'assets/images/posyandu.jpg', // pastikan file logo ini ada
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),

                // Judul Selamat Datang
                const Text(
                  'Selamat Datang di Posyandu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1387AA), // Biru tua
                  ),
                ),
                const SizedBox(height: 40),

                // Input No KK
                TextField(
                  controller: noKKController,
                  decoration: InputDecoration(
                    labelText: 'No KK',
                    filled: true,
                    fillColor: const Color(0xFFF1F8FF), // Biru sangat muda
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.family_restroom,
                        color: Color(0xFF1387AA)),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFF1F8FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF1387AA)),
                  ),
                ),
                const SizedBox(height: 20),

                // Error Message
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                const SizedBox(height: 10),

                // Tombol Masuk atau Loading
                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF1387AA))
                    : ElevatedButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: const Text('Masuk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1387AA),
                          foregroundColor: Colors.white,
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
      ),
    );
  }
}
