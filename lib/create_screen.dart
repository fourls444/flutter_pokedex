import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pokedex/api_config.dart';
import 'package:flutter_pokedex/pokemon_form_fields.dart';
import 'package:http/http.dart' as http;

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => CreateScreenState();
}

class CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _atkController = TextEditingController();
  final TextEditingController _defController = TextEditingController();
  final TextEditingController _spatkController = TextEditingController();
  final TextEditingController _spdefController = TextEditingController();
  final TextEditingController _spdController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  final TextEditingController _type1Controller = TextEditingController();
  final TextEditingController _type2Controller = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  Future<bool> _isNumberTaken(String number) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/pokemon/'));
      if (response.statusCode != 200) return false;

      final pokemons = jsonDecode(response.body);
      if (pokemons is! List) return false;
      return pokemons.any(
        (pokemon) => '${pokemon['num'] ?? ''}'.trim() == number,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _create() async {
    final url = Uri.parse('$apiBaseUrl/pokemon/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': _nameController.text.trim(),
      'total': _totalController.text.trim(),
      'hp': _hpController.text.trim(),
      'atk': _atkController.text.trim(),
      'def': _defController.text.trim(),
      'spatk': _spatkController.text.trim(),
      'spdef': _spdefController.text.trim(),
      'spd': _spdController.text.trim(),
      'avatar': _avatarController.text.trim(),
      'type1': _type1Controller.text,
      'type2': _type2Controller.text.isEmpty ? 'None' : _type2Controller.text,
      'num': _numController.text.trim(),
    });

    final res = await http.post(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      _showSnackBar('Create success');
      Navigator.pop(context, true);
    } else {
      _showSnackBar(_responseError(res, 'Error creating Pokémon'));
    }
  }

  String _responseError(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } catch (_) {
      // Use the fallback when the API response is not JSON.
    }
    return fallback;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _totalController,
      _hpController,
      _atkController,
      _defController,
      _spatkController,
      _spdefController,
      _spdController,
      _avatarController,
      _type1Controller,
      _type2Controller,
      _numController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 154, 147, 147),
      ),
      body: PokemonFormFields(
        formKey: _formKey,
        nameController: _nameController,
        totalController: _totalController,
        hpController: _hpController,
        atkController: _atkController,
        defController: _defController,
        spatkController: _spatkController,
        spdefController: _spdefController,
        spdController: _spdController,
        avatarController: _avatarController,
        type1Controller: _type1Controller,
        type2Controller: _type2Controller,
        numController: _numController,
        submitLabel: 'CREATE',
        onSubmit: _create,
        checkNumberDuplicate: _isNumberTaken,
      ),
    );
  }
}
