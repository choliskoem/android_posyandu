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

    final url = Uri.parse('https://de38-182-1-184-177.ngrok-free.app/api/pemeriksaan/$idOrangTua');
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
      backgroundColor: Color(0xFFE1F5FE), // Biru pastel lembut
      appBar: AppBar(
        title: Text('Data Pemeriksaan'),
        backgroundColor: Color(0xFF4DB6AC), // Hijau pastel
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pemeriksaanData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data pemeriksaan.'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            "Tanggal: ${item['tanggal'] ?? '-'}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),
                      _buildInfoRow("Berat Badan", "${item['berat_badan'] ?? '-'} kg", Icons.monitor_weight),
                      _buildInfoRow("Tinggi Badan", "${item['tinggi_badan'] ?? '-'} cm", Icons.height),
                      _buildInfoRow("Lingkar Kepala", "${item['lingkar_kepala'] ?? '-'} cm", Icons.circle),
                      _buildInfoRow("Vitamin A", item['vitamin_A'] ?? '-', Icons.medical_services),
                      _buildInfoRow("Imunisasi BCG", item['imunisasi_BCG'] ?? '-', Icons.vaccines),
                      _buildInfoRow("Imunisasi DPT 1", item['imunisasi_DPT_HB1'] ?? '-', Icons.vaccines),
                      _buildInfoRow("Imunisasi DPT 2", item['imunisasi_DPT_HB2'] ?? '-', Icons.vaccines),
                      _buildInfoRow("Imunisasi DPT 3", item['imunisasi_DPT_HB3'] ?? '-', Icons.vaccines),
                      _buildInfoRow("Catatan", item['catatan'] ?? '-', Icons.note_alt),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
