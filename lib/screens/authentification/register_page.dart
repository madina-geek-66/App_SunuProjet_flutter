import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/constants_color.dart';
import '../../controllers/authentification/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title:
              const Text('Inscription', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Obx(
          () => authController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  // On centre tout le contenu
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rejoignez SunuProjet pour gérer vos projets',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                            'Nom complet',
                            authController.fullNameController,
                            Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildTextField(
                            'Adresse Email',
                            authController.emailController,
                            Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                            'Mot de Passe',
                            authController.passwordController,
                            authController.isPasswordVisible),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                            'Confirmer le Mot de Passe',
                            authController.confirmPasswordController,
                            authController.isConfirmPasswordVisible),
                        const SizedBox(height: 40),
                        _buildRegisterButton(),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Vous avez déjà un compte? '),
                            TextButton(
                              onPressed: () => Get.toNamed('/login'),
                              child: Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }

  Widget _buildTextField(
      String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: hint.contains('Email')
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildPasswordField(
      String hint, TextEditingController controller, RxBool isVisible) {
    return Obx(
      () => TextField(
        controller: controller,
        obscureText: !isVisible.value,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible.value ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => isVisible.toggle(),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => authController.register(),

        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("S'inscrire",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
