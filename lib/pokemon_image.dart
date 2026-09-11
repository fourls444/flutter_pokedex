import 'package:flutter/material.dart';

class PokemonImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;

  const PokemonImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
  });

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: (width < height ? width : height) * 0.45,
        color: Colors.grey.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    if (imageUrl.isEmpty) return _placeholder();

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}
