import 'package:flutter/material.dart';
import 'package:lista_de_compras/src/pages/home_page.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Compras',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      home: Center(
        child: SplashScreen(
            seconds: 5,
            navigateAfterSeconds: HomePage(),
            title: Text(
              'Sua Lista de Compras',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35.0,
                color: Colors.deepPurple
              ),
            ),
            image: Image.asset('lib/assets/splash_image.png'),
            backgroundColor: Colors.white,
            photoSize: 125.0,
            loaderColor: Colors.deepPurple),
      ),
    );
  }
}
