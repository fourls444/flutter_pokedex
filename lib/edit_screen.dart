import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pokedex/api_config.dart';

class EditScreen extends StatefulWidget {
  final int id;

  const EditScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return EditScreenState();
  }
}

class EditScreenState extends State<EditScreen> {
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

  @override
  void initState() {
    super.initState();
    _fetchPokemon();
  }

  Future<void> _fetchPokemon() async {
    final url = Uri.parse('$apiBaseUrl/pokemon/${widget.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final pokemonData = jsonDecode(response.body)[0];
      _loadPokemonData(pokemonData);
    } else {
      _showSnackBar('Failed to fetch Pokemon data');
    }
  }

  void _loadPokemonData(Map<String, dynamic> pokemonData) {
    _nameController.text = pokemonData['name'] ?? '';
    _totalController.text = pokemonData['total'] ?? '';
    _hpController.text = pokemonData['hp'] ?? '';
    _atkController.text = pokemonData['atk'] ?? '';
    _defController.text = pokemonData['def'] ?? '';
    _spatkController.text = pokemonData['spatk'] ?? '';
    _spdefController.text = pokemonData['spdef'] ?? '';
    _spdController.text = pokemonData['spd'] ?? '';
    _avatarController.text = pokemonData['avatar'] ?? '';
    _type1Controller.text = pokemonData['type1'] ?? '';
    _type2Controller.text = pokemonData['type2'] ?? '';
    _numController.text = pokemonData['num'] ?? '';
    setState(() {});
  }

  Future<void> _update() async {
    final url = Uri.parse('$apiBaseUrl/pokemon/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': _nameController.text,
      'total': _totalController.text,
      'hp': _hpController.text,
      'atk': _atkController.text,
      'def': _defController.text,
      'spatk': _spatkController.text,
      'spdef': _spdefController.text,
      'spd': _spdController.text,
      'avatar': _avatarController.text,
      'type1': _type1Controller.text,
      'type2': _type2Controller.text,
      'num': _numController.text,
      'id': widget.id,
    });

    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      jsonDecode(res.body);
      _showSnackBar('Update Pokemon success');
      Navigator.pop(context, true);
    } else {
      _showSnackBar('Error updating Pokemon');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Pokemon',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.yellow,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 154, 147, 147),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Pokemon Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Pokemon Name';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Total Stats'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Total Stats';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _hpController,
                decoration: const InputDecoration(labelText: 'HP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter HP';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _atkController,
                decoration: const InputDecoration(labelText: 'ATK'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter ATK';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _defController,
                decoration: const InputDecoration(labelText: 'DEF'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter DEF';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _spatkController,
                decoration: const InputDecoration(labelText: 'SP.ATK'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter SP.ATK';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _spdefController,
                decoration: const InputDecoration(labelText: 'Sp.DEF'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Sp.DEF';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _spdController,
                decoration: const InputDecoration(labelText: 'SPD'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter SPD';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Avatar URL';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _type1Controller,
                decoration: const InputDecoration(labelText: 'Type 1'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Type 1';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _type2Controller,
                decoration: const InputDecoration(labelText: 'Type 2'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Type 2';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: _numController,
                decoration: const InputDecoration(labelText: 'No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter No';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _update();
                    }
                  },
                  child: const Text('EDIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
