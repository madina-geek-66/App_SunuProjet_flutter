import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/constants_color.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  Rx<User?> user = Rx<User?>(null);
  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
      user.value = currentUser;
      if (currentUser != null) {
        _fetchUserData(currentUser.uid);
      } else {
        userModel.value = null;
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userModel.value = UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      emailController.clear();
      passwordController.clear();

      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Erreur de connexion',
        _getAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kErrorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login'); // <-- Redirection vers Login après déconnexion
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kErrorColor,
        colorText: Colors.white,
      );
    }
  }




  Future<void> register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        fullNameController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Erreur', 'Les mots de passe ne correspondent pas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Création de l'utilisateur sur Firebase Authentication
      UserCredential userCredential = await _authService.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Envoi de l'email de vérification
      await userCredential.user!.sendEmailVerification();

      // Tentative d'ajout des données utilisateur à Firestore (pourrait échouer à cause des permissions)
      try {
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          role: 'user',
          isActive: true,
          createdAt: DateTime.now(),
          photoUrl: '',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
      } catch (firestoreError) {
        // Gérer l'erreur de Firestore silencieusement (utilisateur créé mais pas ajouté à Firestore)
        print('Erreur Firestore (ignorée): $firestoreError');
      }

      // Vider les champs
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      fullNameController.clear();

      // Déconnexion de l'utilisateur
      await FirebaseAuth.instance.signOut();

      // Message de confirmation
      Get.snackbar(
        'Inscription réussie',
        'Un email de vérification a été envoyé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Redirection vers la page login
      Get.offAllNamed('/login');

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur d\'inscription', _getAuthErrorMessage(e.code),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
    } catch (e) {
      print('Erreur détaillée: ${e.toString()}');
      Get.snackbar('Erreur', 'Une erreur s\'est produite lors de l\'inscription',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Erreur', 'Veuillez entrer une adresse email valide',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kErrorColor,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _authService.resetPassword(email.trim());

      Get.snackbar(
        'Réinitialisation du mot de passe',
        'Un email a été envoyé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé pour cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'email-already-in-use':
        return 'Email déjà utilisé';
      default:
        return 'Une erreur s\'est produite';
    }
  }
}
