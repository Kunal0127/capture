import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeService {
  late final BarcodeScanner _scanner;

  BarcodeService() {
    _scanner = BarcodeScanner(
      formats: [
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
        BarcodeFormat.ean8,
      ],
    );
  }

  Future<List<Barcode>> scan(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final barcodes = await _scanner.processImage(inputImage);
      return barcodes;
    } catch (e) {
      throw Exception('Failed to scan barcode: $e');
    }
  }

  void dispose() {
    _scanner.close();
  }
}
