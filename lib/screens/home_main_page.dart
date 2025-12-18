import 'package:fitnessapp/services/progress_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitnessapp/screens/video_player_screen.dart';
import 'package:fitnessapp/screens/supplements_page.dart';
import '../data/workout_data.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; 
import 'package:fitnessapp/data/recommended_meals.dart';
import 'package:fitnessapp/screens/meal_detail_screen.dart';
import 'package:fitnessapp/models/meal.dart';


class HomeMainPage extends StatefulWidget {
  final void Function(int index) onTabChange;

  const HomeMainPage({super.key, required this.onTabChange});

  @override
  State<HomeMainPage> createState() => HomeMainPageState();
}

class HomeMainPageState extends State<HomeMainPage> with RouteAware {
  bool _didInitialLoad = false;

  late List<Meal> suggestedMeals;
  int weeklyWorkouts = 0;
  String heroMessage = "";
  String userName = "User";
  String avatarUrl = "";
  double? currentWeight;
  double? targetWeight;
  double? remainingKg;

  List<Map<String, String>> homeVideos = [];
  Map<String, String>? lastWatched;

  static const double _cardRadius = 20.0;

  @override
  void initState() {
    super.initState();
    suggestedMeals = [...breakfastMeals.take(1),
        ...lunchMeals.take(1), ...dinnerMeals.take(1)];
  

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _loadUserProfile();
    await _loadHomeRecommendations();
    await _loadLastWatched();
    await loadWeeklySummary();
  });
}

  @override
  void didChangeDependencies() {
   super.didChangeDependencies();

  final route = ModalRoute.of(context);
  if (route is PageRoute) {
    routeObserver.subscribe(this, route);
  }

  if (!_didInitialLoad) {
    _didInitialLoad = true;
    _refreshHome();
  }
}


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  
  @override
  void didPopNext() {
    loadWeeklySummary();
    _loadUserProfile();
    _refreshHome();
  }

  Future<void> _refreshHome() async {
    await _loadUserProfile();
    await _loadHomeRecommendations();
    await _loadLastWatched();
    await loadWeeklySummary();
  }

  Future<void> _loadUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString("email");

  if (email == null) return;

  final w = prefs.getDouble("weight_$email");
  final t = prefs.getDouble("target_weight_$email");

  setState(() {
    userName = prefs.getString("display_name_$email") ?? "User";
    avatarUrl = prefs.getString("avatar_url_$email") ?? "";
    currentWeight = w;
    targetWeight = t;

    if (w != null && t != null) {
      remainingKg = (t - w).clamp(0, 999);
    } else {
      remainingKg = null;
    }
  });
}

  // ---------------------------------------------------------
  // HOME RECOMMENDATION SELECTOR (3 items max)
  // ---------------------------------------------------------
  Future<void> _loadHomeRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWatchedTitle = prefs.getString("last_watched_title");

    List<Map<String, String>> list = List.from(masterWorkouts);
    list.shuffle();

    List<Map<String, String>> selected = [];

    if (lastWatchedTitle != null) {
      final last = list.firstWhere(
        (w) => w["title"] == lastWatchedTitle,
        orElse: () => {},
      );
      if (last.isNotEmpty) selected.add(last);
    }

    for (var w in list) {
      if (selected.length == 3) break;

      bool sameCategory =
          selected.any((s) => s["category"] == w["category"]);

      if (!sameCategory) {
        selected.add(w);
      }
    }

    while (selected.length < 3 && selected.length < list.length) {
      selected.add(list[selected.length]);
    }

    setState(() => homeVideos = selected);
  }

  Future<void> _loadLastWatched() async {
    final prefs = await SharedPreferences.getInstance();

    final title = prefs.getString("last_watched_title");
    if (title == null) return;

    setState(() {
      lastWatched = {
        "title": title,
        "url": prefs.getString("last_watched_url") ?? "",
        "type": prefs.getString("last_watched_type") ?? "mp4",
        "tags": prefs.getString("last_watched_tags") ?? "",
        "thumbnail": prefs.getString("last_watched_thumbnail") ?? "",
      };
    });
  }

  Future<void> loadWeeklySummary() async {
  try {
    final summary = await ProgressService.getWeeklySummary();

    setState(() {
      weeklyWorkouts = summary["weekly_workouts"]?? 0;

      if (weeklyWorkouts == 0) {
        heroMessage = "Let’s get started this week 💪";
      } else if (weeklyWorkouts <= 2) {
        heroMessage = "Nice momentum — keep going 🔥";
      } else {
        heroMessage = "Excellent consistency this week 🚀";
      }
    });
  } catch (e) {
    debugPrint("Failed to load weekly summary: $e");
  }
}


  void _switchTab(int index) => widget.onTabChange(index);

  bool _isYoutube(String url) =>
      url.contains("youtube.com") || url.contains("youtu.be");

  String _extractYoutubeId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains("youtu.be")) return uri.pathSegments.first;
    return uri.queryParameters["v"] ?? "";
  }

  List<BoxShadow> _cardShadow(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      // Softer, tighter shadow for AMOLED
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];
    } else {
      // Light mode soft shadow
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [
                    Color(0xFFFDF7F1),
                    Color(0xFFF7F4F0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isDark ? theme.scaffoldBackgroundColor : null,
        ),
        child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 16),

              _heroCard(context),
              const SizedBox(height: 24),

              _sectionHeader(
                context,
                "Recommended Workouts",
                onSeeAll: () => _switchTab(1),
              ),
              const SizedBox(height: 12),
              _recommendedCarousel(context),
              const SizedBox(height: 24),

              if (lastWatched != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Continue Watching",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _continueWatchingCard(context),
                const SizedBox(height: 24),
              ],

              _sectionHeader(
              context,
              "Suggested meals for you",
              onSeeAll: () => _switchTab(2),
          ),
          const SizedBox(height: 12),
          _suggestedMealCarousel(context),
          const SizedBox(height: 36),
          
              _sectionHeader(
                context,
                "Supplements",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupplementsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _supplementList(context),
              const SizedBox(height: 24),

              _sectionHeader(
                context,
                "Activity Overview",
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              _activityGrid(context),
              const SizedBox(height: 24),

              _sectionHeader(
                context,
                "Progress Tracker",
                onSeeAll: () => _switchTab(3),
              ),
              const SizedBox(height: 12),
              _progressCard(context),
            ],
          ),
        ),
      ),
     ), 
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _topBar(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$userName 👋",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- HERO CARD ----------------
  Widget _heroCard(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(_cardRadius),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9A5B), Color(0xFFFF7A5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are doing great 🔥",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$weeklyWorkouts workouts this week\n$heroMessage",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _weightBadge(context),
      ],
    ),
  );
}

  // ---------------- WEIGHT BADGE ----------------
 Widget _weightBadge(BuildContext context) {
  if (currentWeight == null || targetWeight == null) {
    return const SizedBox.shrink();
  }

  final reachedGoal = remainingKg != null && remainingKg! <= 0;

  return Container(
    height: 82,
    width: 82,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${currentWeight!.toStringAsFixed(1)}kg",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Target ${targetWeight!.toStringAsFixed(0)}kg",
          style: const TextStyle(
            color: Color.fromARGB(255, 241, 228, 228),
            fontSize: 12,
          ),
        ),
        if (!reachedGoal) ...[
          const SizedBox(height: 4),
          Text(
            "-${remainingKg!.toStringAsFixed(1)}kg",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          const Text(
            "Goal 🎯",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    ),
  );
}

  // ---------------- SECTION HEADER ----------------
  Widget _sectionHeader(BuildContext context, String title,
      {required VoidCallback onSeeAll}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            "See all",
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- RECOMMENDED CAROUSEL ----------------
  Widget _recommendedCarousel(BuildContext context) {
    final theme = Theme.of(context);

    if (homeVideos.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: homeVideos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = homeVideos[index];
          final isYT = _isYoutube(item["url"]!);

          return GestureDetector(
            onTap: () {
              final finalUrl =
                  isYT ? _extractYoutubeId(item["url"]!) : item["url"]!;
              final type = isYT ? "youtube" : "mp4";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    title: item["title"]!,
                    videoUrl: finalUrl,
                    type: type,
                    tags: item["tags"]!,
                    thumbnail: item["thumbnail"]!,
                    nextVideos:
                        masterWorkouts.where((v) => v != item).toList(),
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_cardRadius),
                child: Stack(
                  children: [
                    Image.network(
                      item["thumbnail"]!,
                      height: 190,
                      width: 260,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["tags"]!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item["category"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const CircleAvatar(
                                backgroundColor: Colors.orange,
                                radius: 20,
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- CONTINUE WATCHING CARD ----------------
  Widget _continueWatchingCard(BuildContext context) {
    final theme = Theme.of(context);
    final v = lastWatched!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              title: v["title"]!,
              videoUrl: v["url"]!,
              type: v["type"]!,
              tags: v["tags"]!,
              thumbnail: v["thumbnail"]!,
              nextVideos: masterWorkouts
                  .where((x) => x["title"] != v["title"])
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: _cardShadow(context),
        ),
        child: Column(
          children: [
            // Accent strip at top
            Container(
              height: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_cardRadius),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC38B), Color(0xFFFF8A65)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      v["thumbnail"]!,
                      width: 90,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v["title"]!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v["tags"]!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.orange,
                    size: 32,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ---------------- MEAL CARD ----------------
  // ignore: unused_element
  Widget _mealCard(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _switchTab(2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: _cardShadow(context),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                "https://www.themealdb.com/images/media/meals/1548772327.jpg",
                height: 72,
                width: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "High protein salad & egg",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "540 kcal · 25 g protein · 16 g fats",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ideal for lean muscle gain.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestedMealCarousel(BuildContext context) {
  final theme = Theme.of(context);

  return SizedBox(
    height: 155,
    child: PageView.builder(
      controller: PageController(viewportFraction: 0.88),
      itemCount: suggestedMeals.length,
      itemBuilder: (context, index) {
        final meal = suggestedMeals[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(meal: meal),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: _cardShadow(context),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(_cardRadius),
                  ),
                  child: Image.network(
                    meal.imageUrl,
                    width: 110,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${meal.calories} kcal · ${meal.protein} g protein · ${meal.fats} g fats",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meal.prepTime,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  // ---------------- ACTIVITY GRID ----------------
  Widget _activityGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow(context),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: _ActivityBox(
                  value: "7 h",
                  label: "Rest",
                  icon: Icons.self_improvement,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ActivityBox(
                  value: "1.1 h",
                  label: "Workout",
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActivityBox(
                  value: "6.8 k",
                  label: "Steps",
                  icon: Icons.directions_walk,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ActivityBox(
                  value: "15 h",
                  label: "Sleep (week)",
                  icon: Icons.nights_stay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS CARD ----------------
  Widget _progressCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _switchTab(3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF080A10), Color(0xFF151821)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF171B2A), Color(0xFF252C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: isDark ? _cardShadow(context) : _cardShadow(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Progress tracker",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Track weight, workouts and AI recommendations in one place.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "1,879+ AI check-ins completed",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SUPPLEMENT LIST ----------------
  Widget _supplementList(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          SupplementCard(
            name: "Whey Protein",
            price: "RM380",
            image:
                "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/5bb2aa884e16d4b5f4d2f5bc3b73fb78362b2faf/proteinimg/Whey%20Protein.png",
            url:
                "https://shopee.com.my/Optimum-Nutrition-100-ORIGINAL-ON-gold-standard-whey-5lbs-i.55940991.905613857?extraParams=%7B%22display_model_id%22%3A187914699623%2C%22model_selection_logic%22%3A3%7D&sp_atk=06c3763b-faa6-4c45-9908-f3cbbc437cba&xptdk=06c3763b-faa6-4c45-9908-f3cbbc437cba",
          ),
          SupplementCard(
            name: "Creatine",
            price: "RM89",
            image:
                "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/5bb2aa884e16d4b5f4d2f5bc3b73fb78362b2faf/proteinimg/creatine.png",
            url:
                "https://shopee.com.my/Optimum-Nutrition-Micronized-Creatine-Powder-Monohydrate-Unflavored-Strength-Endurance-Muscle-i.23767.5989718?extraParams=%7B%22display_model_id%22%3A295859866%2C%22model_selection_logic%22%3A3%7D&sp_atk=dec07113-6fba-4f6e-ba3c-3db0c377aefc&xptdk=dec07113-6fba-4f6e-ba3c-3db0c377aefc",
          ),
          SupplementCard(
            name: "BCAA Amino",
            price: "RM59",
            image:
                "https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/proteinimg/Bcaa%20amino.png",
            url:
                "https://shopee.com.my/RULE-1-Essential-Amino-9-(30-Servings)-i.1352122896.26264193975?extraParams=%7B%22display_model_id%22%3A157503353615%2C%22model_selection_logic%22%3A3%7D&sp_atk=8a980eab-04f5-4547-a226-df300debeb8a&xptdk=8a980eab-04f5-4547-a226-df300debeb8a",
          ),
        ],
      ),
    );
  }
}

// ---------------- Activity Box ---------------
class _ActivityBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ActivityBox({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0E0F12), Color(0xFF17191F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFDFEFE), Color(0xFFF6F8FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ⭐ SUPPLEMENT CARD WIDGET (For Shopee Links)
// ============================================================
class SupplementCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final String url;

  const SupplementCard({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.url,
  });

  void _openShopee() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _openShopee,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    image,
                    height: 105,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(.95),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Hot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFE8D3A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SEARCH DELEGATE ----------------
class SimpleSearchDelegate extends SearchDelegate<String> {
  final List<String> recent = const ['push up', 'salad', 'leg day'];

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) =>
      Center(child: Text('Search: $query'));

  @override
  Widget buildSuggestions(BuildContext context) {
    final items = query.isEmpty
        ? recent
        : recent
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.search),
        title: Text(items[i]),
        onTap: () => query = items[i],
      ),
    );
  }
}
