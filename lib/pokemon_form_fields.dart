import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pokedex/pokemon_form_validation.dart';
import 'package:flutter_pokedex/type_category_picker.dart';

class _DuplicateAwareNumberField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final Future<bool> Function(String number)? checkDuplicate;

  const _DuplicateAwareNumberField({
    required this.controller,
    required this.label,
    required this.validator,
    this.checkDuplicate,
  });

  @override
  State<_DuplicateAwareNumberField> createState() =>
      _DuplicateAwareNumberFieldState();
}

class _DuplicateAwareNumberFieldState
    extends State<_DuplicateAwareNumberField> {
  Timer? _checkTimer;
  String? _duplicateError;
  bool _checking = false;
  int _checkVersion = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleDuplicateCheck);
    _scheduleDuplicateCheck();
  }

  @override
  void didUpdateWidget(covariant _DuplicateAwareNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleDuplicateCheck);
      widget.controller.addListener(_scheduleDuplicateCheck);
      _scheduleDuplicateCheck();
    }
  }

  void _scheduleDuplicateCheck() {
    _checkTimer?.cancel();
    final version = ++_checkVersion;
    final number = widget.controller.text.trim();

    if (widget.checkDuplicate == null || !RegExp(r'^\d{3}$').hasMatch(number)) {
      if (mounted) {
        setState(() {
          _duplicateError = null;
          _checking = false;
        });
      }
      return;
    }

    setState(() {
      _duplicateError = null;
      _checking = true;
    });

    _checkTimer = Timer(const Duration(milliseconds: 350), () async {
      final isDuplicate = await widget.checkDuplicate!(number);
      if (!mounted || version != _checkVersion) return;
      setState(() {
        _checking = false;
        _duplicateError = isDuplicate ? 'Number already exists' : null;
      });
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    widget.controller.removeListener(_scheduleDuplicateCheck);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _duplicateError,
        suffixIcon:
            _checking
                ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : null,
      ),
      validator: (value) {
        final formatError = widget.validator(value);
        return formatError ?? _duplicateError;
      },
    );
  }
}

class PokemonFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController totalController;
  final TextEditingController hpController;
  final TextEditingController atkController;
  final TextEditingController defController;
  final TextEditingController spatkController;
  final TextEditingController spdefController;
  final TextEditingController spdController;
  final TextEditingController avatarController;
  final TextEditingController type1Controller;
  final TextEditingController type2Controller;
  final TextEditingController numController;
  final String submitLabel;
  final VoidCallback onSubmit;
  final Future<bool> Function(String number)? checkNumberDuplicate;

  const PokemonFormFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.totalController,
    required this.hpController,
    required this.atkController,
    required this.defController,
    required this.spatkController,
    required this.spdefController,
    required this.spdController,
    required this.avatarController,
    required this.type1Controller,
    required this.type2Controller,
    required this.numController,
    required this.submitLabel,
    required this.onSubmit,
    this.checkNumberDuplicate,
  });

  List<TextEditingController> get _statControllers => [
    hpController,
    atkController,
    defController,
    spatkController,
    spdefController,
    spdController,
  ];

  List<String> get _typeOptions =>
      TypeCategoryPicker.types.where((type) => type != 'All').toList();

  InputDecoration _decoration(String label) {
    return InputDecoration(labelText: label);
  }

  TextFormField _numberField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    int maxLength = 3,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: _decoration(label),
      validator: validator,
    );
  }

  Widget _numberInputField() {
    return _DuplicateAwareNumberField(
      controller: numController,
      label: 'No (3 digits, e.g. 001)',
      checkDuplicate: checkNumberDuplicate,
      validator: PokemonFormValidation.threeDigitNumber,
    );
  }

  String? _statsTotalValidator(String? value) {
    final numberError = PokemonFormValidation.wholeNumber(value, 'Total');
    if (numberError != null) return numberError;
    if (_statControllers.any((controller) => controller.text.trim().isEmpty)) {
      return null;
    }
    return PokemonFormValidation.statsTotalError(
      total: value!,
      stats: _statControllers.map((controller) => controller.text).toList(),
    );
  }

  Widget _statsSummary() {
    return AnimatedBuilder(
      animation: Listenable.merge([totalController, ..._statControllers]),
      builder: (context, child) {
        final total = int.tryParse(totalController.text.trim());
        final values =
            _statControllers
                .map((controller) => int.tryParse(controller.text.trim()))
                .toList();
        final enteredCount = values.whereType<int>().length;
        final statsTotal = values.whereType<int>().fold(0, (sum, value) {
          return sum + value;
        });

        String message;
        Color color;
        if (total == null) {
          message = 'Stats entered: $statsTotal / —';
          color = Colors.grey.shade700;
        } else if (enteredCount < _statControllers.length) {
          message = 'Stats entered: $statsTotal / $total (6 values required)';
          color = Colors.grey.shade700;
        } else if (statsTotal == total) {
          message = 'Stats total matches Total ($total)';
          color = Colors.green.shade700;
        } else if (statsTotal > total) {
          message = 'Stats exceed Total by ${statsTotal - total}';
          color = Colors.red.shade700;
        } else {
          message = 'Stats are below Total by ${total - statsTotal}';
          color = Colors.orange.shade800;
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              message,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        );
      },
    );
  }

  DropdownButtonFormField<String> _typeField({
    required TextEditingController controller,
    required String label,
    required bool required,
  }) {
    final options = required ? _typeOptions : ['', ..._typeOptions];
    final selectedValue =
        options.contains(controller.text)
            ? controller.text
            : (required ? null : '');

    return DropdownButtonFormField<String>(
      value: selectedValue,
      isDense: false,
      alignment: AlignmentDirectional.centerStart,
      decoration: _decoration(label).copyWith(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      hint: Text(required ? 'Select $label' : 'Optional'),
      items:
          options
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child:
                      type.isEmpty
                          ? const Text('None')
                          : Row(
                            children: [
                              TypeCategoryPicker.chip(type),
                              const SizedBox(width: 8),
                              Text(type),
                            ],
                          ),
                ),
              )
              .toList(),
      selectedItemBuilder:
          (context) =>
              options
                  .map(
                    (type) =>
                        type.isEmpty
                            ? const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('None'),
                            )
                            : Align(
                              alignment: Alignment.centerLeft,
                              child: TypeCategoryPicker.chip(type),
                            ),
                  )
                  .toList(),
      onChanged: (value) => controller.text = value ?? '',
      validator:
          required
              ? (value) => value == null ? '$label is required' : null
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        key: const ValueKey('admin-form-scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration('Pokemon Name'),
              validator:
                  (value) =>
                      PokemonFormValidation.requiredText(value, 'Pokemon Name'),
            ),
            const SizedBox(height: 8),
            _numberInputField(),
            const SizedBox(height: 8),
            _numberField(
              controller: totalController,
              label: 'Total Stats',
              maxLength: 4,
              validator: _statsTotalValidator,
            ),
            const SizedBox(height: 4),
            const Text(
              'Six stats must equal Total.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 4,
              childAspectRatio: 2.4,
              children: [
                _numberField(
                  controller: hpController,
                  label: 'HP',
                  validator:
                      (value) => PokemonFormValidation.wholeNumber(value, 'HP'),
                ),
                _numberField(
                  controller: atkController,
                  label: 'ATK',
                  validator:
                      (value) =>
                          PokemonFormValidation.wholeNumber(value, 'ATK'),
                ),
                _numberField(
                  controller: defController,
                  label: 'DEF',
                  validator:
                      (value) =>
                          PokemonFormValidation.wholeNumber(value, 'DEF'),
                ),
                _numberField(
                  controller: spatkController,
                  label: 'SP.ATK',
                  validator:
                      (value) =>
                          PokemonFormValidation.wholeNumber(value, 'SP.ATK'),
                ),
                _numberField(
                  controller: spdefController,
                  label: 'SP.DEF',
                  validator:
                      (value) =>
                          PokemonFormValidation.wholeNumber(value, 'SP.DEF'),
                ),
                _numberField(
                  controller: spdController,
                  label: 'SPD',
                  validator:
                      (value) =>
                          PokemonFormValidation.wholeNumber(value, 'SPD'),
                ),
              ],
            ),
            _statsSummary(),
            TextFormField(
              controller: avatarController,
              keyboardType: TextInputType.url,
              decoration: _decoration('Avatar URL (optional)'),
              validator: PokemonFormValidation.url,
            ),
            const SizedBox(height: 8),
            _typeField(
              controller: type1Controller,
              label: 'Type 1 (required)',
              required: true,
            ),
            const SizedBox(height: 8),
            _typeField(
              controller: type2Controller,
              label: 'Type 2 (optional)',
              required: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  onSubmit();
                }
              },
              child: Text(submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}
