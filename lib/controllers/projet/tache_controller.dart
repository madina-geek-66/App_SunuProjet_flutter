import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../projet/projet_controller.dart';
import '../../models/tache_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TacheController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Tache> taches = <Tache>[].obs;
  final RxBool isLoading = false.obs;

  // Référence au contrôleur de projet
  late final ProjetController _projetController;

  @override
  void onInit() {
    super.onInit();
    _projetController = Get.find<ProjetController>();
  }


  Future<void> fetchTachesByProject(String projectId) async {
    if (projectId.isEmpty) return;

    isLoading.value = true;
    try {
      // Requête directe à Firestore pour obtenir les tâches de ce projet
      final QuerySnapshot snapshot = await _firestore
          .collection('taches')
          .where('projetId', isEqualTo: projectId)
          .get();

      print('Nombre de tâches trouvées: ${snapshot.docs.length}'); // Debug

      final List<Tache> fetchedTaches = snapshot.docs
          .map((doc) {
        print('Tâche trouvée: ${doc.id}, ${doc.data()}'); // Debug
        return Tache.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      })
          .toList();

      // Mise à jour de la liste locale
      taches.clear();
      taches.addAll(fetchedTaches);
      taches.refresh(); // Force la mise à jour de l'UI

    } catch (e) {
      print('Erreur lors de la récupération des tâches: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors du chargement des tâches: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }




  // Créer une nouvelle tâche
  Future<void> createTache(
      String titre,
      String description,
      String projetId,
      DateTime dateLimite,
      String priorite,
      List<String> assignesIds,
      ) async {
    try {
      // Créer un document avec un ID généré automatiquement
      final docRef = _firestore.collection('taches').doc();

      // Création de l'objet Tache
      final Tache newTache = Tache(
        uid: docRef.id,
        titre: titre,
        description: description,
        projetId: projetId,
        dateCreation: DateTime.now(),
        dateLimite: dateLimite,
        priorite: priorite,
        statut: 'A faire',
        progression: 0,
        assignesIds: assignesIds,
      );

      // Conversion en Map et ajout dans Firestore
      await docRef.set(newTache.toMap());

      // Ajouter à la liste locale de tâches
      taches.add(newTache);

      // Mise à jour de la progression du projet
      updateProjectProgress(projetId);

      Get.snackbar(
        'Succès',
        'Tâche créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Erreur lors de la création de la tâche: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création de la tâche: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTache(Tache tache) async {
    try {
      await _firestore
          .collection('taches')
          .doc(tache.uid)
          .update(tache.toMap());

      final index = taches.indexWhere((t) => t.uid == tache.uid);
      if (index >= 0) {
        taches[index] = tache;
      } else {
        // Si la tâche n'existe pas localement, l'ajouter
        taches.add(tache);
      }

      // Mettre à jour le projet
      updateProjectProgress(tache.projetId);

    } catch (e) {
      print('Erreur lors de la mise à jour de la tâche: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour de la tâche',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mettre à jour le statut d'une tâche
  Future<void> updateTacheStatus(String tacheId, String newStatus) async {
    try {
      final index = taches.indexWhere((t) => t.uid == tacheId);
      if (index >= 0) {
        final tache = taches[index];

        // Mettre à jour la progression en fonction du statut
        int newProgression = tache.progression;
        if (newStatus == 'Terminé') {
          newProgression = 100;
        } else if (newStatus == 'En cours' && tache.progression == 0) {
          newProgression = 30;

          // AJOUT: Si une tâche passe à "En cours", mettre à jour le statut du projet
          await _projetController.updateProjectStatus(tache.projetId, 'En cours');
        } else if (newStatus == 'A faire') {
          newProgression = 0;
        }

        // Mettre à jour dans Firestore
        await _firestore.collection('taches').doc(tacheId).update({
          'statut': newStatus,
          'progression': newProgression,
        });

        // Mettre à jour localement
        tache.statut = newStatus;
        tache.progression = newProgression;
        taches[index] = tache;

        // Mettre à jour le projet
        updateProjectProgress(tache.projetId);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour du statut',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Mettre à jour la progression d'une tâche
  Future<void> updateTacheProgression(String tacheId, int newProgression) async {
    try {
      final index = taches.indexWhere((t) => t.uid == tacheId);
      if (index >= 0) {
        final tache = taches[index];

        // Mettre à jour le statut en fonction de la progression
        String newStatus = tache.statut;
        if (newProgression == 100) {
          newStatus = 'Terminé';
        } else if (newProgression > 0) {
          newStatus = 'En cours';

          // AJOUT: Si une tâche devient "En cours" via progression, mettre à jour le statut du projet
          await _projetController.updateProjectStatus(tache.projetId, 'En cours');
        } else {
          newStatus = 'A faire';
        }

        // Mettre à jour dans Firestore
        await _firestore.collection('taches').doc(tacheId).update({
          'progression': newProgression,
          'statut': newStatus,
        });

        // Mettre à jour localement
        tache.progression = newProgression;
        tache.statut = newStatus;
        taches[index] = tache;

        // Mettre à jour le projet
        updateProjectProgress(tache.projetId);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la progression: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour de la progression',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Supprimer une tâche
  Future<void> deleteTache(String tacheId) async {
    try {
      final tache = taches.firstWhere((t) => t.uid == tacheId);
      final projetId = tache.projetId;

      // Supprimer de Firestore
      await _firestore.collection('taches').doc(tacheId).delete();

      // Supprimer localement
      taches.removeWhere((t) => t.uid == tacheId);

      // Mettre à jour le projet
      updateProjectProgress(projetId);

      Get.snackbar(
        'Succès',
        'Tâche supprimée avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Erreur lors de la suppression de la tâche: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression de la tâche',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Ajouter un commentaire à une tâche
  Future<void> addCommentToTache(String tacheId, String userId, String message) async {
    try {
      // Récupérer l'ID de l'utilisateur connecté
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      userId = currentUser.uid; // Utiliser l'ID de l'utilisateur connecté

      final index = taches.indexWhere((t) => t.uid == tacheId);
      if (index >= 0) {
        final tache = taches[index];

        final newComment = {
          'userId': userId,
          'message': message,
          'date': DateTime.now(),
        };

        // Mettre à jour dans Firestore
        await _firestore.collection('taches').doc(tacheId).update({
          'discussions': FieldValue.arrayUnion([
            {
              'userId': userId,
              'message': message,
              'date': Timestamp.fromDate(DateTime.now()),
            }
          ]),
        });

        // Mettre à jour localement
        tache.ajouterCommentaire(userId, message);
        taches[index] = tache;

        // Forcer une mise à jour de l'UI
        taches.refresh();
      }
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'ajout du commentaire: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

// Version optimisée dans TacheController
  void updateProjectProgress(String projetId) {
    try {
      // Filtrer les tâches du projet
      final projectTaches = taches.where((t) => t.projetId == projetId).toList();

      if (projectTaches.isEmpty) return;

      // Calculer le pourcentage de progression
      int totalTaches = projectTaches.length;
      int totalProgression = 0;

      // Calculer la progression basée sur la progression de chaque tâche, pas seulement sur les tâches terminées
      for (var tache in projectTaches) {
        totalProgression += tache.progression;
      }

      int progressPercentage = (totalProgression / (totalTaches * 100) * 100).round();

      // S'assurer que la progression est entre 0 et 100
      progressPercentage = progressPercentage.clamp(0, 100);

      // Vérifier s'il y a des tâches en cours
      bool hasTasksInProgress = projectTaches.any((t) => t.statut == 'En cours');

      // Déterminer le statut du projet
      String projectStatus;
      if (progressPercentage == 100) {
        projectStatus = 'Terminé';
      } else if (hasTasksInProgress) {
        projectStatus = 'En cours';
      } else {
        projectStatus = 'En attente';
      }

      print('Mise à jour du projet: $projetId, progression: $progressPercentage%, statut: $projectStatus'); // Debug

      // Mettre à jour la progression et le statut
      //_projetController.updateProjectProgress(projetId, progressPercentage);
      //_projetController.updateProjectStatus(projetId, projectStatus);

      // Utiliser la méthode combinée
      _projetController.updateProjectStatusAndProgress(projetId, projectStatus, progressPercentage);

    } catch (e) {
      print('Erreur lors de la mise à jour de la progression du projet: $e');
    }
  }

  // Récupérer les noms des utilisateurs assignés
  Future<Map<String, String>> getAssignedUsersNames(List<String> userIds) async {
    Map<String, String> usersMap = {};

    for (String userId in userIds) {
      try {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data() ?? {};
          usersMap[userId] = data['fullName'] ?? userId.split('@').first;
        } else {
          usersMap[userId] = userId.split('@').first;
        }
      } catch (e) {
        usersMap[userId] = userId.split('@').first;
      }
    }

    return usersMap;
  }

  // Formatter une date pour l'affichage
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}