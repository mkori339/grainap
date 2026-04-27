import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/contact_actions.dart';
import 'package:grainapp/market_post.dart';

class MarketBackground extends StatelessWidget {
  const MarketBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.background,
            AppColors.backgroundSoft,
            AppColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panel.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
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
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.circle, color: Colors.transparent),
        ),
        Transform.translate(
          offset: const Offset(-44, 0),
          child: Icon(icon, color: AppColors.accentSoft),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(-22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(color: Colors.white.withOpacity(0.62)),
                  ),
              ],
            ),
          ),
        ),
        if (trailing != null) trailing!,
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
    return MarketPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 52, color: AppColors.accentSoft),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.66)),
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
    final isBuy = postType.toLowerCase() == 'buy';
    final color = isBuy ? AppColors.highlight : AppColors.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
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
            isBuy ? 'Buy' : 'Sell',
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: compact ? 15 : 17, color: AppColors.accentSoft),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: compact ? 12 : 13,
              ),
            ),
          ),
        ],
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
      SnackBar(content: Text(errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 16.0 : 18.0;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () {
            _runAction(
              context,
              () => openWhatsApp(phone, message: message),
              'Unable to open WhatsApp for this phone number.',
            );
          },
          icon: FaIcon(
            FontAwesomeIcons.whatsapp,
            size: iconSize,
            color: AppColors.success,
          ),
          label: compact ? const SizedBox.shrink() : const Text('WhatsApp'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            _runAction(
              context,
              () => openDialer(phone),
              'Unable to open the phone dialer.',
            );
          },
          icon: Icon(Icons.call_rounded, size: iconSize, color: AppColors.accentSoft),
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
    this.showContactActions = true,
    this.showPhone = true,
  });

  final MarketPost post;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showContactActions;
  final bool showPhone;

  String _formatCreatedAt() {
    final dateTime = post.createdAt?.toDate();
    if (dateTime == null) {
      return 'Just now';
    }
    return DateFormat('dd MMM yyyy • HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      tween: Tween<double>(begin: 0.97, end: 1),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: Material(
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
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                if (post.description.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    post.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    InfoPill(icon: Icons.scale_outlined, label: '${post.quantity} kg'),
                    InfoPill(icon: Icons.location_on_outlined, label: post.locationLabel),
                    InfoPill(icon: Icons.schedule_rounded, label: _formatCreatedAt()),
                    if (showPhone && post.phone.trim().isNotEmpty)
                      InfoPill(icon: Icons.call_outlined, label: post.phone),
                  ],
                ),
                if (showContactActions && post.phone.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 18),
                  ContactActionRow(
                    phone: post.phone,
                    message:
                        'Hello, I am interested in your ${post.tradeLabel.toLowerCase()} post for ${post.title}.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
