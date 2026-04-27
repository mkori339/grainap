import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grainapp/post_widgets.dart';

void main() {
  testWidgets('trade badge renders buy label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TradeTypeBadge(postType: 'buy'),
          ),
        ),
      ),
    );

    expect(find.text('Buy'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}
