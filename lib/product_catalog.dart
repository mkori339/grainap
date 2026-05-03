import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grainapp/app_support.dart';

class ProductCatalogEntry {
  const ProductCatalogEntry({
    required this.id,
    required this.label,
    required this.nameSw,
    required this.nameEn,
    required this.categorySw,
    required this.categoryEn,
  });

  final String id;
  final String label;
  final String nameSw;
  final String nameEn;
  final String categorySw;
  final String categoryEn;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'name_sw': nameSw,
      'name_en': nameEn,
      'category_sw': categorySw,
      'category_en': categoryEn,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}

class ProductCatalogService {
  ProductCatalogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('product');

  Stream<List<String>> watchProductLabels({
    bool includeAllOption = false,
    String allLabel = 'All',
  }) {
    return _collection.snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final labels = <String>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final primaryLabel = _extractLabel(data);
          if (primaryLabel != null) {
            labels.add(primaryLabel);
            continue;
          }

          for (final value in data.values) {
            final text = value.toString().trim();
            if (text.isNotEmpty) {
              labels.add(text);
            }
          }
        }

        final sorted = labels.toList()
          ..sort(
            (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
          );

        if (includeAllOption) {
          return <String>[allLabel, ...sorted];
        }
        return sorted;
      },
    );
  }

  Stream<List<ProductCatalogEntry>> watchProducts() {
    return _collection.snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final entries = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final data = doc.data();
          return ProductCatalogEntry(
            id: doc.id,
            label: _extractLabel(data) ?? doc.id,
            nameSw: (data['name_sw'] ?? '').toString(),
            nameEn: (data['name_en'] ?? '').toString(),
            categorySw: (data['category_sw'] ?? '').toString(),
            categoryEn: (data['category_en'] ?? '').toString(),
          );
        }).toList()
          ..sort(
            (ProductCatalogEntry a, ProductCatalogEntry b) =>
                a.label.toLowerCase().compareTo(b.label.toLowerCase()),
          );
        return entries;
      },
    );
  }

  Future<void> addProduct({
    required String nameSw,
    required String nameEn,
    required String categorySw,
    required String categoryEn,
  }) async {
    final trimmedSw = nameSw.trim();
    final trimmedEn = nameEn.trim();
    final docId = _slugify('$trimmedSw-$trimmedEn');
    final entry = ProductCatalogEntry(
      id: docId,
      label: bi(trimmedSw, trimmedEn),
      nameSw: trimmedSw,
      nameEn: trimmedEn,
      categorySw: categorySw.trim(),
      categoryEn: categoryEn.trim(),
    );

    await _collection.doc(docId).set({
      ...entry.toMap(),
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  String? _extractLabel(Map<String, dynamic> data) {
    final nameSw = (data['name_sw'] ?? '').toString().trim();
    final nameEn = (data['name_en'] ?? '').toString().trim();
    final bilingualLabel =
        nameSw.isNotEmpty && nameEn.isNotEmpty ? bi(nameSw, nameEn) : '';

    final preferred = <String>[
      (data['label'] ?? '').toString().trim(),
      bilingualLabel,
      nameEn,
      nameSw,
    ];

    for (final candidate in preferred) {
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  String _slugify(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
