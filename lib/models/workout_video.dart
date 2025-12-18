class WorkoutVideo {
  final String id;
  final String title;
  final String muscleGroup; // Chest, Back, etc.
  final String level;       // Beginner, Intermediate, Advanced
  final String duration;    // "10 min"
  final String thumbnailUrl;
  final String videoUrl;    // MP4 from Firebase later

  WorkoutVideo({
    required this.id,
    required this.title,
    required this.muscleGroup,
    required this.level,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}

// For now: mock data using placeholder URLs.
// Later: replace with your real Firebase URLs.
final List<WorkoutVideo> mockWorkoutVideos = [
  WorkoutVideo(
    id: 'chest_1',
    title: 'Dumbbell Bench Press',
    muscleGroup: 'Chest',
    level: 'Intermediate',
    duration: '8 min',
    thumbnailUrl: 'https://via.placeholder.com/300x170.png?text=Chest+Workout',
    videoUrl: 'https://YOUR_FIREBASE_URL_HERE/chest_1.mp4',
  ),
  WorkoutVideo(
    id: 'back_1',
    title: 'Bent Over Row',
    muscleGroup: 'Back',
    level: 'Intermediate',
    duration: '7 min',
    thumbnailUrl: 'https://via.placeholder.com/300x170.png?text=Back+Workout',
    videoUrl: 'https://YOUR_FIREBASE_URL_HERE/back_1.mp4',
  ),
  // you’ll add Biceps / Shoulders / Triceps / Legs / Abs similarly
];
