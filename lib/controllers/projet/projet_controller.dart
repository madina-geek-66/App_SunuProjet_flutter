import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/projet.dart';

class ProjetController extends GetxController {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController membersController = TextEditingController();

  final Rx<DateTime> dateDebut = DateTime.now().obs;
  final Rx<DateTime> dateFin = DateTime.now().add(const Duration(days: 7)).obs;
  final RxString priorite = 'Moyenne'.obs;


  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Ajout pour gérer les membres et leurs rôles
  final RxMap<String, String> memberRoles = <String, String>{}.obs;
  final RxString selectedMemberRole = "Membre d'équipe".obs;
  final List<String> availableRoles = ["Chef de projet", "Administrateur", "Membre d'équipe"];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable projects list
  final RxList<Projet> projects = <Projet>[].obs;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  List<Projet> getProjectsByStatus(String status) {
    return projects.where((project) => project.statut == status).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProjects();
    // Ajout du membre courant (créateur) comme Chef de projet
    if (currentUserId.isNotEmpty) {
      memberRoles[currentUserId] = "Chef de projet";
    }
  }

  void addMember(String memberId, String role) {
    memberRoles[memberId] = role;
    memberRoles.refresh();
  }

  void removeMember(String memberId) {
    memberRoles.remove(memberId);
    memberRoles.refresh();
  }

  void updateMemberRole(String memberId, String newRole) {
    if (memberRoles.containsKey(memberId)) {
      memberRoles[memberId] = newRole;
      memberRoles.refresh();
    }
  }

  // Renamed and unified fetch method
  Future<void> fetchUserProjects() async {
    if (_auth.currentUser == null) return;

    //isLoading.value = true;
    errorMessage.value = '';

    try {
      // Récupérer les projets où l'utilisateur est membre
      final QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .where('memberRoles.$currentUserId', isNull: false)
          .get();

      final List<Projet> loadedProjects = snapshot.docs
          .map((doc) => Projet.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Trier les projets par date de création (les plus récents d'abord)
      loadedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      projects.assignAll(loadedProjects); // Mettre à jour la liste observable
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProject(Projet project) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Créer une nouvelle référence de document
      final DocumentReference docRef = await _firestore.collection('projects').add(project.toMap());

      project.uid = docRef.id;
      await docRef.update({'id': docRef.id});

      projects.add(project);

      // Réinitialiser les rôles des membres pour le prochain projet
      memberRoles.clear();
      if (currentUserId.isNotEmpty) {
        memberRoles[currentUserId] = "Chef de projet";
      }
      memberRoles.refresh();

      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un projet existant
  Future<void> updateProject(Projet project) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Mettre à jour le projet dans Firestore
      await _firestore.collection('projects').doc(project.uid).update(project.toMap());

      // Reload all projects to ensure UI consistency
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Supprimer le projet de Firestore
      await _firestore.collection('projects').doc(projectId).delete();

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le statut d'un projet
  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Mettre à jour uniquement le statut dans Firestore
      await _firestore.collection('projects').doc(projectId).update({'statut': newStatus});

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour la progression d'un projet
  Future<void> updateProjectProgress(String projectId, int newProgress) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Mettre à jour uniquement la progression dans Firestore
      await _firestore.collection('projects').doc(projectId).update({'progress': newProgress});

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un membre à un projet
  Future<void> addMemberToProject(String projectId, String memberId, String role) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Récupérer la référence du projet
      final DocumentReference projectRef = _firestore.collection('projects').doc(projectId);
      // Mettre à jour le rôle du membre
      await projectRef.update({'memberRoles.$memberId': role});

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le rôle d'un membre dans un projet
  Future<void> updateMemberRoleInProject(String projectId, String memberId, String newRole) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Récupérer la référence du projet
      final DocumentReference projectRef = _firestore.collection('projects').doc(projectId);
      // Mettre à jour le rôle du membre
      await projectRef.update({'memberRoles.$memberId': newRole});

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un membre d'un projet
  Future<void> removeMemberFromProject(String projectId, String memberId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Récupérer la référence du projet
      final DocumentReference projectRef = _firestore.collection('projects').doc(projectId);
      // Supprimer le membre du projet
      await projectRef.update({'memberRoles.$memberId': FieldValue.delete()});

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }


  // Ajouter cette méthode au ProjetController
  Future<void> updateProjectStatusAndProgress(String projectId, String newStatus, int newProgress) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Mettre à jour à la fois la progression et le statut dans une seule opération
      await _firestore.collection('projects').doc(projectId).update({
        'progress': newProgress,
        'statut': newStatus
      });

      // Reload all projects
      await fetchUserProjects();
    } catch (e) {
      errorMessage.value = e.toString();
      throw e;
    } finally {
      isLoading.value = false;
    }
  }
}