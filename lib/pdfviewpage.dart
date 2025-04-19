import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? filePath;
  bool isLoading = true;

  final String pdfUrl = 'https://b67b-182-1-210-225.ngrok-free.app/api/surat/pdf';

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/surat.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          filePath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengunduh PDF. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Terjadi error saat mengunduh PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lihat Surat PDF")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filePath != null
              ? PDFView(
                  filePath: filePath!,
                )
              : const Center(child: Text("Gagal menampilkan PDF.")),
    );
  }
}
