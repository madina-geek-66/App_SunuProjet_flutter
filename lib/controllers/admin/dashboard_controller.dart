import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Statistiques observables
  final RxInt totalProjects = 0.obs;
  final RxInt projectsInProgress = 0.obs;
  final RxInt projectsCompleted = 0.obs;
  final RxInt projectsCancelled = 0.obs;

  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt inactiveUsers = 0.obs;

  final RxDouble averageCompletionRate = 0.0.obs;

  final RxList<Map<String, dynamic>> teamPerformance = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Récupérer les projets
      await _fetchProjectsStatistics();

      // Récupérer les utilisateurs
      await _fetchUsersStatistics();

      // Récupérer les performances des équipes
      await _fetchTeamPerformance();

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchProjectsStatistics() async {
    final QuerySnapshot projectsSnapshot = await _firestore.collection('projects').get();

    int inProgress = 0;
    int completed = 0;
    int cancelled = 0;
    double totalProgress = 0;

    for (var doc in projectsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['statut'] as String? ?? 'En attente';

      switch (status) {
        case 'En cours':
          inProgress++;
          break;
        case 'Terminés':
          completed++;
          break;
        case 'Annulés':
          cancelled++;
          break;
      }

      totalProgress += (data['progress'] as int? ?? 0);
    }

    totalProjects.value = projectsSnapshot.size;
    projectsInProgress.value = inProgress;
    projectsCompleted.value = completed;
    projectsCancelled.value = cancelled;

    // Calculer le taux moyen de complétion
    if (totalProjects.value > 0) {
      averageCompletionRate.value = totalProgress / totalProjects.value;
    }
  }

  Future<void> _fetchUsersStatistics() async {
    final QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

    int active = 0;
    int inactive = 0;

    for (var doc in usersSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final isActive = data['isActive'] as bool? ?? true;

      if (isActive) {
        active++;
      } else {
        inactive++;
      }
    }

    totalUsers.value = usersSnapshot.size;
    activeUsers.value = active;
    inactiveUsers.value = inactive;
  }

  Future<void> _fetchTeamPerformance() async {
    final QuerySnapshot projectsSnapshot = await _firestore.collection('projects').get();

    // Map pour stocker les performances par équipe
    Map<String, Map<String, dynamic>> teamStats = {};

    for (var doc in projectsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final memberRoles = data['memberRoles'] as Map<String, dynamic>? ?? {};

      // Pour chaque membre, mettre à jour ses statistiques
      memberRoles.forEach((userId, role) {
        if (!teamStats.containsKey(userId)) {
          teamStats[userId] = {
            'userId': userId,
            'totalProjects': 0,
            'completedProjects': 0,
            'progress': 0,
            'role': role
          };
        }

        teamStats[userId]!['totalProjects'] = teamStats[userId]!['totalProjects'] + 1;

        if (data['statut'] == 'Terminés') {
          teamStats[userId]!['completedProjects'] = teamStats[userId]!['completedProjects'] + 1;
        }

        teamStats[userId]!['progress'] = teamStats[userId]!['progress'] + (data['progress'] as int? ?? 0);
      });
    }

    // Calculer les performances moyennes
    teamStats.forEach((userId, stats) {
      if (stats['totalProjects'] > 0) {
        stats['averageProgress'] = stats['progress'] / stats['totalProjects'];
        stats['completionRate'] = stats['completedProjects'] / stats['totalProjects'];
      } else {
        stats['averageProgress'] = 0;
        stats['completionRate'] = 0;
      }
    });

    // Convertir la map en liste pour l'affichage
    teamPerformance.value = teamStats.values.toList();

    // Trier par taux de complétion décroissant
    teamPerformance.sort((a, b) =>
        (b['completionRate'] as double).compareTo(a['completionRate'] as double));
  }
}