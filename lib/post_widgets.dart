import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/contact_actions.dart';
import 'package:grainapp/market_post.dart';

class MarketBackground extends StatelessWidget {
  const MarketBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            palette.background,
            palette.backgroundSoft,
            palette.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.accent.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            bottom: -160,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.highlight.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class MarketPanel extends StatelessWidget {
  const MarketPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            palette.panel.withValues(alpha: 0.97),
            palette.panelSoft.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.08,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MarketPageTitle extends StatelessWidget {
  const MarketPageTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          sanitizeUiText(title),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sanitizeUiText(subtitle),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: onSurface.withValues(alpha: 0.68),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: palette.accent.withValues(alpha: 0.18),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: palette.accentSoft, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                sanitizeUiText(title),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  sanitizeUiText(subtitle!),
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.62),
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return MarketPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 34, color: palette.accentSoft),
          ),
          const SizedBox(height: 16),
          Text(
            sanitizeUiText(title),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            sanitizeUiText(subtitle),
            style: TextStyle(color: onSurface.withValues(alpha: 0.66)),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: 18),
            action!,
          ],
        ],
      ),
    );
  }
}

class TradeTypeBadge extends StatelessWidget {
  const TradeTypeBadge({super.key, required this.postType});

  final String postType;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isBuy = postType.toLowerCase() == 'buy';
    final color = isBuy ? palette.highlight : palette.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isBuy ? Icons.shopping_bag_outlined : Icons.sell_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isBuy ? bi('Nunua', 'Buy') : bi('Uza', 'Sell'),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 170 : 280),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: onSurface.withValues(
            alpha:
                Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.04,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: compact ? 15 : 17, color: palette.accentSoft),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                sanitizeUiText(label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.92),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactActionRow extends StatelessWidget {
  const ContactActionRow({
    super.key,
    required this.phone,
    required this.message,
    this.compact = false,
  });

  final String phone;
  final String message;
  final bool compact;

  Future<void> _runAction(
    BuildContext context,
    Future<bool> Function() action,
    String errorMessage,
  ) async {
    final launched = await action();
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sanitizeUiText(errorMessage))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final iconSize = compact ? 16.0 : 18.0;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () {
            _runAction(
              context,
              () => openWhatsApp(phone, message: sanitizeUiText(message)),
              'Imeshindikana kufungua WhatsApp / Unable to open WhatsApp.',
            );
          },
          icon: FaIcon(
            FontAwesomeIcons.whatsapp,
            size: iconSize,
            color: palette.success,
          ),
          label: compact ? const SizedBox.shrink() : const Text('WhatsApp'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            _runAction(
              context,
              () => openDialer(phone),
              'Imeshindikana kufungua simu / Unable to open the phone dialer.',
            );
          },
          icon: Icon(Icons.call_rounded,
              size: iconSize, color: palette.accentSoft),
          label: compact ? const SizedBox.shrink() : const Text('Call'),
        ),
      ],
    );
  }
}

class MarketPostCard extends StatelessWidget {
  const MarketPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.trailing,
    this.footer,
    this.showContactActions = true,
    this.showPhone = true,
  });

  final MarketPost post;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? footer;
  final bool showContactActions;
  final bool showPhone;

  String _formatCreatedAt() {
    final dateTime = post.createdAt?.toDate();
    if (dateTime == null) {
      return bi('Sasa hivi', 'Just now');
    }
    return DateFormat('dd MMM yyyy • HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: MarketPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TradeTypeBadge(postType: post.postType),
                        const SizedBox(height: 14),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.username,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
              if (post.description.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.8),
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  if (post.hasPrice)
                    InfoPill(
                      icon: Icons.payments_outlined,
                      label: formatTzsPerKg(post.pricePerKg!),
                    ),
                  InfoPill(
                      icon: Icons.scale_outlined, label: '${post.quantity} kg'),
                  InfoPill(
                      icon: Icons.location_on_outlined,
                      label: post.locationLabel),
                  InfoPill(
                      icon: Icons.schedule_rounded, label: _formatCreatedAt()),
                  if (showPhone && post.phone.trim().isNotEmpty)
                    InfoPill(icon: Icons.call_outlined, label: post.phone),
                ],
              ),
              if (showContactActions &&
                  post.phone.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                ContactActionRow(
                  phone: post.phone,
                  message:
                      'Habari, ninapenda tangazo lako la ${post.isBuy ? 'kununua' : 'kuuza'} la ${post.title}. / Hello, I am interested in your ${post.tradeLabel.toLowerCase()} post for ${post.title}.',
                ),
              ],
              if (footer != null) ...<Widget>[
                const SizedBox(height: 18),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
