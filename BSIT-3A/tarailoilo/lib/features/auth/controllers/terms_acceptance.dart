import 'package:flutter/foundation.dart';

/// The single, app-wide answer to "has the user accepted the Terms and Conditions?".
///
/// Every Terms checkbox (Log in, Sign in, Information, Guest avatar) reads and writes
/// this one object, and the Terms screen's Agree button calls [accept]. There is no
/// per-screen copy, so the checkboxes can never disagree with each other.
///
/// Frontend only for now (kept in memory). When the backend exists, load the stored
/// consent into [setAccepted] at start-up and save it from [accept] / [setAccepted].
class TermsAcceptance extends ChangeNotifier {
  bool _accepted = false;
  DateTime? _acceptedAt;

  bool get accepted => _accepted;
  DateTime? get acceptedAt => _acceptedAt;

  /// The Agree button on page 2 of the Terms and Conditions.
  void accept() => _set(true);

  /// A checkbox ticked or unticked by hand. Unticking withdraws consent everywhere.
  void setAccepted(bool value) => _set(value);

  void _set(bool value) {
    if (value == _accepted) return;
    _accepted = value;
    _acceptedAt = value ? DateTime.now() : null;
    notifyListeners();
  }
}

final TermsAcceptance termsAcceptance = TermsAcceptance();
