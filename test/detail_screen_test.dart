import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pokedex/detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('shows type chips, stat bars, and navigation controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DetailScreen(
          id: 1,
          fetch:
              (_) async => http.Response(
                jsonEncode([
                  {
                    'avatar': 'https://example.com/pokemon.png',
                    'num': '001',
                    'name': 'Bulbasaur',
                    'total': 318,
                    'hp': 45,
                    'atk': 49,
                    'def': 49,
                    'spatk': 65,
                    'spdef': 65,
                    'spd': 45,
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

    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(6));
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets(
    'does not update state when detail request finishes after dispose',
    (tester) async {
      final responseCompleter = Completer<http.Response>();

      await tester.pumpWidget(
        MaterialApp(
          home: DetailScreen(id: 1, fetch: (_) => responseCompleter.future),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());

      responseCompleter.complete(
        http.Response(
          jsonEncode([
            {
              'avatar': 'https://example.com/pokemon.png',
              'num': '001',
              'name': 'Bulbasaur',
              'total': 318,
              'hp': 45,
              'atk': 49,
              'def': 49,
              'spatk': 65,
              'spdef': 65,
              'spd': 45,
            },
          ]),
          200,
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
