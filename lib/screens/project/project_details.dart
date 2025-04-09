import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:madina_diallo_l3gl_examen/config/constants_color.dart';
import 'package:madina_diallo_l3gl_examen/controllers/projet/projet_controller.dart';
import 'package:madina_diallo_l3gl_examen/models/projet.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/projet/projet_file_controller.dart';
import '../../controllers/projet/tache_controller.dart';
import '../../models/projet_file.dart';
import '../../models/tache_model.dart';
import 'add_member.dart';
import 'add_task.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> with SingleTickerProviderStateMixin {
  final ProjetController projetController = Get.find<ProjetController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Get.find<TacheController>().fetchTachesByProject(widget.projectId);
    Get.find<ProjetFileController>().fetchProjectFiles(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projet = projetController.projects.firstWhere(
            (p) => p.uid == widget.projectId,
        orElse: () => Projet(
          uid: '',
          titre: 'Projet non trouvé',
          description: '',
          dateDebut: DateTime.now(),
          dateFin: DateTime.now(),
          priorite: 'Moyenne',
          statut: 'En attente',
          progress: 0,
          ownerId: '',
          createdAt: DateTime.now(),
        ),
      );

      return Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            projet.titre,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Afficher un menu contextuel
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Aperçu'),
              Tab(text: 'Tâches'),
              Tab(text: 'Membres'),
              Tab(text: 'Fichiers'),
            ],
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(projet),
            _buildTasksTab(),
            _buildMembersTab(),
            _buildFilesTab(),
          ],
        ),
      );
    });
  }

  Widget _buildOverviewTab(Projet projet) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(projet),
          const SizedBox(height: 16),
          _buildProgressCard(projet),
          const SizedBox(height: 16),
          _buildStatusCard(projet),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Projet projet) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  projet.titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'En attente',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Priorité: ${projet.priorite}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              projet.description.isEmpty ? 'Plateforme de commerce en ligne' : projet.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Début: ${DateFormat('dd/MM/yyyy').format(projet.dateDebut)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Fin: ${DateFormat('dd/MM/yyyy').format(projet.dateFin)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Projet projet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avancement du projet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: 90.0,
                lineWidth: 13.0,
                animation: true,
                percent: projet.progress / 100,
                center: Text(
                  '${projet.progress}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.grey[200]!,
                progressColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Projet projet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changer le statut du projet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton('En attente', projet, Colors.orange),
                _buildStatusButton('En cours', projet, Colors.blue),
                _buildStatusButton('Terminé', projet, Colors.green),
                _buildStatusButton('Annulé', projet, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, Projet projet, Color color) {
    final isActive = projet.statut == status;

    return InkWell(
      onTap: () {
        projetController.updateProjectStatus(projet.uid, status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }




  Widget _buildMembersTab() {
    final currentUserId = projetController.currentUserId;
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: Obx(() {
        final projet = projetController.projects.firstWhere(
              (p) => p.uid == widget.projectId,
        );

        // Get all member IDs and roles from the project
        final memberRoles = projet.memberRoles;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchMembersData(memberRoles.keys.toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final membersData = snapshot.data ?? [];

            return ListView.builder(
              itemCount: membersData.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final memberData = membersData[index];
                final memberId = memberData['userId'] as String;
                final memberName = memberData['fullName'] as String? ?? memberId.split('@').first;
                final memberEmail = memberData['email'] as String? ?? memberId;
                final memberRole = memberRoles[memberId] ?? "Membre d'équipe";
                final bool isCurrentUser = memberId == currentUserId;

                return _buildMemberCard(
                  memberId: memberId,
                  memberName: memberName,
                  memberEmail: memberEmail,
                  memberRole: memberRole,
                  isCurrentUser: isCurrentUser,
                  projectId: projet.uid,
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Modification ici - utiliser await avec Get.to pour attendre le retour
          await Get.to(() => AddMemberPage(projectId: widget.projectId));

          // Ajouter un rafraîchissement explicite des données du projet
          await projetController.fetchUserProjects();
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMemberCard({
    required String memberId,
    required String memberName,
    required String memberEmail,
    required String memberRole,
    required bool isCurrentUser,
    required String projectId,
  }) {

    final String avatarLetter = memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U';

    // Map the role to display text and color
    String displayRole;
    Color roleColor;

    switch (memberRole) {
      case "Chef de projet":
        displayRole = "Créateur";
        roleColor = Colors.orange;
        break;
      case "Administrateur":
        displayRole = "Admin";
        roleColor = Colors.blue;
        break;
      case "Membre d'équipe":
      default:
        displayRole = "Membre";
        roleColor = Colors.green;
        break;
    }

    // Generate a consistent color for the avatar based on the name
    final int nameHash = memberName.hashCode.abs();
    final List<Color> avatarColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    final Color avatarColor = avatarColors[nameHash % avatarColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Member info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with (Vous) if current user
                  Text(
                    isCurrentUser
                        ? '$memberName (Vous)'
                        : memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Email
                  Text(
                    memberEmail,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Role button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayRole,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMembersData(List<String> memberIds) async {
    final firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> membersData = [];

    for (final memberId in memberIds) {
      try {
        final doc = await firestore.collection('users').doc(memberId).get();
        if (doc.exists) {
          final data = doc.data() ?? {};
          membersData.add({
            'userId': memberId,
            'fullName': data['fullName'] ?? memberId.split('@').first,
            'email': data['email'] ?? memberId,
          });
        } else {
          // User document not found, use member ID as fallback
          membersData.add({
            'userId': memberId,
            'fullName': memberId.split('@').first,
            'email': memberId,
          });
        }
      } catch (e) {
        // Handle error, use member ID as fallback
        membersData.add({
          'userId': memberId,
          'fullName': memberId.split('@').first,
          'email': memberId,
        });
      }
    }

    return membersData;
  }

  Widget _buildFilesTab() {
    final ProjetFileController projetFileController = Get.find<ProjetFileController>();
    final currentUserId = Get.find<ProjetController>().currentUserId;
    final projet = Get.find<ProjetController>().projects.firstWhere(
          (p) => p.uid == widget.projectId,
    );

    // Déterminer le rôle de l'utilisateur actuel
    final userRole = projet.memberRoles[currentUserId] ?? "Membre d'équipe";


    return Scaffold(
      body: Obx(() {
        if (projetFileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => projetFileController.fetchProjectFiles(widget.projectId),
          child: Column(
            children: [
              // Bouton Ajouter un fichier
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => projetFileController.pickAndUploadFile(
                      widget.projectId,
                      userRole
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ajouter un fichier', style: TextStyle(fontSize: 16)),
                ),
              ),

              // Liste des fichiers
              Expanded(
                child: projetFileController.projectFiles.isEmpty
                    ? const Center(child: Text('Aucun fichier pour ce projet'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: projetFileController.projectFiles.length,
                  itemBuilder: (context, index) {
                    final file = projetFileController.projectFiles[index];

                    return FutureBuilder<String>(
                      future: projetFileController.getUserName(file.ajoutePar),
                      builder: (context, snapshot) {
                        final String userName = snapshot.data ?? file.ajoutePar.split('@').first;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: _getFileIcon(file.type),
                            title: Text(file.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Ajouté par: $userName'),
                                Text('Taille: ${file.taille.toStringAsFixed(1)} MB • ${_formatDate(file.dateAjout)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.blue),
                                  onPressed: () => _downloadFile(file),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: (userRole == "Chef de projet" || userRole == "Administrateur")
                                      ? () => projetFileController.deleteFile(file)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

// Mise à jour de la méthode de téléchargement pour fonctionner avec Supabase



  Future<void> _downloadFile(ProjetFile file) async {
    try {
      // Vérifier si l'URL peut être lancée
      final Uri uri = Uri.parse(file.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir ce fichier',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Erreur de téléchargement: $e");
      Get.snackbar(
        'Erreur',
        'Erreur lors du téléchargement: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case '.pdf':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
        );
      case '.doc':
      case '.docx':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: Colors.blue, size: 28),
        );
      case '.xlsx':
      case '.xls':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.table_chart, color: Colors.green, size: 28),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.insert_drive_file, color: Colors.grey, size: 28),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }


  Widget _buildTasksTab() {
    final TacheController tacheController = Get.find<TacheController>();
    final currentUserId = projetController.currentUserId;
    final projet = projetController.projects.firstWhere(
          (p) => p.uid == widget.projectId,
    );

    // Déterminer le rôle de l'utilisateur actuel
    final userRole = projet.memberRoles[currentUserId] ?? "Membre d'équipe";
    final bool canEdit = userRole == "Chef de projet" || userRole == "Administrateur";

    return Scaffold(
      body: Obx(() {
        if (tacheController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final taches = tacheController.taches;

        return RefreshIndicator(
          onRefresh: () => tacheController.fetchTachesByProject(widget.projectId),
          child: taches.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aucune tâche pour ce projet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez une tâche pour commencer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: taches.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final tache = taches[index];
              return _buildTaskCard(tache, canEdit);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddTaskPage(projectId: widget.projectId));
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  Widget _buildTaskCard(Tache tache, bool canEdit) {
    final TacheController tacheController = Get.find<TacheController>();

    // Déterminer la couleur en fonction de la priorité
    Color priorityColor;
    switch (tache.priorite) {
      case 'Basse':
        priorityColor = Colors.green;
        break;
      case 'Moyenne':
        priorityColor = Colors.blue;
        break;
      case 'Haute':
        priorityColor = Colors.orange;
        break;
      case 'Urgente':
        priorityColor = Colors.red;
        break;
      default:
        priorityColor = Colors.blue;
    }

    // Déterminer la couleur en fonction du statut
    Color statusColor;
    switch (tache.statut) {
      case 'A faire':
        statusColor = Colors.grey;
        break;
      case 'En cours':
        statusColor = Colors.blue;
        break;
      case 'Terminé':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          tache.titre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tache.priorite,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tache.statut,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Date limite: ${tacheController.formatDate(tache.dateLimite)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.2),
          child: Text(
            tache.titre.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: priorityColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tache.progression}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tache.description.isEmpty
                      ? 'Aucune description disponible'
                      : tache.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                const Text(
                  'Progression',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: tache.progression / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    tache.progression < 30
                        ? Colors.red
                        : tache.progression < 70
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tache.progression}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (canEdit)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 18),
                            onPressed: tache.progression <= 0
                                ? null
                                : () {
                              final newProgress = (tache.progression - 10).clamp(0, 100);
                              tacheController.updateTacheProgression(tache.uid, newProgress);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            onPressed: tache.progression >= 100
                                ? null
                                : () {
                              final newProgress = (tache.progression + 10).clamp(0, 100);
                              tacheController.updateTacheProgression(tache.uid, newProgress);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Membres assignés
                const Text(
                  'Membres assignés',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<Map<String, String>>(
                  future: tacheController.getAssignedUsersNames(tache.assignesIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final usersMap = snapshot.data ?? {};

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tache.assignesIds.map((userId) {
                        final userName = usersMap[userId] ?? userId.split('@').first;
                        final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

                        // Générer une couleur cohérente basée sur le nom
                        final int nameHash = userName.hashCode.abs();
                        final List<Color> avatarColors = [
                          Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                          Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                          Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                          Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
                        ];
                        final Color avatarColor = avatarColors[nameHash % avatarColors.length];

                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: avatarColor,
                            child: Text(
                              avatarLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: Text(userName),
                          backgroundColor: Colors.grey[100],
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Actions (changer le statut)
                if (canEdit) ...[
                  const Text(
                    'Changer le statut',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusTacheButton('A faire', tache, Colors.grey),
                      _buildStatusTacheButton('En cours', tache, Colors.blue),
                      _buildStatusTacheButton('Terminé', tache, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Discussion
                const Text(
                  'Discussion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // Liste des commentaires
                ...tache.discussions.isNotEmpty
                    ? tache.discussions.map((comment) => _buildCommentItem(comment))
                    : [
                  Center(
                    child: Text(
                      'Aucun commentaire',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                // Ajouter un commentaire
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ajouter un commentaire...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            tacheController.addCommentToTache(
                              tache.uid,
                              projetController.currentUserId,
                              value,
                            );
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: kPrimaryColor),
                      onPressed: () {
                        // Implémenté via onSubmitted pour simplifier
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTacheButton(String status, Tache tache, Color color) {
    final TacheController tacheController = Get.find<TacheController>();
    final isActive = tache.statut == status;

    return InkWell(
      onTap: () {
        tacheController.updateTacheStatus(tache.uid, status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final TacheController tacheController = Get.find<TacheController>();
    final String userId = comment['userId'] ?? '';
    final String message = comment['message'] ?? '';
    final DateTime date = comment['date'] is DateTime
        ? comment['date']
        : (comment['date'] is Timestamp
        ? (comment['date'] as Timestamp).toDate()
        : DateTime.now());

    return FutureBuilder<Map<String, String>>(
      future: tacheController.getAssignedUsersNames([userId]),
      builder: (context, snapshot) {
        final String userName = snapshot.data?[userId] ?? userId.split('@').first;
        final String avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        // Générer une couleur cohérente basée sur le nom
        final int nameHash = userName.hashCode.abs();
        final List<Color> avatarColors = [
          Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
          Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
          Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
          Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
        ];
        final Color avatarColor = avatarColors[nameHash % avatarColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarColor,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(date),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}