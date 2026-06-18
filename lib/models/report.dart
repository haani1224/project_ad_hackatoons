class Report {
  final String title;
  final String category;
  final String description;
  final String status;
  final bool anonymous;
  final String writer;
  final String dateSubmitted;
  final String? imagePath;

  Report({
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.anonymous,
    required this.writer,
    required this.dateSubmitted,
    this.imagePath,
  });
}