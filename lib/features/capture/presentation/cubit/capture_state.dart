import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class CaptureState extends Equatable {
  final bool isCapturing;
  final bool isProcessing;
  final List<XFile> images;
  final Map<String, List<String>> scannedResults;

  const CaptureState({
    this.isCapturing = false,
    this.isProcessing = false,
    this.images = const [],
    this.scannedResults = const {},
  });

  CaptureState copyWith({
    bool? isCapturing,
    bool? isProcessing,
    List<XFile>? images,
    Map<String, List<String>>? scannedResults,
  }) {
    return CaptureState(
      isCapturing: isCapturing ?? this.isCapturing,
      isProcessing: isProcessing ?? this.isProcessing,
      images: images ?? this.images,
      scannedResults: scannedResults ?? this.scannedResults,
    );
  }

  @override
  List<Object?> get props => [
    isCapturing,
    isProcessing,
    images,
    scannedResults,
  ];
}
