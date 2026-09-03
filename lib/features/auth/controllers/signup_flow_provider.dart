import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/signup_context.dart';

/// Ambient signup state that persists across the entry → code/type →
/// credentials → account form flow. Set by signup_code_page (on invite
/// success) and signup_type_page (on role selection); read + mutated
/// by credentials_page and the account form.
///
/// Cleared implicitly when a user reaches /passport (signup done) or
/// restarts the flow from the entry screen.
final signupFlowProvider = StateProvider<SignupContext?>((ref) => null);
