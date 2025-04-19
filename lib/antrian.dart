import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({super.key});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedJadwal;
  int? _selectedAnak;
  String? _message;
  bool _isLoading = false;

  List<dynamic> _jadwalList = [];
  List<dynamic> _anakList = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final jadwalRes = await http.get(
      Uri.parse('https://b67b-182-1-210-225.ngrok-free.app/api/jadwal'),
    );

    final prefs = await SharedPreferences.getInstance();
    final idOrangTua = prefs.getInt('id_orang_tua');

    final anakRes = await http.get(
      Uri.parse(
          'https://b67b-182-1-210-225.ngrok-free.app/api/anak/$idOrangTua'),
    );

    if (!mounted) return;

    setState(() {
      _jadwalList = jsonDecode(jadwalRes.body);
      _anakList = jsonDecode(anakRes.body);
    });
  }

  Future<void> _submitForm() async {
    if (_selectedJadwal == null || _selectedAnak == null) {
      if (!mounted) return;
      setState(() {
        _message = 'Silakan pilih jadwal dan anak.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final url =
        Uri.parse('https://b67b-182-1-210-225.ngrok-free.app/api/antrian');
    final response = await http.post(url, body: {
      'id_jadwal': _selectedJadwal.toString(),
      'id_anak': _selectedAnak.toString(),
    });

    final jsonResponse = jsonDecode(response.body);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.statusCode == 201) {
        _message =
            "Berhasil daftar! Nomor antrian: ${jsonResponse['nomor_antrian']}";
      } else {
        _message = jsonResponse['message'] ?? 'Pendaftaran gagal.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF), // Biru sangat muda
      appBar: AppBar(
        backgroundColor: const Color(0xFF1387AA), // Biru utama
        title: const Text(
          'Form Pendaftaran Antrian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _jadwalList.isEmpty || _anakList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1387AA)),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown Jadwal Posyandu
                    DropdownButtonFormField<int>(
                      value: _selectedJadwal,
                      items: _jadwalList.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item['id_jadwal'],
                          child: Text(
                            '${item['tanggal']}/${item['bulan']}/${item['tahun']}',
                            style: const TextStyle(color: Color(0xFF0D47A1)),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedJadwal = value),
                      decoration: InputDecoration(
                        labelText: 'Pilih Jadwal Posyandu',
                        prefixIcon: const Icon(Icons.calendar_month,
                            color: Color(0xFF1387AA)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Anak
                    DropdownButtonFormField<int>(
                      value: _selectedAnak,
                      items: _anakList.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item['id_anak'],
                          child: Text(
                            item['nama'],
                            style: const TextStyle(color: Color(0xFF0D47A1)),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAnak = value),
                      decoration: InputDecoration(
                        labelText: 'Pilih Anak',
                        prefixIcon: const Icon(Icons.child_care,
                            color: Color(0xFF1387AA)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 24),

                    // Tombol Daftar
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF1387AA)))
                        : ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.send),
                            label: const Text('Daftar Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1387AA),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),

                    // Pesan notifikasi
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _message!.contains('Berhasil')
                                ? Colors.green
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
