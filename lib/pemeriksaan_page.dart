import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PemeriksaanPage extends StatefulWidget {
  @override
  _PemeriksaanPageState createState() => _PemeriksaanPageState();
}

class _PemeriksaanPageState extends State<PemeriksaanPage> {
  late Future<List<dynamic>> _pemeriksaanData;

  Future<int?> _getIdOrangTua() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_orang_tua');
  }

  Future<List<dynamic>> _fetchPemeriksaan() async {
    final idOrangTua = await _getIdOrangTua();
    if (idOrangTua == null) {
      throw Exception('ID Orang Tua tidak ditemukan');
    }

    final url = Uri.parse(
        'https://b67b-182-1-210-225.ngrok-free.app/api/pemeriksaan/$idOrangTua');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data pemeriksaan');
    }
  }

  @override
  void initState() {
    super.initState();
    _pemeriksaanData = _fetchPemeriksaan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Hijau pastel sangat lembut
      appBar: AppBar(
        title: const Text(
          'Data Pemeriksaan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1387AA), // Hijau daun
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 2,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pemeriksaanData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada data pemeriksaan.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            "Tanggal: ${item['tanggal'] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildInfoRow("Nama Anak", "${item['nama'] ?? '-'}",
                          Icons.child_care),
                      _buildInfoRow(
                          "Nik", "${item['nik'] ?? '-'}", Icons.perm_identity),
                      _buildInfoRow("Jenis Kelamin", "${item['JK'] ?? '-'}",
                          Icons.transgender),
                      _buildInfoRow("Anak Ke", "${item['anak_ke'] ?? '-'}",
                          Icons.format_list_numbered),
                      _buildInfoRow(
                          "Berat Badan",
                          "${item['berat_badan'] ?? '-'} kg",
                          Icons.monitor_weight),
                      _buildInfoRow("Tinggi Badan",
                          "${item['tinggi_badan'] ?? '-'} cm", Icons.height),
                      _buildInfoRow(
                          "Lingkar Kepala",
                          "${item['lingkar_kepala'] ?? '-'} cm",
                          Icons.circle_outlined),
                      _buildInfoRow("Vitamin A", item['vitamin_A'] ?? '-',
                          Icons.medical_services_outlined),
                      _buildInfoRow(
                          "Imunisasi BCG",
                          item['imunisasi_BCG'] ?? '-',
                          Icons.vaccines_outlined),
                      _buildInfoRow(
                          "Imunisasi DPT 1",
                          item['imunisasi_DPT_HB1'] ?? '-',
                          Icons.vaccines_outlined),
                      _buildInfoRow(
                          "Imunisasi DPT 2",
                          item['imunisasi_DPT_HB2'] ?? '-',
                          Icons.vaccines_outlined),
                      _buildInfoRow(
                          "Imunisasi DPT 3",
                          item['imunisasi_DPT_HB3'] ?? '-',
                          Icons.vaccines_outlined),
                      _buildInfoRow("Catatan", item['catatan'] ?? '-',
                          Icons.note_alt_outlined),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1387AA), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
