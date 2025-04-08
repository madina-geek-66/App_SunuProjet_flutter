import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/screens/project/create_project.dart';
import '../config/constants_color.dart';
import '../controllers/authentification/auth_controller.dart';
import '../controllers/projet/projet_controller.dart';
import '../models/projet.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  //static const String routeName = '/home';
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ProjetController projetController = Get.put(ProjetController());
  int currentTabIndex = 0;
  List<String> statusTabs = ['En attente', 'En cours', 'Terminés', 'Annulés'];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les projets au démarrage
    projetController.fetchUserProjects();
  }

  void changeTab(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  void filterProjects(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'SunuProjet',
          style: TextStyle(
            color: kWhiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: kWhiteColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran de création de projet avec GetX
          Get.to(() => const CreateProject());
        },
        backgroundColor: kSecondaryColor,
        child: const Icon(Icons.add, color: kWhiteColor),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kPrimaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: kWhiteColor,
                  child: Icon(Icons.person, size: 35, color: kPrimaryColor),
                ),
                const SizedBox(height: 10),
                Obx(() => Text(
                  Get.find<AuthController>().userModel.value?.fullName ?? 'Utilisateur',
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                Obx(() => Text(
                  Get.find<AuthController>().userModel.value?.email ?? 'utilisateur@email.com',
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontSize: 14,
                  ),
                )),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Tableau de bord', '/dashboard'),
          _buildDrawerItem(Icons.description, 'Projets', '/projects'),
          _buildDrawerItem(Icons.people, 'Équipe', '/team'),
          _buildDrawerItem(Icons.settings, 'Paramètres', '/settings'),
          const Divider(),
          _buildDrawerItem(Icons.help_outline, 'Aide', '/help'),
          _buildDrawerItem(Icons.logout, 'Déconnexion', '/logout'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {
        Get.back();
        if (route == '/logout') {
          Get.find<AuthController>().logout(); // Déconnexion
        } else {
          Get.toNamed(route);
        }
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabs(),
        _buildSearchBar(),
        Expanded(child: _buildProjectsList()),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      color: kPrimaryColor,
      child: Row(
        children: List.generate(
          statusTabs.length,
              (index) => _buildTab(statusTabs[index], index),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: currentTabIndex == index ? kWhiteColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: kWhiteColor,
                fontWeight: currentTabIndex == index ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: filterProjects,
        decoration: InputDecoration(
          hintText: 'Rechercher un projet...',
          prefixIcon: const Icon(Icons.search, color: kGreyColor),
          filled: true,
          fillColor: kWhiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return Obx(() {
      if (projetController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
      }

      // Utiliser getProjectsByStatus pour obtenir les projets par statut
      final projects = projetController.getProjectsByStatus(statusTabs[currentTabIndex]);

      // Filtrer les projets selon la recherche
      final filteredProjects = searchQuery.isEmpty
          ? projects
          : projects.where((project) =>
      project.titre.toLowerCase().contains(searchQuery) ||
          project.description.toLowerCase().contains(searchQuery)).toList();

      if (filteredProjects.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_outlined, size: 80, color: kGreyColor),
              const SizedBox(height: 16),
              Text(
                  'Aucun projet ${statusTabs[currentTabIndex].toLowerCase()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              const Text(
                  'Créez un nouveau projet pour commencer',
                  style: TextStyle(fontSize: 14, color: Colors.black54)
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Espace pour le FAB
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          final project = filteredProjects[index];
          return _buildProjectCard(project);
        },
      );
    });
  }

  Widget _buildProjectCard(Projet project) {
    // Déterminer la couleur de priorité
    Color priorityColor;
    String priorityLabel;

    switch (project.priorite.toLowerCase()) {
      case 'haute':
        priorityColor = Colors.orange;
        priorityLabel = 'Haute';
        break;
      case 'urgente':
        priorityColor = Colors.red;
        priorityLabel = 'Urgente';
        break;
      case 'basse':
        priorityColor = Colors.green;
        priorityLabel = 'Basse';
        break;
      default:
        priorityColor = Colors.blue;
        priorityLabel = 'Moyenne';
    }

    // Formater la date
    String formattedDate = DateFormat('dd/MM/yyyy').format(project.dateFin);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed('/project-details/${project.uid}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      priorityLabel,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${project.progress}% terminé',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        'Échéance: $formattedDate',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: project.progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(project.progress),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: kPrimaryColor,
                        child: Icon(Icons.person, size: 14, color: kWhiteColor),
                      ),
                      const SizedBox(width: 8),
                      // Vous pouvez ajouter d'autres avatars de membres ici si nécessaire
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}