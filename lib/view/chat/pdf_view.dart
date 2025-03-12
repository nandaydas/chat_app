import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String senderName;
  final String timeStamp;
  const PDFViewerPage(
      {super.key,
      required this.pdfUrl,
      required this.senderName,
      required this.timeStamp});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? filePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPDF();
  }

  Future<void> _downloadAndLoadPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await Dio().download(widget.pdfUrl, file.path);
      setState(() {
        filePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.senderName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              widget.timeStamp,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filePath != null
              ? PDFView(
                  filePath: filePath!,
                  backgroundColor: Colors.black,
                )
              : const Center(child: Text('Failed to load PDF')),
    );
  }
}
