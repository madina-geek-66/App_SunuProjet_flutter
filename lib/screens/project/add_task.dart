import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/constants_color.dart';
import '../../controllers/projet/projet_controller.dart';
import '../../controllers/projet/tache_controller.dart';

class AddTaskPage extends StatefulWidget {
  final String projectId;

  const AddTaskPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  String selectedPriority = 'Moyenne';
  List<String> selectedMembers = [];

  final TacheController tacheController = Get.find<TacheController>();
  final ProjetController projetController = Get.find<ProjetController>();


  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projet = projetController.projects.firstWhere(
          (p) => p.uid == widget.projectId,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle tâche'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre de la tâche',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date limite
              ListTile(
                title: const Text('Date limite'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                leading: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priorité
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priorité',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Basse', 'Moyenne', 'Haute', 'Urgente'].map((priority) {
                      Color color;
                      switch (priority) {
                        case 'Basse':
                          color = Colors.green;
                          break;
                        case 'Moyenne':
                          color = Colors.blue;
                          break;
                        case 'Haute':
                          color = Colors.orange;
                          break;
                        case 'Urgente':
                          color = Colors.red;
                          break;
                        default:
                          color = Colors.blue;
                      }

                      return ChoiceChip(
                        label: Text(priority),
                        selected: selectedPriority == priority,
                        selectedColor: color.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: selectedPriority == priority ? color : Colors.grey[700],
                          fontWeight: selectedPriority == priority ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedPriority = priority;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Assigner des membres
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigner des membres',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projet.members.map((memberId) {
                      final bool isSelected = selectedMembers.contains(memberId);
                      return FutureBuilder<Map<String, String>>(
                        future: tacheController.getAssignedUsersNames([memberId]),
                        builder: (context, snapshot) {
                          final String memberName = snapshot.data?[memberId] ?? memberId.split('@').first;
                          return FilterChip(
                            label: Text(memberName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedMembers.add(memberId);
                                } else {
                                  selectedMembers.remove(memberId);
                                }
                              });
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton de création
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Créer la tâche',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _submitForm() {
    if (formKey.currentState!.validate()) {
      try {
        if (selectedMembers.isEmpty) {
          Get.snackbar(
            'Attention',
            'Aucun membre n\'a été assigné à cette tâche',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          // Vous pouvez décider de continuer quand même ou de retourner
        }

        print('Création de tâche avec: ${titleController.text}, ${widget.projectId}, $selectedDate, $selectedPriority');

        tacheController.createTache(
          titleController.text,
          descriptionController.text,
          widget.projectId,
          selectedDate,
          selectedPriority,
          selectedMembers,
        );

        Get.back();

      } catch (e) {
        print('Erreur dans _submitForm: $e');
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}