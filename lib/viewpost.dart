import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/market_post.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('userpost').doc(pid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyStateCard(
                    icon: Icons.search_off_rounded,
                    title: 'Post not found',
                    subtitle: 'This listing may have been removed or is no longer available.',
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
                                      color: Colors.white.withOpacity(0.68),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withOpacity(0.08),
                              child: Icon(
                                post.isBuy ? Icons.shopping_cart_checkout_rounded : Icons.inventory_2_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          post.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.84),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            InfoPill(icon: Icons.scale_outlined, label: '${post.quantity} kg'),
                            InfoPill(icon: Icons.call_outlined, label: post.phone),
                            InfoPill(icon: Icons.location_on_outlined, label: post.locationLabel),
                            InfoPill(
                              icon: Icons.schedule_rounded,
                              label: post.createdAt == null
                                  ? 'Just now'
                                  : '${post.createdAt!.toDate()}'.substring(0, 16),
                            ),
                          ],
                        ),
                        if (!isOwner) ...<Widget>[
                          const SizedBox(height: 24),
                          ContactActionRow(
                            phone: post.phone,
                            message:
                                'Hello, I am interested in your ${post.tradeLabel.toLowerCase()} post for ${post.title}.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isOwner) ...<Widget>[
                    const SizedBox(height: 16),
                    const EmptyStateCard(
                      icon: Icons.verified_user_outlined,
                      title: 'This is your listing',
                      subtitle: 'Other users will see WhatsApp and call actions here instead of in-app chat.',
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
