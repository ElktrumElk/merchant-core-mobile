import 'dart:async';
import 'dart:math';

import 'package:first_flutter_project/network/market_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Billboard extends StatefulWidget {
  const Billboard({super.key, this.ads});

  final List<Map<String, dynamic>>? ads;

  @override
  State<Billboard> createState() => _BillboardState();
}

class _BillboardState extends State<Billboard> {
  static const int _maxAds = 4;
  static const Duration _minDuration = Duration(seconds: 10);
  static const Duration _maxDuration = Duration(minutes: 1);
  static const Duration _videoInitTimeout = Duration(seconds: 10);
  static const Duration _disposeTimeout = Duration(seconds: 3);
  static const Duration _watchdogTimeout = Duration(seconds: 25);

  final MarketService _marketService = MarketService();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _adverts = [];
  List<VideoPlayerController?> _controllers = [];
  int _currentPage = 0;
  bool _isLoading = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ads != null) {
      _prepare(widget.ads!);
    } else {
      _fetchAndPrepare();
    }
  }

  @override
  void didUpdateWidget(Billboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ads != null && oldWidget.ads != widget.ads) {
      setState(() => _isLoading = true);
      _prepare(widget.ads!);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndPrepare() async {
    try {
      final ads = await _marketService.getAdverts();
      if (mounted) await _prepare(ads);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _prepare(List<Map<String, dynamic>> source) async {
    final gen = ++_generation;
    final watchdog = Timer(_watchdogTimeout, () {
      if (mounted && gen == _generation) {
        setState(() => _isLoading = false);
      }
    });
    try {
      final shuffled = source
          .where((a) => a['video_url'] is String &&
              (a['video_url'] as String).isNotEmpty)
          .toList()
        ..shuffle(Random());

      final ads = <Map<String, dynamic>>[];
      final controllers = <VideoPlayerController?>[];

      for (final ad in shuffled) {
        if (ads.length >= _maxAds) break;
        final videoUrl = ad['video_url'] as String;
        final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        var usable = false;
        try {
          await controller.initialize().timeout(_videoInitTimeout);
          final duration = controller.value.duration;
          usable =
              duration >= _minDuration && duration <= _maxDuration;
        } catch (_) {}
        if (usable) {
          ads.add(ad);
          controllers.add(controller);
          continue;
        }
        if (_isUsablePoster(ad)) {
          ads.add(ad);
          controllers.add(null);
        }
        _disposeQuietly(controller);
      }

      if (!mounted || gen != _generation) {
        for (final c in controllers) {
          _disposeQuietly(c);
        }
        return;
      }

      _disposeControllers();
      setState(() {
        _adverts = ads;
        _controllers = controllers;
        _isLoading = false;
      });
      _bindListeners();
      _playCurrent();
    } finally {
      watchdog.cancel();
      if (mounted && gen == _generation) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _disposeControllers() {
    for (final c in _controllers) {
      c?.removeListener(_noop);
      _disposeQuietly(c);
    }
    _controllers = [];
  }

  void _disposeQuietly(VideoPlayerController? controller) {
    final future = controller?.dispose().timeout(_disposeTimeout);
    if (future != null) {
      unawaited(future.catchError((_) {}));
    }
  }

  static bool _isUsablePoster(Map<String, dynamic> ad) {
    final url = ad['advert_url'];
    return url is String && url.isNotEmpty;
  }

  static void _noop() {}

  void _bindListeners() {
    for (var i = 0; i < _controllers.length; i++) {
      final controller = _controllers[i];
      if (controller == null) continue;
      final index = i;
      controller.addListener(() {
        if (index != _currentPage) return;
        final duration = controller.value.duration;
        if (duration > Duration.zero &&
            controller.value.position >= duration) {
          _advance();
        }
      });
    }
  }

  void _playCurrent() {
    if (_adverts.isEmpty) return;
    final controller = _controllers.elementAtOrNull(_currentPage);
    if (controller == null) return;
    controller.seekTo(Duration.zero);
    controller.play();
  }

  void _advance() {
    if (_controllers.isEmpty) return;
    if (!_pageController.hasClients) return;
    final next = (_currentPage + 1) % _controllers.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    for (var i = 0; i < _controllers.length; i++) {
      if (i == index) continue;
      _controllers[i]?.pause();
    }
    _currentPage = index;
    setState(() {});
    _playCurrent();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeleton(context);
    }

    if (_adverts.isEmpty) {
      return _buildPlaceholder(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _adverts.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _buildPage(index),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _adverts.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentPage ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surface.withAlpha(120),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'Sponsored',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.withAlpha(150)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Featured Spotlight',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Check back soon for new offers',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    final ad = _adverts[index];
    final controller = _controllers[index];

    if (controller == null) {
      return _buildPosterPage(ad);
    }

    final title = ad['title'] ?? 'Special Offer';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width > 0
                  ? controller.value.size.width
                  : 400,
              height: controller.value.size.height > 0
                  ? controller.value.size.height
                  : 200,
              child: GestureDetector(
                onTap: () => controller.value.isPlaying
                    ? controller.pause()
                    : controller.play(),
                child: VideoPlayer(controller),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(170),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Badge(text: 'AD · ${_formatDuration(controller.value.duration)}'),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 14,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    return IconButton(
                      onPressed: () => value.isPlaying
                          ? controller.pause()
                          : controller.play(),
                      icon: Icon(
                        value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 30,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final duration = value.duration.inMilliseconds;
                final progress = duration == 0
                    ? 0.0
                    : (value.position.inMilliseconds / duration).clamp(0.0, 1.0);
                return LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterPage(Map<String, dynamic> ad) {
    final posterUrl = ad['advert_url'] as String?;
    final title = ad['title'] ?? 'Special Offer';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (posterUrl != null)
            Image.network(
              posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, _, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(170),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: _Badge(text: 'AD'),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 14,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return 'Ad';
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '${s}s';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}