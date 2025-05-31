import 'package:flutter/material.dart';
import 'package:flutter_pokedex/detail_screen.dart';
import 'package:flutter_pokedex/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
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
          'Pokedex',
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 204, 35, 23),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
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
