enum UserRole {
  user('user'),
  moderator('moderator'),
  admin('admin');

  final String role;

  const UserRole(this.role);

  String getRole() {
    return role;
  }
}
