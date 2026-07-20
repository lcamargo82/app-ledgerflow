import 'auth_me.dart';
import 'auth_tokens.dart';
import 'user_profile.dart';

class AuthSession {
  const AuthSession({required this.tokens, required this.user, this.me});

  final AuthTokens tokens;
  final UserProfile user;
  final AuthMe? me;
}
