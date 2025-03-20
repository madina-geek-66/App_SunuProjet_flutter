import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/config/constants_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/projet/projet_controller.dart';
import '../../models/projet.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({Key? key}) : super(key: key);

  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final ProjetController projectController = Get.find<ProjetController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Contrôleur pour le champ de recherche de membres
  //final TextEditingController _memberSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Créer un projet', style: TextStyle(color: Colors.white)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
            () => projectController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleInput(),
              const SizedBox(height: 16),
              _buildDescriptionInput(),
              const SizedBox(height: 24),
              _buildProjectDatesSection(),
              const SizedBox(height: 24),
              _buildPrioritySection(),
              const SizedBox(height: 24),
              _buildCreateProjectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return _buildCard(
      child: TextField(
        controller: projectController.titreController,
        decoration: const InputDecoration(
          hintText: 'Titre du projet',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return _buildCard(
      child: TextField(
        controller: projectController.descriptionController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Description',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildProjectDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Dates du projet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: 'Date de début',
                dateTime: projectController.dateDebut,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                label: 'Date de fin',
                dateTime: projectController.dateFin,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required Rx<DateTime> dateTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCard(
        child: Obx(
              () => Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black54, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    Text(
                      '${dateTime.value.day.toString().padLeft(2, '0')}/${dateTime.value.month.toString().padLeft(2, '0')}/${dateTime.value.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Priorité',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        _buildCard(
          child: Column(
            children: ['Basse', 'Moyenne', 'Haute', 'Urgente']
                .map((priority) => Column(
              children: [
                _buildPriorityOption(priority),
                if (priority != 'Urgente') const Divider(height: 1),
              ],
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(String priority) {
    return Obx(
          () => InkWell(
        onTap: () => projectController.priorite.value = priority,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Radio(
                value: priority,
                groupValue: projectController.priorite.value,
                onChanged: (value) => projectController.priorite.value = value as String,
                activeColor: kSecondaryColor,
              ),
              Text(priority, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCreateProjectButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _createProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Créer le projet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _createProject() async {
    if (projectController.titreController.text.isEmpty) {
      Get.snackbar('Erreur', 'Le titre du projet est requis',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Erreur', 'Vous devez être connecté pour créer un projet',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      Map<String, String> memberRolesMap = {userId: "Chef de projet"};
      // Créer un nouveau projet avec les rôles des membres
      final newProject = Projet(
        uid: '',
        titre: projectController.titreController.text,
        description: projectController.descriptionController.text,
        dateDebut: projectController.dateDebut.value,
        dateFin: projectController.dateFin.value,
        priorite: projectController.priorite.value,
        statut: 'En attente',
        progress: 0,
        ownerId: userId,
        memberRoles: memberRolesMap,
        createdAt: DateTime.now(),
      );

      await projectController.addProject(newProject);
      projectController.titreController.clear();
      projectController.descriptionController.clear();
      projectController.dateDebut.value = DateTime.now();
      projectController.dateFin.value = DateTime.now().add(const Duration(days: 7));
      projectController.priorite.value = 'Moyenne';

      Get.snackbar('Succès', 'Projet créé avec succès',
          backgroundColor: Colors.green, colorText: Colors.white);

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de créer le projet: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? projectController.dateDebut.value
          : projectController.dateFin.value,
      firstDate: isStartDate ? DateTime.now() : projectController.dateDebut.value,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStartDate) {
        projectController.dateDebut.value = picked;
        if (projectController.dateDebut.value.isAfter(projectController.dateFin.value)) {
          projectController.dateFin.value = projectController.dateDebut.value.add(const Duration(days: 1));
        }
      } else {
        projectController.dateFin.value = picked;
      }
    }
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}