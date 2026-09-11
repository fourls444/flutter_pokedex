class PokemonFormValidation {
  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? wholeNumber(String? value, String label) {
    final requiredError = requiredText(value, label);
    if (requiredError != null) return requiredError;

    final number = int.tryParse(value!.trim());
    if (number == null || number < 0) {
      return '$label must be a whole number';
    }
    return null;
  }

  static String? threeDigitNumber(String? value) {
    if (value == null || !RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'Number must be exactly 3 digits';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Enter a valid Avatar URL';
    }
    return null;
  }

  static String? statsTotalError({
    required String total,
    required List<String> stats,
  }) {
    final expectedTotal = int.tryParse(total.trim());
    final values = stats.map((value) => int.tryParse(value.trim())).toList();
    if (expectedTotal == null || values.any((value) => value == null)) {
      return null;
    }

    final statsTotal = values.cast<int>().reduce((sum, value) => sum + value);
    if (statsTotal == expectedTotal) return null;

    if (statsTotal > expectedTotal) {
      return 'Stats exceed Total by ${statsTotal - expectedTotal}';
    }
    return 'Stats are below Total by ${expectedTotal - statsTotal}';
  }
}
