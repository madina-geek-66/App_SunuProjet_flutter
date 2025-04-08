import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/projet_file.dart';

class ProjetFileController extends GetxController {
  final RxList<ProjetFile> projectFiles = <ProjetFile>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Instance Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

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
          .from('projectfiles')
          .select()
          .eq('projetId', projectId)
          .order('dateAjout', ascending: false);

      // Convertir les résultats en objets ProjetFile
      final List<ProjetFile> files = response.map<ProjetFile>((file) =>
          ProjetFile.fromSupabase(file)
      ).toList();

      projectFiles.assignAll(files);
    } catch (e) {
      errorMessage.value = e.toString();
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

        // Générer un nom de fichier unique
        String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        String filePath = 'project_files/$projectId/$uniqueFileName';

        // Télécharger le fichier vers Supabase Storage
        final uploadResponse = await _supabase
            .storage
            .from('projectfiles')
            .upload(
            '$projectId/$uniqueFileName',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false)
        );

        // Obtenir l'URL publique du fichier
        final String fileUrl = _supabase
            .storage
            .from('projectfiles')
            .getPublicUrl('$projectId/$uniqueFileName');

        // Créer l'objet ProjetFile
        final now = DateTime.now();

        // Enregistrer les métadonnées dans la table project_files
        final insertResponse = await _supabase.from('projectfiles').insert({
          'nom': fileName,
          'type': path.extension(file.path),
          'taille': fileSizeInMB,
          'ajoutePar': currentUserId,
          'dateAjout': now.toIso8601String(),
          'projetId': projectId,
          'fileUrl': fileUrl
        }).select();

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
      final Uri uri = Uri.parse(file.fileUrl);
      final List<String> pathSegments = uri.pathSegments;
      final String storagePath = pathSegments.length > 1
          ? pathSegments.sublist(pathSegments.indexOf('projectfiles') + 1).join('/')
          : '${file.projetId}/${path.basename(file.fileUrl)}';

      // Supprimer le fichier de Supabase Storage
      await _supabase
          .storage
          .from('projectfiles')
          .remove([storagePath]);

      // Supprimer les métadonnées de la table project_files
      await _supabase
          .from('projectfiles')
          .delete()
          .eq('uid', file.uid);

      // Actualiser la liste des fichiers
      await fetchProjectFiles(file.projetId);

      Get.snackbar(
        'Succès',
        'Fichier supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la suppression du fichier: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Récupérer le nom de l'utilisateur ayant ajouté le fichier
  Future<String> getUserName(String userId) async {
    try {
      // Requête à la table des utilisateurs dans Supabase
      final response = await _supabase
          .from('users')
          .select('fullName')
          .eq('id', userId)
          .single();

      return response['fullName'] ?? userId.split('@').first;
    } catch (e) {
      return userId.split('@').first;
    }
  }
}