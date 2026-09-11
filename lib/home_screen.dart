import 'package:flutter/material.dart';
import 'package:flutter_pokedex/api_config.dart';
import 'package:flutter_pokedex/detail_screen.dart';
import 'package:flutter_pokedex/login_screen.dart';
import 'package:flutter_pokedex/pokemon_image.dart';
import 'package:flutter_pokedex/type_category_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final Future<http.Response> Function(Uri uri)? fetch;

  const HomeScreen({super.key, this.fetch});

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

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
    _searchController.addListener(_filterPokemons);
  }

  Future<void> _fetchPokemons() async {
    final uri = Uri.parse('$apiBaseUrl/pokemon/');
    final response =
        widget.fetch == null ? await http.get(uri) : await widget.fetch!(uri);

    setState(() {
      _pokemons = json.decode(response.body);
      _filteredPokemons = _pokemons;
    });
  }

  void _filterPokemons() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPokemons =
          _pokemons.where((pokemon) {
            final name = '${pokemon['name'] ?? ''}'.toLowerCase();
            final number = '${pokemon['num'] ?? ''}'.toLowerCase();
            final paddedNumber = number.padLeft(3, '0');
            final matchesSearch =
                name.contains(query) ||
                number.contains(query) ||
                (query.isNotEmpty && paddedNumber == query.padLeft(3, '0'));
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

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
    _filterPokemons();
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
            child: TypeCategoryPicker(
              selectedType: _selectedType,
              onChanged: _selectType,
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
                      leading: PokemonImage(
                        url: pokemon['avatar']?.toString(),
                        width: 50,
                        height: 50,
                      ),
                      title: Text(
                        '#${pokemon['num']} ${pokemon['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none')
                            TypeCategoryPicker.chip(pokemon['type1']),
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none')
                            const SizedBox(width: 5),
                          if (pokemon['type2'] != null &&
                              pokemon['type2'].toLowerCase() != 'none')
                            TypeCategoryPicker.chip(pokemon['type2']),
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
