import 'package:flutter/material.dart';
import 'package:fitnessapp/screens/video_player_screen.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  /// Detect if URL is YouTube
  bool isYouTube(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be");
  }

  /// Extract YouTube ID
  String extractId(String url) {
    final uri = Uri.parse(url);

    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.first;
    }
    return uri.queryParameters["v"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final categories = {
      "Chest": [
        {"title": "Chest Press", "videoUrl": "https://www.youtube.com/watch?v=X1TuhAn6C-g"},
        {"title": "Incline Dumbbell Press", "videoUrl": "https://www.youtube.com/watch?v=8iPEnn-ltC8"},
      ],
      "Back": [
        {"title": "Pull Ups", "videoUrl": "https://www.youtube.com/watch?v=eGo4IYlbE5g"},
        {"title": "Deadlift", "videoUrl": "https://www.youtube.com/watch?v=op9kVnSso6Q"},
      ],
      "Biceps": [
        {"title": "Barbell Curl", "videoUrl": "https://www.youtube.com/watch?v=kwG2ipFRgfo"},
        {"title": "Hammer Curl", "videoUrl": "https://www.youtube.com/watch?v=zC3nLlEvin4"},
      ],
      "Shoulders": [
        {"title": "Overhead Press", "videoUrl": "https://www.youtube.com/watch?v=qEwKCR5JCog"},
        {"title": "Lateral Raise", "videoUrl": "https://www.youtube.com/watch?v=3VcKaXpzqRo"},
      ],
      "Abs": [
        {"title": "Crunches", "videoUrl": "https://www.youtube.com/watch?v=Xyd_fa5zoEU"},
        {"title": "Leg Raises", "videoUrl": "https://www.youtube.com/watch?v=JB2oyawG9KI"},
      ],
      "Legs": [
        {"title": "Squats", "videoUrl": "https://www.youtube.com/watch?v=aclHkVaku9U"},
        {"title": "Lunges", "videoUrl": "https://www.youtube.com/watch?v=QOVaHwm-Q6U"},
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Categories"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: categories.entries.map((entry) {
          final muscle = entry.key;
          final workouts = entry.value;

          return ExpansionTile(
            title: Text(
              muscle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: workouts.map((video) {
              final url = video["videoUrl"]!;
              final isYT = isYouTube(url);
              final String thumb = isYT
                  ? "https://img.youtube.com/vi/${extractId(url)}/hqdefault.jpg"
                  : "https://via.placeholder.com/400x225.png?text=Workout+Video";

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    thumb,
                    width: 60,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(video["title"]!),
                trailing: const Icon(Icons.play_arrow_rounded, color: Colors.orange),
                onTap: () {
                  _openVideo(context, video["title"]!, url, isYT, thumb, workouts);
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  void _openVideo(
    BuildContext context,
    String title,
    String url,
    bool isYT,
    String thumbnail,
    List workouts,
  ) {
    // Build next recommended list (others in same muscle group)
    final next = workouts.where((v) => v["videoUrl"] != url).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          title: title,
          videoUrl: isYT ? extractId(url) : url,
          type: isYT ? "youtube" : "mp4",
          tags: "",
          thumbnail: thumbnail,
          nextVideos: next.map((e) => Map<String, String>.from(e)).toList(),
        ),
      ),
    );
  }
}
