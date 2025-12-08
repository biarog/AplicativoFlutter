class AuthDto {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<Map<String, dynamic>>? routines;

  AuthDto({required this.uid, this.email, this.displayName, this.photoUrl, this.routines});
}
