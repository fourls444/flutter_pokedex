import 'package:flutter/material.dart';
import 'package:flutter_pokedex/create_screen.dart';
import 'package:flutter_pokedex/detail_screen.dart';
import 'package:flutter_pokedex/edit_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() {
    return _AdminScreenState();
  }
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _pokemons = [];
  List<dynamic> _filteredPokemons = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';

  final List<String> _types = [
    'All',
    'Grass',
    'Fire',
    'Water',
    'Electric',
    'Psychic',
    'Ice',
    'Dragon',
    'Dark',
    'Fairy',
    'Fighting',
    'Flying',
    'Poison',
    'Ground',
    'Rock',
    'Bug',
    'Ghost',
    'Steel',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
    _searchController.addListener(_filterPokemons);
  }

  Future<void> _fetchPokemons() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/pokemon/'),
    );

    setState(() {
      _pokemons = json.decode(response.body);
      _filteredPokemons = _pokemons;
    });
  }

  Future<void> _delPokemons(id, index) async {
    final url = Uri.parse('http://localhost:3000/pokemon/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': id});
    final res = await http.delete(url, headers: headers, body: body);
    if (res.statusCode == 200) {
      setState(() {
        _pokemons.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pokemon deleted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Pokemon')),
        );
      }
    }
  }

  void _navigateUpdate(id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(id: id)),
    );
    if (result == true) {
      await _fetchPokemons();
    }
  }

  // Future<void> _delPokemons(id, index) async {
  //   final url = Uri.parse('http://localhost:3000/pokemon/$id');
  //   final headers = {'Content-Type': 'application/json'};
  //   final res = await http.delete(url, headers: headers);
  //   if (res.statusCode == 200) {
  //     setState(() {
  //       _pokemons.removeAt(index); // Remove the pokemon from the list
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Pokemon deleted successfully')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Failed to delete Pokemon')));
  //   }
  // }

  void _filterPokemons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPokemons =
          _pokemons.where((pokemon) {
            final matchesSearch = pokemon['name'].toLowerCase().contains(query);
            final matchesType =
                _selectedType == 'All' ||
                pokemon['type1'].toLowerCase() == _selectedType.toLowerCase() ||
                (pokemon['type2'] != null &&
                    pokemon['type2'].toLowerCase() ==
                        _selectedType.toLowerCase());
            return matchesSearch && matchesType;
          }).toList();
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return Colors.green;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return const Color.fromARGB(255, 255, 110, 168);
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return const Color.fromARGB(255, 139, 110, 96);
      case 'fairy':
        return const Color.fromARGB(255, 241, 168, 241);
      case 'fighting':
        return const Color.fromARGB(255, 207, 24, 24);
      case 'flying':
        return const Color.fromARGB(255, 154, 168, 255);
      case 'poison':
        return const Color.fromARGB(255, 180, 83, 160);
      case 'ground':
        return const Color.fromARGB(255, 226, 197, 110);
      case 'rock':
        return const Color.fromARGB(255, 197, 183, 125);
      case 'bug':
        return Colors.lightGreen;
      case 'ghost':
        return Colors.deepPurpleAccent;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokedex Admin',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Pokémon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              items:
                  _types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _filterPokemons();
                });
              },
              decoration: InputDecoration(
                labelText: 'Type Catagory',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPokemons.length,
              itemBuilder: (context, index) {
                final pokemon = _filteredPokemons[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailScreen(id: pokemon['id']),
                          ),
                        );
                      },
                      leading: Image.network(
                        pokemon['avatar'],
                        width: 50,
                        height: 50,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error),
                      ),
                      title: Text(
                        '#${pokemon['num']} ${pokemon['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none')
                            Chip(
                              label: Text(
                                pokemon['type1'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: _getTypeColor(pokemon['type1']),
                            ),
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none')
                            const SizedBox(width: 5),
                          if (pokemon['type2'] != null &&
                              pokemon['type2'].toLowerCase() != 'none')
                            Chip(
                              label: Text(
                                pokemon['type2'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: _getTypeColor(pokemon['type2']),
                            ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              if (pokemon['id'] != null) {
                                _navigateUpdate(pokemon['id']);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Pokémon ID'),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (pokemon['id'] != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                        'Are you sure you want to delete this Pokémon?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _delPokemons(pokemon['id'], index);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Pokémon ID'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
