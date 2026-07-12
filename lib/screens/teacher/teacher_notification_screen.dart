import 'package:flutter/material.dart';
import '../../services/app_notification_service.dart';
import 'm4_ttraining_screen.dart';
import 'teacher_leave_module.dart';
import 'teacher_duty_page.dart';
import '../../models/teacher_model.dart';

class TeacherNotificationScreen extends StatefulWidget {

  final TeacherModel teacher;

  const TeacherNotificationScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherNotificationScreen> createState() =>
      _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {

  final _service = AppNotificationService();

  List<Map<String, dynamic>> notifications = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    loadNotifications();
  }


  Future<void> loadNotifications() async {
    final data = await _service.getMyNotifications();

    if (!mounted) return;

    setState(() {
      notifications = data;
      loading = false;
    });
  }

  void _openNotification(Map<String, dynamic> item) {
    final type = item['type'];

    switch (type) {
      case 'training':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherTrainingScreen(
              teacherId: widget.teacher.authId,
            ),
          ),
        );
        break;
      case 'leave':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherLeaveModule(
              teacherId: widget.teacher.id,
            ),
          ),
        );
        break;
      case 'task':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherDutyPage(
              teacher: widget.teacher,
            ),
          ),
        );
        break;
      default:
        break;
    }

    // optional: mark as read after opening
    if (!(item['is_read'] ?? false)) {
      markRead(item['id'].toString());
    }
}


  Future<void> markRead(String id) async {
    await _service.markAsRead(id);

    loadNotifications();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                  ),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,

                  itemBuilder: (context, index){

                    final item = notifications[index];

                    final bool isRead =
                        item['is_read'] ?? false;
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _openNotification(item);
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: isRead
                                ? Colors.grey
                                : Colors.blue,
                          ),
                          title: Text(
                            item['message'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          trailing: isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  onPressed: (){
                                    markRead(
                                      item['id'].toString(),
                                    );
                                  },
                                ),
                          ),
                      ),
                    );
                  },
                ),
    );
  }
}