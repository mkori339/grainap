import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPost {
  const MarketPost({
    required this.id,
    required this.ownerId,
    required this.username,
    required this.phone,
    required this.title,
    required this.quantity,
    required this.description,
    required this.region,
    required this.district,
    required this.street,
    required this.postType,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String username;
  final String phone;
  final String title;
  final String quantity;
  final String description;
  final String region;
  final String district;
  final String street;
  final String postType;
  final Timestamp? createdAt;

  factory MarketPost.fromMap(String id, Map<String, dynamic>? data) {
    final source = data ?? <String, dynamic>{};
    final rawType = (source['postType'] as String?)?.trim().toLowerCase();

    return MarketPost(
      id: id,
      ownerId: (source['usertable'] ?? '').toString(),
      username: (source['username'] ?? 'Trader').toString(),
      phone: (source['phone'] ?? '').toString(),
      title: (source['pname'] ?? 'Untitled product').toString(),
      quantity: (source['quantyty'] ?? '').toString(),
      description: (source['expl'] ?? '').toString(),
      region: (source['region'] ?? '').toString(),
      district: (source['distrname'] ?? '').toString(),
      street: (source['mtaa'] ?? '').toString(),
      postType: rawType == 'buy' ? 'buy' : 'sell',
      createdAt: source['created_at'] as Timestamp?,
    );
  }

  factory MarketPost.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MarketPost.fromMap(doc.id, doc.data());
  }

  factory MarketPost.fromQueryDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return MarketPost.fromMap(doc.id, doc.data());
  }

  bool get isBuy => postType == 'buy';

  String get tradeLabel => isBuy ? 'Buy' : 'Sell';

  int get createdAtMillis => createdAt?.millisecondsSinceEpoch ?? 0;

  String get locationLabel {
    final values = <String>[region, district, street]
        .where((value) => value.trim().isNotEmpty)
        .toList();
    return values.join(' • ');
  }
}
