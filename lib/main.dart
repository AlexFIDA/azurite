import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  //await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  //);

  runApp(const ProviderScope(child: SuperApp()));
}


class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Azurite',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
     // home: const AuthChecker,
    );
  }
}