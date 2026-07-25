import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:school_management_app/app/core/widgets/shared_widgets.dart';

void main() {
  tearDown(Get.reset);

  group('StatusChip', () {
    testWidgets('maps ACT to Active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusChip.status('ACT'))),
      );
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('maps DEL to Deleted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusChip.status('DEL'))),
      );
      expect(find.text('Deleted'), findsOneWidget);
    });
  });

  group('PaginationBar', () {
    testWidgets('shows record count and page position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              page: 1,
              totalPages: 6,
              totalElements: 11,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      expect(find.text('11 records'), findsOneWidget);
      expect(find.text('Page 2 of 6'), findsOneWidget);
    });

    testWidgets('hides itself when there are no records', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationBar(
              page: 0,
              totalPages: 0,
              totalElements: 0,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );
      expect(find.byType(IconButton), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('renders message and action', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              message: 'No students found',
              actionLabel: 'Add',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.text('No students found'), findsOneWidget);
      await tester.tap(find.text('Add'));
      expect(tapped, isTrue);
    });
  });
}
