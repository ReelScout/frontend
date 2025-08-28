import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/injection_container.dart';
import 'screens/home_screen.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/user_profile/user_profile_bloc.dart';
import 'bloc/content/content_bloc.dart';
import 'services/auth_service.dart';
import 'services/token_service.dart';
import 'services/user_service.dart';
import 'services/content_service.dart';
import 'styles/app_theme.dart';

void main() {
  configureDependencies();
  runApp(const ReelScoutApp());
}

class ReelScoutApp extends StatelessWidget {
  const ReelScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: getIt<AuthService>(),
            tokenService: getIt<TokenService>(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(
            userService: getIt<UserService>(),
            tokenService: getIt<TokenService>(),
          ),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider<ContentBloc>(
          create: (context) => ContentBloc(
            contentService: getIt<ContentService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ReelScout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}