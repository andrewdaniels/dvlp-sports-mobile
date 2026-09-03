import '../../../generated/api/validate_invite.dart';

/// Carries data through the signup flow across screens: invite context
/// (if any), the user's chosen role, and credentials collected on the
/// credentials screen.
///
/// Immutable — evolve via [copyWith] as each screen adds its piece.
class SignupContext {
  const SignupContext({
    required this.role,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.inviteId,
    this.invite,
  });

  /// 'athlete' or 'coach' — matches the `role_tier` enum values on
  /// backend so we can pass this through to create-profile as-is.
  final String role;

  /// Known from the invite; otherwise collected on the credentials screen.
  final String? email;

  /// Collected on the credentials screen.
  final String? password;

  /// From invite (nullable) — prefills the profile form.
  final String? firstName;
  final String? lastName;

  /// Invite metadata carried through for the eventual create-profile call.
  final String? inviteId;
  final ValidateInviteData? invite;

  bool get fromInvite => inviteId != null;

  SignupContext copyWith({
    String? role,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? inviteId,
    ValidateInviteData? invite,
  }) {
    return SignupContext(
      role: role ?? this.role,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      inviteId: inviteId ?? this.inviteId,
      invite: invite ?? this.invite,
    );
  }
}
