import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late AuthProvider _authProvider;
  late ProjectProvider _projectProvider;
  late TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _projectProvider = ProjectProvider();
    _taskProvider = TaskProvider();
    _loadData();
  }

  Future<void> _loadData() async {
    await _authProvider.init();
    final user = StorageService.instance.getCurrentUser();
    if (user != null) {
      await _projectProvider.loadProjects(user.id);
      await _taskProvider.loadTasksByUser(user.id);
    }
  }

  Future<void> _logout() async {
    await _authProvider.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authProvider,
      builder: (context, _) {
        final user = _authProvider.currentUser ??
            StorageService.instance.getCurrentUser();
        final userName = user?.name ?? '';
        final userEmail = user?.email ?? '';
        final avatarLetter =
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

        return Scaffold(
          appBar: AppBar(
            title: Text(_tabTitle(_currentIndex)),
          ),
          drawer: _buildDrawer(avatarLetter, userName, userEmail),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardTab(
                projectProvider: _projectProvider,
                taskProvider: _taskProvider,
                userName: userName,
              ),
              ProjectsTab(
                projectProvider: _projectProvider,
                taskProvider: _taskProvider,
              ),
              TasksTab(taskProvider: _taskProvider),
              ProfileTab(
                authProvider: _authProvider,
                projectProvider: _projectProvider,
                taskProvider: _taskProvider,
                onLogout: _logout,
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Tableau de bord',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: AppStrings.projects,
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist),
                label: AppStrings.tasks,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: AppStrings.profile,
              ),
            ],
          ),
          floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
              ? FloatingActionButton(
            onPressed: () async {
              final user = StorageService.instance.getCurrentUser();
              if (user == null) return;
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProjectFormScreen(userId: user.id),
                ),
              );
              if (result == true) {
                await _projectProvider.loadProjects(user.id);
                await _taskProvider.loadTasksByUser(user.id);
              }
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          )
              : null,
        );
      },
    );
  }

  String _tabTitle(int index) {
    switch (index) {
      case 0:
        return 'Tableau de bord';
      case 1:
        return AppStrings.projects;
      case 2:
        return AppStrings.tasks;
      case 3:
        return AppStrings.profile;
      default:
        return AppStrings.appName;
    }
  }

  Widget _buildDrawer(
      String avatarLetter, String userName, String userEmail) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration:
            const BoxDecoration(color: AppColors.primary),
            accountName: Text(userName,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          _drawerItem(Icons.dashboard_outlined, 'Tableau de bord', 0),
          _drawerItem(Icons.folder_outlined, AppStrings.projects, 1),
          _drawerItem(Icons.checklist_outlined, AppStrings.tasks, 2),
          _drawerItem(Icons.person_outline, AppStrings.profile, 3),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(AppStrings.logout,
                style: TextStyle(color: AppColors.error)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon,
          color: _currentIndex == index
              ? AppColors.primary
              : AppColors.textSecondary),
      title: Text(label,
          style: TextStyle(
            color: _currentIndex == index
                ? AppColors.primary
                : AppColors.textPrimary,
            fontWeight: _currentIndex == index
                ? FontWeight.w700
                : FontWeight.normal,
          )),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
