import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreateScreenState();
  }
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

  Future<void> _create() async {
    final url = Uri.parse('http://localhost:3000/pokemon/');
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
    });

    final res = await http.post(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      jsonDecode(res.body);
      _showSnackBar('Create success');
      Navigator.pop(context);
    } else {
      final errorResponse = jsonDecode(res.body);
      final errorMessage = errorResponse['error'] ?? 'Unknown error occurred';
      _showSnackBar('Error creating: $errorMessage');
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
          'Create ',
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
                      _create();
                    }
                  },
                  child: const Text('CREATE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
