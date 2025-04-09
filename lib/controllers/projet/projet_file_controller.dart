import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/controllers/projet/projet_controller.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/projet_file.dart';
import '../../models/user_model.dart';


class ProjetFileController extends GetxController {
  final RxList<ProjetFile> projectFiles = <ProjetFile>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Instance Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // Instance Firestore pour accéder aux utilisateurs
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Limite de taille de fichier par rôle (en Mo)
  final Map<String, double> fileSizeLimits = {
    "Chef de projet": 50.0,
    "Administrateur": 30.0,
    "Membre d'équipe": 10.0
  };

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // Récupérer les fichiers d'un projet depuis Supabase
  Future<void> fetchProjectFiles(String projectId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Requête à la table "project_files" dans Supabase
      final response = await _supabase
          .from('project_files')
          .select()
          .eq('projet_id', projectId)
          .order('date_ajout', ascending: false);
      print("Réponse brute de Supabase: $response");

      // Convertir les résultats en objets ProjetFile
      final List<ProjetFile> files = response.map<ProjetFile>((file) =>
          ProjetFile.fromSupabase(file)
      ).toList();

      projectFiles.assignAll(files);
      print("ID du projet pour récupération: $projectId");
    } catch (e) {
      errorMessage.value = e.toString();
      print("Erreur fetchProjectFiles: $e");
    } finally {
      isLoading.value = false;
    }
  }




  // Sélectionner et télécharger un fichier
  Future<void> pickAndUploadFile(String projectId, String userRole) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        double fileSizeInMB = file.lengthSync() / (1024 * 1024);

        // Vérification de la taille du fichier
        if (fileSizeInMB > (fileSizeLimits[userRole] ?? 10.0)) {
          Get.snackbar(
            'Erreur',
            'La taille du fichier dépasse la limite autorisée pour votre rôle (${fileSizeLimits[userRole]} MB).',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        isLoading.value = true;

        // Obtenir l'ID de l'utilisateur actuel
        final currentUserId = Get.find<ProjetController>().currentUserId;

        // Étape 1: Upload du fichier
        final fileUrl = await uploadFileToStorage(file, projectId, fileName);

        // Étape 2: Insertion des métadonnées
        await insertFileMetadata(
            fileName,
            path.extension(file.path),
            fileSizeInMB,
            currentUserId,
            projectId,
            fileUrl
        );

        // Actualiser la liste des fichiers
        await fetchProjectFiles(projectId);

        Get.snackbar(
          'Succès',
          'Fichier téléchargé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      }
    } catch (e) {
      print("ERREUR D'UPLOAD: $e");
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Échec du téléchargement du fichier: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un fichier
  Future<void> deleteFile(ProjetFile file) async {
    try {
      // Extraire le chemin du fichier à partir de l'URL
      final String fileName = path.basename(file.fileUrl);
      final String storagePath = "${file.projetId}/$fileName";

      // Supprimer le fichier de Supabase Storage
      await _supabase
          .storage
          .from('project_files')
          .remove([storagePath]);

      // Supprimer les métadonnées de la table project_files
      await _supabase
          .from('project_files')
          .delete()
          .eq('id', file.uid);

      // Actualiser la liste des fichiers
      await fetchProjectFiles(file.projetId);

      Get.snackbar(
        'Succès',
        'Fichier supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("Erreur de suppression: $e");
      Get.snackbar(
        'Erreur',
        'Échec de la suppression du fichier: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Récupérer le nom de l'utilisateur depuis Firebase
  Future<String> getUserName(String userId) async {
    try {
      // Récupération depuis Firebase au lieu de Supabase
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['fullName'] ?? userId.split('@').first;
      } else {
        return userId.split('@').first;
      }
    } catch (e) {
      print("Erreur getUserName: $e");
      return userId.split('@').first;
    }
  }

  // Étape 1 : Upload du fichier vers Supabase Storage
  Future<String> uploadFileToStorage(File file, String projectId, String fileName) async {
    try {
      // Générer un nom de fichier unique pour éviter les conflits
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      String filePath = '$projectId/$uniqueFileName';

      print("Début upload vers bucket 'projectfiles', chemin: $filePath");

      // Vérifier si le bucket existe
      final buckets = await _supabase.storage.listBuckets();
      print("Buckets disponibles: ${buckets.map((b) => b.name).join(', ')}");

      // Upload du fichier
      await _supabase.storage
          .from('projectfiles')  // Vérifiez que ce bucket existe dans votre projet Supabase
          .upload(
          filePath,
          file,
          fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'application/octet-stream'
          )
      );

      // Générer l'URL publique
      final String fileUrl = _supabase.storage
          .from('projectfiles')
          .getPublicUrl(filePath);

      print("Fichier uploadé avec succès, URL: $fileUrl");
      return fileUrl;
    } catch (e) {
      print("Erreur détaillée pendant l'upload: $e");
      throw Exception("Échec de l'upload: $e");
    }
  }

  // Étape 2 : Insertion des métadonnées dans la table
  Future<void> insertFileMetadata(
      String fileName,
      String fileExtension,
      double fileSize,
      String userId,
      String projectId,
      String fileUrl) async {
    try {
      final now = DateTime.now();
      //final uuid = Uuid();
      await _supabase
          .from('project_files')
          .insert({
        'nom': fileName,
        'type': fileExtension,
        'taille': fileSize,
        'ajoute_par': userId,
        'date_ajout': now.toIso8601String(),
        'projet_id': projectId,
        'file_url': fileUrl
      });

      print("Métadonnées insérées avec succès");
    } catch (e) {
      print("Erreur d'insertion des métadonnées: $e");
      throw Exception("Échec de l'insertion des métadonnées: $e");
    }
  }
}