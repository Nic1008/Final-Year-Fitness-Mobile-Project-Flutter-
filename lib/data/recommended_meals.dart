import 'package:fitnessapp/models/meal.dart';

final List<Meal> breakfastMeals = [
  Meal(
    id: "b1",
    title: "Salad & Egg",
    calories: 540,
    protein: 25,
    fats: 16,
    imageUrl:
        "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800",
    description:
        "High-protein salad with eggs and leafy greens.",
    prepTime: "20 min prep",
  ),
  // others...
];

final List<Meal> lunchMeals = [
  Meal(
    id: "l1",
    title: "Chicken & Rice Bowl",
    calories: 560,
    protein: 38,
    fats: 12,
    imageUrl:
        "https://www.skinnytaste.com/wp-content/uploads/2024/05/Coconut-Chicken-Rice-Bowls-10-500x500.jpg",
    description:
        "Grilled chicken with rice and vegetables.",
    prepTime: "25 min prep",
  ),
];

final List<Meal> dinnerMeals = [
  Meal(
    id: "d1",
    title: "Fish & Vegetables",
    calories: 325,
    protein: 30,
    fats: 10,
    imageUrl:
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800",
    description:
        "Light grilled fish with roasted vegetables.",
    prepTime: "20 min prep",
  ),
];
