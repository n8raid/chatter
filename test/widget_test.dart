import 'package:chatter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Chatter app builds', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidgetWithProvider(const Chatter());

    // Look for Host text
    expect(find.text('Host'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpWidgetWithProvider(Widget widget) {
    return pumpWidget(ProviderScope(child: widget));
  }
}
