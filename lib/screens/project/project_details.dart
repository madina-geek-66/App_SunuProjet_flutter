import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:madina_diallo_l3gl_examen/config/constants_color.dart';
import 'package:madina_diallo_l3gl_examen/controllers/projet/projet_controller.dart';
import 'package:madina_diallo_l3gl_examen/models/projet.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: Colors.grey[50],
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
                      fontSize: 12,
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

  // Onglets supplémentaires
  Widget _buildTasksTab() {
    return const Center(
      child: Text('Contenu de l\'onglet Tâches à implémenter'),
    );
  }

  // Widget _buildMembersTab() {
  //   return const Center(
  //     child: Text('Contenu de l\'onglet Membres à implémenter'),
  //   );
  // }

  Widget _buildMembersTab() {
    final currentUserId = projetController.currentUserId;
    final firestore = FirebaseFirestore.instance;

    return Obx(() {
      final projet = projetController.projects.firstWhere(
            (p) => p.uid == widget.projectId,
        // orElse: () => Projet(
        //   uid: '',
        //   titre: 'Projet non trouvé',
        //   description: '',
        //   dateDebut: DateTime.now(),
        //   dateFin: DateTime.now(),
        //   priorite: 'Moyenne',
        //   statut: 'En attente',
        //   progress: 0,
        //   ownerId: '',
        //   createdAt: DateTime.now(),
        // ),
      );

      // Get all member IDs and roles from the project
      final memberRoles = projet.memberRoles;

      // if (memberRoles.isEmpty) {
      //   return const Center(
      //     child: Text(
      //       'Aucun membre dans ce projet',
      //       style: TextStyle(fontSize: 16, color: Colors.black54),
      //     ),
      //   );
      // }

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
    });
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
    return const Center(
      child: Text('Contenu de l\'onglet Fichiers à implémenter'),
    );
  }
}