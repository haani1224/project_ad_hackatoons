import 'package:flutter/material.dart';
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
    "View Users",
    "Applications",
    "Deactivate/Delete",
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
    setState(() {
      loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(tabs[selectedIndex]),
      ),
      drawer: isMobile ? Drawer(child: _buildMenu(isMobile: true)) : null,
      body: isMobile
          ? _buildContent()
          : Row(
              children: [
                Container(
                  width: 260,
                  color: Colors.white,
                  child: _buildMenu(isMobile: false),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildMenu({required bool isMobile}) {
    return SafeArea(
      child: ListView.builder(
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.primary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                if (isMobile) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
    );
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
    String emptyMessage = "No users found",
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: Text(emptyMessage));
        }

        final users = filter == null
            ? snapshot.data!
            : snapshot.data!.where(filter).toList();

        if (users.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return itemBuilder(users[index]);
            },
          ),
        );
      },
    );
  }

  Widget _viewUsers() {
    return _buildFutureUserList(
      itemBuilder: (user) {
        return UserCard(
          name: user["name"] ?? "",
          email: user["email"] ?? "",
          status: user["status"] ?? "",
        );
      },
    );
  }

  Widget _applications() {
    return _buildFutureUserList(
      emptyMessage: "No pending applications",
      filter: (user) => user["status"] == "pending",
      itemBuilder: (user) {
        return UserCard(
          name: user["name"] ?? "",
          email: user["email"] ?? "",
          status: user["status"] ?? "",
          actions: Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await userService.approveUser(user["id"]);
                  refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Application approved")),
                  );
                },
                child: const Text("Approve"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await userService.rejectUser(user["id"]);
                  refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Application rejected")),
                  );
                },
                child: const Text("Reject"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deactivateDelete() {
    return _buildFutureUserList(
      emptyMessage: "No active teachers found",
      filter: (user) => user["status"] == "active",
      itemBuilder: (user) {
        return UserCard(
          name: user["name"] ?? "",
          email: user["email"] ?? "",
          status: user["status"] ?? "",
          actions: Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () async {
                  await userService.deactivateUser(user["id"]);
                  refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User deactivated")),
                  );
                },
                child: const Text("Deactivate"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await userService.deleteUser(user["id"]);
                  refresh();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User deleted")),
                  );
                },
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
    );
  }
}