// import 'package:flutter/material.dart';

<<<<<<< Updated upstream
import '../../features/teachers/teacher_list_page.dart';
import '../leave/apply_leave_page.dart';
import '../leave/leave_list_page.dart';
=======
// import '../../features/teachers/teacher_list_page.dart';
// import '../leave/apply_leave_page.dart';
// import '../leave/leave_list_page.dart';
>>>>>>> Stashed changes
// import '../../presentation/principal/leave_approval_page.dart';

// class MainNavigationPage extends StatefulWidget {
//   const MainNavigationPage({super.key});

//   @override
//   State<MainNavigationPage> createState() =>
//       _MainNavigationPageState();
// }

// class _MainNavigationPageState
//     extends State<MainNavigationPage> {

//   int currentIndex = 0;

//   final pages = [
//     const TeacherListPage(),
//     const ApplyLeavePage(),
//     const LeaveListPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex],

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,

//         onTap: (index) {
//           setState(() {
//             currentIndex = index;
//           });
//         },

//         items: const [

//           BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: "Teachers",
//           ),

//           BottomNavigationBarItem(
//             icon: Icon(Icons.event_note),
//             label: "Apply Leave",
//           ),

//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: "My Leaves",
//           ),
//         ],
//       ),
//     );
//   }
// }