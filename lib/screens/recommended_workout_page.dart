import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitnessapp/screens/video_player_screen.dart';

class RecommendedWorkoutPage extends StatefulWidget {
  const RecommendedWorkoutPage({super.key});

  @override
  State<RecommendedWorkoutPage> createState() => _RecommendedWorkoutPageState();
}

class _RecommendedWorkoutPageState extends State<RecommendedWorkoutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<int> favorites = [];

  String _selectedCategory = 'All';
  final List<String> _categories = const [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Abs',
    'Full Body'
  ];

  // Workout List
  final List<Map<String, String>> videos = [
    {
      'title': 'Full Body Strength (YouTube)',
      'tags': 'Full Body • Intermediate • 30 min',
      'url': 'https://www.youtube.com/watch?v=UItWltVZZmE',
      'thumbnail': 'https://img.youtube.com/vi/UItWltVZZmE/hqdefault.jpg',
      'category': 'Full Body',
    },
    {
      'title': 'Barbell Squats (YouTube)',
      'tags': 'Legs • Advanced • 10 min',
      'url': 'https://youtu.be/aclHkVaku9U',
      'thumbnail': 'https://img.youtube.com/vi/aclHkVaku9U/hqdefault.jpg',
      'category': 'Legs',
    },
    {
      'title': 'Full Chest Workout',
      'tags': 'Chest • Beginner',
      'url':
          'https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/videos/chestworkout%20(2).mp4',
      'thumbnail':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/thumbnails/chestworkouttn.png',
      'category': 'Chest',
    },
    {
      'title': 'Bench Press',
      'tags': 'Chest • Intermediate',
      'url':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/videos/benchpress.mp4',
      'thumbnail':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/thumbnails/benchpresstn.png',
      'category': 'Chest',
    },
    {
      'title': 'Lat Pulldown',
      'tags': 'Back • Intermediate',
      'url':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/videos/LatPulldown.mp4',
      'thumbnail':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/thumbnails/latpulldowntn.png',
      'category': 'Back',
    },
    {
      'title': 'Bicep Curls',
      'tags': 'Arms • Beginner',
      'url':
          'https://cdn.jsdelivr.net/gh/Nic1008/fitness-workout-videos/videos/bicep.mp4',
      'thumbnail':
          'https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/thumbnails/bicepcurltn.png',
      'category': 'Arms',
    },
    { 
      'title': 'Lateral Raises',
      'tags': 'Shoulders • Beginner',
      'url':
          'https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/videos/LateralRaise.mp4',
      'thumbnail':
          'https://raw.githubusercontent.com/Nic1008/fitness-workout-videos/main/thumbnails/Screenshot%202025-12-19%20003505.png',
      'category': 'Shoulders',
    },
  ];

  bool isYouTube(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be");
  }

  String extractYoutubeId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.first;
    }
    return uri.queryParameters["v"] ?? "";
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredVideos {
    if (_selectedCategory == 'All') return videos;
    return videos.where((v) => v['category'] == _selectedCategory).toList();
  }

  void _openFilterSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.cardColor,
                labelStyle: GoogleFonts.poppins(
                  color: selected
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                ),
                onSelected: (_) {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // AMOLED Black Background
    final Color background = isDark ? Colors.black : const Color(0xFFF7F6F3);
    final Color cardColor = isDark ? const Color(0xFF111111) : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER -----------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recommended Workouts',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  // FILTER BUTTON
                  IconButton(
                    onPressed: _openFilterSheet,
                    icon: Icon(
                      Icons.filter_list,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // VIDEO LIST --------------------------------------
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = _filteredVideos[index];
                    final originalIndex = videos.indexOf(video);
                    final isFav = favorites.contains(originalIndex);

                    final nextVideos =
                        _filteredVideos.where((v) => v != video).toList();

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.05),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ],
                      ),
                      child: Column(
                        children: [
                          // Thumbnail --------------------------------
                          GestureDetector(
                            onTap: () {
                              final url = video['url']!;
                              String finalUrl = url;
                              String type = "mp4";

                              if (isYouTube(url)) {
                                type = "youtube";
                                finalUrl = extractYoutubeId(url);
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    title: video['title']!,
                                    videoUrl: finalUrl,
                                    type: type,
                                    tags: video['tags']!,
                                    thumbnail: video['thumbnail']!,
                                    nextVideos: nextVideos,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                              child: Image.network(
                                video['thumbnail']!,
                                height: 190,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // CONTENT -----------------------------------
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + Favorite
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        video['title']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: theme
                                              .textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isFav
                                              ? favorites.remove(originalIndex)
                                              : favorites.add(originalIndex);
                                        });
                                      },
                                      icon: Icon(
                                        isFav
                                            ? Icons.star
                                            : Icons.star_border_rounded,
                                        color: isFav
                                            ? Colors.amber
                                            : theme.iconTheme.color,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  '${video['tags']} • ${video['category']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
