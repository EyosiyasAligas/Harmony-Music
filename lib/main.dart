import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_music/src/core/router/app_router.dart';
import 'package:harmony_music/src/core/service_locator/service_locator.dart';
import 'package:harmony_music/src/core/theme/app_theme.dart';
import 'package:harmony_music/src/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppInjections();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Harmony Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: getGoRouterOfTheApp(),
      ),
    );
  }
}
