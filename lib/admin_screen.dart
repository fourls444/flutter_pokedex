import 'package:flutter/material.dart';
import 'package:flutter_pokedex/api_config.dart';
import 'package:flutter_pokedex/create_screen.dart';
import 'package:flutter_pokedex/detail_screen.dart';
import 'package:flutter_pokedex/edit_screen.dart';
import 'package:flutter_pokedex/pokemon_image.dart';
import 'package:flutter_pokedex/type_category_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  final Future<http.Response> Function(Uri uri)? fetch;

  const AdminScreen({super.key, this.fetch});

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

  Future<void> _delPokemons(id) async {
    final url = Uri.parse('$apiBaseUrl/pokemon/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': id});
    final res = await http.delete(url, headers: headers, body: body);
    if (res.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        _pokemons.removeWhere((pokemon) => pokemon['id'] == id);
        _filteredPokemons.removeWhere((pokemon) => pokemon['id'] == id);
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
  //   final url = Uri.parse('$apiBaseUrl/pokemon/$id');
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

  Widget _adminTypeChip(String type) {
    return Chip(
      label: Text(
        type,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      backgroundColor: TypeCategoryPicker.typeColor(type),
      side: const BorderSide(color: Colors.black, width: 1),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateScreen()),
              );
              if (!mounted) return;
              if (result == true) await _fetchPokemons();
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: PokemonImage(
                        url: pokemon['avatar']?.toString(),
                        width: 50,
                        height: 50,
                      ),
                      title: Text(
                        '#${pokemon['num']} ${pokemon['name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Row(
                        key: const ValueKey('admin-type-row'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none')
                            _adminTypeChip(pokemon['type1']),
                          if (pokemon['type1'] != null &&
                              pokemon['type1'].toLowerCase() != 'none' &&
                              pokemon['type2'] != null &&
                              pokemon['type2'].toLowerCase() != 'none')
                            const SizedBox(width: 4),
                          if (pokemon['type2'] != null &&
                              pokemon['type2'].toLowerCase() != 'none')
                            _adminTypeChip(pokemon['type2']),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit Pokémon',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 24,
                            ),
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
                            tooltip: 'Delete Pokémon',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 24,
                            ),
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
                                            _delPokemons(pokemon['id']);
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
