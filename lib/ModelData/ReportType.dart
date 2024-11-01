enum ReportType {
  user('user'),
  post('post');

  final String type;

  const ReportType(this.type);

  String getType() {
    return type;
  }
}
