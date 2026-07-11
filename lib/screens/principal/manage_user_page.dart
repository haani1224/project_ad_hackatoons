import 'package:flutter/material.dart';

import 'principal_main_page.dart';
import '../../services/user_service.dart';
import '../../widgets/user_card.dart';
import '../../utils/constants.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final UserService userService = UserService();

  int selectedIndex = 0;

  final List<String> tabs = [
    'Users',
    'Applications',
    'Deactivate',
  ];

  late Future<List<Map<String, dynamic>>> futureUsers;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() {
    futureUsers = userService.getUsers();
  }

  void refresh() {
    setState(loadUsers);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 78,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Manage Teachers',
          style: AppTextStyles.pageTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrincipalMainPage(),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
      ),
      bottomNavigationBar:
          isMobile ? _mobileNavigation() : null,
      body: isMobile
          ? _buildContent()
          : Row(
              children: [
                Container(
                  width: 265,
                  margin: const EdgeInsets.all(18),
                  decoration: AppDecorations.card,
                  child: _desktopMenu(),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _mobileNavigation() {
    return NavigationBar(
      height: 72,
      selectedIndex: selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.accentLight,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(
            Icons.people_rounded,
            color: AppColors.primary,
          ),
          label: 'Users',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_add_alt_1_outlined),
          selectedIcon: Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.primary,
          ),
          label: 'Applications',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_off_outlined),
          selectedIcon: Icon(
            Icons.person_off_rounded,
            color: AppColors.primary,
          ),
          label: 'Deactivate',
        ),
      ],
    );
  }

  Widget _desktopMenu() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final selected = selectedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(
              _tabIcon(index),
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            title: Text(
              tabs[index],
              style: AppTextStyles.body.copyWith(
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            onTap: () {
              setState(() => selectedIndex = index);
            },
          ),
        );
      },
    );
  }

  IconData _tabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.people_rounded;
      case 1:
        return Icons.person_add_alt_1_rounded;
      default:
        return Icons.person_off_rounded;
    }
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _viewUsers();
      case 1:
        return _applications();
      case 2:
        return _deactivateDelete();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFutureUserList({
    required Widget Function(Map<String, dynamic> user) itemBuilder,
    bool Function(Map<String, dynamic> user)? filter,
    required String title,
    required String subtitle,
    String emptyMessage = 'No users found',
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final originalUsers = snapshot.data ?? [];

        final users = filter == null
            ? originalUsers
            : originalUsers.where(filter).toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            refresh();
            await futureUsers;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            children: [
              Text(title, style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.caption),
              const SizedBox(height: 20),
              _summaryBanner(
                total: users.length,
                icon: _tabIcon(selectedIndex),
              ),
              const SizedBox(height: 22),
              if (users.isEmpty)
                _emptyState(emptyMessage)
              else
                ...users.map(itemBuilder),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryBanner({
    required int total,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Text(
            '$total',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.accent,
              fontSize: 27,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            tabs[selectedIndex],
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewUsers() {
    return _buildFutureUserList(
      title: 'Teacher Directory',
      subtitle: 'View all registered preschool teachers.',
      filter: (user) =>
          user['role'] == 'teacher' &&
          user['status'] != 'deleted',
      itemBuilder: (user) {
        return UserCard(
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          status: user['status'] ?? '',
        );
      },
    );
  }

  Widget _applications() {
    return _buildFutureUserList(
      title: 'Applications',
      subtitle: 'Review new teacher registration applications.',
      emptyMessage: 'No pending applications',
      filter: (user) =>
          user['role'] == 'teacher' &&
          user['status'] == 'pending',
      itemBuilder: (user) {
        return UserCard(
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          status: user['status'] ?? '',
          actions: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await userService.approveUser(user['id']);
                  refresh();
                  _showMessage('Application approved');
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Approve'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                onPressed: () async {
                  await userService.rejectUser(user['id']);
                  refresh();
                  _showMessage('Application rejected');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deactivateDelete() {
    return _buildFutureUserList(
      title: 'Deactivate Teachers',
      subtitle:
          'Temporarily deactivate or remove active teacher accounts.',
      emptyMessage: 'No active teachers found',
      filter: (user) =>
          user['role'] == 'teacher' &&
          user['status'] == 'active',
      itemBuilder: (user) {
        return UserCard(
          name: user['name'] ?? '',
          email: user['email'] ?? '',
          status: user['status'] ?? '',
          actions: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: const BorderSide(
                      color: AppColors.warning,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await userService.deactivateUser(user['id']);
                    refresh();

                    _showMessage('Teacher deactivated');
                  },
                  icon: const Icon(
                    Icons.pause_circle_outline_rounded,
                    size: 19,
                  ),
                  label: const Text('Deactivate'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _confirmDelete(user),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                  ),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    Map<String, dynamic> user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Delete Teacher?',
            style: AppTextStyles.sectionTitle,
          ),
          content: Text(
            'Are you sure you want to remove ${user['name']}?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await userService.deleteUser(user['id']);
    refresh();

    if (!mounted) return;

    _showMessage('Teacher deleted');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}