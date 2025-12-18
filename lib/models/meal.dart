// lib/models/meal.dart
import 'dart:convert';

class Meal {
  final String id;
  final String title;
  final int calories;
  final int protein; // g
  final int fats; // g
  final String imageUrl; // can be "" (no image) or local path or network URL
  final String prepTime;
  final String description;
  final bool isCustom;

  const Meal({
    required this.id,
    required this.title,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.imageUrl,
    required this.prepTime,
    required this.description,
    this.isCustom = false,
  });

  Meal copyWith({
    String? id,
    String? title,
    int? calories,
    int? protein,
    int? fats,
    String? imageUrl,
    String? prepTime,
    String? description,
    bool? isCustom,
  }) {
    return Meal(
      id: id ?? this.id,
      title: title ?? this.title,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fats: fats ?? this.fats,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTime: prepTime ?? this.prepTime,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'calories': calories,
        'protein': protein,
        'fats': fats,
        'imageUrl': imageUrl,
        'prepTime': prepTime,
        'description': description,
        'isCustom': isCustom,
      };

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      title: json['title'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      fats: json['fats'] as int,
      imageUrl: json['imageUrl'] as String? ?? "",
      prepTime: json['prepTime'] as String? ?? "10 min prep",
      description: json['description'] as String? ?? "",
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static String encodeList(List<Meal> meals) {
    final list = meals.map((m) => m.toJson()).toList();
    return jsonEncode(list);
  }

  static List<Meal> decodeList(String? data) {
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => Meal.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}


