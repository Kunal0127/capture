import 'package:flutter/material.dart';
import 'package:capture/features/capture/presentation/pages/camera_pages.dart';
import 'package:capture/features/capture/presentation/pages/result_page.dart';

class RouteName {
  static const String camera = '/camera';
  static const String result = '/result';
}

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    RouteName.camera: (_) => const CameraPages(),
    RouteName.result: (_) => const ResultPage(),
  };
}
