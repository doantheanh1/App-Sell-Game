import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Views/main_screen.dart';
import 'login_or_gegister.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if (snapshot.hasData){
              return const AppMainScreen();
            }else{
              return const LoginOrRegister();
            }
          },
        )
    );
  }
}
