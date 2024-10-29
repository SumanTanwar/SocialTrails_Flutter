
enum ReportStatus {
  pending,
  review,
  actioned,
}

extension ReportStatusExtension on ReportStatus {
  String get status {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.review:
        return 'reviewing';
      case ReportStatus.actioned:
        return 'actioned';
      default:
        return '';
    }
  }
}
