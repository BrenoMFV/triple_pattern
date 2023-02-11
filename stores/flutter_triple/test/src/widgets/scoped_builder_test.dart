import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';
import '../mocks/mocks.dart';

void main() {
  group('ScopedBuilder', () {
    late MockStore store;

    setUp(() {
      store = MockStore();
    });

    testWidgets(
        'throws AssertionError if either onState, onError, or onLoading is not provided',
        (tester) async {
      expect(() => ScopedBuilder(store: store), throwsAssertionError);
    });

    testWidgets('calls onLoading initially and onState when state changes',
        (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onState: (context, state) => Text('state $state'),
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.updateWithValue(1);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 1'), findsOneWidget);

      store.updateWithValue(2);
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('state 2'), findsOneWidget);
    });

    testWidgets('calls onError when an error is emitted', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onError: (context, error) => Text('$error'),
          ),
        ),
      );

      store.updateWithError('error 1');
      await tester.pump();

      expect(find.text('loading'), findsNothing);
      expect(find.text('error 1'), findsOneWidget);
    });

    testWidgets('calls onLoading when loading is emitted', (tester) async {
      await tester.pumpWidget(
        MockWidget(
          child: ScopedBuilder<MockStore, String, int>(
            store: store,
            onLoading: (context) => const Text('loading'),
            onState: (context, state) => Text('state $state'),
          ),
        ),
      );

      store.enableLoading();
      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
      expect(find.text('state'), findsNothing);
    });
  });
}
