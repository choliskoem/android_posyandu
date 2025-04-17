import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      Uri.parse('https://de38-182-1-184-177.ngrok-free.app/api/jadwal'),
    );

    final prefs = await SharedPreferences.getInstance();
    final idOrangTua = prefs.getInt('id_orang_tua');

    final anakRes = await http.get(
      Uri.parse('https://de38-182-1-184-177.ngrok-free.app/api/anak/$idOrangTua'),
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

    final url = Uri.parse('https://de38-182-1-184-177.ngrok-free.app/api/antrian');
    final response = await http.post(url, body: {
      'id_jadwal': _selectedJadwal.toString(),
      'id_anak': _selectedAnak.toString(),
    });

    final jsonResponse = jsonDecode(response.body);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.statusCode == 201) {
        _message = "Berhasil daftar! Nomor antrian: ${jsonResponse['nomor_antrian']}";
      } else {
        _message = jsonResponse['message'] ?? 'Pendaftaran gagal.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Form Pendaftaran Antrian',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _jadwalList.isEmpty || _anakList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedJadwal,
                      items: _jadwalList.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item['id_jadwal'],
                          child: Text(
                            '${item['tanggal']}/${item['bulan']}/${item['tahun']}',
                            style: const TextStyle(color: Colors.brown),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedJadwal = value),
                      decoration: InputDecoration(
                        labelText: 'Pilih Jadwal Posyandu',
                        prefixIcon: const Icon(Icons.calendar_month, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedAnak,
                      items: _anakList.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem<int>(
                          value: item['id_anak'],
                          child: Text(
                            item['nama'],
                            style: const TextStyle(color: Colors.brown),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedAnak = value),
                      decoration: InputDecoration(
                        labelText: 'Pilih Anak',
                        prefixIcon: const Icon(Icons.child_care, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.send),
                            label: const Text('Daftar Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 40),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                    if (_message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _message!.contains('Berhasil') ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
      ),
    );
  }
}
