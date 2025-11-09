class AuthDto {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  AuthDto({required this.uid, this.email, this.displayName, this.photoUrl});
}
