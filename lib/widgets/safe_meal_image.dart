// lib/widgets/safe_meal_image.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/meal.dart';

Widget safeMealImage(Meal meal, {double size = 70}) {
  final url = meal.imageUrl;

  if (url.isEmpty) {
    // Simple grey placeholder box
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  if (url.startsWith("/")) {
    // Local file path (gallery)
    final file = File(url);
    return Image.file(
      file,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  // Network image
  return Image.network(
    url,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    },
  );
}

