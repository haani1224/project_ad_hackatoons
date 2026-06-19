import '../models/teacher_model.dart';
import '../models/leave_model.dart';

class LeaveValidationService {
  static String? validateLeave(
    TeacherModel teacher,
    LeaveModel request,
    String leaveTypeName,
  ) {

    // End date before start date
    if (request.endDate.isBefore(request.startDate)) {
      return "End date cannot be before start date";
    }

    // Birthday Leave
    if (leaveTypeName == "Birthday Leave") {

      if (teacher.dob == null) {
        return "Teacher birthday not found";
      }

      final birthDate = DateTime.parse(
        teacher.dob!,
      );

      if (request.startDate.month != birthDate.month) {
        return "Birthday leave only during birthday month";
      }
    }

    // Medical Leave
    if (leaveTypeName == "Medical Leave") {

      // Future attachment validation
      // if(request.attachmentPath == null)

      return null;
    }

    // Marriage Leave
    if (leaveTypeName == "Marriage Leave" &&
        request.totalDays > 5) {
      return "Marriage leave maximum 5 days";
    }

    // Compassionate Leave
    if (leaveTypeName == "Compassionate Leave" &&
        request.totalDays > 2) {
      return "Compassionate leave maximum 2 days";
    }

    return null;
  }
}