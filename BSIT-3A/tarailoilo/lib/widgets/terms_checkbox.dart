import 'package:flutter/material.dart';
import '../services/terms_acceptance.dart';
import '../theme.dart';
import 'element_design.dart';

/// "By clicking this, you are agreeing on our Terms and Conditions" checkbox.
/// It is bound to the shared [termsAcceptance] state, so ticking it here, or
/// pressing Agree on the Terms page, updates every Terms checkbox in the app.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({super.key, required this.onOpenTerms, this.error});

  final VoidCallback onOpenTerms;

  /// Error text from the screen's validation. It hides itself once terms are accepted.
  final String? error;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: termsAcceptance,
      builder: (context, _) {
        final accepted = termsAcceptance.accepted;
        return AppCheckbox(
          checked: accepted,
          onChanged: termsAcceptance.setAccepted,
          error: accepted ? null : error,
          label: Text.rich(
            TextSpan(
              style: jost(size: 14.4, height: 1.4),
              children: [
                const TextSpan(text: 'By clicking this, you are agreeing on our '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ClickLink(
                    text: 'Terms and Conditions',
                    fontSize: 14.4,
                    onTap: onOpenTerms,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
