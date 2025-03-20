import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/screens/authentification/login_page.dart';
import 'package:madina_diallo_l3gl_examen/screens/authentification/register_page.dart';
import 'package:madina_diallo_l3gl_examen/screens/home.dart';
import 'package:madina_diallo_l3gl_examen/screens/project/project_details.dart';


import 'config/theme.dart';
import 'controllers/authentification/auth_controller.dart';
import 'controllers/projet/projet_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Get.put(AuthController());
  Get.put(ProjetController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      //home: SplashScreen(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/login', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/project-details/:id', page: () => ProjectDetailPage(projectId: Get.parameters['id']!)),
      ],
    );
  }
}