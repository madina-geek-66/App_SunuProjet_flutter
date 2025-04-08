import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../config/constants_color.dart';
import '../../models/user_model.dart';

class AddMemberPage extends StatefulWidget {
  final String projectId;

  const AddMemberPage({Key? key, required this.projectId}) : super(key: key);
  @override
  _AddMemberPageState createState() => _AddMemberPageState();

}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  UserModel? _foundUser;
  bool _isLoading = false;

  final List<String> _roles = ['Administrateur', 'Membre'];

  void _searchUserByEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _foundUser = null;
      });

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _foundUser = UserModel.fromFirestore(querySnapshot.docs.first);
          });
        } else {
          Get.snackbar(
            'Utilisateur non trouvé',
            'Aucun utilisateur trouvé avec cet email',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue lors de la recherche',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addMemberToProject() async {
    if (_foundUser != null && _selectedRole != null) {
      try {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .update({
          'memberRoles.${_foundUser!.uid}': _selectedRole
        });

        Get.back(); // Return to previous screen
        Get.snackbar(
          'Succès',
          'Membre ajouté au projet',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ajouter le membre',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Ajouter un membre', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email du membre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchUserByEmail,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un email';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Veuillez saisir un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_foundUser != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: kPrimaryColor.withOpacity(0.2),
                          child: Text(
                            _foundUser!.fullName?[0].toUpperCase() ?? '?',
                            style: TextStyle(
                              fontSize: 24,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _foundUser!.fullName ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _foundUser!.email ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sélectionnez un rôle',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._roles.map((role) => RadioListTile<String>(
                          title: Text(role),
                          value: role,
                          groupValue: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        )).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedRole != null ? _addMemberToProject : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Ajouter au projet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}