import 'package:bc_assignment/screens/login_screen.dart';
import 'package:bc_assignment/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'screens/stream_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(BlackCofferAssignment());
}

class BlackCofferAssignment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        StreamPage.id: (context) => StreamPage(),
        // VideoPage.id: (context) => VideoPage(),
        CameraScreen.id: (context) => CameraScreen(),
        // PostConfirmationScreen.id: (context) => PostConfirmationScreen(),
      },
    );
  }
}
