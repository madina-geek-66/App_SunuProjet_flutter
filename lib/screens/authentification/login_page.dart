import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/screens/authentification/register_page.dart';
import '../../config/constants_color.dart';
import '../../controllers/authentification/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  LoginPage({Key? key}) : super(key: key);

  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  void validateAndLogin() {
    emailError.value = authController.emailController.text.isEmpty
        ? 'Veuillez entrer votre adresse email'
        : '';
    passwordError.value = authController.passwordController.text.isEmpty
        ? 'Veuillez entrer votre mot de passe'
        : '';

    if (emailError.value.isEmpty && passwordError.value.isEmpty) {
      authController.login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Obx(
    () => authController.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : Center( // On centre tout le contenu
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Text(
                'SunuProjet',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connectez-vous pour continuer',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: Text(
                    'Mot de passe oublié?',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildLoginButton(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous n'avez pas de compte? "),
                  TextButton(
                    onPressed: () => Get.to(() => RegisterPage()),
                    child: Text(
                      "S'inscrire",
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
      )
      ),
    );
  }

  Widget _buildEmailField() {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: authController.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Adresse Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: emailError.value.isNotEmpty ? Colors.red : Colors.grey.shade300,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              errorText: emailError.value.isEmpty ? null : emailError.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: authController.passwordController,
            obscureText: !authController.isPasswordVisible.value,
            decoration: InputDecoration(
              hintText: 'Mot de Passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  authController.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () => authController.togglePasswordVisibility(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: passwordError.value.isNotEmpty ? Colors.red : Colors.grey.shade300,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              errorText: passwordError.value.isEmpty ? null : passwordError.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: validateAndLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Se Connecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
