import '../../domain/auth_session.dart';
import '../../domain/auth_tokens.dart';
import '../../domain/user_profile.dart';

class AuthResponseDto {
  const AuthResponseDto({required this.tokens, required this.user});

  final AuthTokens tokens;
  final UserProfile user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      tokens: AuthTokens.fromJson(json),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  AuthSession toSession() {
    return AuthSession(tokens: tokens, user: user);
  }
}
