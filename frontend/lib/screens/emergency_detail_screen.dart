import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/video_links.dart';
import '../models/emergency_tutorial.dart';

class EmergencyDetailScreen extends StatefulWidget {
  final EmergencyTutorial emergency;

  const EmergencyDetailScreen({super.key, required this.emergency});

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.emergency.color));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: color,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).cardTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.emergency.title,
                  style: TextStyle(
                    color: Theme.of(context).cardTheme.color ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Theme.of(context).cardTheme.color),
                        SizedBox(width: 4),
                        Text(
                          widget.emergency.videoDuration,
                          style: TextStyle(
                            color: Theme.of(context).cardTheme.color ?? Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Video Section — in-app YouTube player
              SliverToBoxAdapter(
                child: _YoutubePlayerCard(
                  videoUrl: VideoLinks.forEmergency(widget.emergency.title),
                  duration: widget.emergency.videoDuration,
                  accentColor: color,
                ),
              ),

              // Step-by-Step Guide
              SliverToBoxAdapter(
                child: _buildStepByStepGuide(color),
              ),

              // DO and DON'T Lists
              SliverToBoxAdapter(
                child: _buildDoAndDontLists(color),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepByStepGuide(Color color) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered, color: color, size: 28),
              SizedBox(width: 12),
              Text(
                'Step-by-Step Guide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Follow these steps carefully:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 16),
          ...widget.emergency.steps.asMap().entries.map((entry) {
            final step = entry.value;
            return _buildStepCard(step, color);
          }),
        ],
      ),
    );
  }

  Widget _buildStepCard(EmergencyStep step, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: step.isCritical
            ? color.withOpacity(isDark ? 0.12 : 0.05)
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: step.isCritical ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFBAC2CC)),
          width: step.isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: step.isCritical ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: step.isCritical ? Colors.white : color,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Step Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    if (step.isCritical)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CRITICAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoAndDontLists(Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // DO List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF102010) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'DO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.emergency.doList.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // DON'T List
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF200C0C) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE57373), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cancel, color: Color(0xFFE57373), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'DON\'T',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.emergency.dontList.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.close, color: Color(0xFFE57373), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ── WebView YouTube player ─────────────────────────────────────────────────
// Loads the FULL YouTube page (not the embed API), exactly like WhatsApp/
// Telegram do.  No Error 150 — works for ANY public video regardless of the
// channel's "Allow embedding" setting.

class _YoutubePlayerCard extends StatefulWidget {
  final String videoUrl;
  final String duration;
  final Color accentColor;

  const _YoutubePlayerCard({
    required this.videoUrl,
    required this.duration,
    required this.accentColor,
  });

  @override
  State<_YoutubePlayerCard> createState() => _YoutubePlayerCardState();
}

class _YoutubePlayerCardState extends State<_YoutubePlayerCard> {
  bool _playerVisible = false;

  String? _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    return null;
  }

  // Mobile-friendly YouTube URL that auto-plays and hides navigation chrome
  String get _playerUrl {
    final id = _extractVideoId(widget.videoUrl);
    if (id == null) return widget.videoUrl;
    // youtu.be short URL forces the mobile YouTube PWA which auto-plays cleanly
    return 'https://m.youtube.com/watch?v=$id&autoplay=1&rel=0';
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId(widget.videoUrl);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Player area ─────────────────────────────────────────────────
          SizedBox(
            height: 210,
            child: _playerVisible
                ? InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(_playerUrl),
                    ),
                    initialSettings: InAppWebViewSettings(
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      javaScriptEnabled: true,
                      useHybridComposition: true,
                      domStorageEnabled: true,
                    ),
                  )
                : _ThumbnailOverlay(
                    videoId: videoId,
                    duration: widget.duration,
                    accentColor: widget.accentColor,
                    onPlay: () => setState(() => _playerVisible = true),
                  ),
          ),

          // ── Bottom bar ──────────────────────────────────────────────────
          Material(
            color: const Color(0xFF1A1A1A),
            child: InkWell(
              onTap: _openExternal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new, color: Colors.white54, size: 15),
                    const SizedBox(width: 6),
                    const Text(
                      'Open in YouTube',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text('YouTube',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thumbnail shown before play is tapped ──────────────────────────────────

class _ThumbnailOverlay extends StatelessWidget {
  final String? videoId;
  final String duration;
  final Color accentColor;
  final VoidCallback onPlay;

  const _ThumbnailOverlay({
    required this.videoId,
    required this.duration,
    required this.accentColor,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final thumbUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return GestureDetector(
      onTap: onPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          if (thumbUrl != null)
            Image.network(
              thumbUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) =>
                  p == null ? child : _gradientBg(),
              errorBuilder: (_, __, ___) => _gradientBg(),
            )
          else
            _gradientBg(),

          // Scrim
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.55)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Play button
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.93),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.play_arrow_rounded, size: 46, color: accentColor),
            ),
          ),

          // Duration badge
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.78),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(duration,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),

          // "Tap to play" label
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Tap to play',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBg() => Container(
        color: Colors.black87,
        child: Center(
          child: Icon(Icons.play_circle_outline,
              size: 56, color: accentColor.withOpacity(0.7)),
        ),
      );
}
