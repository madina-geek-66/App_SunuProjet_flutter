import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/constants_color.dart';
import '../../controllers/admin/dashboard_controller.dart';
import '../../controllers/authentification/auth_controller.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DashboardController dashboardController = Get.put(DashboardController());
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est admin
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    final user = authController.userModel.value;
    if (user == null || user.role != 'admin') {
      Get.offAllNamed('/home');
      Get.snackbar(
        'Accès refusé',
        'Vous n\'avez pas les autorisations nécessaires pour accéder à cette page.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Tableau de Bord Admin',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kWhiteColor),
            onPressed: () => dashboardController.fetchDashboardData(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
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
                  child: Icon(Icons.admin_panel_settings, size: 35, color: kPrimaryColor),
                ),
                const SizedBox(height: 10),
                Obx(() => Text(
                  authController.userModel.value?.fullName ?? 'Administrateur',
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                Obx(() => Text(
                  authController.userModel.value?.email ?? 'admin@email.com',
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
          _buildDrawerItem(Icons.people, 'Utilisateurs', '/users'),
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
          authController.logout(); // Déconnexion
        } else {
          Get.toNamed(route);
        }
      },
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (dashboardController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
      }

      return RefreshIndicator(
        onRefresh: dashboardController.fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dernière mise à jour: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 24),
              _buildProjectStatusChart(),
              const SizedBox(height: 24),
              _buildUserStatusChart(),
              const SizedBox(height: 24),
              _buildCompletionRateSection(),
              const SizedBox(height: 24),
              //_buildTeamPerformanceSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          'Projets',
          dashboardController.totalProjects.toString(),
          Icons.folder,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Utilisateurs',
          dashboardController.totalUsers.toString(),
          Icons.people,
          Colors.green,
        ),
        _buildSummaryCard(
          'Taux de Complétion',
          '${dashboardController.averageCompletionRate.value.toStringAsFixed(1)}%',
          Icons.pie_chart,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Projets Terminés',
          dashboardController.projectsCompleted.toString(),
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStatusChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projets par Statut',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      title: 'En cours',
                      value: dashboardController.projectsInProgress.toDouble(),
                      color: Colors.blue,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      title: 'Terminés',
                      value: dashboardController.projectsCompleted.toDouble(),
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      title: 'Annulés',
                      value: dashboardController.projectsCancelled.toDouble(),
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('En cours', Colors.blue, dashboardController.projectsInProgress.value),
                _buildLegendItem('Terminés', Colors.green, dashboardController.projectsCompleted.value),
                _buildLegendItem('Annulés', Colors.red, dashboardController.projectsCancelled.value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatusChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Utilisateurs par Statut',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      title: 'Actifs',
                      value: dashboardController.activeUsers.toDouble(),
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      title: 'Inactifs',
                      value: dashboardController.inactiveUsers.toDouble(),
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Actifs', Colors.green, dashboardController.activeUsers.value),
                _buildLegendItem('Inactifs', Colors.red, dashboardController.inactiveUsers.value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title ($value)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionRateSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Taux de Complétion Global',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 16.0,
              percent: dashboardController.averageCompletionRate.value / 100,
              center: Text(
                '${dashboardController.averageCompletionRate.value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: _getCompletionColor(dashboardController.averageCompletionRate.value),
              backgroundColor: Colors.grey[300]!,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Taux moyen de complétion de tous les projets',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }





  Color _getCompletionColor(double completion) {
    if (completion < 30) return Colors.red;
    if (completion < 70) return Colors.orange;
    return Colors.green;
  }
}