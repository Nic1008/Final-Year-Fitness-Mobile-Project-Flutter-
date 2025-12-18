import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl; // YouTube ID or MP4 URL
  final String type;     // "youtube" or "mp4"
  final String tags;
  final String thumbnail;
  final List<Map<String, String>> nextVideos;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.type,
    required this.tags,
    required this.thumbnail,
    required this.nextVideos,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _mp4Controller;
  ChewieController? _chewieController;
  YoutubePlayerController? _ytController;

  bool _loading = true;
  bool _error = false;

  // --------------------------------------------------------
  //                INITIALIZATION
  // --------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.type == "mp4") {
        _mp4Controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

        await _mp4Controller!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _mp4Controller!,
          autoPlay: true,
          looping: false,
          showControlsOnInitialize: false,
          allowPlaybackSpeedChanging: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.orange,
            handleColor: Colors.orangeAccent,
          ),
        );
      } else {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: widget.videoUrl,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showFullscreenButton: true,
            strictRelatedVideos: true,
            color: 'white',
          ),
        );
      }

      // Save last watched
final prefs = await SharedPreferences.getInstance();
prefs.setString("last_watched_title", widget.title);
prefs.setString("last_watched_url", widget.videoUrl);
prefs.setString("last_watched_type", widget.type);
prefs.setString("last_watched_tags", widget.tags);
prefs.setString("last_watched_thumbnail", widget.thumbnail);

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _mp4Controller?.dispose();
    _chewieController?.dispose();
    _ytController?.close();
    super.dispose();
  }

  // --------------------------------------------------------
  //           HELPERS
  // --------------------------------------------------------
  String _extractYoutubeId(String url) {
    final uri = Uri.parse(url);

    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";
    }

    return uri.queryParameters["v"] ?? "";
  }

  // 🔥 FIXED + POLISHED open-another-video navigation
  void _openAnotherVideo(Map<String, String> v) {
    final url = v['url']!;
    final isYT = url.contains("youtube.com") || url.contains("youtu.be");

    final type = isYT ? "youtube" : "mp4";
    final finalUrl = isYT ? _extractYoutubeId(url) : url;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => VideoPlayerScreen(
          title: v['title']!,
          videoUrl: finalUrl,
          type: type,
          tags: v['tags'] ?? "",
          thumbnail: v['thumbnail'] ?? "",
          nextVideos:
              widget.nextVideos.where((x) => x['title'] != v['title']).toList(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // --------------------------------------------------------
  //                    UI
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final playerWidget = _loading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          )
        : _error
            ? const Center(
                child: Text(
                  "Unable to load video",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : widget.type == "mp4"
                ? Chewie(controller: _chewieController!)
                : YoutubePlayer(controller: _ytController!);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            //                      VIDEO PLAYER
            // ----------------------------------------------------
            AspectRatio(
              aspectRatio: widget.type == "mp4"
                  ? (_mp4Controller?.value.aspectRatio ?? 16 / 9)
                  : 16 / 9,
              child: playerWidget,
            ),

            // ----------------------------------------------------
            //                    BOTTOM PANEL
            // ----------------------------------------------------
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E0F12),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // TAGS
                    Text(
                      widget.tags,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(color: Colors.white10, thickness: 1),
                    const SizedBox(height: 10),

                    const Text(
                      "Next Recommended",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ----------------------------------------------------
                    //           NEXT VIDEOS LIST
                    // ----------------------------------------------------
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.nextVideos.length,
                        itemBuilder: (context, i) {
                          final v = widget.nextVideos[i];

                          return InkWell(
                            onTap: () => _openAnotherVideo(v),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      v['thumbnail']!,
                                      height: 70,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // TEXT INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v['title']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          v['tags'] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white70,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
