import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:iloilo_tourist_app/widgets/icons.dart';
import 'package:iloilo_tourist_app/data/chat_content.dart';
import 'package:iloilo_tourist_app/models/chat_message.dart';
import 'package:iloilo_tourist_app/app/theme.dart';
import 'package:iloilo_tourist_app/widgets/anim.dart';

/// Widest the chat column gets on tablets / desktop.
const double kChatMaxWidth = 720;

const Color _kHeaderPink = Color(0xFFFBE9F5);
const Color _kGlassText = Color(0xFF7D2F66);

/* ------------------------------------------------------------------ Header */

/// Light pink header: back + branding + account on one row, then heading and subtitle.
/// The back and account buttons are passed in so this file stays independent of the dashboard.
class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.backButton,
    required this.accountButton,
  });
  final Widget backButton;
  final Widget accountButton;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final headingSize = (mq.size.width * 0.07).clamp(26.0, 34.0).toDouble();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12 + mq.padding.top, 16, 16),
      decoration: BoxDecoration(
        color: _kHeaderPink,
        border: Border(
          bottom: BorderSide(color: rgba(205, 123, 180, .35), width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kChatMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  backButton,
                  const SizedBox(width: 12),
                  Text(
                    'TARA ILOILO',
                    style: jost(
                      size: 11.2,
                      weight: FontWeight.w700,
                      letterSpacing: 0.67,
                      color: AppColors.deep,
                    ),
                  ),
                  const Spacer(),
                  accountButton,
                ],
              ),
              const SizedBox(height: 14),
              Text(
                kChatHeading,
                style: jost(
                  size: headingSize,
                  weight: FontWeight.w700,
                  height: 1.1,
                  color: AppColors.deep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kChatSubtitle,
                style: jost(
                  size: 14.4,
                  weight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: AppColors.pur,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------------- Bubbles */

class TataAvatar extends StatelessWidget {
  const TataAvatar({super.key, this.size = 38});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.lite, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          assetImg('tata'),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: jost(
        size: 11.2,
        weight: FontWeight.w700,
        letterSpacing: 0.9,
        color: color,
      ),
    );
  }
}

/// Right-aligned solid pink-purple bubble with a small USER label.
class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text, required this.maxWidth});
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 4, bottom: 4),
              child: _Label('USER', AppColors.soft),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pur,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: rgba(165, 70, 136, .22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: jost(size: 15.2, height: 1.45, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Left-aligned frame: avatar + TATA label + light pink container around [child].
class _TataShell extends StatelessWidget {
  const _TataShell({required this.maxWidth, required this.child});
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TataAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.max(120.0, maxWidth - 48),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: _Label('TATA', AppColors.deep),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _kHeaderPink,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: rgba(205, 123, 180, .35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rgba(165, 70, 136, .10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TataBubble extends StatelessWidget {
  const TataBubble({super.key, required this.text, required this.maxWidth});
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return _TataShell(
      maxWidth: maxWidth,
      child: Text(
        text,
        style: jost(size: 15.2, height: 1.5, color: AppColors.ink),
      ),
    );
  }
}

/// Three bouncing dots shown while TATA prepares a reply.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, required this.maxWidth});
  final double maxWidth;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TATA is typing',
      child: _TataShell(
        maxWidth: widget.maxWidth,
        child: SizedBox(
          height: 22,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _dot(i),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(int i) {
    final phase = (((_c.value - i * 0.18) % 1.0) + 1.0) % 1.0;
    final lift = math.sin(phase * math.pi); // 0 -> 1 -> 0
    return Transform.translate(
      offset: Offset(0, -4 * lift),
      child: Opacity(
        opacity: 0.35 + 0.65 * lift,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.pur,
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------ Conversation */

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TataAvatar(size: 72),
            const SizedBox(height: 14),
            Text(
              kChatEmptyTitle,
              style: jost(
                size: 22,
                weight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kChatEmptyBody,
              textAlign: TextAlign.center,
              style: jost(size: 15.2, height: 1.5, color: AppColors.soft),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of messages. Messages at or after [animateFromIndex] slide in;
/// older ones appear instantly so reopening the chat doesn't replay every animation.
class ConversationView extends StatelessWidget {
  const ConversationView({
    super.key,
    required this.messages,
    required this.isTyping,
    required this.scroll,
    this.animateFromIndex = 0,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final ScrollController scroll;
  final int animateFromIndex;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isTyping) return const ChatEmptyState();

    return LayoutBuilder(
      builder: (context, c) {
        final content = math.min(c.maxWidth, kChatMaxWidth) - 32;
        final bubbleMax = math.min(content * 0.86, 520.0);
        return SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kChatMaxWidth - 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < messages.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    _item(messages[i], i, bubbleMax),
                  ],
                  if (isTyping) ...[
                    if (messages.isNotEmpty) const SizedBox(height: 14),
                    _enter(
                      const ValueKey('typing'),
                      TypingIndicator(maxWidth: bubbleMax),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _item(ChatMessage m, int i, double maxWidth) {
    final bubble = m.role == ChatRole.user
        ? UserBubble(text: m.text, maxWidth: maxWidth)
        : TataBubble(text: m.text, maxWidth: maxWidth);
    final key = ValueKey(m.id);
    return i >= animateFromIndex
        ? _enter(key, bubble)
        : KeyedSubtree(key: key, child: bubble);
  }

  Widget _enter(Key key, Widget child) => Entrance(
    key: key,
    duration: const Duration(milliseconds: 380),
    curve: kEase,
    from: const Offset(0, 14),
    child: child,
  );
}

/* ---------------------------------------------------- Suggested questions */

/// White -> glass purple on touch, white text and arrow, then runs [onPressed].
/// Same press-then-open rhythm as the Landmark and Food cards.
class SuggestionButton extends StatefulWidget {
  const SuggestionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<SuggestionButton> createState() => _SuggestionButtonState();
}

class _SuggestionButtonState extends State<SuggestionButton> {
  bool _on = false;
  bool _down = false;

  Future<void> _go() async {
    if (_on || !widget.enabled) return;
    setState(() => _on = true);
    await Future.delayed(const Duration(milliseconds: 280));
    if (mounted) widget.onPressed();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _on = false);
  }

  @override
  Widget build(BuildContext context) {
    final on = _on;
    final textColor = on ? Colors.white : AppColors.pur;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: (on || _down) ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: _go,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: on
                    ? [rgba(165, 70, 136, .95), rgba(165, 70, 136, .82)]
                    : const [Colors.white, Colors.white],
              ),
              border: Border.all(
                color: on ? rgba(255, 255, 255, .7) : rgba(205, 123, 180, .55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: on ? rgba(165, 70, 136, .40) : rgba(165, 70, 136, .10),
                  blurRadius: on ? 14 : 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: jost(
                      size: 15.2,
                      weight: FontWeight.w600,
                      height: 1.3,
                      color: textColor,
                    ),
                    child: Text(widget.label),
                  ),
                ),
                const SizedBox(width: 12),
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: textColor),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, c, __) =>
                      Icn(Ic.arrow, size: 20, color: c ?? AppColors.pur),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Heading + list of [SuggestionButton]s. Pass any list of questions to replace them.
class SuggestedQuestions extends StatelessWidget {
  const SuggestedQuestions({
    super.key,
    required this.questions,
    required this.onSelected,
    this.enabled = true,
    this.heading = kSuggestionsHeading,
  });

  final List<String> questions;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading,
          style: jost(
            size: 16.5,
            weight: FontWeight.w600,
            color: AppColors.pur,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < questions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          SuggestionButton(
            label: questions[i],
            enabled: enabled,
            onPressed: () => onSelected(questions[i]),
          ),
        ],
      ],
    );
  }
}

/* ------------------------------------------------------------------- Input */

/// Round glass send button: translucent purple, solid + white icon on touch.
class SendButton extends StatefulWidget {
  const SendButton({super.key, required this.onPressed, required this.enabled});
  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down && widget.enabled;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Send message',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (widget.enabled) setState(() => _down = true);
        },
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: pressed ? 0.9 : 1,
          duration: const Duration(milliseconds: 140),
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: pressed
                          ? [AppColors.pur, AppColors.pur]
                          : [rgba(165, 70, 136, .62), rgba(165, 70, 136, .42)],
                    ),
                    border: Border.all(
                      color: pressed ? AppColors.pur : rgba(255, 255, 255, .7),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: rgba(165, 70, 136, .35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icn(
                      Ic.send,
                      size: 22,
                      color: pressed ? Colors.white : _kGlassText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom message bar: growing text field + send button.
/// Enter submits (mobile "send" key and hardware keyboards); empty messages are ignored.
/// [busy] only blocks sending, so the user can keep typing while TATA answers.
class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    required this.focusNode,
    this.busy = false,
  });
  final ValueChanged<String> onSend;
  final FocusNode focusNode;
  final bool busy;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctl.text.trim();
    if (text.isEmpty || widget.busy) return;
    widget.onSend(text);
    _ctl.clear();
    widget.focusNode
        .requestFocus(); // keep the keyboard up for the next message
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: rgba(205, 123, 180, .35), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: rgba(165, 70, 136, .08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kChatMaxWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  focusNode: widget.focusNode,
                  minLines: 1,
                  maxLines: 5,
                  // "text" (not "multiline") so the keyboard shows a Send key and Enter submits.
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _submit(),
                  cursorColor: AppColors.pur,
                  style: jost(size: 15.2, height: 1.35, color: AppColors.pur),
                  decoration: InputDecoration(
                    hintText: kChatInputHint,
                    hintStyle: jost(size: 15.2, color: AppColors.lite),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: rgba(205, 123, 180, .55),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.pur,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ListenableBuilder(
                listenable: _ctl,
                builder: (context, _) => SendButton(
                  enabled: _ctl.text.trim().isNotEmpty && !widget.busy,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
