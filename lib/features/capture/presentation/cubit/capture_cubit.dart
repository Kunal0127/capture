import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capture/core/camera/camera_service.dart';
import 'package:capture/core/scanner/barcode_service.dart';
import 'package:capture/core/utils/log.dart';
import 'package:capture/features/capture/presentation/cubit/capture_state.dart';

class CaptureCubit extends Cubit<CaptureState> {
  final CameraService cameraService;
  final BarcodeService barcodeService;

  CaptureCubit({required this.cameraService, required this.barcodeService})
    : super(const CaptureState());

  void start() {
    emit(state.copyWith(isCapturing: true));
  }

  void stop() {
    emit(state.copyWith(isCapturing: false));
  }

  void addImage(XFile image) {
    final update = List<XFile>.from(state.images)..add(image);
    emit(state.copyWith(images: update));
  }

  void removeImage(XFile image) {
    final update = List<XFile>.from(state.images)..remove(image);
    emit(state.copyWith(images: update));
  }

  void reset() {
    emit(const CaptureState(isCapturing: false, images: []));
  }

  Future<void> captureAndScan() async {
    if (!state.isCapturing) return;

    emit(state.copyWith(isProcessing: true));

    try {
      final image = await cameraService.capture();
      final barcodes = await barcodeService.scan(image.path);

      final codes = barcodes
          .map((b) => b.rawValue ?? "")
          .where((value) => value.isNotEmpty)
          .toList();

      Log.log("Captured Image: ${image.path}");
      Log.log("Scanned Codes: $codes");

      final updatedResult = Map<String, List<String>>.from(
        state.scannedResults,
      );

      updatedResult[image.path] = codes;

      emit(
        state.copyWith(
          isProcessing: false,
          images: [...state.images, image],
          scannedResults: updatedResult,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessing: false));
    }
  }

  @override
  Future<void> close() {
    barcodeService.dispose();
    cameraService.dispose();
    return super.close();
  }
}
