import 'package:flutter/material.dart';
import '../../services/app_notification_service.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/loading_widget.dart';
import 'm4_ptraining_screen.dart';
import 'principal_leave_approval.dart';
import 'principal_duty_page.dart';
import 'principal_dashboard.dart';

class PrincipalNotificationScreen extends StatefulWidget {
  const PrincipalNotificationScreen({super.key});

  @override
  State<PrincipalNotificationScreen> createState() =>
      _PrincipalNotificationScreenState();
}

class _PrincipalNotificationScreenState
    extends State<PrincipalNotificationScreen> {
  final _service = AppNotificationService();

  bool _loading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.getPrincipalNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _openNotification(
      Map<String,dynamic> item
  ){
    final type = item['type'];
    switch(type){
      case 'training':
      Navigator.push(
        context,
          MaterialPageRoute(
            builder: (_) =>
              const PrincipalTrainingScreen(),
          ),
        );
        break;
      case 'leave':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
              const PrincipalLeaveApproval(),
          ),
        );
       break;
      case 'report':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
              PrincipalDashboard(),
          ),
        );
        break;
      default:
        break;
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'training_cancelled':
        return Icons.cancel_schedule_send;

      case 'training_completed':
        return Icons.verified;

      case 'training_application':
        return Icons.school;

      default:
        return Icons.notifications;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'training_cancelled':
        return Colors.red;

      case 'training_completed':
        return Colors.green;

      case 'training_application':
        return Colors.blue;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Notifications"),
      ),
      body: _loading
          ? const LoadingWidget()
          : _notifications.isEmpty
              ? const Center(
                  child: Text("No notifications."),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (_, index) {
                      final n = _notifications[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _color(n['type']).withOpacity(.12),
                            child: Icon(
                              _icon(n['type']),
                              color: _color(n['type']),
                            ),
                          ),
                          title: Text(
                            n['message'] ?? '',
                            style: TextStyle(
                              fontWeight:
                                  n['is_read'] == false
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            n['created_at'] ?? '',
                          ),
                          onTap: () async {
                            await _service.markAsRead(
                              n['id'].toString(),
                            );
                            _openNotification(n);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}