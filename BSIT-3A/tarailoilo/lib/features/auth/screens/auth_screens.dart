import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/data/terms_content.dart';
import '../controllers/auth_service.dart' as auth;
import '../controllers/terms_acceptance.dart';
import '/app/theme.dart';
import '/widgets/anim.dart';
import '../widgets/auth_shell.dart';
import '/widgets/element_design.dart';
import '../widgets/terms_checkbox.dart';
import 'dart:ui' show ImageFilter;

final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String _msg(Object e) => e is auth.AuthException ? e.message : e.toString();

void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

/* FRAME 1 */
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 2400), widget.onDone);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Entrance(
            duration: const Duration(milliseconds: 1300),
            curve: kEase,
            fromScale: 0.85,
            child: const Logo(small: true),
          ),
        ),
      ),
    );
  }
}

/* FRAME 2 */
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onLogin, required this.onGuest, required this.onSignIn});
  final VoidCallback onLogin;
  final VoidCallback onGuest;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(),
                const SizedBox(height: 28),
                GlassButton(label: 'Log in', color: GlassColor.purple, onPressed: onLogin),
                const SizedBox(height: 28),
                GlassButton(label: 'Log in as a guest', color: GlassColor.purple, onPressed: onGuest),                const SizedBox(height: 28),
                Text.rich(
                  TextSpan(
                    style: jost(size: 15.2, color: const Color(0xFF333333)),
                    children: [
                      const TextSpan(text: "Don't have an account yet? "),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ClickLink(
                          text: 'Sign in here',
                          color: AppColors.pink,
                          fontSize: 15.2,
                          onTap: onSignIn,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'or',
          textAlign: TextAlign.center,
          style: jost(size: 12.48, color: AppColors.brown),
        ),
      ),
    );
  }
}

class _AuthTitle extends StatelessWidget {
  const _AuthTitle(this.text, {this.center = false});
  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: center ? 6 : 4),
      child: SizedBox(
        width: center ? double.infinity : null,
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: jost(size: 30.4, weight: FontWeight.w600),
        ),
      ),
    );
  }
}

/* FRAMES 3-4 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onBack, required this.onOpenTerms, required this.onDone});
  final VoidCallback onBack;
  final VoidCallback onOpenTerms;
  final VoidCallback onDone;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _pw = '';
  bool _remember = false;
  Map<String, String> _errors = {};
  String _formError = '';

  Future<void> _submit() async {
    final e = <String, String>{};
    if (!_emailRe.hasMatch(_email)) e['email'] = 'Enter a valid email address.';
    if (_pw.isEmpty) e['pw'] = 'Enter your password.';
    if (!termsAcceptance.accepted) e['agree'] = kTermsRequiredMessage;
    setState(() {
      _errors = e;
      _formError = '';
    });
    if (e.isNotEmpty) return;
    _unfocus();
    try {
      await auth.login(email: _email, password: _pw, remember: _remember);
      widget.onDone();
    } catch (err) {
      if (mounted) setState(() => _formError = _msg(err));
    }
  }

  Future<void> _google() async {
    if (!termsAcceptance.accepted) {
      setState(() {
        _errors = {'agree': kTermsRequiredMessage};
        _formError = '';
      });
      return;
    }
    setState(() {
      _errors = {};
      _formError = '';
    });
    try {
      await auth.signInWithGoogle();
      widget.onDone();
    } catch (err) {
      if (mounted) setState(() => _formError = _msg(err));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      onBack: widget.onBack,
      children: [
        const Rise(d: 0.35, child: _AuthTitle('Log in')),
        Rise(
          d: 0.45,
          child: FloatingInput(
            label: 'Email',
            icon: FieldIcon.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (v) => _email = v,
            error: _errors['email'],
          ),
        ),
        Rise(
          d: 0.55,
          child: FloatingInput(
            label: 'Password',
            icon: FieldIcon.lock,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: (v) => _pw = v,
            onSubmitted: (_) => _submit(),
            error: _errors['pw'],
          ),
        ),
        Rise(
          d: 0.65,
          child: AppCheckbox(
            checked: _remember,
            onChanged: (v) => setState(() => _remember = v),
            label: Text('Remember this account', style: jost(size: 14.4, height: 1.4)),
          ),
        ),
        Rise(
          d: 0.7,
          child: TermsCheckbox(onOpenTerms: widget.onOpenTerms, error: _errors['agree']),
        ),
        if (_formError.isNotEmpty) FormError(_formError),
        Rise(d: 0.75, child: GlassButton(label: 'Log in', color: GlassColor.orange, onPressed: _submit)),
        const Rise(d: 0.85, child: _OrDivider()),
        Rise(
          d: 0.95,
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: GlassButton(label: 'Log in with Google', color: GlassColor.google, onPressed: _google),
            ),
          ),
        ),
      ],
    );
  }
}

/* FRAMES 6-7 */
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onBack, required this.onOpenTerms, required this.onNext});
  final VoidCallback onBack;
  final VoidCallback onOpenTerms;
  final ValueChanged<String> onNext;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _email = '';
  String _pw = '';
  Map<String, String> _errors = {};
  String _formError = '';

  Future<void> _submit() async {
    final e = <String, String>{};
    if (!_emailRe.hasMatch(_email)) e['email'] = 'Enter a valid email address.';
    if (_pw.length < 8) e['pw'] = 'Use at least 8 characters.';
    if (!termsAcceptance.accepted) e['agree'] = kTermsRequiredMessage;
    setState(() {
      _errors = e;
      _formError = '';
    });
    if (e.isNotEmpty) return;
    _unfocus();
    try {
      await auth.signUp(email: _email, password: _pw);
      widget.onNext(_email);
    } catch (err) {
      if (mounted) setState(() => _formError = _msg(err));
    }
  }

  Future<void> _google() async {
    if (!termsAcceptance.accepted) {
      setState(() {
        _errors = {'agree': kTermsRequiredMessage};
        _formError = '';
      });
      return;
    }
    setState(() {
      _errors = {};
      _formError = '';
    });
    try {
      final res = await auth.signInWithGoogle();
      widget.onNext(res.email);
    } catch (err) {
      if (mounted) setState(() => _formError = _msg(err));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      onBack: widget.onBack,
      children: [
        const Rise(d: 0.35, child: _AuthTitle('SIGN IN')),
        Rise(
          d: 0.45,
          child: FloatingInput(
            label: 'Email',
            icon: FieldIcon.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (v) => _email = v,
            error: _errors['email'],
          ),
        ),
        Rise(
          d: 0.55,
          child: FloatingInput(
            label: 'Password',
            icon: FieldIcon.lock,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (v) => _pw = v,
            onSubmitted: (_) => _submit(),
            error: _errors['pw'],
          ),
        ),
        Rise(
          d: 0.62,
          child: TermsCheckbox(onOpenTerms: widget.onOpenTerms, error: _errors['agree']),
        ),
        if (_formError.isNotEmpty) FormError(_formError),
        Rise(
          d: 0.7,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: GlassButton(label: 'Sign in', color: GlassColor.orange, onPressed: _submit),
          ),
        ),
        const Rise(d: 0.8, child: _OrDivider()),
        Rise(
          d: 0.9,
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: GlassButton(label: 'Sign in with Google', color: GlassColor.google, onPressed: _google),
            ),
          ),
        ),
      ],
    );
  }
}

/* FRAME 8 */
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email, required this.onVerified});
  final String email;
  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Each box holds an invisible zero-width marker so a Backspace on an
  // "empty" box still produces a text change we can react to.
  static const String _zw = '\u200b';

  final List<String> _d = List.filled(6, '');
  final List<TextEditingController> _ctl =
      List.generate(6, (_) => TextEditingController(text: _zw));
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  int _focused = -1;
  String _error = '';
  String _notice = '';

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 6; i++) {
      _nodes[i].addListener(() {
        if (!mounted) return;
        if (_nodes[i].hasFocus) {
          // select the box content on focus (like e.target.select())
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _ctl[i].selection = TextSelection(baseOffset: 0, extentOffset: _ctl[i].text.length);
          });
          setState(() => _focused = i);
        } else if (_focused == i) {
          setState(() => _focused = -1);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctl) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _focusAt(int i) => _nodes[i.clamp(0, 5)].requestFocus();

  void _setAt(int i, String v) {
    _d[i] = v;
    _ctl[i].value = TextEditingValue(
      text: _zw + v,
      selection: TextSelection.collapsed(offset: 1 + v.length),
    );
  }

  void _onChanged(int i, String raw) {
    final stripped = raw.replaceAll(_zw, '');
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    setState(() => _error = '');

    if (stripped.isEmpty) {
      // Backspace
      if (raw.isEmpty && _d[i].isEmpty && i > 0) {
        _setAt(i, '');
        _setAt(i - 1, '');
        _focusAt(i - 1);
      } else {
        _setAt(i, '');
      }
      return;
    }
    if (digits.isEmpty) {
      _setAt(i, _d[i]); // ignore non-digits
      return;
    }
    if (digits.length == 1 || (digits.length == 2 && _d[i].isNotEmpty)) {
      // typed a single digit (replaces whatever was in the box)
      String v = digits[digits.length - 1];
      if (digits.length == 2) v = digits[0] == _d[i] ? digits[1] : digits[0];
      _setAt(i, v);
      if (i < 5) _focusAt(i + 1);
      return;
    }
    // pasted a code: fill from the first box
    final text = digits.length > 6 ? digits.substring(0, 6) : digits;
    for (var k = 0; k < 6; k++) {
      _setAt(k, k < text.length ? text[k] : '');
    }
    _focusAt(text.length);
  }

  Future<void> _verify() async {
    final code = _d.join();
    setState(() => _notice = '');
    if (code.length < 6) {
      setState(() => _error = 'Enter all six digits.');
      return;
    }
    try {
      await auth.verifyOtp(widget.email, code);
      widget.onVerified();
    } catch (err) {
      if (mounted) setState(() => _error = _msg(err));
    }
  }

  Future<void> _resend() async {
    setState(() => _error = '');
    try {
      await auth.resendOtp(widget.email);
      if (!mounted) return;
      for (var k = 0; k < 6; k++) {
        _setAt(k, '');
      }
      _focusAt(0);
      setState(() => _notice = 'A new code was sent to ${widget.email}.');
    } catch (err) {
      if (mounted) setState(() => _error = _msg(err));
    }
  }

  Widget _box(int i, double h) {
    final focused = _focused == i;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rgba(255, 255, 255, .75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.pink : rgba(165, 70, 136, .4),
          width: 1.5,
        ),
        boxShadow: focused
            ? [BoxShadow(color: rgba(165, 70, 136, .25), spreadRadius: 3)]
            : const [],
      ),
      child: Semantics(
        label: 'Digit ${i + 1}',
        child: TextField(
          controller: _ctl[i],
          focusNode: _nodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofillHints: i == 0 ? const [AutofillHints.oneTimeCode] : null,
          autocorrect: false,
          enableSuggestions: false,
          cursorColor: AppColors.pink,
          style: jost(size: 22.4, weight: FontWeight.w600),
          decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onChanged(i, v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final titleSize = (sw * 0.05).clamp(28.8, 38.4).toDouble();
 
    Widget msg(String text) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: jost(size: 14.08, weight: FontWeight.w600, color: AppColors.pink),
          ),
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Text(
                      'Verify OTP',
                      textAlign: TextAlign.center,
                      style: jost(size: titleSize, weight: FontWeight.w700, color: AppColors.pink),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: const Alignment(-0.3, -1),
                            end: const Alignment(0.3, 1),
                            colors: [rgba(165, 70, 136, .2), rgba(165, 70, 136, .06)],
                          ),
                          border: Border.all(color: rgba(165, 70, 136, .3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: rgba(165, 70, 136, .18),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: rgba(255, 255, 255, .5),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: rgba(165, 70, 136, .25), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < 6; i++) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text.rich(
                              TextSpan(
                                style: jost(size: 16, height: 1.45),
                                children: [
                                  const TextSpan(text: 'We sent a six-digit verification code to '),
                                  TextSpan(
                                    text: widget.email,
                                    style: jost(size: 16, weight: FontWeight.w700, height: 1.45),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(builder: (context, c) {
                                final gap = c.maxWidth < 300 ? 4.0 : 8.0;
                                final slot = (c.maxWidth - gap * 5) / 6;
                                final boxH = (slot * 1.2).clamp(40.0, 60.0).toDouble();
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var i = 0; i < 6; i++) ...[
                                      if (i > 0) SizedBox(width: gap),
                                      Flexible(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 52),
                                          child: _box(i, boxH),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            if (_error.isNotEmpty) msg(_error),
                            if (_notice.isNotEmpty) msg(_notice),
                            const SizedBox(height: 16),
                            Text.rich(
                              TextSpan(
                                style: jost(size: 13.6, color: const Color(0xFF333333), height: 1.45),
                                children: [
                                  const TextSpan(text: "Didn't receive code? "),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: ClickLink(
                                      text: 'Resend OTP',
                                      color: AppColors.pink,
                                      fontSize: 13.6,
                                      onTap: _resend,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            GlassButton(label: 'Verify email', color: GlassColor.purple, onPressed: _verify),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* FRAME 9 */
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key, required this.onBack, required this.onOpenTerms, required this.onComplete});
  
  final VoidCallback onBack;
  final VoidCallback onOpenTerms;
  final VoidCallback onComplete;

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final Map<String, String> _f = {'firstName': '','lastName': '', 'age': '', 'gender': '', 'nationality': '', 'phone': ''};
  String _avatar = '';
  String? _avatarPath;
  Map<String, String> _errors = {};
  String _formError = '';

  Future<void> _submit() async {
    final e = <String, String>{};
    if (_f['firstName']!.trim().isEmpty) e['firstName'] = 'Enter your first name.';
    if (_f['lastName']!.trim().isEmpty) e['lastName'] = 'Enter your last name.';
    final age = int.tryParse(_f['age']!);
    if (_f['age']!.isEmpty || age == null || age < 1 || age > 120) e['age'] = 'Enter a valid age.';
    if (_f['gender']!.isEmpty) e['gender'] = 'Select a gender.';
    if (_f['nationality']!.trim().isEmpty) e['nationality'] = 'Enter your nationality.';
    if (!RegExp(r'^\+?[\d\s-]{7,15}$').hasMatch(_f['phone']!.trim())) {
      e['phone'] = 'Enter a valid contact number.';
    }
    if (_avatar.isEmpty) e['avatar'] = 'Select an avatar or upload your own photo.';
    if (!termsAcceptance.accepted) e['agree'] = kTermsRequiredMessage;
    setState(() {
      _errors = e;
      _formError = '';
    });
    if (e.isNotEmpty) return;
    _unfocus();
    try {
      await auth.saveProfile({..._f, 'age': age.toString(), 'avatar': _avatar, if (_avatarPath != null) 'avatarPath': _avatarPath!,});
      widget.onComplete();
    } catch (err) {
      if (mounted) setState(() => _formError = _msg(err));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      onBack: widget.onBack,
      autoReveal: true,
      compact: true,
      ingredients: kInfoIngredients,
      children: [
        const Rise(d: 0.35, child: _AuthTitle('INFORMATION', center: true)),
        Rise(
          d: 0.45,
          child: FloatingInput(
            label: 'First Name:',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            onChanged: (v) => _f['firstName'] = v,
            error: _errors['firstName'],
          ),
        ),
        Rise(
          d: 0.5,
          child: FloatingInput(
            label: 'Last Name:',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            onChanged: (v) => _f['lastName'] = v,
            error: _errors['lastName'],
          ),
        ),
        Rise(
          d: 0.52,
          child: FloatingInput(
            label: 'Age:',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => _f['age'] = v,
            error: _errors['age'],
          ),
        ),
        Rise(
          d: 0.59,
          child: FloatingSelect(
            label: 'Gender:',
            value: _f['gender']!,
            options: const ['Female', 'Male', 'Non-binary', 'Prefer not to say'],
            onChanged: (v) => setState(() => _f['gender'] = v),
            error: _errors['gender'],
          ),
        ),
        Rise(
          d: 0.66,
          child: FloatingInput(
            label: 'Nationality:',
            textInputAction: TextInputAction.next,
            onChanged: (v) => _f['nationality'] = v,
            error: _errors['nationality'],
          ),
        ),
        Rise(
          d: 0.73,
          child: FloatingInput(
            label: 'Contact Number:',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            onChanged: (v) => _f['phone'] = v,
            error: _errors['phone'],
          ),
        ),
        Rise(
          d: 0.78,
          child: AvatarPicker(
            value: _avatar,
            customPath: _avatarPath,
            onChanged: (v, p) => setState(() {
              _avatar = v;
              _avatarPath = p;
            }),
            error: _errors['avatar'],
          ),
        ),
        Rise(
          d: 0.8,
          child: TermsCheckbox(onOpenTerms: widget.onOpenTerms, error: _errors['agree']),
        ),
        if (_formError.isNotEmpty) FormError(_formError),
        Rise(
          d: 0.9,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: GlassButton(label: 'Continue', color: GlassColor.orange, onPressed: _submit),
          ),
        ),
      ],
    );
  }
}

/* GUEST AVATAR */
class GuestAvatarScreen extends StatefulWidget {
  const GuestAvatarScreen({
    super.key,
    required this.onBack,
    required this.onOpenTerms,
    required this.onComplete,
  });
  final VoidCallback onBack;
  final VoidCallback onOpenTerms;
  final VoidCallback onComplete;

  @override
  State<GuestAvatarScreen> createState() => _GuestAvatarScreenState();
}

class _GuestAvatarScreenState extends State<GuestAvatarScreen> {
  String _avatar = '';
  Map<String, String> _errors = {};

  void _submit() {
    final e = <String, String>{};
    if (_avatar.isEmpty) e['avatar'] = 'Select an avatar to continue.';
    if (!termsAcceptance.accepted) e['agree'] = kTermsRequiredMessage;
    setState(() => _errors = e);
    if (e.isNotEmpty) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      onBack: widget.onBack,
      autoReveal: true,
      compact: true,
      ingredients: kInfoIngredients,
      children: [
        const Rise(d: 0.35, child: _AuthTitle('PLEASE SELECT AN AVATAR', center: true)),
        Rise(
          d: 0.5,
          child: AvatarPicker(
            value: _avatar,
            customPath: null,
            allowCustom: false,
            showLabel: false,
            onChanged: (v, _) => setState(() => _avatar = v),
            error: _errors['avatar'],
          ),
        ),
        Rise(
          d: 0.65,
          child: TermsCheckbox(onOpenTerms: widget.onOpenTerms, error: _errors['agree']),
        ),
        Rise(
          d: 0.8,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: GlassButton(label: 'Continue', color: GlassColor.orange, onPressed: _submit),
          ),
        ),
      ],
    );
  }
}
