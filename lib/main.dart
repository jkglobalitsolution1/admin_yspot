import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Authentication/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyDqmnjokk7Q-zKcmq7FWd7MJgHnhS_HHXQ',
    appId: '1:783996806068:android:7e91cf60683ca8d558c8e1',
    messagingSenderId: '783996806068',
    projectId: 'y-spot-e84ca',
    databaseURL: 'https://y-spot-e84ca-default-rtdb.firebaseio.com',
    storageBucket: 'y-spot-e84ca.appspot.com',
  ));
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminLogin(),
    );
  }
}
