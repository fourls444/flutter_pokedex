import 'package:flutter/material.dart';

class TypeCategoryPicker extends StatelessWidget {
  static const List<String> types = [
    'All',
    'Normal',
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

  final String selectedType;
  final ValueChanged<String> onChanged;

  const TypeCategoryPicker({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'all':
        return const Color.fromARGB(255, 96, 96, 96);
      case 'normal':
        return const Color(0xFFB6B6A8);
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

  static Widget chip(String type) {
    return Chip(
      label: Text(
        type,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      backgroundColor: typeColor(type),
      side: const BorderSide(color: Colors.black, width: 1),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _choiceChip(BuildContext sheetContext, String type) {
    final isSelected = type == selectedType;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      label: Text(
        type,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      backgroundColor: typeColor(type),
      selectedColor: typeColor(type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide(
        color: isSelected ? Colors.black : Colors.black54,
        width: isSelected ? 2 : 1,
      ),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      elevation: 0,
      pressElevation: 2,
      onSelected: (_) => Navigator.pop(sheetContext, type),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFF7FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.75;

        return Container(
          key: const ValueKey('type-category-sheet'),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose Type Category',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select a type to filter Pokémon',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6470),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: _choiceChip(sheetContext, 'All'),
                            ),
                            const SizedBox(height: 12),
                            for (
                              var index = 1;
                              index < types.length;
                              index += 3
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    for (final type in types
                                        .skip(index)
                                        .take(3))
                                      Expanded(
                                        child: Center(
                                          child: _choiceChip(
                                            sheetContext,
                                            type,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => _showPicker(context),
      child: InputDecorator(
        key: const ValueKey('type-category-field'),
        decoration: const InputDecoration(
          labelText: 'Type Category',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: chip(selectedType),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}
