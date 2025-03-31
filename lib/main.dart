import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterproject/%20blocs/auth_bloc.dart' show AuthBloc;
import 'package:flutterproject/screens/signup_screen.dart';
import 'package:flutterproject/services/config_service.dart';
import 'package:flutterproject/services/firebase_service.dart';
import 'package:provider/provider.dart';
// import 'blocs/auth_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
// import 'services/firebase_auth_service.dart';
// import 'services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Load authentication configuration
  final configService = ConfigService();
  await configService.loadAuthConfig();

  runApp(MyApp(configService: configService));
}

class MyApp extends StatelessWidget {
  final ConfigService configService;

  const MyApp({Key? key, required this.configService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<ConfigService>.value(value: configService),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            firebaseAuthService: context.read<FirebaseAuthService>(),
            configService: context.read<ConfigService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Add this line

        title: 'Flutter Auth Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/signup': (context) => const SignupScreen(), // Add this line
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
