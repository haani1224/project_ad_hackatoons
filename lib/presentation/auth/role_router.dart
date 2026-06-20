// <<<<<<< Updated upstream
// import 'package:flutter/material.dart';
// import '../../presentation/leave/apply_leave_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../data/services/auth_service.dart';
// import '../../features/teachers/teacher_list_page.dart';
// import '../../features/auth/login_page.dart';
// =======
// // import 'package:flutter/material.dart';
// // import 'package:project_ad_hackatoons/presentation/leave/apply_leave_page.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // import '../../data/services/auth_service.dart';
// // import '../../features/teachers/teacher_list_page.dart';
// // import '../principal/leave_approval_page.dart';
// // import '../../features/auth/login_page.dart';
// >>>>>>> Stashed changes

// // class RoleRouter extends StatefulWidget {
// //   const RoleRouter({super.key});

// //   @override
// //   State<RoleRouter> createState() => _RoleRouterState();
// // }

// // class _RoleRouterState extends State<RoleRouter> {
// //   final auth = AuthService();

// //   bool loading = true;
// //   String? role;
// //   String? status;

// //   @override
// //   void initState() {
// //     super.initState();
// //     init();
// //   }

// //   Future init() async {
// //     final user = Supabase.instance.client.auth.currentUser;

// //     if (user == null) {
// //       setState(() => loading = false);
// //       return;
// //     }

// //     role = await auth.getUserRole(user.id);
// //     status = await auth.getUserStatus(user.id);

// //     setState(() => loading = false);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (loading) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     final user = Supabase.instance.client.auth.currentUser;

// //     if (user == null) {
// //       return const LoginPage(); // fallback
// //     }

// //     // ❌ BLOCK IF PENDING
// //     if (status == "pending") {
// //       return const Scaffold(
// //         body: Center(
// //           child: Text("Your account is pending approval"),
// //         ),
// //       );
// //     }

// //     // 👨‍🏫 TEACHER DASHBOARD
// //     if (role == "teacher") {
// //       return const ApplyLeavePage();
// //     }

// //     // 👨‍💼 PRINCIPAL DASHBOARD
// //     if (role == "principal") {
// //       return const TeacherListPage();
// //     }

// //     return const Scaffold(
// //       body: Center(child: Text("No role assigned")),
// //     );
// //   }
// // }