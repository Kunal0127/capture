import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capture/core/camera/camera_service.dart';
import 'package:capture/core/di/service_locator.dart';
import 'package:capture/core/routes/app_routes.dart';
import 'package:capture/features/capture/presentation/cubit/capture_cubit.dart';
import 'package:capture/features/capture/presentation/cubit/capture_state.dart';
import 'package:capture/features/capture/presentation/pages/result_page.dart';

class CameraPages extends StatefulWidget {
  const CameraPages({super.key});

  @override
  State<CameraPages> createState() => _CameraPagesState();
}

class _CameraPagesState extends State<CameraPages> {
  final CameraService _cameraService = sl<CameraService>();

  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final camera = await _cameraService.getAvailableCameras();

      if (camera.isEmpty) {
        setState(() => _error = "No camera available");
        return;
      }

      final backCamera = camera.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => camera.first,
      );
      await _cameraService.initializeCamera(backCamera);

      if (!mounted) return;

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = "Failed to initialize camera: $e");
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_cameraService.cameraController == null ||
        !_cameraService.cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Capture")),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              var scale =
                  size.aspectRatio *
                  _cameraService.cameraController!.value.aspectRatio;

              if (scale < 1) scale = 1 / scale;

              return ClipRect(
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_cameraService.cameraController!),
                  ),
                ),
              );
            },
          ),

          // capture counter
          Positioned(
            top: 20,
            left: 20,
            child: BlocBuilder<CaptureCubit, CaptureState>(
              buildWhen: (previous, current) {
                return previous.images.length != current.images.length;
              },
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Captured: ${state.images.length}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // control
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: BlocBuilder<CaptureCubit, CaptureState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // play/pause button
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          state.isCapturing ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (state.isCapturing) {
                            context.read<CaptureCubit>().stop();
                          } else {
                            context.read<CaptureCubit>().start();
                          }
                        },
                      ),
                    ),

                    // capture button
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: state.isCapturing && !state.isProcessing
                          ? Colors.red
                          : Colors.grey,
                      child: IconButton(
                        icon: state.isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                        onPressed: state.isCapturing && !state.isProcessing
                            ? () =>
                                  context.read<CaptureCubit>().captureAndScan()
                            : null,
                      ),
                    ),

                    // stop/done button
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.check, color: Colors.black),
                        onPressed: state.images.isNotEmpty
                            ? () {
                                context.read<CaptureCubit>().stop();

                                final results = state.images.map((image) {
                                  return ScanResultItem(
                                    image: image,
                                    codes:
                                        state.scannedResults[image.path] ?? [],
                                  );
                                }).toList();

                                Navigator.pushNamed(
                                  context,
                                  RouteName.result,
                                  arguments: results,
                                ).then((_) {
                                  if (context.mounted) {
                                    context.read<CaptureCubit>().reset();
                                  }
                                });
                              }
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
