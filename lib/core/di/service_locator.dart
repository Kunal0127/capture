import 'package:capture/core/scanner/barcode_service.dart';

import 'package:capture/core/camera/camera_service.dart';
import 'package:capture/features/capture/presentation/cubit/capture_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<CameraService>(() => CameraService());
  sl.registerLazySingleton<BarcodeService>(() => BarcodeService());
  sl.registerFactory<CaptureCubit>(
    () => CaptureCubit(cameraService: sl(), barcodeService: sl()),
  );
}
