// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../features/teachers/teacher_list_page.dart';
// import '../leave/apply_leave_page.dart';
// import '../../features/auth/login_page.dart';
// import '../../presentation/principal/leave_approval_page.dart';

// class AppDrawer extends StatelessWidget {
//   final String role;

//   const AppDrawer({
//     super.key,
//     required this.role,
//   });

//   void logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           const UserAccountsDrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.orange,
//             ),
//             accountName: Text("Teacher System"),
//             accountEmail: Text("Logged in user"),
//           ),

//           // =========================
//           // TEACHER MENU
//           // =========================
//           if (role == "teacher") ...[
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text("My Profile"),
//               onTap: () {},
//             ),

//             ListTile(
//               leading: const Icon(Icons.beach_access),
//               title: const Text("Apply Leave"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ApplyLeavePage(),
//                   ),
//                 );
//               },
//             ),
//           ],

//           // =========================
//           // PRINCIPAL / ADMIN MENU
//           // =========================
//           if (role == "principal") ...[
//             ListTile(
//               leading: const Icon(Icons.people),
//               title: const Text("Teacher List"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const TeacherListPage(),
//                   ),
//                 );
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.how_to_reg),
//               title: const Text("Leave Approval"),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const LeaveApprovalPage(),
//                   ),
//                 );
//               },
//             ),
//           ],

//           const Divider(),

//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Logout"),
//             onTap: () => logout(context),
//           ),
//         ],
//       ),
//     );
//   }
// }