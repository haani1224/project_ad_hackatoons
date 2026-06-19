import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';
import 'add_teacher_page.dart';
import 'teacher_detail_page.dart';
import '../test/edit_teacher_page.dart';
import '../../presentation/widgets/app_drawer.dart';

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State {
  final repo = TeacherRepository();

  List teachers = [];
  List filteredTeachers = [];

  bool loading = true;

  final searchController = TextEditingController();

  String filterStatus = "all"; // all, pending, approved

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  Future loadTeachers() async {
    final data = await repo.getTeachers();

    setState(() {
      teachers = data;
      applyFilters();
      loading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        final matchSearch =
            teacher.fullName.toLowerCase().contains(searchController.text.toLowerCase()) ||
            teacher.icNumber.contains(searchController.text);

        final matchStatus =
            filterStatus == "all" || teacher.status == filterStatus;

        return matchSearch && matchStatus;
      }).toList();
    });
  }

  void search(String keyword) {
    applyFilters();
  }

  void changeFilter(String status) {
    setState(() {
      filterStatus = status;
      applyFilters();
    });
  }

  Future deleteTeacher(String id) async {
    await repo.deleteTeacher(id);
    loadTeachers();
  }

  Future goToAddTeacher() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTeacherPage(),
      ),
    );

    if (result == true) {
      loadTeachers();
    }
  }

  Future goToDetail(TeacherModel teacher) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherDetailPage(teacher: teacher),
      ),
    );
  }

  Future goToEdit(TeacherModel teacher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTeacherPage(teacher: teacher),
      ),
    );

    if (result == true) {
      loadTeachers();
    }
  }

  Future approveTeacher(String id) async {
    await repo.updateTeacherStatus(id, "approved");
    loadTeachers();
  }

  String getInitial(String name) {
    if (name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  Widget statusChip(String label) {
    final isSelected = filterStatus == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(label.toUpperCase()),
        selected: isSelected,
        onSelected: (_) => changeFilter(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teachers"),
      ),

      drawer: const AppDrawer(
          role: "principal",
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: goToAddTeacher,
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // SEARCH
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: "Search Name / IC",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // FILTER STATUS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      statusChip("all"),
                      statusChip("pending"),
                      statusChip("approved"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // LIST
                Expanded(
                  child: filteredTeachers.isEmpty
                      ? const Center(child: Text("No Teachers Found"))
                      : ListView.builder(
                          itemCount: filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = filteredTeachers[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: ListTile(
                                onTap: () => goToDetail(teacher),

                                leading: CircleAvatar(
                                  child: Text(getInitial(teacher.fullName)),
                                ),

                                title: Text(teacher.fullName ?? '-'),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("IC: ${teacher.icNumber}"),
                                    Text(
                                      "Status: ${teacher.status}",
                                      style: TextStyle(
                                        color: teacher.status == "approved"
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // APPROVE BUTTON (ONLY PENDING)
                                    if (teacher.status == "pending")
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            approveTeacher(teacher.id!),
                                      ),

                                    // EDIT
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          goToEdit(teacher),
                                    ),

                                    // DELETE
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: const Text("Delete Teacher"),
                                              content: const Text("Are you sure?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await deleteTeacher(
                                                        teacher.id!);
                                                  },
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}