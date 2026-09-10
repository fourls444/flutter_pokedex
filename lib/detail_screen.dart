import 'package:flutter/material.dart';
import 'package:flutter_pokedex/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final int id;
  final Future<http.Response> Function(Uri uri)? fetch;

  const DetailScreen({super.key, required this.id, this.fetch});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const int _maxPokemonId = 150;

  Map<dynamic, dynamic>? _pokemonDetail;

  @override
  void initState() {
    super.initState();
    _fetchPokemonDetail();
  }

  Future<void> _fetchPokemonDetail() async {
    final uri = Uri.parse('$apiBaseUrl/pokemon/${widget.id}');
    final response =
        widget.fetch == null ? await http.get(uri) : await widget.fetch!(uri);

    if (!mounted) return;

    setState(() {
      _pokemonDetail = json.decode(response.body)[0];
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

  List<String> _pokemonTypes() {
    final types = <String>[];
    for (final key in ['type1', 'type2']) {
      final value = _pokemonDetail?[key]?.toString();
      if (value != null && value.isNotEmpty && value.toLowerCase() != 'none') {
        types.add(value);
      }
    }
    return types;
  }

  double _getStatValue(String key) {
    final value = _pokemonDetail?[key];
    return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  }

  Widget _buildStatBar(String label, String key, Color color) {
    final value = _getStatValue(key);
    final progress = (value / 255).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              color: color,
              backgroundColor: color.withAlpha(40),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              value.toInt().toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openPokemon(int id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokemon Detail',
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
      ),
      body:
          _pokemonDetail == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      _pokemonDetail!['avatar'],
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 120,
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No: ${_pokemonDetail!['num']}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pokemonDetail!['name'],
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final type in _pokemonTypes())
                          Chip(
                            label: Text(
                              type,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: _getTypeColor(type),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Stats: ${_pokemonDetail!['total']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          _buildStatBar('HP', 'hp', Colors.red),
                          _buildStatBar('Attack', 'atk', Colors.orange),
                          _buildStatBar('Defense', 'def', Colors.blue),
                          _buildStatBar('Sp. Atk', 'spatk', Colors.purple),
                          _buildStatBar('Sp. Def', 'spdef', Colors.green),
                          _buildStatBar('Speed', 'spd', Colors.teal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              widget.id > 1
                                  ? () => _openPokemon(widget.id - 1)
                                  : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              widget.id < _maxPokemonId
                                  ? () => _openPokemon(widget.id + 1)
                                  : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
