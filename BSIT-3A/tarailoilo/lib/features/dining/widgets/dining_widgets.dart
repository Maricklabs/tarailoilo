import 'package:flutter/material.dart';

import '../data/dining_models.dart';

/// Brand colours read off the Figma frames. Swap for the app theme tokens if
/// they exist (lib/core).
class DiningColors {
  static const purple = Color(0xFF9B3F8E);
  static const purpleDark = Color(0xFF7A2C70);
  static const headerTint = Color(0xFFF3E6F3);
  static const chipTint = Color(0xFFF7EDF7);
  static const border = Color(0xFFE4CDE3);
  static const body = Color(0xFF4A3A48);
}

/// Lavender header band: back, "TARA ILO", profile, big title.
class DiningHeader extends StatelessWidget {
  const DiningHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onProfileTap,
  });

  final String title;

  /// Optional pill next to the title (e.g. "Locate in Maps").
  final Widget? trailing;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      color: DiningColors.headerTint,
      padding: EdgeInsets.fromLTRB(
          8, MediaQuery.paddingOf(context).top + 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (canPop)
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back,
                      size: 18, color: DiningColors.purple),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              else
                const SizedBox(width: 12),
              const Text(
                'TARA ILO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: DiningColors.purple,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Profile',
                icon: const Icon(Icons.account_circle_outlined,
                    color: DiningColors.purple),
                onPressed: onProfileTap,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: DiningColors.purple,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: DiningColors.purple,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: DiningColors.purpleDark,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('See all', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

/// Network image with a tinted placeholder when there is no URL or it fails.
class DiningImage extends StatelessWidget {
  const DiningImage({
    super.key,
    required this.url,
    this.icon = Icons.restaurant,
    this.borderRadius = 12,
    this.width,
    this.height,
  });

  final String? url;
  final IconData icon;
  final double borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: DiningColors.chipTint,
      alignment: Alignment.center,
      child: Icon(icon, color: DiningColors.purple.withValues(alpha: 0.5)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

/// Featured dish card ("Taste Iloilo").
class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, required this.onTap});

  final Dish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: DiningColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                DiningImage(
                    url: dish.imageUrl, width: 72, height: 72, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dish.isIloiloFavorite)
                        const Text(
                          'ILONGGO FAVORITE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: DiningColors.purple,
                          ),
                        ),
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DiningColors.purpleDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dish.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: DiningColors.body),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Explore dish →',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DiningColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row used for restaurants ("Places to try") and compact dish rows.
class DiningListTile extends StatelessWidget {
  const DiningListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageUrl,
    this.icon = Icons.storefront,
    this.caption,
    this.horizontalPadding = 16,
  });

  final double horizontalPadding;

  final String title;
  final String subtitle;
  final String? caption;
  final String? imageUrl;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DiningColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DiningImage(
                  url: imageUrl,
                  icon: icon,
                  width: 44,
                  height: 44,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: DiningColors.purpleDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10, color: DiningColors.body),
                      ),
                      if (caption != null)
                        Text(
                          caption!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: DiningColors.purple,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: DiningColors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows allergens ONLY as a dated declaration by a restaurant.
/// Never implies a dish is safe to eat.
class AllergenPanel extends StatelessWidget {
  const AllergenPanel({super.key, required this.declarations});

  final List<AllergenDeclaration> declarations;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DiningColors.chipTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Allergens',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: DiningColors.purple,
            ),
          ),
          const SizedBox(height: 6),
          if (declarations.isEmpty)
            const Text(
              'No restaurant has declared allergens for this dish yet.',
              style: TextStyle(fontSize: 11, color: DiningColors.body),
            )
          else
            for (final d in declarations)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Declared by ${d.restaurantName} as of '
                  '${formatDate(d.declaredOn)}: '
                  '${d.allergens.isEmpty ? 'none listed' : d.allergens.join(', ')}',
                  style: const TextStyle(
                      fontSize: 11, color: DiningColors.body),
                ),
              ),
          const SizedBox(height: 4),
          const Text(
            'Recipes change. This is not a guarantee that the dish is safe '
            'to eat. Always confirm with the restaurant.',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: DiningColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading / error / empty wrapper for a Future.
///
/// TODO: swap the three private views for LoadingView / EmptyView / ErrorView
/// from lib/widgets/state_views.dart (constructors weren't shared yet).
class DiningAsync<T> extends StatelessWidget {
  const DiningAsync({
    super.key,
    required this.future,
    required this.builder,
    this.isEmpty,
    this.emptyMessage = 'Nothing here yet.',
    this.onRetry,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return DiningMessage(
            icon: Icons.error_outline,
            text: 'Something went wrong.',
            actionLabel: onRetry == null ? null : 'Try again',
            onAction: onRetry,
          );
        }
        final data = snap.data as T;
        if (data == null || (isEmpty?.call(data) ?? false)) {
          return DiningMessage(icon: Icons.search_off, text: emptyMessage);
        }
        return builder(context, data);
      },
    );
  }
}

class DiningMessage extends StatelessWidget {
  const DiningMessage({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: DiningColors.purple),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
