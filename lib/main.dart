import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:capture/core/di/service_locator.dart';
import 'package:capture/core/routes/app_routes.dart';
import 'package:capture/features/capture/presentation/cubit/capture_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CaptureCubit>(create: (_) => sl<CaptureCubit>()),
      ],
      child: MaterialApp(
        title: 'Capture',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: RouteName.camera,
        routes: AppRoutes.routes,
      ),
    );
  }
}
