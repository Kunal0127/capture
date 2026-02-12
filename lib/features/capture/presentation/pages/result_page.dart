import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanResultItem {
  final XFile image;
  final List<String> codes;

  ScanResultItem({required this.image, required this.codes});
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! List<ScanResultItem> || args.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No scan results", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final results = args;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Results'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(item.image.path),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                ),

             
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    item.image.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),

               
                if (item.codes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      "No barcode detected",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: item.codes.map((code) {
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Copied to clipboard"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
