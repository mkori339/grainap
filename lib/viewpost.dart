import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/mypost.dart';
import 'package:grainapp/post_widgets.dart';

class ViewPost extends StatelessWidget {
  const ViewPost({
    super.key,
    required this.pid,
    required this.userId_,
    required this.postuid,
  });

  final String pid;
  final String userId_;
  final String postuid;

  Future<void> _deletePost(BuildContext context, MarketPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete post'),
          content: Text(
            'Ondoa "${post.title}" kwenye matangazo yako?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('userpost')
        .doc(post.id)
        .delete();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tangazo limefutwa.'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MarketPageTitle(
          title: 'Maelezo ya Tangazo / Post Details',
          subtitle:
              'Soma tangazo na wasiliana moja kwa moja na muuzaji / Read the listing and contact the trader directly.',
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('userpost')
                .doc(pid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateCard(
                    icon: Icons.search_off_rounded,
                    title: 'Tangazo halipo / Post not found',
                    subtitle: bi(
                      'Tangazo hili linaweza kuwa limeondolewa au halipo tena.',
                      'This listing may have been removed or is no longer available.',
                    ),
                  ),
                );
              }

              final post = MarketPost.fromDocument(snapshot.data!);
              final isOwner = userId_ == postuid;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  MarketPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TradeTypeBadge(postType: post.postType),
                                  const SizedBox(height: 16),
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post.username,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.68),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.08),
                              child: Icon(
                                post.isBuy
                                    ? Icons.shopping_cart_checkout_rounded
                                    : Icons.inventory_2_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          post.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            if (post.hasPrice)
                              InfoPill(
                                icon: Icons.payments_outlined,
                                label: formatTzsPerKg(post.pricePerKg!),
                              ),
                            InfoPill(
                                icon: Icons.scale_outlined,
                                label: '${post.quantity} kg'),
                            InfoPill(
                                icon: Icons.call_outlined,
                                label: post.phone.isEmpty
                                    ? 'Hakuna simu'
                                    : post.phone),
                            InfoPill(
                                icon: Icons.location_on_outlined,
                                label: post.locationLabel),
                            InfoPill(
                              icon: Icons.schedule_rounded,
                              label: post.createdAt == null
                                  ? 'Sasa hivi'
                                  : DateFormat('dd MMM yyyy • HH:mm')
                                      .format(post.createdAt!.toDate()),
                            ),
                          ],
                        ),
                        if (!isOwner) ...<Widget>[
                          const SizedBox(height: 24),
                          ContactActionRow(
                            phone: post.phone,
                            message:
                                'Habari, ninapenda tangazo lako la ${post.isBuy ? 'kununua' : 'kuuza'} la ${post.title}. / Hello, I am interested in your ${post.tradeLabel.toLowerCase()} post for ${post.title}.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isOwner) ...<Widget>[
                    const SizedBox(height: 16),
                    MarketPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SectionHeader(
                            icon: Icons.verified_user_outlined,
                            title: 'Simamia tangazo / Manage your listing',
                            subtitle:
                                'Badili taarifa au futa tangazo kama halitumiki tena / Update the details or remove this post if it is no longer active.',
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          MyPost(existingPost: post),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit post'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _deletePost(context, post),
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Delete post'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
