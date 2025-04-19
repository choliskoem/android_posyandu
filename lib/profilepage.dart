import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> futureProfile;

  @override
  void initState() {
    super.initState();
    futureProfile = _loadProfile();
  }

  // Function to fetch the ID from SharedPreferences and then load the profile
  Future<Map<String, dynamic>> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idOrangTua =
        prefs.getInt('id_orang_tua') ?? 0; // Default to 0 if no ID is found
    return fetchProfile(idOrangTua.toString());
  }

  Future<Map<String, dynamic>> fetchProfile(String id) async {
    const String apiUrl =
        'https://b67b-182-1-210-225.ngrok-free.app/api/profile'; // Replace with your actual API URL
    final response = await http.get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Return the response body as a Map
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),

        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FAFB), Color(0xFFF8FAFB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: futureProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (snapshot.hasData) {
                final profile = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 45,
                              backgroundColor:  Color(0xFF1387AA),
                              child: Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile['nama'] ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 1),
                            // buildProfileRow(
                            //     Icons.perm_identity, 'ID', profile['id']),
                            buildProfileRow(
                                Icons.group, 'No KK', profile['noKK']),
                            buildProfileRow(
                                Icons.credit_card, 'NIK', profile['nik']),
                            buildProfileRow(
                                Icons.home, 'Alamat', profile['alamat']),
                            buildProfileRow(
                                Icons.phone, 'No HP', profile['no_hp']),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Data tidak ditemukan',
                      style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildProfileRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF1387AA)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
