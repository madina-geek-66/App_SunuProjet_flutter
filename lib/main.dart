import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/controllers/projet/projet_file_controller.dart';
import 'package:madina_diallo_l3gl_examen/controllers/projet/tache_controller.dart';
import 'package:madina_diallo_l3gl_examen/screens/admin/admin_dashboard.dart';
import 'package:madina_diallo_l3gl_examen/screens/authentification/login_page.dart';
import 'package:madina_diallo_l3gl_examen/screens/authentification/register_page.dart';
import 'package:madina_diallo_l3gl_examen/screens/home.dart';
import 'package:madina_diallo_l3gl_examen/screens/project/add_member.dart';
import 'package:madina_diallo_l3gl_examen/screens/project/add_task.dart';
import 'package:madina_diallo_l3gl_examen/screens/project/project_details.dart';
import 'package:madina_diallo_l3gl_examen/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'config/theme.dart';
import 'controllers/authentification/auth_controller.dart';
import 'controllers/projet/projet_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // await Supabase.initialize(
  //   url: 'https://qrmuoporxscexxdhakfh.supabase.co',
  //   anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFybXVvcG9yeHNjZXh4ZGhha2ZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyMTA4MDMsImV4cCI6MjA1ODc4NjgwM30.1LQkZefC-X5b4QjnTwkIWM9dF1utyO661d_z7zJGDnk',
  // );

  Get.put(AuthController());
  Get.put(ProjetController());
  Get.put(ThemeController());
  Get.put(ProjetFileController());
  Get.put(TacheController());

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
      themeMode: ThemeMode.system,
      //initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      home: SplashScreen(),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => Home()),
        GetPage(name: '/project-details/:id', page: () => ProjectDetailPage(projectId: Get.parameters['id']!)),
        GetPage(name: '/add-member', page: () => AddMemberPage(projectId: Get.parameters['id']!)),
        GetPage(name: '/add-task', page: () => AddTaskPage(projectId: Get.parameters['id']!)),
        GetPage(
          name: '/dashboard',
          page: () => const AdminDashboard(),
        ),

      ],
    );
  }
}