import 'package:camera/camera.dart';

class CameraService {
  CameraController? cameraController;
  bool _istakingPicture = false;

  Future<void> initializeCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await cameraController!.initialize();
  }

  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw Exception('Failed to get available cameras: $e');
    }
  }

  Future<XFile> capture() async {
    if (_istakingPicture) {
      throw Exception('Already taking a picture');
    }

    try {
      _istakingPicture = true;
      if (!cameraController!.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      return await cameraController!.takePicture();
    } finally {
      _istakingPicture = false;
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}
