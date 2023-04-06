import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:productos_app/services/services.dart';

import 'package:productos_app/screens/screens.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider( create: (_) => AuthService() ),
      ChangeNotifierProvider( create: (_) => ProductsService() ),
    ],
    child: const MyApp()
  )
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productos App',
      initialRoute: 'checkauth',
      routes: {
        'login'    :(_) => const LoginScreen(),
        'home'     :(_) => const HomeScreen(),
        'product'  :(_) => const ProductScreen(),
        'register' :(_) => const RegisterScreen(),
        'checkauth':(_) => const CheckAuthScreen(),
      },
      scaffoldMessengerKey: NotificationsService.messengerKey,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(elevation: 0, color: Colors.indigo),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          elevation: 0
        )
      ),
    );
  }
}