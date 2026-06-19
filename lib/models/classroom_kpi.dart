class ClassroomKpi {
  bool isClean;
  String? cleanProofUrl;
  
  bool studentsManaged;
  String? studentsManagedProofUrl;
  
  bool cornersUpdated;
  String? cornersProofUrl;
  
  bool safetyRules;
  bool studentsLineUp;

  ClassroomKpi({
    this.isClean = false,
    this.cleanProofUrl,
    this.studentsManaged = false,
    this.studentsManagedProofUrl,
    this.cornersUpdated = false,
    this.cornersProofUrl,
    this.safetyRules = false,
    this.studentsLineUp = false,
  });
}