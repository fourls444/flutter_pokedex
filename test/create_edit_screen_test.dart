import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pokedex/create_screen.dart';
import 'package:flutter_pokedex/edit_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  testWidgets('create form is scrollable on a phone-sized screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: CreateScreen()));

    expect(find.byKey(const ValueKey('admin-form-scroll')), findsOneWidget);
  });

  testWidgets('edit form is scrollable on a phone-sized screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: EditScreen(
          id: 1,
          fetch:
              (_) async => http.Response(
                jsonEncode([
                  {
                    'name': 'Bulbasaur',
                    'total': '318',
                    'hp': '45',
                    'atk': '49',
                    'def': '49',
                    'spatk': '65',
                    'spdef': '65',
                    'spd': '45',
                    'avatar': 'https://example.com/bulbasaur.png',
                    'type1': 'Grass',
                    'type2': 'Poison',
                    'num': '001',
                  },
                ]),
                200,
              ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('admin-form-scroll')), findsOneWidget);
  });
}
