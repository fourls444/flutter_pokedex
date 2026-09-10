import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pokedex/admin_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('admin uses the shared category picker and compact actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: AdminScreen(
          fetch:
              (_) async => http.Response(
                jsonEncode([
                  {
                    'id': 1,
                    'num': '001',
                    'name': 'Bulbasaur',
                    'avatar': 'https://example.com/bulbasaur.png',
                    'type1': 'Grass',
                    'type2': 'Poison',
                  },
                ]),
                200,
              ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('type-category-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-type-row')), findsOneWidget);
    expect(find.byType(Wrap), findsNothing);

    await tester.tap(find.byKey(const ValueKey('type-category-field')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('type-category-sheet')), findsOneWidget);
    expect(find.text('Select a type to filter Pokémon'), findsOneWidget);
  });
}
