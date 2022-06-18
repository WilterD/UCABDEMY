import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ucabdemy/initial_page.dart';
import 'package:ucabdemy/provider/auth_provider.dart';
import 'package:ucabdemy/provider/user_provider.dart';
import 'package:ucabdemy/services/shared_preferences_local.dart';

Directory? appDocDi25;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferencesLocal.configurePrefs();

  runApp(const AppState());
  if (!Platform.isAndroid) {
    appDocDi25 = await getApplicationDocumentsDirectory();
  }else{
    appDocDi25 = await getExternalStorageDirectory();
  }
}

class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(lazy: false,create: ( _ ) => AuthProvider()),
        ChangeNotifierProvider(lazy: false,create: ( _ ) => UserProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ucademy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitialPage(),
    );
  }
}


