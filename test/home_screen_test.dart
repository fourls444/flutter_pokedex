import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pokedex/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('category bottom sheet shows Normal and full-width field', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          fetch: (_) async => http.Response(jsonEncode([]), 200),
        ),
      ),
    );
    await tester.pump();

    final categoryField = find.byKey(const ValueKey('type-category-field'));
    expect(categoryField, findsOneWidget);
    expect(tester.getSize(categoryField).width, greaterThan(300));
    expect(find.text('Type Category'), findsOneWidget);

    final allChip = tester.widget<Chip>(find.widgetWithText(Chip, 'All'));
    expect(allChip.backgroundColor, const Color.fromARGB(255, 96, 96, 96));
    final categoryFieldRect = tester.getRect(categoryField);
    final selectedChipRect = tester.getRect(find.widgetWithText(Chip, 'All'));
    expect(selectedChipRect.left, lessThan(categoryFieldRect.left + 40));

    await tester.tap(categoryField);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byKey(const ValueKey('type-category-sheet')), findsOneWidget);
    expect(find.text('Choose Type Category'), findsOneWidget);
    expect(find.text('Select a type to filter Pokémon'), findsOneWidget);

    final allTop = tester.getTopLeft(find.widgetWithText(ChoiceChip, 'All')).dy;
    final grassTop =
        tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Grass')).dy;
    final fireTop =
        tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Fire')).dy;
    final waterTop =
        tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Water')).dy;
    final normalTop =
        tester.getTopLeft(find.widgetWithText(ChoiceChip, 'Normal')).dy;
    expect(allTop, lessThan(normalTop));
    expect(normalTop, closeTo(grassTop, 1));
    expect(fireTop, closeTo(grassTop, 1));
    expect(waterTop, greaterThan(grassTop + 1));

    final sheetCenter =
        tester
            .getRect(find.byKey(const ValueKey('type-category-sheet')))
            .center
            .dx;
    final allCenter =
        tester.getRect(find.widgetWithText(ChoiceChip, 'All')).center.dx;
    expect(allCenter, closeTo(sheetCenter, 2));

    final normalCenter =
        tester.getRect(find.widgetWithText(ChoiceChip, 'Normal')).center.dx;
    final grassCenter =
        tester.getRect(find.widgetWithText(ChoiceChip, 'Grass')).center.dx;
    final fireCenter =
        tester.getRect(find.widgetWithText(ChoiceChip, 'Fire')).center.dx;
    expect(grassCenter - normalCenter, closeTo(fireCenter - grassCenter, 2));

    final allChoiceChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'All'),
    );
    expect(allChoiceChip.showCheckmark, isTrue);
    expect(allChoiceChip.materialTapTargetSize, MaterialTapTargetSize.padded);

    final normalChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Normal'),
    );
    expect(normalChip.backgroundColor, Colors.blueGrey);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Normal'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Normal'), findsOneWidget);
  });
}
