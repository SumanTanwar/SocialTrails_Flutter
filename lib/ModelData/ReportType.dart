
enum ReportType {
  user,
  post,
}

extension ReportTypeExtension on ReportType {
  String get type {
    switch (this) {
      case ReportType.user:
        return 'user';
      case ReportType.post:
        return 'post';
      default:
        return '';
    }
  }
}
