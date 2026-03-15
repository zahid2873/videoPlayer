// // // import 'dart:async';

// // // import 'package:chewie/chewie.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:video_player/video_player.dart';
// // // import 'package:video_player_app/utils.dart/utils.dart';

// // // // Custom Chewie Controls
// // // // Drop into ChewieController via customControls: const CustomVideoControls()

// // // class CustomVideoControls extends StatefulWidget {
// // //   const CustomVideoControls({super.key, this.thumbnail});

// // //   /// Optional blurred thumbnail shown while buffering.
// // //   final Uint8List? thumbnail;

// // //   @override
// // //   State<CustomVideoControls> createState() => _CustomVideoControlsState();
// // // }

// // // class _CustomVideoControlsState extends State<CustomVideoControls>
// // //     with SingleTickerProviderStateMixin {
// // //   // ── Chewie / VideoPlayer refs ────────────────────────────────────────────
// // //   late ChewieController _chewie;
// // //   VideoPlayerController get _vpc => _chewie.videoPlayerController;

// // //   // ── UI state ─────────────────────────────────────────────────────────────
// // //   bool _controlsVisible = true;
// // //   bool _isSeeking = false;
// // //   double _seekPosition = 0; // 0..1
// // //   double _volume = 1.0;
// // //   bool _showVolumeSlider = false;
// // //   double _playbackSpeed = 1.0;
// // //   bool _isFullScreen = false;

// // //   // ── Animation ─────────────────────────────────────────────────────────────
// // //   late AnimationController _fadeCtrl;
// // //   late Animation<double> _fadeAnim;

// // //   // ── Auto-hide timer ───────────────────────────────────────────────────────
// // //   Timer? _hideTimer;

// // //   // ── Seek-tap tracking (double-tap seek) ───────────────────────────────────
// // //   Timer? _seekFeedbackTimer;
// // //   int _seekSeconds = 0; // positive = forward, negative = back
// // //   bool _showSeekFeedback = false;
// // //   bool _seekLeft = false;

// // //   static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
// // //   static const _kAccentRed = Color(0xFFE53935);
// // //   static const _kBgGradient = [Color(0xCC000000), Colors.transparent];

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fadeCtrl = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 250),
// // //       value: 1,
// // //     );
// // //     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
// // //     _startHideTimer();
// // //   }

// // //   @override
// // //   void didChangeDependencies() {
// // //     super.didChangeDependencies();
// // //     _chewie = ChewieController.of(context);
// // //     _vpc.addListener(_onVideoUpdate);
// // //     _isFullScreen = _chewie.isFullScreen;
// // //     _volume = _vpc.value.volume;
// // //     setState(() {});
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _vpc.removeListener(_onVideoUpdate);
// // //     _fadeCtrl.dispose();
// // //     _hideTimer?.cancel();
// // //     _seekFeedbackTimer?.cancel();
// // //     super.dispose();
// // //   }

// // //   // ── Listeners ─────────────────────────────────────────────────────────────
// // //   void _onVideoUpdate() {
// // //     if (mounted) setState(() {});
// // //   }

// // //   // ── Controls visibility ───────────────────────────────────────────────────
// // //   void _toggleControls() {
// // //     setState(() => _controlsVisible = !_controlsVisible);
// // //     if (_controlsVisible) {
// // //       _fadeCtrl.forward();
// // //       _startHideTimer();
// // //     } else {
// // //       _fadeCtrl.reverse();
// // //       _hideTimer?.cancel();
// // //     }
// // //   }

// // //   void _showControls() {
// // //     if (!_controlsVisible) {
// // //       setState(() => _controlsVisible = true);
// // //       _fadeCtrl.forward();
// // //     }
// // //     _startHideTimer();
// // //   }

// // //   void _startHideTimer() {
// // //     _hideTimer?.cancel();
// // //     _hideTimer = Timer(const Duration(seconds: 4), () {
// // //       if (mounted && !_isSeeking && _vpc.value.isPlaying) {
// // //         setState(() => _controlsVisible = false);
// // //         _fadeCtrl.reverse();
// // //       }
// // //     });
// // //   }

// // //   // ── Playback controls ─────────────────────────────────────────────────────
// // //   void _togglePlay() {
// // //     _showControls();
// // //     _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
// // //   }

// // //   void _seek(Duration position) {
// // //     final clamped = position < Duration.zero
// // //         ? Duration.zero
// // //         : position > _vpc.value.duration
// // //         ? _vpc.value.duration
// // //         : position;
// // //     _vpc.seekTo(clamped);
// // //     _startHideTimer();
// // //   }

// // //   void _doubleTapSeek(bool forward) {
// // //     final delta = Duration(seconds: forward ? 10 : -10);
// // //     _seek(_vpc.value.position + delta);

// // //     setState(() {
// // //       _seekLeft = !forward;
// // //       _seekSeconds =
// // //           (forward ? 1 : -1) * ((_seekSeconds.abs() + 10).clamp(10, 999));
// // //       _showSeekFeedback = true;
// // //     });

// // //     _seekFeedbackTimer?.cancel();
// // //     _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
// // //       if (mounted) {
// // //         setState(() {
// // //           _showSeekFeedback = false;
// // //           _seekSeconds = 0;
// // //         });
// // //       }
// // //     });
// // //   }

// // //   void _setSpeed(double speed) {
// // //     setState(() => _playbackSpeed = speed);
// // //     _vpc.setPlaybackSpeed(speed);
// // //     Navigator.of(context).pop();
// // //   }

// // //   void _setVolume(double v) {
// // //     setState(() => _volume = v);
// // //     _vpc.setVolume(v);
// // //   }

// // //   // ── Helpers ───────────────────────────────────────────────────────────────
// // //   Duration get _duration => _vpc.value.duration;
// // //   Duration get _position => _vpc.value.position;
// // //   bool get _isPlaying => _vpc.value.isPlaying;
// // //   bool get _isBuffering => _vpc.value.isBuffering;

// // //   double get _progressFraction => _duration.inMilliseconds == 0
// // //       ? 0
// // //       : _position.inMilliseconds / _duration.inMilliseconds;

// // //   String _fmt(Duration d) {
// // //     if (d.inHours > 0) {
// // //       return '${d.inHours}:${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// // //     }
// // //     return '${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// // //   }

// // //   String _pad(int v) => v.toString().padLeft(2, '0');

// // //   // ── Speed sheet ───────────────────────────────────────────────────────────
// // //   void _showSpeedSheet() {
// // //     _hideTimer?.cancel();
// // //     showModalBottomSheet(
// // //       context: context,
// // //       backgroundColor: const Color(0xFF1A1A1A),
// // //       shape: const RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //       ),
// // //       builder: (_) => _SpeedSheet(
// // //         speeds: _speeds,
// // //         current: _playbackSpeed,
// // //         onSelect: _setSpeed,
// // //       ),
// // //     ).then((_) => _startHideTimer());
// // //   }

// // //   // ── Build ─────────────────────────────────────────────────────────────────
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       behavior: HitTestBehavior.opaque,
// // //       onTap: _toggleControls,
// // //       child: Stack(
// // //         fit: StackFit.expand,
// // //         children: [
// // //           // ── Buffering spinner (always visible when buffering) ──────────
// // //           if (_isBuffering) _buildBufferingOverlay(),

// // //           // ── Double-tap zones ───────────────────────────────────────────
// // //           _buildDoubleTapZones(),

// // //           // ── Seek feedback ripples ──────────────────────────────────────
// // //           if (_showSeekFeedback) _buildSeekFeedback(),

// // //           // ── Fading controls overlay ────────────────────────────────────
// // //           FadeTransition(
// // //             opacity: _fadeAnim,
// // //             child: _controlsVisible
// // //                 ? _buildControlsOverlay()
// // //                 : const SizedBox.shrink(),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Buffering ─────────────────────────────────────────────────────────────
// // //   Widget _buildBufferingOverlay() {
// // //     return Center(
// // //       child: SizedBox(
// // //         width: 48,
// // //         height: 48,
// // //         child: CircularProgressIndicator(
// // //           color: _kAccentRed,
// // //           strokeWidth: 2.5,
// // //           backgroundColor: Colors.white12,
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Double-tap seek zones ─────────────────────────────────────────────────
// // //   Widget _buildDoubleTapZones() {
// // //     return Row(
// // //       children: [
// // //         Expanded(
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.translucent,
// // //             onDoubleTap: () => _doubleTapSeek(false),
// // //             child: const SizedBox.expand(),
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: GestureDetector(
// // //             behavior: HitTestBehavior.translucent,
// // //             onDoubleTap: () => _doubleTapSeek(true),
// // //             child: const SizedBox.expand(),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ── Seek feedback ─────────────────────────────────────────────────────────
// // //   Widget _buildSeekFeedback() {
// // //     return Align(
// // //       alignment: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// // //       child: Container(
// // //         width: 100,
// // //         height: double.infinity,
// // //         decoration: BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// // //             end: _seekLeft ? Alignment.centerRight : Alignment.centerLeft,
// // //             colors: [
// // //               Utils.colorWithOpacity(_kAccentRed, 0.18),
// // //               Colors.transparent,
// // //             ],
// // //           ),
// // //         ),
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(
// // //               _seekLeft
// // //                   ? Icons.fast_rewind_rounded
// // //                   : Icons.fast_forward_rounded,
// // //               color: Colors.white,
// // //               size: 32,
// // //             ),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               '${_seekSeconds.abs()}s',
// // //               style: const TextStyle(
// // //                 color: Colors.white,
// // //                 fontSize: 13,
// // //                 fontWeight: FontWeight.w600,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ── Full controls overlay ─────────────────────────────────────────────────
// // //   // Stack-based: bars are Positioned so they never fight for height.
// // //   Widget _buildControlsOverlay() {
// // //     return Stack(
// // //       fit: StackFit.expand,
// // //       children: [
// // //         Center(child: _buildCentreControls()),
// // //         Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
// // //         Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
// // //       ],
// // //     );
// // //   }

// // //   // ── Top bar ───────────────────────────────────────────────────────────────
// // //   Widget _buildTopBar() {
// // //     return Container(
// // //       decoration: const BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topCenter,
// // //           end: Alignment.bottomCenter,
// // //           colors: _kBgGradient,
// // //         ),
// // //       ),
// // //       padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
// // //       child: Row(
// // //         children: [
// // //           // Back button (only in full-screen)
// // //           if (_isFullScreen)
// // //             IconButton(
// // //               icon: const Icon(
// // //                 Icons.arrow_back_ios_new_rounded,
// // //                 color: Colors.white,
// // //                 size: 20,
// // //               ),
// // //               onPressed: () {
// // //                 _chewie.exitFullScreen();
// // //                 SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// // //               },
// // //             ),
// // //           const Spacer(),
// // //           // Speed pill
// // //           GestureDetector(
// // //             onTap: _showSpeedSheet,
// // //             child: Container(
// // //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white12,
// // //                 borderRadius: BorderRadius.circular(20),
// // //                 border: Border.all(color: Colors.white24),
// // //               ),
// // //               child: Row(
// // //                 mainAxisSize: MainAxisSize.min,
// // //                 children: [
// // //                   const Icon(
// // //                     Icons.speed_rounded,
// // //                     color: Colors.white70,
// // //                     size: 14,
// // //                   ),
// // //                   const SizedBox(width: 4),
// // //                   Text(
// // //                     '${_playbackSpeed}x',
// // //                     style: const TextStyle(
// // //                       color: Colors.white,
// // //                       fontSize: 12,
// // //                       fontWeight: FontWeight.w600,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(width: 8),
// // //           // Volume
// // //           IconButton(
// // //             icon: Icon(
// // //               _volume == 0
// // //                   ? Icons.volume_off_rounded
// // //                   : _volume < 0.5
// // //                   ? Icons.volume_down_rounded
// // //                   : Icons.volume_up_rounded,
// // //               color: Colors.white,
// // //               size: 22,
// // //             ),
// // //             onPressed: () =>
// // //                 setState(() => _showVolumeSlider = !_showVolumeSlider),
// // //           ),
// // //           // Volume slider (inline)
// // //           if (_showVolumeSlider)
// // //             SizedBox(
// // //               width: 80,
// // //               child: SliderTheme(
// // //                 data: SliderTheme.of(context).copyWith(
// // //                   trackHeight: 2,
// // //                   thumbShape: const RoundSliderThumbShape(
// // //                     enabledThumbRadius: 6,
// // //                   ),
// // //                   overlayShape: const RoundSliderOverlayShape(
// // //                     overlayRadius: 12,
// // //                   ),
// // //                   activeTrackColor: Color(0xFF53BC77), // _kAccentRed,
// // //                   inactiveTrackColor: Color(0xFFD4FFDF), // Colors.white24,
// // //                   thumbColor: Colors.white,
// // //                   overlayColor: Utils.colorWithOpacity(_kAccentRed, 0.2),
// // //                 ),
// // //                 child: Slider(value: _volume, onChanged: _setVolume),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Centre controls ───────────────────────────────────────────────────────
// // //   Widget _buildCentreControls() {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.center,
// // //       children: [
// // //         // Rewind 10 s
// // //         _CircleIconButton(
// // //           icon: Icons.replay_10_rounded,
// // //           size: 32,
// // //           onTap: () => _doubleTapSeek(false),
// // //         ),
// // //         const SizedBox(width: 28),
// // //         // Play / Pause – prominent
// // //         GestureDetector(
// // //           onTap: _togglePlay,
// // //           child: AnimatedContainer(
// // //             duration: const Duration(milliseconds: 180),
// // //             width: 64,
// // //             height: 64,
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               color: Utils.colorWithOpacity(Colors.white, 0.15),
// // //               border: Border.all(color: Colors.white38, width: 1.5),
// // //             ),
// // //             child: _isBuffering
// // //                 ? const SizedBox.shrink()
// // //                 : Icon(
// // //                     _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
// // //                     color: Colors.white,
// // //                     size: 36,
// // //                   ),
// // //           ),
// // //         ),
// // //         const SizedBox(width: 28),
// // //         // Forward 10 s
// // //         _CircleIconButton(
// // //           icon: Icons.forward_10_rounded,
// // //           size: 32,
// // //           onTap: () => _doubleTapSeek(true),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ── Bottom bar ────────────────────────────────────────────────────────────
// // //   Widget _buildBottomBar() {
// // //     return Container(
// // //       decoration: const BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.bottomCenter,
// // //           end: Alignment.topCenter,
// // //           colors: _kBgGradient,
// // //         ),
// // //       ),
// // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
// // //       child: Column(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           // ── Scrubber ──────────────────────────────────────────────────
// // //           _buildScrubber(),
// // //           const SizedBox(height: 6),
// // //           // ── Time + fullscreen ─────────────────────────────────────────
// // //           Row(
// // //             children: [
// // //               Text(
// // //                 _fmt(_position),
// // //                 style: const TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 12,
// // //                   fontWeight: FontWeight.w500,
// // //                   fontFeatures: [FontFeature.tabularFigures()],
// // //                 ),
// // //               ),
// // //               const Text(
// // //                 '  /  ',
// // //                 style: TextStyle(color: Colors.white38, fontSize: 12),
// // //               ),
// // //               Text(
// // //                 _fmt(_duration),
// // //                 style: const TextStyle(
// // //                   color: Colors.white54,
// // //                   fontSize: 12,
// // //                   fontFeatures: [FontFeature.tabularFigures()],
// // //                 ),
// // //               ),
// // //               const Spacer(),
// // //               // Fullscreen toggle
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   _isFullScreen
// // //                       ? _chewie.exitFullScreen()
// // //                       : _chewie.enterFullScreen();
// // //                   setState(() => _isFullScreen = !_isFullScreen);
// // //                 },
// // //                 child: Icon(
// // //                   _isFullScreen
// // //                       ? Icons.fullscreen_exit_rounded
// // //                       : Icons.fullscreen_rounded,
// // //                   color: Colors.white,
// // //                   size: 26,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ── Scrubber (seek bar) ───────────────────────────────────────────────────
// // //   Widget _buildScrubber() {
// // //     final buffered = _vpc.value.buffered;
// // //     final bufferedFraction = buffered.isEmpty || _duration.inMilliseconds == 0
// // //         ? 0.0
// // //         : (buffered.last.end.inMilliseconds / _duration.inMilliseconds).clamp(
// // //             0.0,
// // //             1.0,
// // //           );

// // //     return LayoutBuilder(
// // //       builder: (context, constraints) {
// // //         final trackW = constraints.maxWidth;
// // //         return GestureDetector(
// // //           behavior: HitTestBehavior.opaque,
// // //           onHorizontalDragStart: (_) {
// // //             _isSeeking = true;
// // //             _hideTimer?.cancel();
// // //           },
// // //           onHorizontalDragUpdate: (d) {
// // //             final fraction = (d.localPosition.dx / trackW).clamp(0.0, 1.0);
// // //             setState(() => _seekPosition = fraction);
// // //           },
// // //           onHorizontalDragEnd: (_) {
// // //             _isSeeking = false;
// // //             _seek(
// // //               Duration(
// // //                 milliseconds: (_seekPosition * _duration.inMilliseconds)
// // //                     .round(),
// // //               ),
// // //             );
// // //             _startHideTimer();
// // //           },
// // //           child: SizedBox(
// // //             height: 28,
// // //             child: Stack(
// // //               alignment: Alignment.centerLeft,
// // //               children: [
// // //                 // ── Track background ──────────────────────────────────
// // //                 Container(
// // //                   height: _isSeeking ? 5 : 3,
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.white24,
// // //                     borderRadius: BorderRadius.circular(4),
// // //                   ),
// // //                 ),
// // //                 // ── Buffered ──────────────────────────────────────────
// // //                 FractionallySizedBox(
// // //                   widthFactor: bufferedFraction,
// // //                   child: Container(
// // //                     height: _isSeeking ? 5 : 3,
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white38,
// // //                       borderRadius: BorderRadius.circular(4),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 // ── Played ────────────────────────────────────────────
// // //                 FractionallySizedBox(
// // //                   widthFactor: _isSeeking ? _seekPosition : _progressFraction,
// // //                   child: Container(
// // //                     height: _isSeeking ? 5 : 3,
// // //                     decoration: BoxDecoration(
// // //                       color: Color(0xFF53BC77), // _kAccentRed,
// // //                       borderRadius: BorderRadius.circular(4),
// // //                     ),
// // //                   ),
// // //                 ),

// // //                 // ── Thumb ────────────────────────────────────────────
// // //                 Positioned(
// // //                   left:
// // //                       ((_isSeeking ? _seekPosition : _progressFraction) *
// // //                               trackW)
// // //                           .clamp(0, trackW - 14),
// // //                   child: AnimatedContainer(
// // //                     duration: const Duration(milliseconds: 120),
// // //                     width: _isSeeking ? 16 : 12,
// // //                     height: _isSeeking ? 16 : 12,
// // //                     decoration: BoxDecoration(
// // //                       shape: BoxShape.circle,
// // //                       color: Colors.white,
// // //                       boxShadow: [
// // //                         BoxShadow(
// // //                           color: Utils.colorWithOpacity(_kAccentRed, 0.6),
// // //                           blurRadius: _isSeeking ? 8 : 0,
// // //                           spreadRadius: _isSeeking ? 2 : 0,
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // Speed sheet
// // // // ─────────────────────────────────────────────────────────────────────────────
// // // class _SpeedSheet extends StatelessWidget {
// // //   const _SpeedSheet({
// // //     required this.speeds,
// // //     required this.current,
// // //     required this.onSelect,
// // //   });

// // //   final List<double> speeds;
// // //   final double current;
// // //   final void Function(double) onSelect;

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       mainAxisSize: MainAxisSize.min,
// // //       children: [
// // //         const SizedBox(height: 12),
// // //         Container(
// // //           width: 36,
// // //           height: 4,
// // //           decoration: BoxDecoration(
// // //             color: Colors.white24,
// // //             borderRadius: BorderRadius.circular(2),
// // //           ),
// // //         ),
// // //         const SizedBox(height: 16),
// // //         const Text(
// // //           'Playback Speed',
// // //           style: TextStyle(
// // //             color: Colors.white,
// // //             fontSize: 15,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         const SizedBox(height: 12),
// // //         ...speeds.map(
// // //           (s) => InkWell(
// // //             onTap: () => onSelect(s),
// // //             child: Container(
// // //               width: double.infinity,
// // //               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
// // //               child: Row(
// // //                 children: [
// // //                   Text(
// // //                     '$s ×',
// // //                     style: TextStyle(
// // //                       color: s == current
// // //                           ? const Color(0xFFE53935)
// // //                           : Colors.white,
// // //                       fontSize: 15,
// // //                       fontWeight: s == current
// // //                           ? FontWeight.w700
// // //                           : FontWeight.w400,
// // //                     ),
// // //                   ),
// // //                   if (s == current) ...[
// // //                     const Spacer(),
// // //                     const Icon(
// // //                       Icons.check_rounded,
// // //                       color: Color(0xFFE53935),
// // //                       size: 18,
// // //                     ),
// // //                   ],
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //         const SizedBox(height: 16),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // ─────────────────────────────────────────────────────────────────────────────
// // // // Small circle icon button
// // // // ─────────────────────────────────────────────────────────────────────────────
// // // class _CircleIconButton extends StatelessWidget {
// // //   const _CircleIconButton({
// // //     required this.icon,
// // //     required this.onTap,
// // //     this.size = 28,
// // //   });

// // //   final IconData icon;
// // //   final VoidCallback onTap;
// // //   final double size;

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: Container(
// // //         padding: const EdgeInsets.all(8),
// // //         decoration: BoxDecoration(
// // //           shape: BoxShape.circle,
// // //           color: Utils.colorWithOpacity(Colors.white, 0.1),
// // //         ),
// // //         child: Icon(icon, color: Colors.white, size: size),
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'dart:async';

// // import 'package:chewie/chewie.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:screen_brightness/screen_brightness.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:video_player_app/utils.dart/utils.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // CustomVideoControls  –  Cinema skin
// // //
// // // New features vs previous version:
// // //   • Swipe up/down LEFT  half → brightness control  (needs screen_brightness pkg)
// // //   • Swipe up/down RIGHT half → volume control
// // //   • Long-press play button  → 2× fast-forward while held
// // //   • Rotation lock toggle button in top bar
// // //   • Video title in top bar
// // //   • Tap time label to toggle remaining time display
// // //   • Next / Previous skip buttons (optional callbacks)
// // // ─────────────────────────────────────────────────────────────────────────────

// // class CustomVideoControls extends StatefulWidget {
// //   const CustomVideoControls({
// //     super.key,
// //     this.thumbnail,
// //     this.title,
// //     this.onNext,
// //     this.onPrevious,
// //     this.hasNext = false,
// //     this.hasPrevious = false,
// //   });

// //   final Uint8List? thumbnail;
// //   final String? title;
// //   final VoidCallback? onNext;
// //   final VoidCallback? onPrevious;
// //   final bool hasNext;
// //   final bool hasPrevious;

// //   @override
// //   State<CustomVideoControls> createState() => _CustomVideoControlsState();
// // }

// // class _CustomVideoControlsState extends State<CustomVideoControls>
// //     with SingleTickerProviderStateMixin {
// //   // ── Chewie / VideoPlayer ──────────────────────────────────────────────────
// //   late ChewieController _chewie;
// //   VideoPlayerController get _vpc => _chewie.videoPlayerController;

// //   // ── Existing state ────────────────────────────────────────────────────────
// //   bool _controlsVisible = true;
// //   bool _isSeeking = false;
// //   double _seekPosition = 0;
// //   double _volume = 1.0;
// //   bool _showVolumeSlider = false;
// //   double _playbackSpeed = 1.0;
// //   bool _isFullScreen = false;

// //   // ── NEW state ─────────────────────────────────────────────────────────────
// //   bool _showRemainingTime = false; // tap time → toggle remaining
// //   bool _isRotationLocked = false; // rotation lock
// //   bool _isFastForwarding = false; // long-press 2× speed

// //   // swipe gesture tracking
// //   double _swipeBrightness = 0.8;
// //   double _swipeVolume = 1.0;
// //   bool _showBrightnessOverlay = false;
// //   bool _showVolumeOverlay = false;
// //   double _swipeDragStartY = 0;
// //   Timer? _overlayHideTimer;

// //   // ── Animation ─────────────────────────────────────────────────────────────
// //   late AnimationController _fadeCtrl;
// //   late Animation<double> _fadeAnim;

// //   // ── Timers ────────────────────────────────────────────────────────────────
// //   Timer? _hideTimer;
// //   Timer? _seekFeedbackTimer;

// //   // ── Seek feedback ─────────────────────────────────────────────────────────
// //   int _seekSeconds = 0;
// //   bool _showSeekFeedback = false;
// //   bool _seekLeft = false;

// //   static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
// //   static const _kAccentRed = Color(0xFFE53935);
// //   static const _kAccentGreen = Color(0xFF53BC77);
// //   static const _kBgGradient = [Color(0xCC000000), Colors.transparent];

// //   // ── Init / dispose ────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fadeCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 250),
// //       value: 1,
// //     );
// //     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
// //     _startHideTimer();
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     _chewie = ChewieController.of(context);
// //     _isFullScreen = _chewie.isFullScreen;
// //     _volume = _vpc.value.volume;
// //     _swipeVolume = _volume;
// //     _vpc.addListener(_onVideoUpdate);
// //     setState(() {});
// //   }

// //   @override
// //   void dispose() {
// //     _vpc.removeListener(_onVideoUpdate);
// //     _fadeCtrl.dispose();
// //     _hideTimer?.cancel();
// //     _seekFeedbackTimer?.cancel();
// //     _overlayHideTimer?.cancel();
// //     if (_isRotationLocked) {
// //       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
// //     }
// //     super.dispose();
// //   }

// //   void _onVideoUpdate() {
// //     if (mounted) setState(() {});
// //   }

// //   // ── Controls visibility ───────────────────────────────────────────────────
// //   void _toggleControls() {
// //     setState(() => _controlsVisible = !_controlsVisible);
// //     _controlsVisible ? _fadeCtrl.forward() : _fadeCtrl.reverse();
// //     if (_controlsVisible) {
// //       _startHideTimer();
// //     } else {
// //       _hideTimer?.cancel();
// //     }
// //   }

// //   void _showControls() {
// //     if (!_controlsVisible) {
// //       setState(() => _controlsVisible = true);
// //       _fadeCtrl.forward();
// //     }
// //     _startHideTimer();
// //   }

// //   void _startHideTimer() {
// //     _hideTimer?.cancel();
// //     _hideTimer = Timer(const Duration(seconds: 4), () {
// //       if (mounted && !_isSeeking && _vpc.value.isPlaying) {
// //         setState(() => _controlsVisible = false);
// //         _fadeCtrl.reverse();
// //       }
// //     });
// //   }

// //   // ── Playback ──────────────────────────────────────────────────────────────
// //   void _togglePlay() {
// //     _showControls();
// //     _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
// //   }

// //   void _seek(Duration position) {
// //     final clamped = position < Duration.zero
// //         ? Duration.zero
// //         : position > _vpc.value.duration
// //         ? _vpc.value.duration
// //         : position;
// //     _vpc.seekTo(clamped);
// //     _startHideTimer();
// //   }

// //   void _doubleTapSeek(bool forward) {
// //     _seek(_vpc.value.position + Duration(seconds: forward ? 10 : -10));
// //     setState(() {
// //       _seekLeft = !forward;
// //       _seekSeconds =
// //           (forward ? 1 : -1) * ((_seekSeconds.abs() + 10).clamp(10, 999));
// //       _showSeekFeedback = true;
// //     });
// //     _seekFeedbackTimer?.cancel();
// //     _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
// //      // if (mounted)
// //         setState(() {
// //           _showSeekFeedback = false;
// //           _seekSeconds = 0;
// //         });
// //     });
// //   }

// //   // ── Long-press fast forward ───────────────────────────────────────────────
// //   void _startFastForward() {
// //     if (_isFastForwarding) return;
// //     setState(() => _isFastForwarding = true);
// //     _vpc.setPlaybackSpeed(2.0);
// //     _showControls();
// //   }

// //   void _stopFastForward() {
// //     if (!_isFastForwarding) return;
// //     setState(() => _isFastForwarding = false);
// //     _vpc.setPlaybackSpeed(_playbackSpeed);
// //   }

// //   // ── Rotation lock ─────────────────────────────────────────────────────────
// //   void _toggleRotationLock() {
// //     setState(() => _isRotationLocked = !_isRotationLocked);
// //     if (_isRotationLocked) {
// //       final isLandscape =
// //           MediaQuery.of(context).orientation == Orientation.landscape;
// //       SystemChrome.setPreferredOrientations(
// //         isLandscape
// //             ? [
// //                 DeviceOrientation.landscapeLeft,
// //                 DeviceOrientation.landscapeRight,
// //               ]
// //             : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
// //       );
// //     } else {
// //       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
// //     }
// //     _showControls();
// //   }

// //   // ── Swipe gestures ────────────────────────────────────────────────────────
// //   void _onSwipeStart(DragStartDetails d, bool isLeft) {
// //     _swipeDragStartY = d.localPosition.dy;
// //     setState(() {
// //       _showBrightnessOverlay = isLeft;
// //       _showVolumeOverlay = !isLeft;
// //     });
// //     _overlayHideTimer?.cancel();
// //   }

// //   void _onSwipeUpdate(DragUpdateDetails d, bool isLeft) {
// //     final delta = (_swipeDragStartY - d.localPosition.dy) / 220;
// //     _swipeDragStartY = d.localPosition.dy;
// //     if (isLeft) {
// //       _swipeBrightness = (_swipeBrightness + delta).clamp(0.0, 1.0);
// //       // Plug in screen_brightness pkg here:
// //        ScreenBrightness().setApplicationScreenBrightness(_swipeBrightness);
// //     } else {
// //       _swipeVolume = (_swipeVolume + delta).clamp(0.0, 1.0);
// //       _vpc.setVolume(_swipeVolume);
// //       _volume = _swipeVolume;
// //     }
// //     setState(() {});
// //   }

// //   void _onSwipeEnd() {
// //     _overlayHideTimer = Timer(const Duration(seconds: 2), () {
// //      // if (mounted)
// //         setState(() {
// //           _showBrightnessOverlay = false;
// //           _showVolumeOverlay = false;
// //         });
// //     });
// //   }

// //   // ── Speed / Volume ────────────────────────────────────────────────────────
// //   void _setSpeed(double speed) {
// //     setState(() => _playbackSpeed = speed);
// //     _vpc.setPlaybackSpeed(speed);
// //     Navigator.of(context).pop();
// //   }

// //   void _setVolume(double v) {
// //     setState(() {
// //       _volume = v;
// //       _swipeVolume = v;
// //     });
// //     _vpc.setVolume(v);
// //   }

// //   void _showSpeedSheet() {
// //     _hideTimer?.cancel();
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: const Color(0xFF1A1A1A),
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) => _SpeedSheet(
// //         speeds: _speeds,
// //         current: _playbackSpeed,
// //         onSelect: _setSpeed,
// //       ),
// //     ).then((_) => _startHideTimer());
// //   }

// //   // ── Computed helpers ──────────────────────────────────────────────────────
// //   Duration get _duration => _vpc.value.duration;
// //   Duration get _position => _vpc.value.position;
// //   Duration get _remaining => _duration - _position;
// //   bool get _isPlaying => _vpc.value.isPlaying;
// //   bool get _isBuffering => _vpc.value.isBuffering;

// //   double get _progressFraction => _duration.inMilliseconds == 0
// //       ? 0
// //       : _position.inMilliseconds / _duration.inMilliseconds;

// //   String _fmt(Duration d) {
// //     if (d.inHours > 0) {
// //       return '${d.inHours}:${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// //     }
// //     return '${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// //   }

// //   String _pad(int v) => v.toString().padLeft(2, '0');

// //   IconData _volumeIcon(double v) => v == 0
// //       ? Icons.volume_off_rounded
// //       : v < 0.5
// //       ? Icons.volume_down_rounded
// //       : Icons.volume_up_rounded;

// //   IconData _brightnessIcon(double v) => v < 0.33
// //       ? Icons.brightness_low_rounded
// //       : v < 0.66
// //       ? Icons.brightness_medium_rounded
// //       : Icons.brightness_high_rounded;

// //   // ── Build ─────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       behavior: HitTestBehavior.opaque,
// //       onTap: _toggleControls,
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           // Always-visible buffering spinner
// //           if (_isBuffering) _buildBufferingOverlay(),

// //           // Swipe zones (left = brightness / right = volume)
// //           _buildSwipeZones(),

// //           // Double-tap seek zones
// //           _buildDoubleTapZones(),

// //           // Seek ripple feedback
// //           if (_showSeekFeedback) _buildSeekFeedback(),

// //           // Brightness overlay
// //           if (_showBrightnessOverlay)
// //             _buildSwipeOverlay(
// //               icon: _brightnessIcon(_swipeBrightness),
// //               value: _swipeBrightness,
// //               color: Colors.amber,
// //               isLeft: true,
// //             ),

// //           // Volume overlay
// //           if (_showVolumeOverlay)
// //             _buildSwipeOverlay(
// //               icon: _volumeIcon(_swipeVolume),
// //               value: _swipeVolume,
// //               color: _kAccentGreen,
// //               isLeft: false,
// //             ),

// //           // Fast-forward banner
// //           if (_isFastForwarding) _buildFastForwardBanner(),

// //           // Fading controls
// //           FadeTransition(
// //             opacity: _fadeAnim,
// //             child: _controlsVisible
// //                 ? _buildControlsOverlay()
// //                 : const SizedBox.shrink(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Swipe zones ───────────────────────────────────────────────────────────
// //   Widget _buildSwipeZones() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onVerticalDragStart: (d) => _onSwipeStart(d, true),
// //             onVerticalDragUpdate: (d) => _onSwipeUpdate(d, true),
// //             onVerticalDragEnd: (_) => _onSwipeEnd(),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onVerticalDragStart: (d) => _onSwipeStart(d, false),
// //             onVerticalDragUpdate: (d) => _onSwipeUpdate(d, false),
// //             onVerticalDragEnd: (_) => _onSwipeEnd(),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Double-tap zones ──────────────────────────────────────────────────────
// //   Widget _buildDoubleTapZones() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onDoubleTap: () => _doubleTapSeek(false),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onDoubleTap: () => _doubleTapSeek(true),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Buffering overlay ─────────────────────────────────────────────────────
// //   Widget _buildBufferingOverlay() => Center(
// //     child: SizedBox(
// //       width: 48,
// //       height: 48,
// //       child: CircularProgressIndicator(
// //         color: _kAccentRed,
// //         strokeWidth: 2.5,
// //         backgroundColor: Colors.white12,
// //       ),
// //     ),
// //   );

// //   // ── Seek feedback ─────────────────────────────────────────────────────────
// //   Widget _buildSeekFeedback() {
// //     return Align(
// //       alignment: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// //       child: Container(
// //         width: 100,
// //         height: double.infinity,
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// //             end: _seekLeft ? Alignment.centerRight : Alignment.centerLeft,
// //             colors: [
// //               Utils.colorWithOpacity(_kAccentRed, 0.18),
// //               Colors.transparent,
// //             ],
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               _seekLeft
// //                   ? Icons.fast_rewind_rounded
// //                   : Icons.fast_forward_rounded,
// //               color: Colors.white,
// //               size: 32,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               '${_seekSeconds.abs()}s',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Swipe overlay (brightness / volume pill) ──────────────────────────────
// //   Widget _buildSwipeOverlay({
// //     required IconData icon,
// //     required double value,
// //     required Color color,
// //     required bool isLeft,
// //   }) {
// //     return Positioned(
// //       left: isLeft ? 16 : null,
// //       right: isLeft ? null : 16,
// //       top: 0,
// //       bottom: 0,
// //       child: Center(
// //         child: Container(
// //           width: 44,
// //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
// //           decoration: BoxDecoration(
// //             color: Colors.black54,
// //             borderRadius: BorderRadius.circular(24),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Icon(icon, color: Colors.white, size: 20),
// //               const SizedBox(height: 8),
// //               SizedBox(
// //                 height: 80,
// //                 width: 4,
// //                 child: RotatedBox(
// //                   quarterTurns: -1,
// //                   child: LinearProgressIndicator(
// //                     value: value,
// //                     backgroundColor: Colors.white24,
// //                     valueColor: AlwaysStoppedAnimation(color),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 '${(value * 100).round()}%',
// //                 style: const TextStyle(color: Colors.white, fontSize: 10),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Fast-forward banner ───────────────────────────────────────────────────
// //   Widget _buildFastForwardBanner() => Center(
// //     child: Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.black54,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.white24),
// //       ),
// //       child: const Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
// //           SizedBox(width: 6),
// //           Text(
// //             '2× Speed',
// //             style: TextStyle(
// //               color: Colors.white,
// //               fontSize: 13,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );

// //   // ── Controls overlay (Stack-based, no overflow) ───────────────────────────
// //   Widget _buildControlsOverlay() => Stack(
// //     fit: StackFit.expand,
// //     children: [
// //       Center(child: _buildCentreControls()),
// //       Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
// //       Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
// //     ],
// //   );

// //   // ── Top bar ───────────────────────────────────────────────────────────────
// //   Widget _buildTopBar() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: _kBgGradient,
// //         ),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
// //       child: Row(
// //         children: [
// //           // Back (fullscreen only)
// //           if (_isFullScreen)
// //             IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_ios_new_rounded,
// //                 color: Colors.white,
// //                 size: 20,
// //               ),
// //               onPressed: () {
// //                 _chewie.exitFullScreen();
// //                 SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// //               },
// //             ),

// //           // Title
// //           if (widget.title != null)
// //             Expanded(
// //               child: Padding(
// //                 padding: EdgeInsets.only(left: _isFullScreen ? 0 : 12),
// //                 child: Text(
// //                   widget.title!,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             const Spacer(),

// //           // Rotation lock
// //           _TopBarBtn(
// //             icon: _isRotationLocked
// //                 ? Icons.screen_lock_rotation_rounded
// //                 : Icons.screen_rotation_rounded,
// //             active: _isRotationLocked,
// //             onTap: _toggleRotationLock,
// //           ),
// //           const SizedBox(width: 4),

// //           // Speed pill
// //           GestureDetector(
// //             onTap: _showSpeedSheet,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //               decoration: BoxDecoration(
// //                 color: Colors.white12,
// //                 borderRadius: BorderRadius.circular(20),
// //                 border: Border.all(color: Colors.white24),
// //               ),
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   const Icon(
// //                     Icons.speed_rounded,
// //                     color: Colors.white70,
// //                     size: 14,
// //                   ),
// //                   const SizedBox(width: 4),
// //                   Text(
// //                     '${_playbackSpeed}x',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 8),

// //           // Volume icon
// //           IconButton(
// //             icon: Icon(_volumeIcon(_volume), color: Colors.white, size: 22),
// //             onPressed: () =>
// //                 setState(() => _showVolumeSlider = !_showVolumeSlider),
// //           ),

// //           // Inline volume slider
// //           if (_showVolumeSlider)
// //             SizedBox(
// //               width: 80,
// //               child: SliderTheme(
// //                 data: SliderTheme.of(context).copyWith(
// //                   trackHeight: 2,
// //                   thumbShape: const RoundSliderThumbShape(
// //                     enabledThumbRadius: 6,
// //                   ),
// //                   overlayShape: const RoundSliderOverlayShape(
// //                     overlayRadius: 12,
// //                   ),
// //                   activeTrackColor: _kAccentGreen,
// //                   inactiveTrackColor: const Color(0xFFD4FFDF),
// //                   thumbColor: Colors.white,
// //                   overlayColor: Utils.colorWithOpacity(_kAccentRed, 0.2),
// //                 ),
// //                 child: Slider(value: _volume, onChanged: _setVolume),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Centre controls ───────────────────────────────────────────────────────
// //   Widget _buildCentreControls() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         // Previous (optional)
// //         if (widget.hasPrevious) ...[
// //           _CircleIconButton(
// //             icon: Icons.skip_previous_rounded,
// //             size: 26,
// //             onTap: () {
// //               widget.onPrevious?.call();
// //               _showControls();
// //             },
// //           ),
// //           const SizedBox(width: 12),
// //         ],

// //         // Rewind 10s
// //         _CircleIconButton(
// //           icon: Icons.replay_10_rounded,
// //           size: 32,
// //           onTap: () => _doubleTapSeek(false),
// //         ),
// //         const SizedBox(width: 28),

// //         // Play / Pause with long-press fast-forward
// //         GestureDetector(
// //           onTap: _togglePlay,
// //           onLongPressStart: (_) => _startFastForward(),
// //           onLongPressEnd: (_) => _stopFastForward(),
// //           onLongPressCancel: _stopFastForward,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 180),
// //             width: 64,
// //             height: 64,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: Utils.colorWithOpacity(
// //                 Colors.white,
// //                 _isFastForwarding ? 0.25 : 0.15,
// //               ),
// //               border: Border.all(
// //                 color: _isFastForwarding ? _kAccentGreen : Colors.white38,
// //                 width: 1.5,
// //               ),
// //             ),
// //             child: _isBuffering
// //                 ? const SizedBox.shrink()
// //                 : Icon(
// //                     _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
// //                     color: Colors.white,
// //                     size: 36,
// //                   ),
// //           ),
// //         ),
// //         const SizedBox(width: 28),

// //         // Forward 10s
// //         _CircleIconButton(
// //           icon: Icons.forward_10_rounded,
// //           size: 32,
// //           onTap: () => _doubleTapSeek(true),
// //         ),

// //         // Next (optional)
// //         if (widget.hasNext) ...[
// //           const SizedBox(width: 12),
// //           _CircleIconButton(
// //             icon: Icons.skip_next_rounded,
// //             size: 26,
// //             onTap: () {
// //               widget.onNext?.call();
// //               _showControls();
// //             },
// //           ),
// //         ],
// //       ],
// //     );
// //   }

// //   // ── Bottom bar ────────────────────────────────────────────────────────────
// //   Widget _buildBottomBar() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.bottomCenter,
// //           end: Alignment.topCenter,
// //           colors: _kBgGradient,
// //         ),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _buildScrubber(),
// //           const SizedBox(height: 6),
// //           Row(
// //             children: [
// //               // Tap to toggle position / remaining
// //               GestureDetector(
// //                 onTap: () =>
// //                     setState(() => _showRemainingTime = !_showRemainingTime),
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       _fmt(_position),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                         fontFeatures: [FontFeature.tabularFigures()],
// //                       ),
// //                     ),
// //                     const Text(
// //                       '  /  ',
// //                       style: TextStyle(color: Colors.white38, fontSize: 12),
// //                     ),
// //                     Text(
// //                       _showRemainingTime
// //                           ? '-${_fmt(_remaining)}'
// //                           : _fmt(_duration),
// //                       style: TextStyle(
// //                         color: _showRemainingTime
// //                             ? _kAccentGreen
// //                             : Colors.white54,
// //                         fontSize: 12,
// //                         fontFeatures: const [FontFeature.tabularFigures()],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const Spacer(),
// //               // Fullscreen toggle
// //               GestureDetector(
// //                 onTap: () {
// //                   _isFullScreen
// //                       ? _chewie.exitFullScreen()
// //                       : _chewie.enterFullScreen();
// //                   setState(() => _isFullScreen = !_isFullScreen);
// //                 },
// //                 child: Icon(
// //                   _isFullScreen
// //                       ? Icons.fullscreen_exit_rounded
// //                       : Icons.fullscreen_rounded,
// //                   color: Colors.white,
// //                   size: 26,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Scrubber ──────────────────────────────────────────────────────────────
// //   Widget _buildScrubber() {
// //     final buffered = _vpc.value.buffered;
// //     final bufferedFraction = buffered.isEmpty || _duration.inMilliseconds == 0
// //         ? 0.0
// //         : (buffered.last.end.inMilliseconds / _duration.inMilliseconds).clamp(
// //             0.0,
// //             1.0,
// //           );

// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final trackW = constraints.maxWidth;
// //         return GestureDetector(
// //           behavior: HitTestBehavior.opaque,
// //           onHorizontalDragStart: (_) {
// //             _isSeeking = true;
// //             _hideTimer?.cancel();
// //           },
// //           onHorizontalDragUpdate: (d) {
// //             setState(
// //               () =>
// //                   _seekPosition = (d.localPosition.dx / trackW).clamp(0.0, 1.0),
// //             );
// //           },
// //           onHorizontalDragEnd: (_) {
// //             _isSeeking = false;
// //             _seek(
// //               Duration(
// //                 milliseconds: (_seekPosition * _duration.inMilliseconds)
// //                     .round(),
// //               ),
// //             );
// //             _startHideTimer();
// //           },
// //           child: SizedBox(
// //             height: 28,
// //             child: Stack(
// //               alignment: Alignment.centerLeft,
// //               children: [
// //                 // Track
// //                 Container(
// //                   height: _isSeeking ? 5 : 3,
// //                   decoration: BoxDecoration(
// //                     color: Colors.white24,
// //                     borderRadius: BorderRadius.circular(4),
// //                   ),
// //                 ),
// //                 // Buffered
// //                 FractionallySizedBox(
// //                   widthFactor: bufferedFraction,
// //                   child: Container(
// //                     height: _isSeeking ? 5 : 3,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white38,
// //                       borderRadius: BorderRadius.circular(4),
// //                     ),
// //                   ),
// //                 ),
// //                 // Played
// //                 FractionallySizedBox(
// //                   widthFactor: _isSeeking ? _seekPosition : _progressFraction,
// //                   child: Container(
// //                     height: _isSeeking ? 5 : 3,
// //                     decoration: BoxDecoration(
// //                       color: _kAccentGreen,
// //                       borderRadius: BorderRadius.circular(4),
// //                     ),
// //                   ),
// //                 ),
// //                 // Thumb
// //                 Positioned(
// //                   left:
// //                       ((_isSeeking ? _seekPosition : _progressFraction) *
// //                               trackW)
// //                           .clamp(0, trackW - 14),
// //                   child: AnimatedContainer(
// //                     duration: const Duration(milliseconds: 120),
// //                     width: _isSeeking ? 16 : 12,
// //                     height: _isSeeking ? 16 : 12,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.white,
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Utils.colorWithOpacity(_kAccentRed, 0.6),
// //                           blurRadius: _isSeeking ? 8 : 0,
// //                           spreadRadius: _isSeeking ? 2 : 0,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Top bar icon button with active state
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _TopBarBtn extends StatelessWidget {
// //   const _TopBarBtn({
// //     required this.icon,
// //     required this.onTap,
// //     this.active = false,
// //   });

// //   final IconData icon;
// //   final VoidCallback onTap;
// //   final bool active;

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(6),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: active
// //               ? const Color(0xFF53BC77).withOpacity(0.25)
// //               : Colors.transparent,
// //         ),
// //         child: Icon(
// //           icon,
// //           color: active ? const Color(0xFF53BC77) : Colors.white,
// //           size: 20,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Speed bottom sheet
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _SpeedSheet extends StatelessWidget {
// //   const _SpeedSheet({
// //     required this.speeds,
// //     required this.current,
// //     required this.onSelect,
// //   });

// //   final List<double> speeds;
// //   final double current;
// //   final void Function(double) onSelect;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         const SizedBox(height: 12),
// //         Container(
// //           width: 36,
// //           height: 4,
// //           decoration: BoxDecoration(
// //             color: Colors.white24,
// //             borderRadius: BorderRadius.circular(2),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         const Text(
// //           'Playback Speed',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 15,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         ...speeds.map(
// //           (s) => InkWell(
// //             onTap: () => onSelect(s),
// //             child: Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
// //               child: Row(
// //                 children: [
// //                   Text(
// //                     '$s ×',
// //                     style: TextStyle(
// //                       color: s == current
// //                           ? const Color(0xFFE53935)
// //                           : Colors.white,
// //                       fontSize: 15,
// //                       fontWeight: s == current
// //                           ? FontWeight.w700
// //                           : FontWeight.w400,
// //                     ),
// //                   ),
// //                   if (s == current) ...[
// //                     const Spacer(),
// //                     const Icon(
// //                       Icons.check_rounded,
// //                       color: Color(0xFFE53935),
// //                       size: 18,
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //       ],
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Small circle icon button
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _CircleIconButton extends StatelessWidget {
// //   const _CircleIconButton({
// //     required this.icon,
// //     required this.onTap,
// //     this.size = 28,
// //   });

// //   final IconData icon;
// //   final VoidCallback onTap;
// //   final double size;

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(8),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: Utils.colorWithOpacity(Colors.white, 0.1),
// //         ),
// //         child: Icon(icon, color: Colors.white, size: size),
// //       ),
// //     );
// //   }
// // }

// // import 'dart:async';

// // import 'package:chewie/chewie.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:screen_brightness/screen_brightness.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:video_player_app/utils.dart/utils.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // CustomVideoControls  –  Cinema skin
// // //
// // // New features vs previous version:
// // //   • Swipe up/down LEFT  half → brightness control  (needs screen_brightness pkg)
// // //   • Swipe up/down RIGHT half → volume control
// // //   • Long-press play button  → 2× fast-forward while held
// // //   • Rotation lock toggle button in top bar
// // //   • Video title in top bar
// // //   • Tap time label to toggle remaining time display
// // //   • Next / Previous skip buttons (optional callbacks)
// // // ─────────────────────────────────────────────────────────────────────────────

// // class CustomVideoControls extends StatefulWidget {
// //   const CustomVideoControls({
// //     super.key,
// //     this.thumbnail,
// //     this.title,
// //     this.onNext,
// //     this.onPrevious,
// //     this.hasNext = false,
// //     this.hasPrevious = false,
// //   });

// //   final Uint8List? thumbnail;
// //   final String? title;
// //   final VoidCallback? onNext;
// //   final VoidCallback? onPrevious;
// //   final bool hasNext;
// //   final bool hasPrevious;

// //   @override
// //   State<CustomVideoControls> createState() => _CustomVideoControlsState();
// // }

// // class _CustomVideoControlsState extends State<CustomVideoControls>
// //     with SingleTickerProviderStateMixin {
// //   // ── Chewie / VideoPlayer ──────────────────────────────────────────────────
// //   late ChewieController _chewie;
// //   VideoPlayerController get _vpc => _chewie.videoPlayerController;

// //   // ── Existing state ────────────────────────────────────────────────────────
// //   bool _controlsVisible = true;
// //   bool _isSeeking = false;
// //   double _seekPosition = 0;
// //   double _volume = 1.0;
// //   bool _showVolumeSlider = false;
// //   double _playbackSpeed = 1.0;
// //   bool _isFullScreen = false;

// //   // ── NEW state ─────────────────────────────────────────────────────────────
// //   bool _showRemainingTime = false; // tap time → toggle remaining
// //   bool _isRotationLocked = false; // rotation lock
// //   bool _isFastForwarding = false; // long-press 2× speed

// //   // swipe gesture tracking
// //   double _swipeBrightness = 0.8;
// //   double _swipeVolume = 1.0;
// //   bool _showBrightnessOverlay = false;
// //   bool _showVolumeOverlay = false;
// //   double _swipeDragStartY = 0;
// //   Timer? _overlayHideTimer;

// //   // ── Animation ─────────────────────────────────────────────────────────────
// //   late AnimationController _fadeCtrl;
// //   late Animation<double> _fadeAnim;

// //   // ── Timers ────────────────────────────────────────────────────────────────
// //   Timer? _hideTimer;
// //   Timer? _seekFeedbackTimer;

// //   // ── Seek feedback ─────────────────────────────────────────────────────────
// //   int _seekSeconds = 0;
// //   bool _showSeekFeedback = false;
// //   bool _seekLeft = false;

// //   static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
// //   static const _kAccentRed = Color(0xFFE53935);
// //   static const _kAccentGreen = Color(0xFF53BC77);
// //   static const _kBgGradient = [Color(0xCC000000), Colors.transparent];

// //   // ── Init / dispose ────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fadeCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 250),
// //       value: 1,
// //     );
// //     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
// //     _startHideTimer();
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     _chewie = ChewieController.of(context);
// //     _isFullScreen = _chewie.isFullScreen;
// //     _volume = _vpc.value.volume;
// //     _swipeVolume = _volume;
// //     _vpc.addListener(_onVideoUpdate);
// //     setState(() {});
// //   }

// //   @override
// //   void dispose() {
// //     _vpc.removeListener(_onVideoUpdate);
// //     _fadeCtrl.dispose();
// //     _hideTimer?.cancel();
// //     _seekFeedbackTimer?.cancel();
// //     _overlayHideTimer?.cancel();
// //     if (_isRotationLocked) {
// //       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
// //     }
// //     super.dispose();
// //   }

// //   void _onVideoUpdate() {
// //     if (mounted) setState(() {});
// //   }

// //   // ── Controls visibility ───────────────────────────────────────────────────
// //   void _toggleControls() {
// //     setState(() => _controlsVisible = !_controlsVisible);
// //     _controlsVisible ? _fadeCtrl.forward() : _fadeCtrl.reverse();
// //     if (_controlsVisible) {
// //       _startHideTimer();
// //     } else {
// //       _hideTimer?.cancel();
// //     }
// //   }

// //   void _showControls() {
// //     if (!_controlsVisible) {
// //       setState(() => _controlsVisible = true);
// //       _fadeCtrl.forward();
// //     }
// //     _startHideTimer();
// //   }

// //   void _startHideTimer() {
// //     _hideTimer?.cancel();
// //     _hideTimer = Timer(const Duration(seconds: 4), () {
// //       if (mounted && !_isSeeking && _vpc.value.isPlaying) {
// //         setState(() => _controlsVisible = false);
// //         _fadeCtrl.reverse();
// //       }
// //     });
// //   }

// //   // ── Playback ──────────────────────────────────────────────────────────────
// //   void _togglePlay() {
// //     _showControls();
// //     _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
// //   }

// //   void _seek(Duration position) {
// //     final clamped = position < Duration.zero
// //         ? Duration.zero
// //         : position > _vpc.value.duration
// //         ? _vpc.value.duration
// //         : position;
// //     _vpc.seekTo(clamped);
// //     _startHideTimer();
// //   }

// //   void _doubleTapSeek(bool forward) {
// //     _seek(_vpc.value.position + Duration(seconds: forward ? 10 : -10));
// //     setState(() {
// //       _seekLeft = !forward;
// //       _seekSeconds =
// //           (forward ? 1 : -1) * ((_seekSeconds.abs() + 10).clamp(10, 999));
// //       _showSeekFeedback = true;
// //     });
// //     _seekFeedbackTimer?.cancel();
// //     _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
// //         setState(() {
// //           _showSeekFeedback = false;
// //           _seekSeconds = 0;
// //         });
// //     });
// //   }

// //   // ── Long-press fast forward ───────────────────────────────────────────────
// //   void _startFastForward() {
// //     if (_isFastForwarding) return;
// //     setState(() => _isFastForwarding = true);
// //     _vpc.setPlaybackSpeed(2.0);
// //     _showControls();
// //   }

// //   void _stopFastForward() {
// //     if (!_isFastForwarding) return;
// //     setState(() => _isFastForwarding = false);
// //     _vpc.setPlaybackSpeed(_playbackSpeed);
// //   }

// //   // ── Rotation lock ─────────────────────────────────────────────────────────
// //   void _toggleRotationLock() {
// //     setState(() => _isRotationLocked = !_isRotationLocked);
// //     if (_isRotationLocked) {
// //       final isLandscape =
// //           MediaQuery.of(context).orientation == Orientation.landscape;
// //       SystemChrome.setPreferredOrientations(
// //         isLandscape
// //             ? [
// //                 DeviceOrientation.landscapeLeft,
// //                 DeviceOrientation.landscapeRight,
// //               ]
// //             : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
// //       );
// //     } else {
// //       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
// //     }
// //     _showControls();
// //   }

// //   // ── Swipe gestures ────────────────────────────────────────────────────────
// //   void _onSwipeStart(DragStartDetails d, bool isLeft) {
// //     _swipeDragStartY = d.localPosition.dy;
// //     setState(() {
// //       _showBrightnessOverlay = isLeft;
// //       _showVolumeOverlay = !isLeft;
// //     });
// //     _overlayHideTimer?.cancel();
// //   }

// //   void _onSwipeUpdate(DragUpdateDetails d, bool isLeft) {
// //     final delta = (_swipeDragStartY - d.localPosition.dy) / 220;
// //     _swipeDragStartY = d.localPosition.dy;
// //     if (isLeft) {
// //       _swipeBrightness = (_swipeBrightness + delta).clamp(0.0, 1.0);
// //       ScreenBrightness().setApplicationScreenBrightness(_swipeBrightness);
// //     } else {
// //       _swipeVolume = (_swipeVolume + delta).clamp(0.0, 1.0);
// //       _vpc.setVolume(_swipeVolume);
// //       _volume = _swipeVolume;
// //     }
// //     setState(() {});
// //   }

// //   void _onSwipeEnd() {
// //     _overlayHideTimer = Timer(const Duration(seconds: 2), () {
// //         setState(() {
// //           _showBrightnessOverlay = false;
// //           _showVolumeOverlay = false;
// //         });
// //     });
// //   }

// //   // ── Speed / Volume ────────────────────────────────────────────────────────
// //   void _setSpeed(double speed) {
// //     setState(() => _playbackSpeed = speed);
// //     _vpc.setPlaybackSpeed(speed);
// //     Navigator.of(context).pop();
// //   }

// //   void _setVolume(double v) {
// //     setState(() {
// //       _volume = v;
// //       _swipeVolume = v;
// //     });
// //     _vpc.setVolume(v);
// //   }

// //   void _showSpeedSheet() {
// //     _hideTimer?.cancel();
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: const Color(0xFF1A1A1A),
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) => _SpeedSheet(
// //         speeds: _speeds,
// //         current: _playbackSpeed,
// //         onSelect: _setSpeed,
// //       ),
// //     ).then((_) => _startHideTimer());
// //   }

// //   // ── Computed helpers ──────────────────────────────────────────────────────
// //   Duration get _duration => _vpc.value.duration;
// //   Duration get _position => _vpc.value.position;
// //   Duration get _remaining => _duration - _position;
// //   bool get _isPlaying => _vpc.value.isPlaying;
// //   bool get _isBuffering => _vpc.value.isBuffering;

// //   double get _progressFraction => _duration.inMilliseconds == 0
// //       ? 0
// //       : _position.inMilliseconds / _duration.inMilliseconds;

// //   String _fmt(Duration d) {
// //     if (d.inHours > 0) {
// //       return '${d.inHours}:${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// //     }
// //     return '${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
// //   }

// //   String _pad(int v) => v.toString().padLeft(2, '0');

// //   IconData _volumeIcon(double v) => v == 0
// //       ? Icons.volume_off_rounded
// //       : v < 0.5
// //       ? Icons.volume_down_rounded
// //       : Icons.volume_up_rounded;

// //   IconData _brightnessIcon(double v) => v < 0.33
// //       ? Icons.brightness_low_rounded
// //       : v < 0.66
// //       ? Icons.brightness_medium_rounded
// //       : Icons.brightness_high_rounded;

// //   // ── Build ─────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       behavior: HitTestBehavior.translucent,
// //       onTap: _toggleControls,
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           // Always-visible buffering spinner
// //           if (_isBuffering) _buildBufferingOverlay(),

// //           // Swipe zones (left = brightness / right = volume)
// //           _buildSwipeZones(),

// //           // Double-tap seek zones
// //           _buildDoubleTapZones(),

// //           // Seek ripple feedback
// //           if (_showSeekFeedback) _buildSeekFeedback(),

// //           // Brightness overlay
// //           if (_showBrightnessOverlay)
// //             _buildSwipeOverlay(
// //               icon: _brightnessIcon(_swipeBrightness),
// //               value: _swipeBrightness,
// //               color: Colors.amber,
// //               isLeft: true,
// //             ),

// //           // Volume overlay
// //           if (_showVolumeOverlay)
// //             _buildSwipeOverlay(
// //               icon: _volumeIcon(_swipeVolume),
// //               value: _swipeVolume,
// //               color: _kAccentGreen,
// //               isLeft: false,
// //             ),

// //           // Fast-forward banner
// //           if (_isFastForwarding) _buildFastForwardBanner(),

// //           // Fading controls
// //           FadeTransition(
// //             opacity: _fadeAnim,
// //             child: _controlsVisible
// //                 ? _buildControlsOverlay()
// //                 : const SizedBox.shrink(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Swipe zones ───────────────────────────────────────────────────────────
// //   // Swipe zones use a RawGestureDetector with custom threshold:
// //   // short/slow vertical drag → brightness/volume (consumed here)
// //   // long/fast vertical drag  → passes through to ListView scroll
// //   Widget _buildSwipeZones() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: _SwipeZone(
// //             onSwipeStart: (d) => _onSwipeStart(d, true),
// //             onSwipeUpdate: (d) => _onSwipeUpdate(d, true),
// //             onSwipeEnd: () => _onSwipeEnd(),
// //           ),
// //         ),
// //         Expanded(
// //           child: _SwipeZone(
// //             onSwipeStart: (d) => _onSwipeStart(d, false),
// //             onSwipeUpdate: (d) => _onSwipeUpdate(d, false),
// //             onSwipeEnd: () => _onSwipeEnd(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Double-tap zones ──────────────────────────────────────────────────────
// //   Widget _buildDoubleTapZones() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onDoubleTap: () => _doubleTapSeek(false),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //         Expanded(
// //           child: GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             onDoubleTap: () => _doubleTapSeek(true),
// //             child: const SizedBox.expand(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ── Buffering overlay ─────────────────────────────────────────────────────
// //   Widget _buildBufferingOverlay() => Center(
// //     child: SizedBox(
// //       width: 48,
// //       height: 48,
// //       child: CircularProgressIndicator(
// //         color: _kAccentRed,
// //         strokeWidth: 2.5,
// //         backgroundColor: Colors.white12,
// //       ),
// //     ),
// //   );

// //   // ── Seek feedback ─────────────────────────────────────────────────────────
// //   Widget _buildSeekFeedback() {
// //     return Align(
// //       alignment: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// //       child: Container(
// //         width: 100,
// //         height: double.infinity,
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
// //             end: _seekLeft ? Alignment.centerRight : Alignment.centerLeft,
// //             colors: [
// //               Utils.colorWithOpacity(_kAccentRed, 0.18),
// //               Colors.transparent,
// //             ],
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               _seekLeft
// //                   ? Icons.fast_rewind_rounded
// //                   : Icons.fast_forward_rounded,
// //               color: Colors.white,
// //               size: 32,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               '${_seekSeconds.abs()}s',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Swipe overlay (brightness / volume pill) ──────────────────────────────
// //   Widget _buildSwipeOverlay({
// //     required IconData icon,
// //     required double value,
// //     required Color color,
// //     required bool isLeft,
// //   }) {
// //     return Positioned(
// //       left: isLeft ? 16 : null,
// //       right: isLeft ? null : 16,
// //       top: 0,
// //       bottom: 0,
// //       child: Center(
// //         child: Container(
// //           width: 44,
// //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
// //           decoration: BoxDecoration(
// //             color: Colors.black54,
// //             borderRadius: BorderRadius.circular(24),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Icon(icon, color: Colors.white, size: 20),
// //               const SizedBox(height: 8),
// //               SizedBox(
// //                 height: 80,
// //                 width: 4,
// //                 child: RotatedBox(
// //                   quarterTurns: -1,
// //                   child: LinearProgressIndicator(
// //                     value: value,
// //                     backgroundColor: Colors.white24,
// //                     valueColor: AlwaysStoppedAnimation(color),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 '${(value * 100).round()}%',
// //                 style: const TextStyle(color: Colors.white, fontSize: 10),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Fast-forward banner ───────────────────────────────────────────────────
// //   Widget _buildFastForwardBanner() => Center(
// //     child: Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.black54,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: Colors.white24),
// //       ),
// //       child: const Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
// //           SizedBox(width: 6),
// //           Text(
// //             '2× Speed',
// //             style: TextStyle(
// //               color: Colors.white,
// //               fontSize: 13,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );

// //   // ── Controls overlay (Stack-based, no overflow) ───────────────────────────
// //   Widget _buildControlsOverlay() => Stack(
// //     fit: StackFit.expand,
// //     children: [
// //       Center(child: _buildCentreControls()),
// //       Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
// //       Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
// //     ],
// //   );

// //   // ── Top bar ───────────────────────────────────────────────────────────────
// //   Widget _buildTopBar() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: _kBgGradient,
// //         ),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
// //       child: Row(
// //         children: [
// //           // Back (fullscreen only)
// //           if (_isFullScreen)
// //             IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_ios_new_rounded,
// //                 color: Colors.white,
// //                 size: 20,
// //               ),
// //               onPressed: () {
// //                 _chewie.exitFullScreen();
// //                 SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
// //               },
// //             ),

// //           // Title
// //           if (widget.title != null)
// //             Expanded(
// //               child: Padding(
// //                 padding: EdgeInsets.only(left: _isFullScreen ? 0 : 12),
// //                 child: Text(
// //                   widget.title!,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             )
// //           else
// //             const Spacer(),

// //           // Rotation lock
// //           _TopBarBtn(
// //             icon: _isRotationLocked
// //                 ? Icons.screen_lock_rotation_rounded
// //                 : Icons.screen_rotation_rounded,
// //             active: _isRotationLocked,
// //             onTap: _toggleRotationLock,
// //           ),
// //           const SizedBox(width: 4),

// //           // Speed pill
// //           GestureDetector(
// //             onTap: _showSpeedSheet,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //               decoration: BoxDecoration(
// //                 color: Colors.white12,
// //                 borderRadius: BorderRadius.circular(20),
// //                 border: Border.all(color: Colors.white24),
// //               ),
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   const Icon(
// //                     Icons.speed_rounded,
// //                     color: Colors.white70,
// //                     size: 14,
// //                   ),
// //                   const SizedBox(width: 4),
// //                   Text(
// //                     '${_playbackSpeed}x',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 8),

// //           // Volume icon
// //           IconButton(
// //             icon: Icon(_volumeIcon(_volume), color: Colors.white, size: 22),
// //             onPressed: () =>
// //                 setState(() => _showVolumeSlider = !_showVolumeSlider),
// //           ),

// //           // Inline volume slider
// //           if (_showVolumeSlider)
// //             SizedBox(
// //               width: 80,
// //               child: SliderTheme(
// //                 data: SliderTheme.of(context).copyWith(
// //                   trackHeight: 2,
// //                   thumbShape: const RoundSliderThumbShape(
// //                     enabledThumbRadius: 6,
// //                   ),
// //                   overlayShape: const RoundSliderOverlayShape(
// //                     overlayRadius: 12,
// //                   ),
// //                   activeTrackColor: _kAccentGreen,
// //                   inactiveTrackColor: const Color(0xFFD4FFDF),
// //                   thumbColor: Colors.white,
// //                   overlayColor: Utils.colorWithOpacity(_kAccentRed, 0.2),
// //                 ),
// //                 child: Slider(value: _volume, onChanged: _setVolume),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Centre controls ───────────────────────────────────────────────────────
// //   Widget _buildCentreControls() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         // Previous (optional)
// //         if (widget.hasPrevious) ...[
// //           _CircleIconButton(
// //             icon: Icons.skip_previous_rounded,
// //             size: 26,
// //             onTap: () {
// //               widget.onPrevious?.call();
// //               _showControls();
// //             },
// //           ),
// //           const SizedBox(width: 12),
// //         ],

// //         // Rewind 10s
// //         _CircleIconButton(
// //           icon: Icons.replay_10_rounded,
// //           size: 32,
// //           onTap: () => _doubleTapSeek(false),
// //         ),
// //         const SizedBox(width: 28),

// //         // Play / Pause with long-press fast-forward
// //         GestureDetector(
// //           onTap: _togglePlay,
// //           onLongPressStart: (_) => _startFastForward(),
// //           onLongPressEnd: (_) => _stopFastForward(),
// //           onLongPressCancel: _stopFastForward,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 180),
// //             width: 64,
// //             height: 64,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: Utils.colorWithOpacity(
// //                 Colors.white,
// //                 _isFastForwarding ? 0.25 : 0.15,
// //               ),
// //               border: Border.all(
// //                 color: _isFastForwarding ? _kAccentGreen : Colors.white38,
// //                 width: 1.5,
// //               ),
// //             ),
// //             child: _isBuffering
// //                 ? const SizedBox.shrink()
// //                 : Icon(
// //                     _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
// //                     color: Colors.white,
// //                     size: 36,
// //                   ),
// //           ),
// //         ),
// //         const SizedBox(width: 28),

// //         // Forward 10s
// //         _CircleIconButton(
// //           icon: Icons.forward_10_rounded,
// //           size: 32,
// //           onTap: () => _doubleTapSeek(true),
// //         ),

// //         // Next (optional)
// //         if (widget.hasNext) ...[
// //           const SizedBox(width: 12),
// //           _CircleIconButton(
// //             icon: Icons.skip_next_rounded,
// //             size: 26,
// //             onTap: () {
// //               widget.onNext?.call();
// //               _showControls();
// //             },
// //           ),
// //         ],
// //       ],
// //     );
// //   }

// //   // ── Bottom bar ────────────────────────────────────────────────────────────
// //   Widget _buildBottomBar() {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.bottomCenter,
// //           end: Alignment.topCenter,
// //           colors: _kBgGradient,
// //         ),
// //       ),
// //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           _buildScrubber(),
// //           const SizedBox(height: 6),
// //           Row(
// //             children: [
// //               // Tap to toggle position / remaining
// //               GestureDetector(
// //                 onTap: () =>
// //                     setState(() => _showRemainingTime = !_showRemainingTime),
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       _fmt(_position),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                         fontFeatures: [FontFeature.tabularFigures()],
// //                       ),
// //                     ),
// //                     const Text(
// //                       '  /  ',
// //                       style: TextStyle(color: Colors.white38, fontSize: 12),
// //                     ),
// //                     Text(
// //                       _showRemainingTime
// //                           ? '-${_fmt(_remaining)}'
// //                           : _fmt(_duration),
// //                       style: TextStyle(
// //                         color: _showRemainingTime
// //                             ? _kAccentGreen
// //                             : Colors.white54,
// //                         fontSize: 12,
// //                         fontFeatures: const [FontFeature.tabularFigures()],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const Spacer(),
// //               // Fullscreen toggle
// //               GestureDetector(
// //                 onTap: () {
// //                   _isFullScreen
// //                       ? _chewie.exitFullScreen()
// //                       : _chewie.enterFullScreen();
// //                   setState(() => _isFullScreen = !_isFullScreen);
// //                 },
// //                 child: Icon(
// //                   _isFullScreen
// //                       ? Icons.fullscreen_exit_rounded
// //                       : Icons.fullscreen_rounded,
// //                   color: Colors.white,
// //                   size: 26,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Scrubber ──────────────────────────────────────────────────────────────
// //   Widget _buildScrubber() {
// //     final buffered = _vpc.value.buffered;
// //     final bufferedFraction = buffered.isEmpty || _duration.inMilliseconds == 0
// //         ? 0.0
// //         : (buffered.last.end.inMilliseconds / _duration.inMilliseconds).clamp(
// //             0.0,
// //             1.0,
// //           );

// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final trackW = constraints.maxWidth;
// //         return GestureDetector(
// //           behavior: HitTestBehavior.opaque,
// //           onHorizontalDragStart: (_) {
// //             _isSeeking = true;
// //             _hideTimer?.cancel();
// //           },
// //           onHorizontalDragUpdate: (d) {
// //             setState(
// //               () =>
// //                   _seekPosition = (d.localPosition.dx / trackW).clamp(0.0, 1.0),
// //             );
// //           },
// //           onHorizontalDragEnd: (_) {
// //             _isSeeking = false;
// //             _seek(
// //               Duration(
// //                 milliseconds: (_seekPosition * _duration.inMilliseconds)
// //                     .round(),
// //               ),
// //             );
// //             _startHideTimer();
// //           },
// //           child: SizedBox(
// //             height: 28,
// //             child: Stack(
// //               alignment: Alignment.centerLeft,
// //               children: [
// //                 // Track
// //                 Container(
// //                   height: _isSeeking ? 5 : 3,
// //                   decoration: BoxDecoration(
// //                     color: Colors.white24,
// //                     borderRadius: BorderRadius.circular(4),
// //                   ),
// //                 ),
// //                 // Buffered
// //                 FractionallySizedBox(
// //                   widthFactor: bufferedFraction,
// //                   child: Container(
// //                     height: _isSeeking ? 5 : 3,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white38,
// //                       borderRadius: BorderRadius.circular(4),
// //                     ),
// //                   ),
// //                 ),
// //                 // Played
// //                 FractionallySizedBox(
// //                   widthFactor: _isSeeking ? _seekPosition : _progressFraction,
// //                   child: Container(
// //                     height: _isSeeking ? 5 : 3,
// //                     decoration: BoxDecoration(
// //                       color: _kAccentGreen,
// //                       borderRadius: BorderRadius.circular(4),
// //                     ),
// //                   ),
// //                 ),
// //                 // Thumb
// //                 Positioned(
// //                   left:
// //                       ((_isSeeking ? _seekPosition : _progressFraction) *
// //                               trackW)
// //                           .clamp(0, trackW - 14),
// //                   child: AnimatedContainer(
// //                     duration: const Duration(milliseconds: 120),
// //                     width: _isSeeking ? 16 : 12,
// //                     height: _isSeeking ? 16 : 12,
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.white,
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Utils.colorWithOpacity(_kAccentRed, 0.6),
// //                           blurRadius: _isSeeking ? 8 : 0,
// //                           spreadRadius: _isSeeking ? 2 : 0,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Top bar icon button with active state
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _TopBarBtn extends StatelessWidget {
// //   const _TopBarBtn({
// //     required this.icon,
// //     required this.onTap,
// //     this.active = false,
// //   });

// //   final IconData icon;
// //   final VoidCallback onTap;
// //   final bool active;

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(6),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: active
// //               ? const Color(0xFF53BC77).withOpacity(0.25)
// //               : Colors.transparent,
// //         ),
// //         child: Icon(
// //           icon,
// //           color: active ? const Color(0xFF53BC77) : Colors.white,
// //           size: 20,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Speed bottom sheet
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _SpeedSheet extends StatelessWidget {
// //   const _SpeedSheet({
// //     required this.speeds,
// //     required this.current,
// //     required this.onSelect,
// //   });

// //   final List<double> speeds;
// //   final double current;
// //   final void Function(double) onSelect;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         const SizedBox(height: 12),
// //         Container(
// //           width: 36,
// //           height: 4,
// //           decoration: BoxDecoration(
// //             color: Colors.white24,
// //             borderRadius: BorderRadius.circular(2),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         const Text(
// //           'Playback Speed',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 15,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //         ...speeds.map(
// //           (s) => InkWell(
// //             onTap: () => onSelect(s),
// //             child: Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
// //               child: Row(
// //                 children: [
// //                   Text(
// //                     '$s ×',
// //                     style: TextStyle(
// //                       color: s == current
// //                           ? const Color(0xFFE53935)
// //                           : Colors.white,
// //                       fontSize: 15,
// //                       fontWeight: s == current
// //                           ? FontWeight.w700
// //                           : FontWeight.w400,
// //                     ),
// //                   ),
// //                   if (s == current) ...[
// //                     const Spacer(),
// //                     const Icon(
// //                       Icons.check_rounded,
// //                       color: Color(0xFFE53935),
// //                       size: 18,
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //       ],
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Small circle icon button
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _CircleIconButton extends StatelessWidget {
// //   const _CircleIconButton({
// //     required this.icon,
// //     required this.onTap,
// //     this.size = 28,
// //   });

// //   final IconData icon;
// //   final VoidCallback onTap;
// //   final double size;

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(8),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: Utils.colorWithOpacity(Colors.white, 0.1),
// //         ),
// //         child: Icon(icon, color: Colors.white, size: size),
// //       ),
// //     );
// //   }
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // SwipeZone — vertical drag for brightness/volume that doesn't block scrolling.
// // // Only consumes the gesture if the drag is slow/deliberate (velocity < 800).
// // // Fast flicks pass through to the parent ListView as scroll events.
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _SwipeZone extends StatefulWidget {
// //   const _SwipeZone({
// //     required this.onSwipeStart,
// //     required this.onSwipeUpdate,
// //     required this.onSwipeEnd,
// //   });

// //   final void Function(DragStartDetails) onSwipeStart;
// //   final void Function(DragUpdateDetails) onSwipeUpdate;
// //   final VoidCallback onSwipeEnd;

// //   @override
// //   State<_SwipeZone> createState() => _SwipeZoneState();
// // }

// // class _SwipeZoneState extends State<_SwipeZone> {
// //   bool _isTracking = false;
// //   Offset _startPosition = Offset.zero;

// //   static const double _minDragDistance = 8.0; // px before we decide intent

// //   @override
// //   Widget build(BuildContext context) {
// //     return Listener(
// //       behavior: HitTestBehavior.translucent,
// //       onPointerDown: (e) {
// //         _isTracking = false;
// //         _startPosition = e.position;
// //       },
// //       onPointerMove: (e) {
// //         final delta = e.position - _startPosition;
// //         if (!_isTracking && delta.distance > _minDragDistance) {
// //           // Decide: more vertical than horizontal = swipe intent
// //           if (delta.dy.abs() > delta.dx.abs()) {
// //             _isTracking = true;
// //             widget.onSwipeStart(
// //               DragStartDetails(
// //                 globalPosition: _startPosition,
// //                 localPosition: _startPosition,
// //               ),
// //             );
// //           }
// //         }
// //         if (_isTracking) {
// //           widget.onSwipeUpdate(
// //             DragUpdateDetails(
// //               globalPosition: e.position,
// //               localPosition: e.localPosition,
// //               delta: e.delta,
// //               primaryDelta: e.delta.dy,
// //             ),
// //           );
// //         }
// //       },
// //       onPointerUp: (_) {
// //         if (_isTracking) {
// //           _isTracking = false;
// //           widget.onSwipeEnd();
// //         }
// //       },
// //       onPointerCancel: (_) {
// //         _isTracking = false;
// //       },
// //       child: const SizedBox.expand(),
// //     );
// //   }
// // }

// import 'dart:async';

// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_player_app/utils.dart/utils.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // CustomVideoControls  –  Cinema skin
// //
// // New features vs previous version:
// //   • Swipe up/down LEFT  half → brightness control  (needs screen_brightness pkg)
// //   • Swipe up/down RIGHT half → volume control
// //   • Long-press play button  → 2× fast-forward while held
// //   • Rotation lock toggle button in top bar
// //   • Video title in top bar
// //   • Tap time label to toggle remaining time display
// //   • Next / Previous skip buttons (optional callbacks)
// // ─────────────────────────────────────────────────────────────────────────────

// class CustomVideoControls extends StatefulWidget {
//   const CustomVideoControls({
//     super.key,
//     this.thumbnail,
//     this.title,
//     this.onNext,
//     this.onPrevious,
//     this.hasNext = false,
//     this.hasPrevious = false,
//   });

//   final Uint8List? thumbnail;
//   final String?    title;
//   final VoidCallback? onNext;
//   final VoidCallback? onPrevious;
//   final bool hasNext;
//   final bool hasPrevious;

//   @override
//   State<CustomVideoControls> createState() => _CustomVideoControlsState();
// }

// class _CustomVideoControlsState extends State<CustomVideoControls>
//     with SingleTickerProviderStateMixin {

//   // ── Chewie / VideoPlayer ──────────────────────────────────────────────────
//   late ChewieController _chewie;
//   VideoPlayerController get _vpc => _chewie.videoPlayerController;

//   // ── Existing state ────────────────────────────────────────────────────────
//   bool   _controlsVisible  = true;
//   bool   _isSeeking        = false;
//   double _seekPosition     = 0;
//   double _volume           = 1.0;
//   bool   _showVolumeSlider = false;
//   double _playbackSpeed    = 1.0;
//   bool   _isFullScreen     = false;

//   // ── NEW state ─────────────────────────────────────────────────────────────
//   bool   _showRemainingTime   = false;   // tap time → toggle remaining
//   bool   _isRotationLocked    = false;   // rotation lock
//   bool   _isFastForwarding    = false;   // long-press 2× speed

//   // swipe gesture tracking
//   double _swipeBrightness       = 0.8;
//   double _swipeVolume           = 1.0;
//   bool   _showBrightnessOverlay = false;
//   bool   _showVolumeOverlay     = false;
//   double _swipeDragStartY       = 0;
//   Timer? _overlayHideTimer;

//   // ── Animation ─────────────────────────────────────────────────────────────
//   late AnimationController _fadeCtrl;
//   late Animation<double>   _fadeAnim;

//   // ── Timers ────────────────────────────────────────────────────────────────
//   Timer? _hideTimer;
//   Timer? _seekFeedbackTimer;

//   // ── Seek feedback ─────────────────────────────────────────────────────────
//   int  _seekSeconds      = 0;
//   bool _showSeekFeedback = false;
//   bool _seekLeft         = false;

//   static const _speeds       = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
//   static const _kAccentRed   = Color(0xFFE53935);
//   static const _kAccentGreen = Color(0xFF53BC77);
//   static const _kBgGradient  = [Color(0xCC000000), Colors.transparent];

//   // ── Init / dispose ────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//       value: 1,
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
//     _startHideTimer();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _chewie      = ChewieController.of(context);
//     _isFullScreen = _chewie.isFullScreen;
//     _volume      = _vpc.value.volume;
//     _swipeVolume = _volume;
//     _vpc.addListener(_onVideoUpdate);
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _vpc.removeListener(_onVideoUpdate);
//     _fadeCtrl.dispose();
//     _hideTimer?.cancel();
//     _seekFeedbackTimer?.cancel();
//     _overlayHideTimer?.cancel();
//     if (_isRotationLocked) {
//       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
//     }
//     super.dispose();
//   }

//   void _onVideoUpdate() { if (mounted) setState(() {}); }

//   // ── Controls visibility ───────────────────────────────────────────────────
//   void _toggleControls() {
//     setState(() => _controlsVisible = !_controlsVisible);
//     _controlsVisible ? _fadeCtrl.forward() : _fadeCtrl.reverse();
//     if (_controlsVisible) _startHideTimer(); else _hideTimer?.cancel();
//   }

//   void _showControls() {
//     if (!_controlsVisible) {
//       setState(() => _controlsVisible = true);
//       _fadeCtrl.forward();
//     }
//     _startHideTimer();
//   }

//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted && !_isSeeking && _vpc.value.isPlaying) {
//         setState(() => _controlsVisible = false);
//         _fadeCtrl.reverse();
//       }
//     });
//   }

//   // ── Playback ──────────────────────────────────────────────────────────────
//   void _togglePlay() {
//     _showControls();
//     _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
//   }

//   void _seek(Duration position) {
//     final clamped = position < Duration.zero
//         ? Duration.zero
//         : position > _vpc.value.duration
//             ? _vpc.value.duration
//             : position;
//     _vpc.seekTo(clamped);
//     _startHideTimer();
//   }

//   void _doubleTapSeek(bool forward) {
//     _seek(_vpc.value.position + Duration(seconds: forward ? 10 : -10));
//     setState(() {
//       _seekLeft      = !forward;
//       _seekSeconds   = (forward ? 1 : -1) * ((_seekSeconds.abs() + 10).clamp(10, 999));
//       _showSeekFeedback = true;
//     });
//     _seekFeedbackTimer?.cancel();
//     _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
//       if (mounted) setState(() { _showSeekFeedback = false; _seekSeconds = 0; });
//     });
//   }

//   // ── Long-press fast forward ───────────────────────────────────────────────
//   void _startFastForward() {
//     if (_isFastForwarding) return;
//     setState(() => _isFastForwarding = true);
//     _vpc.setPlaybackSpeed(2.0);
//     _showControls();
//   }

//   void _stopFastForward() {
//     if (!_isFastForwarding) return;
//     setState(() => _isFastForwarding = false);
//     _vpc.setPlaybackSpeed(_playbackSpeed);
//   }

//   // ── Rotation lock ─────────────────────────────────────────────────────────
//   void _toggleRotationLock() {
//     setState(() => _isRotationLocked = !_isRotationLocked);
//     if (_isRotationLocked) {
//       final isLandscape =
//           MediaQuery.of(context).orientation == Orientation.landscape;
//       SystemChrome.setPreferredOrientations(isLandscape
//           ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
//           : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//     } else {
//       SystemChrome.setPreferredOrientations(DeviceOrientation.values);
//     }
//     _showControls();
//   }

//   // ── Swipe gestures ────────────────────────────────────────────────────────
//   void _onSwipeStart(DragStartDetails d, bool isLeft) {
//     _swipeDragStartY = d.localPosition.dy;
//     setState(() {
//       _showBrightnessOverlay = isLeft;
//       _showVolumeOverlay     = !isLeft;
//     });
//     _overlayHideTimer?.cancel();
//   }

//   void _onSwipeUpdate(DragUpdateDetails d, bool isLeft) {
//     final delta = (_swipeDragStartY - d.localPosition.dy) / 220;
//     _swipeDragStartY = d.localPosition.dy;
//     if (isLeft) {
//       _swipeBrightness = (_swipeBrightness + delta).clamp(0.0, 1.0);
//       // Plug in screen_brightness pkg here:
//        ScreenBrightness().setApplicationScreenBrightness(_swipeBrightness);
//     } else {
//       _swipeVolume = (_swipeVolume + delta).clamp(0.0, 1.0);
//       _vpc.setVolume(_swipeVolume);
//       _volume = _swipeVolume;
//     }
//     setState(() {});
//   }

//   void _onSwipeEnd() {
//     _overlayHideTimer = Timer(const Duration(seconds: 2), () {
//       if (mounted) setState(() {
//         _showBrightnessOverlay = false;
//         _showVolumeOverlay     = false;
//       });
//     });
//   }

//   // ── Speed / Volume ────────────────────────────────────────────────────────
//   void _setSpeed(double speed) {
//     setState(() => _playbackSpeed = speed);
//     _vpc.setPlaybackSpeed(speed);
//     Navigator.of(context).pop();
//   }

//   void _setVolume(double v) {
//     setState(() { _volume = v; _swipeVolume = v; });
//     _vpc.setVolume(v);
//   }

//   void _showSpeedSheet() {
//     _hideTimer?.cancel();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1A1A1A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _SpeedSheet(
//         speeds: _speeds, current: _playbackSpeed, onSelect: _setSpeed,
//       ),
//     ).then((_) => _startHideTimer());
//   }

//   // ── Computed helpers ──────────────────────────────────────────────────────
//   Duration get _duration  => _vpc.value.duration;
//   Duration get _position  => _vpc.value.position;
//   Duration get _remaining => _duration - _position;
//   bool get _isPlaying     => _vpc.value.isPlaying;
//   bool get _isBuffering   => _vpc.value.isBuffering;

//   double get _progressFraction => _duration.inMilliseconds == 0
//       ? 0 : _position.inMilliseconds / _duration.inMilliseconds;

//   String _fmt(Duration d) {
//     if (d.inHours > 0) {
//       return '${d.inHours}:${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
//     }
//     return '${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
//   }
//   String _pad(int v) => v.toString().padLeft(2, '0');

//   IconData _volumeIcon(double v) => v == 0
//       ? Icons.volume_off_rounded
//       : v < 0.5 ? Icons.volume_down_rounded : Icons.volume_up_rounded;

//   IconData _brightnessIcon(double v) => v < 0.33
//       ? Icons.brightness_low_rounded
//       : v < 0.66 ? Icons.brightness_medium_rounded : Icons.brightness_high_rounded;

//   // ── Build ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: _toggleControls,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Always-visible buffering spinner
//           if (_isBuffering) _buildBufferingOverlay(),

//           // Swipe zones (left = brightness / right = volume)
//           _buildSwipeZones(),

//           // Double-tap seek zones
//           _buildDoubleTapZones(),

//           // Seek ripple feedback
//           if (_showSeekFeedback) _buildSeekFeedback(),

//           // Brightness overlay
//           if (_showBrightnessOverlay)
//             _buildSwipeOverlay(
//               icon: _brightnessIcon(_swipeBrightness),
//               value: _swipeBrightness,
//               color: Colors.amber,
//               isLeft: true,
//             ),

//           // Volume overlay
//           if (_showVolumeOverlay)
//             _buildSwipeOverlay(
//               icon: _volumeIcon(_swipeVolume),
//               value: _swipeVolume,
//               color: _kAccentGreen,
//               isLeft: false,
//             ),

//           // Fast-forward banner
//           if (_isFastForwarding) _buildFastForwardBanner(),

//           // Fading controls
//           FadeTransition(
//             opacity: _fadeAnim,
//             child: _controlsVisible
//                 ? _buildControlsOverlay()
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Swipe zones ───────────────────────────────────────────────────────────
//   // Swipe zones use a RawGestureDetector with custom threshold:
//   // short/slow vertical drag → brightness/volume (consumed here)
//   // long/fast vertical drag  → passes through to ListView scroll
//   Widget _buildSwipeZones() {
//     return Row(children: [
//       Expanded(child: _SwipeZone(
//         onSwipeStart:  (d) => _onSwipeStart(d, true),
//         onSwipeUpdate: (d) => _onSwipeUpdate(d, true),
//         onSwipeEnd:    () => _onSwipeEnd(),
//       )),
//       Expanded(child: _SwipeZone(
//         onSwipeStart:  (d) => _onSwipeStart(d, false),
//         onSwipeUpdate: (d) => _onSwipeUpdate(d, false),
//         onSwipeEnd:    () => _onSwipeEnd(),
//       )),
//     ]);
//   }

//   // ── Double-tap zones ──────────────────────────────────────────────────────
//   Widget _buildDoubleTapZones() {
//     return Row(children: [
//       Expanded(child: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onDoubleTap: () => _doubleTapSeek(false),
//         child: const SizedBox.expand(),
//       )),
//       Expanded(child: GestureDetector(
//         behavior: HitTestBehavior.translucent,
//         onDoubleTap: () => _doubleTapSeek(true),
//         child: const SizedBox.expand(),
//       )),
//     ]);
//   }

//   // ── Buffering overlay ─────────────────────────────────────────────────────
//   Widget _buildBufferingOverlay() => Center(
//     child: SizedBox(
//       width: 48, height: 48,
//       child: CircularProgressIndicator(
//         color: _kAccentRed, strokeWidth: 2.5,
//         backgroundColor: Colors.white12,
//       ),
//     ),
//   );

//   // ── Seek feedback ─────────────────────────────────────────────────────────
//   Widget _buildSeekFeedback() {
//     return Align(
//       alignment: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
//       child: Container(
//         width: 100, height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: _seekLeft ? Alignment.centerLeft  : Alignment.centerRight,
//             end:   _seekLeft ? Alignment.centerRight : Alignment.centerLeft,
//             colors: [Utils.colorWithOpacity(_kAccentRed, 0.18), Colors.transparent],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _seekLeft ? Icons.fast_rewind_rounded : Icons.fast_forward_rounded,
//               color: Colors.white, size: 32,
//             ),
//             const SizedBox(height: 4),
//             Text('${_seekSeconds.abs()}s',
//               style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Swipe overlay (brightness / volume pill) ──────────────────────────────
//   Widget _buildSwipeOverlay({
//     required IconData icon,
//     required double value,
//     required Color color,
//     required bool isLeft,
//   }) {
//     return Positioned(
//       left:   isLeft ? 16 : null,
//       right:  isLeft ? null : 16,
//       top: 0, bottom: 0,
//       child: Center(
//         child: Container(
//           width: 44,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//           decoration: BoxDecoration(
//             color: Colors.black54,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: Colors.white, size: 20),
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 80, width: 4,
//                 child: RotatedBox(
//                   quarterTurns: -1,
//                   child: LinearProgressIndicator(
//                     value: value,
//                     backgroundColor: Colors.white24,
//                     valueColor: AlwaysStoppedAnimation(color),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text('${(value * 100).round()}%',
//                 style: const TextStyle(color: Colors.white, fontSize: 10)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Fast-forward banner ───────────────────────────────────────────────────
//   Widget _buildFastForwardBanner() => Center(
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.black54,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white24),
//       ),
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
//           SizedBox(width: 6),
//           Text('2× Speed',
//             style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//         ],
//       ),
//     ),
//   );

//   // ── Controls overlay (Stack-based, no overflow) ───────────────────────────
//   Widget _buildControlsOverlay() => Stack(
//     fit: StackFit.expand,
//     children: [
//       Center(child: _buildCentreControls()),
//       Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
//       Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
//     ],
//   );

//   // ── Top bar ───────────────────────────────────────────────────────────────
//   Widget _buildTopBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter, end: Alignment.bottomCenter,
//           colors: _kBgGradient,
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
//       child: Row(children: [
//         // Back (fullscreen only)
//         if (_isFullScreen)
//           IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
//             onPressed: () {
//               _chewie.exitFullScreen();
//               SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//             },
//           ),

//         // Title
//         if (widget.title != null)
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(left: _isFullScreen ? 0 : 12),
//               child: Text(widget.title!,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
//               ),
//             ),
//           )
//         else
//           const Spacer(),

//         // Rotation lock
//         _TopBarBtn(
//           icon: _isRotationLocked
//               ? Icons.screen_lock_rotation_rounded
//               : Icons.screen_rotation_rounded,
//           active: _isRotationLocked,
//           onTap: _toggleRotationLock,
//         ),
//         const SizedBox(width: 4),

//         // Speed pill
//         GestureDetector(
//           onTap: _showSpeedSheet,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.white12,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white24),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.speed_rounded, color: Colors.white70, size: 14),
//                 const SizedBox(width: 4),
//                 Text('${_playbackSpeed}x',
//                   style: const TextStyle(
//                     color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),

//         // Volume icon
//         IconButton(
//           icon: Icon(_volumeIcon(_volume), color: Colors.white, size: 22),
//           onPressed: () => setState(() => _showVolumeSlider = !_showVolumeSlider),
//         ),

//         // Inline volume slider
//         if (_showVolumeSlider)
//           SizedBox(
//             width: 80,
//             child: SliderTheme(
//               data: SliderTheme.of(context).copyWith(
//                 trackHeight: 2,
//                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//                 overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
//                 activeTrackColor: _kAccentGreen,
//                 inactiveTrackColor: const Color(0xFFD4FFDF),
//                 thumbColor: Colors.white,
//                 overlayColor: Utils.colorWithOpacity(_kAccentRed, 0.2),
//               ),
//               child: Slider(value: _volume, onChanged: _setVolume),
//             ),
//           ),
//       ]),
//     );
//   }

//   // ── Centre controls ───────────────────────────────────────────────────────
//   Widget _buildCentreControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Previous (optional)
//         if (widget.hasPrevious) ...[
//           _CircleIconButton(
//             icon: Icons.skip_previous_rounded, size: 26,
//             onTap: () { widget.onPrevious?.call(); _showControls(); },
//           ),
//           const SizedBox(width: 12),
//         ],

//         // Rewind 10s
//         _CircleIconButton(
//           icon: Icons.replay_10_rounded, size: 32,
//           onTap: () => _doubleTapSeek(false),
//         ),
//         const SizedBox(width: 28),

//         // Play / Pause with long-press fast-forward
//         GestureDetector(
//           onTap: _togglePlay,
//           onLongPressStart: (_) => _startFastForward(),
//           onLongPressEnd:   (_) => _stopFastForward(),
//           onLongPressCancel:    _stopFastForward,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             width: 64, height: 64,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Utils.colorWithOpacity(Colors.white,
//                   _isFastForwarding ? 0.25 : 0.15),
//               border: Border.all(
//                 color: _isFastForwarding ? _kAccentGreen : Colors.white38,
//                 width: 1.5,
//               ),
//             ),
//             child: _isBuffering
//                 ? const SizedBox.shrink()
//                 : Icon(
//                     _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
//                     color: Colors.white, size: 36,
//                   ),
//           ),
//         ),
//         const SizedBox(width: 28),

//         // Forward 10s
//         _CircleIconButton(
//           icon: Icons.forward_10_rounded, size: 32,
//           onTap: () => _doubleTapSeek(true),
//         ),

//         // Next (optional)
//         if (widget.hasNext) ...[
//           const SizedBox(width: 12),
//           _CircleIconButton(
//             icon: Icons.skip_next_rounded, size: 26,
//             onTap: () { widget.onNext?.call(); _showControls(); },
//           ),
//         ],
//       ],
//     );
//   }

//   // ── Bottom bar ────────────────────────────────────────────────────────────
//   Widget _buildBottomBar() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.bottomCenter, end: Alignment.topCenter,
//           colors: _kBgGradient,
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildScrubber(),
//           const SizedBox(height: 6),
//           Row(children: [
//             // Tap to toggle position / remaining
//             GestureDetector(
//               onTap: () => setState(() => _showRemainingTime = !_showRemainingTime),
//               child: Row(children: [
//                 Text(_fmt(_position),
//                   style: const TextStyle(
//                     color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500,
//                     fontFeatures: [FontFeature.tabularFigures()],
//                   )),
//                 const Text('  /  ',
//                   style: TextStyle(color: Colors.white38, fontSize: 12)),
//                 Text(
//                   _showRemainingTime ? '-${_fmt(_remaining)}' : _fmt(_duration),
//                   style: TextStyle(
//                     color: _showRemainingTime ? _kAccentGreen : Colors.white54,
//                     fontSize: 12,
//                     fontFeatures: const [FontFeature.tabularFigures()],
//                   ),
//                 ),
//               ]),
//             ),
//             const Spacer(),
//             // Fullscreen toggle
//             GestureDetector(
//               onTap: () {
//                 _isFullScreen
//                     ? _chewie.exitFullScreen()
//                     : _chewie.enterFullScreen();
//                 setState(() => _isFullScreen = !_isFullScreen);
//               },
//               child: Icon(
//                 _isFullScreen
//                     ? Icons.fullscreen_exit_rounded
//                     : Icons.fullscreen_rounded,
//                 color: Colors.white, size: 26,
//               ),
//             ),
//           ]),
//         ],
//       ),
//     );
//   }

//   // ── Scrubber ──────────────────────────────────────────────────────────────
//   Widget _buildScrubber() {
//     final buffered = _vpc.value.buffered;
//     final bufferedFraction = buffered.isEmpty || _duration.inMilliseconds == 0
//         ? 0.0
//         : (buffered.last.end.inMilliseconds / _duration.inMilliseconds)
//             .clamp(0.0, 1.0);

//     return LayoutBuilder(builder: (context, constraints) {
//       final trackW = constraints.maxWidth;
//       return GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onHorizontalDragStart: (_) { _isSeeking = true; _hideTimer?.cancel(); },
//         onHorizontalDragUpdate: (d) {
//           setState(() => _seekPosition =
//               (d.localPosition.dx / trackW).clamp(0.0, 1.0));
//         },
//         onHorizontalDragEnd: (_) {
//           _isSeeking = false;
//           _seek(Duration(
//             milliseconds: (_seekPosition * _duration.inMilliseconds).round()));
//           _startHideTimer();
//         },
//         child: SizedBox(
//           height: 28,
//           child: Stack(
//             alignment: Alignment.centerLeft,
//             children: [
//               // Track
//               Container(
//                 height: _isSeeking ? 5 : 3,
//                 decoration: BoxDecoration(
//                   color: Colors.white24,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               // Buffered
//               FractionallySizedBox(
//                 widthFactor: bufferedFraction,
//                 child: Container(
//                   height: _isSeeking ? 5 : 3,
//                   decoration: BoxDecoration(
//                     color: Colors.white38,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//               // Played
//               FractionallySizedBox(
//                 widthFactor: _isSeeking ? _seekPosition : _progressFraction,
//                 child: Container(
//                   height: _isSeeking ? 5 : 3,
//                   decoration: BoxDecoration(
//                     color: _kAccentGreen,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//               // Thumb
//               Positioned(
//                 left: ((_isSeeking ? _seekPosition : _progressFraction) * trackW)
//                     .clamp(0, trackW - 14),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 120),
//                   width: _isSeeking ? 16 : 12,
//                   height: _isSeeking ? 16 : 12,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Utils.colorWithOpacity(_kAccentRed, 0.6),
//                         blurRadius: _isSeeking ? 8 : 0,
//                         spreadRadius: _isSeeking ? 2 : 0,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Top bar icon button with active state
// // ─────────────────────────────────────────────────────────────────────────────
// class _TopBarBtn extends StatelessWidget {
//   const _TopBarBtn({
//     required this.icon,
//     required this.onTap,
//     this.active = false,
//   });

//   final IconData    icon;
//   final VoidCallback onTap;
//   final bool        active;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: active
//               ? const Color(0xFF53BC77).withOpacity(0.25)
//               : Colors.transparent,
//         ),
//         child: Icon(icon,
//           color: active ? const Color(0xFF53BC77) : Colors.white,
//           size: 20),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Speed bottom sheet
// // ─────────────────────────────────────────────────────────────────────────────
// class _SpeedSheet extends StatelessWidget {
//   const _SpeedSheet({
//     required this.speeds,
//     required this.current,
//     required this.onSelect,
//   });

//   final List<double>       speeds;
//   final double             current;
//   final void Function(double) onSelect;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 12),
//         Container(
//           width: 36, height: 4,
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text('Playback Speed',
//           style: TextStyle(
//             color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 12),
//         ...speeds.map((s) => InkWell(
//           onTap: () => onSelect(s),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//             child: Row(children: [
//               Text('$s ×',
//                 style: TextStyle(
//                   color: s == current ? const Color(0xFFE53935) : Colors.white,
//                   fontSize: 15,
//                   fontWeight: s == current ? FontWeight.w700 : FontWeight.w400,
//                 )),
//               if (s == current) ...[
//                 const Spacer(),
//                 const Icon(Icons.check_rounded, color: Color(0xFFE53935), size: 18),
//               ],
//             ]),
//           ),
//         )),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Small circle icon button
// // ─────────────────────────────────────────────────────────────────────────────
// class _CircleIconButton extends StatelessWidget {
//   const _CircleIconButton({
//     required this.icon,
//     required this.onTap,
//     this.size = 28,
//   });

//   final IconData    icon;
//   final VoidCallback onTap;
//   final double      size;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Utils.colorWithOpacity(Colors.white, 0.1),
//         ),
//         child: Icon(icon, color: Colors.white, size: size),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // SwipeZone — vertical drag for brightness/volume that doesn't block scrolling.
// // Only consumes the gesture if the drag is slow/deliberate (velocity < 800).
// // Fast flicks pass through to the parent ListView as scroll events.
// // ─────────────────────────────────────────────────────────────────────────────
// class _SwipeZone extends StatefulWidget {
//   const _SwipeZone({
//     required this.onSwipeStart,
//     required this.onSwipeUpdate,
//     required this.onSwipeEnd,
//   });

//   final void Function(DragStartDetails) onSwipeStart;
//   final void Function(DragUpdateDetails) onSwipeUpdate;
//   final VoidCallback onSwipeEnd;

//   @override
//   State<_SwipeZone> createState() => _SwipeZoneState();
// }

// class _SwipeZoneState extends State<_SwipeZone> {
//   bool _isTracking = false;
//   Offset _startPosition = Offset.zero;

//   static const double _minDragDistance = 8.0; // px before we decide intent

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       behavior: HitTestBehavior.translucent,
//       onPointerDown: (e) {
//         _isTracking = false;
//         _startPosition = e.position;
//       },
//       onPointerMove: (e) {
//         final delta = e.position - _startPosition;
//         if (!_isTracking && delta.distance > _minDragDistance) {
//           // Decide: more vertical than horizontal = swipe intent
//           if (delta.dy.abs() > delta.dx.abs()) {
//             _isTracking = true;
//             widget.onSwipeStart(DragStartDetails(
//               globalPosition: _startPosition,
//               localPosition: _startPosition,
//             ));
//           }
//         }
//         if (_isTracking) {
//           widget.onSwipeUpdate(DragUpdateDetails(
//             globalPosition: e.position,
//             localPosition: e.localPosition,
//             delta: e.delta,
//             primaryDelta: null,
//           ));
//         }
//       },
//       onPointerUp: (_) {
//         if (_isTracking) {
//           _isTracking = false;
//           widget.onSwipeEnd();
//         }
//       },
//       onPointerCancel: (_) {
//         _isTracking = false;
//       },
//       child: const SizedBox.expand(),
//     );
//   }
// }

import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player_app/utils.dart/utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CustomVideoControls  –  Cinema skin
//
// New features vs previous version:
//   • Swipe up/down LEFT  half → brightness control  (needs screen_brightness pkg)
//   • Swipe up/down RIGHT half → volume control
//   • Long-press play button  → 2× fast-forward while held
//   • Rotation lock toggle button in top bar
//   • Video title in top bar
//   • Tap time label to toggle remaining time display
//   • Next / Previous skip buttons (optional callbacks)
// ─────────────────────────────────────────────────────────────────────────────

class CustomVideoControls extends StatefulWidget {
  const CustomVideoControls({
    super.key,
    this.thumbnail,
    this.title,
    this.onNext,
    this.onPrevious,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  final Uint8List? thumbnail;
  final String? title;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls>
    with SingleTickerProviderStateMixin {
  // ── Chewie / VideoPlayer ──────────────────────────────────────────────────
  late ChewieController _chewie;
  VideoPlayerController get _vpc => _chewie.videoPlayerController;

  // ── Existing state ────────────────────────────────────────────────────────
  bool _controlsVisible = true;
  bool _isSeeking = false;
  double _seekPosition = 0;
  double _volume = 1.0;
  bool _showVolumeSlider = false;
  double _playbackSpeed = 1.0;
  bool _isFullScreen = false;

  // ── NEW state ─────────────────────────────────────────────────────────────
  bool _showRemainingTime = false; // tap time → toggle remaining
  bool _isRotationLocked = false; // rotation lock
  bool _isFastForwarding = false; // long-press 2× speed

  // swipe gesture tracking
  double _swipeBrightness = 0.8;
  double _swipeVolume = 1.0;
  bool _showBrightnessOverlay = false;
  bool _showVolumeOverlay = false;
  double _swipeDragStartY = 0;
  Timer? _overlayHideTimer;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── Timers ────────────────────────────────────────────────────────────────
  Timer? _hideTimer;
  Timer? _seekFeedbackTimer;

  // ── Seek feedback ─────────────────────────────────────────────────────────
  int _seekSeconds = 0;
  bool _showSeekFeedback = false;
  bool _seekLeft = false;

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const _kAccentRed = Color(0xFFE53935);
  static const _kAccentGreen = Color(0xFF53BC77);
  static const _kBgGradient = [Color(0xCC000000), Colors.transparent];

  // ── Init / dispose ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _startHideTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chewie = ChewieController.of(context);
    _isFullScreen = _chewie.isFullScreen;
    _volume = _vpc.value.volume;
    _swipeVolume = _volume;
    _vpc.addListener(_onVideoUpdate);
    _initBrightness();
    setState(() {});
  }

  @override
  void dispose() {
    _vpc.removeListener(_onVideoUpdate);
    _fadeCtrl.dispose();
    _hideTimer?.cancel();
    _seekFeedbackTimer?.cancel();
    _overlayHideTimer?.cancel();
    if (_isRotationLocked) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _initBrightness() async {
    try {
      final current = await ScreenBrightness().application;
      if (mounted) setState(() => _swipeBrightness = current);
    } catch (_) {}
  }

  // ── Controls visibility ───────────────────────────────────────────────────
  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _controlsVisible ? _fadeCtrl.forward() : _fadeCtrl.reverse();
    if (_controlsVisible) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
      _fadeCtrl.forward();
    }
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isSeeking && _vpc.value.isPlaying) {
        setState(() => _controlsVisible = false);
        _fadeCtrl.reverse();
      }
    });
  }

  // ── Playback ──────────────────────────────────────────────────────────────
  void _togglePlay() {
    _showControls();
    _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
  }

  void _seek(Duration position) {
    final clamped = position < Duration.zero
        ? Duration.zero
        : position > _vpc.value.duration
        ? _vpc.value.duration
        : position;
    _vpc.seekTo(clamped);
    _startHideTimer();
  }

  void _doubleTapSeek(bool forward) {
    _seek(_vpc.value.position + Duration(seconds: forward ? 10 : -10));
    setState(() {
      _seekLeft = !forward;
      _seekSeconds =
          (forward ? 1 : -1) * ((_seekSeconds.abs() + 10).clamp(10, 999));
      _showSeekFeedback = true;
    });
    _seekFeedbackTimer?.cancel();
    _seekFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
        setState(() {
          _showSeekFeedback = false;
          _seekSeconds = 0;
        });
    });
  }

  // ── Long-press fast forward ───────────────────────────────────────────────
  void _startFastForward() {
    if (_isFastForwarding) return;
    setState(() => _isFastForwarding = true);
    _vpc.setPlaybackSpeed(2.0);
    _showControls();
  }

  void _stopFastForward() {
    if (!_isFastForwarding) return;
    setState(() => _isFastForwarding = false);
    _vpc.setPlaybackSpeed(_playbackSpeed);
  }

  // ── Rotation lock ─────────────────────────────────────────────────────────
  void _toggleRotationLock() {
    setState(() => _isRotationLocked = !_isRotationLocked);
    if (_isRotationLocked) {
      final isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;
      SystemChrome.setPreferredOrientations(
        isLandscape
            ? [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      );
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    _showControls();
  }

  // ── Swipe gestures ────────────────────────────────────────────────────────
  void _onSwipeStart(DragStartDetails d, bool isLeft) {
    _swipeDragStartY = d.localPosition.dy;
    setState(() {
      _showBrightnessOverlay = isLeft;
      _showVolumeOverlay = !isLeft;
    });
    _overlayHideTimer?.cancel();
  }

  void _onSwipeUpdate(DragUpdateDetails d, bool isLeft) {
    final delta = (_swipeDragStartY - d.localPosition.dy) / 220;
    _swipeDragStartY = d.localPosition.dy;
    if (isLeft) {
      _swipeBrightness = (_swipeBrightness + delta).clamp(0.0, 1.0);
      ScreenBrightness().setApplicationScreenBrightness(_swipeBrightness);
    } else {
      _swipeVolume = (_swipeVolume + delta).clamp(0.0, 1.0);
      _vpc.setVolume(_swipeVolume);
      _volume = _swipeVolume;
    }
    setState(() {});
  }

  void _onSwipeEnd() {
    _overlayHideTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          _showBrightnessOverlay = false;
          _showVolumeOverlay = false;
        });
    });
  }

  // ── Speed / Volume ────────────────────────────────────────────────────────
  void _setSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _vpc.setPlaybackSpeed(speed);
    Navigator.of(context).pop();
  }

  void _setVolume(double v) {
    setState(() {
      _volume = v;
      _swipeVolume = v;
    });
    _vpc.setVolume(v);
  }

  void _showSpeedSheet() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SpeedSheet(
        speeds: _speeds,
        current: _playbackSpeed,
        onSelect: _setSpeed,
      ),
    ).then((_) => _startHideTimer());
  }

  // ── Computed helpers ──────────────────────────────────────────────────────
  Duration get _duration => _vpc.value.duration;
  Duration get _position => _vpc.value.position;
  Duration get _remaining => _duration - _position;
  bool get _isPlaying => _vpc.value.isPlaying;
  bool get _isBuffering => _vpc.value.isBuffering;

  double get _progressFraction => _duration.inMilliseconds == 0
      ? 0
      : _position.inMilliseconds / _duration.inMilliseconds;

  String _fmt(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
    }
    return '${_pad(d.inMinutes.remainder(60))}:${_pad(d.inSeconds.remainder(60))}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  IconData _volumeIcon(double v) => v == 0
      ? Icons.volume_off_rounded
      : v < 0.5
      ? Icons.volume_down_rounded
      : Icons.volume_up_rounded;

  IconData _brightnessIcon(double v) => v < 0.33
      ? Icons.brightness_low_rounded
      : v < 0.66
      ? Icons.brightness_medium_rounded
      : Icons.brightness_high_rounded;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Always-visible buffering spinner
          if (_isBuffering) _buildBufferingOverlay(),

          // Swipe zones (left = brightness / right = volume)
          _buildSwipeZones(),

          // Double-tap seek zones
          _buildDoubleTapZones(),

          // Seek ripple feedback
          if (_showSeekFeedback) _buildSeekFeedback(),

          // Brightness overlay
          if (_showBrightnessOverlay)
            _buildSwipeOverlay(
              icon: _brightnessIcon(_swipeBrightness),
              value: _swipeBrightness,
              color: Colors.amber,
              isLeft: true,
            ),

          // Volume overlay
          if (_showVolumeOverlay)
            _buildSwipeOverlay(
              icon: _volumeIcon(_swipeVolume),
              value: _swipeVolume,
              color: _kAccentGreen,
              isLeft: false,
            ),

          // Fast-forward banner
          if (_isFastForwarding) _buildFastForwardBanner(),

          // Fading controls
          FadeTransition(
            opacity: _fadeAnim,
            child: _controlsVisible
                ? _buildControlsOverlay()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Swipe zones ───────────────────────────────────────────────────────────
  // Swipe zones use a RawGestureDetector with custom threshold:
  // short/slow vertical drag → brightness/volume (consumed here)
  // long/fast vertical drag  → passes through to ListView scroll
  Widget _buildSwipeZones() {
    return Row(
      children: [
        Expanded(
          child: _SwipeZone(
            onSwipeStart: (d) => _onSwipeStart(d, true),
            onSwipeUpdate: (d) => _onSwipeUpdate(d, true),
            onSwipeEnd: () => _onSwipeEnd(),
          ),
        ),
        Expanded(
          child: _SwipeZone(
            onSwipeStart: (d) => _onSwipeStart(d, false),
            onSwipeUpdate: (d) => _onSwipeUpdate(d, false),
            onSwipeEnd: () => _onSwipeEnd(),
          ),
        ),
      ],
    );
  }

  // ── Double-tap zones ──────────────────────────────────────────────────────
  Widget _buildDoubleTapZones() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () => _doubleTapSeek(false),
            child: const SizedBox.expand(),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () => _doubleTapSeek(true),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  // ── Buffering overlay ─────────────────────────────────────────────────────
  Widget _buildBufferingOverlay() => Center(
    child: SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        color: _kAccentRed,
        strokeWidth: 2.5,
        backgroundColor: Colors.white12,
      ),
    ),
  );

  // ── Seek feedback ─────────────────────────────────────────────────────────
  Widget _buildSeekFeedback() {
    return Align(
      alignment: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: 100,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _seekLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: _seekLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              Utils.colorWithOpacity(_kAccentRed, 0.18),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _seekLeft
                  ? Icons.fast_rewind_rounded
                  : Icons.fast_forward_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              '${_seekSeconds.abs()}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Swipe overlay (brightness / volume pill) ──────────────────────────────
  Widget _buildSwipeOverlay({
    required IconData icon,
    required double value,
    required Color color,
    required bool isLeft,
  }) {
    return Positioned(
      left: isLeft ? 16 : null,
      right: isLeft ? null : 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                width: 4,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fast-forward banner ───────────────────────────────────────────────────
  Widget _buildFastForwardBanner() => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fast_forward_rounded, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text(
            '2× Speed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Controls overlay (Stack-based, no overflow) ───────────────────────────
  Widget _buildControlsOverlay() => Stack(
    fit: StackFit.expand,
    children: [
      Center(child: _buildCentreControls()),
      Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
      Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
    ],
  );

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _kBgGradient,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
      child: Row(
        children: [
          // Back (fullscreen only)
          if (_isFullScreen)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                _chewie.exitFullScreen();
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              },
            ),

          // Title
          if (widget.title != null)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: _isFullScreen ? 0 : 12),
                child: Text(
                  widget.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            const Spacer(),

          // Rotation lock
          _TopBarBtn(
            icon: _isRotationLocked
                ? Icons.screen_lock_rotation_rounded
                : Icons.screen_rotation_rounded,
            active: _isRotationLocked,
            onTap: _toggleRotationLock,
          ),
          const SizedBox(width: 4),

          // Speed pill
          GestureDetector(
            onTap: _showSpeedSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Volume icon
          IconButton(
            icon: Icon(_volumeIcon(_volume), color: Colors.white, size: 22),
            onPressed: () =>
                setState(() => _showVolumeSlider = !_showVolumeSlider),
          ),

          // Inline volume slider
          if (_showVolumeSlider)
            SizedBox(
              width: 80,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: _kAccentGreen,
                  inactiveTrackColor: const Color(0xFFD4FFDF),
                  thumbColor: Colors.white,
                  overlayColor: Utils.colorWithOpacity(_kAccentRed, 0.2),
                ),
                child: Slider(value: _volume, onChanged: _setVolume),
              ),
            ),
        ],
      ),
    );
  }

  // ── Centre controls ───────────────────────────────────────────────────────
  Widget _buildCentreControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous (optional)
        if (widget.hasPrevious) ...[
          _CircleIconButton(
            icon: Icons.skip_previous_rounded,
            size: 26,
            onTap: () {
              widget.onPrevious?.call();
              _showControls();
            },
          ),
          const SizedBox(width: 12),
        ],

        // Rewind 10s
        _CircleIconButton(
          icon: Icons.replay_10_rounded,
          size: 32,
          onTap: () => _doubleTapSeek(false),
        ),
        const SizedBox(width: 28),

        // Play / Pause with long-press fast-forward
        GestureDetector(
          onTap: _togglePlay,
          onLongPressStart: (_) => _startFastForward(),
          onLongPressEnd: (_) => _stopFastForward(),
          onLongPressCancel: _stopFastForward,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Utils.colorWithOpacity(
                Colors.white,
                _isFastForwarding ? 0.25 : 0.15,
              ),
              border: Border.all(
                color: _isFastForwarding ? _kAccentGreen : Colors.white38,
                width: 1.5,
              ),
            ),
            child: _isBuffering
                ? const SizedBox.shrink()
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
          ),
        ),
        const SizedBox(width: 28),

        // Forward 10s
        _CircleIconButton(
          icon: Icons.forward_10_rounded,
          size: 32,
          onTap: () => _doubleTapSeek(true),
        ),

        // Next (optional)
        if (widget.hasNext) ...[
          const SizedBox(width: 12),
          _CircleIconButton(
            icon: Icons.skip_next_rounded,
            size: 26,
            onTap: () {
              widget.onNext?.call();
              _showControls();
            },
          ),
        ],
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: _kBgGradient,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScrubber(),
          const SizedBox(height: 6),
          Row(
            children: [
              // Tap to toggle position / remaining
              GestureDetector(
                onTap: () =>
                    setState(() => _showRemainingTime = !_showRemainingTime),
                child: Row(
                  children: [
                    Text(
                      _fmt(_position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Text(
                      '  /  ',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Text(
                      _showRemainingTime
                          ? '-${_fmt(_remaining)}'
                          : _fmt(_duration),
                      style: TextStyle(
                        color: _showRemainingTime
                            ? _kAccentGreen
                            : Colors.white54,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Fullscreen toggle
              GestureDetector(
                onTap: () {
                  _isFullScreen
                      ? _chewie.exitFullScreen()
                      : _chewie.enterFullScreen();
                  setState(() => _isFullScreen = !_isFullScreen);
                },
                child: Icon(
                  _isFullScreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Scrubber ──────────────────────────────────────────────────────────────
  Widget _buildScrubber() {
    final buffered = _vpc.value.buffered;
    final bufferedFraction = buffered.isEmpty || _duration.inMilliseconds == 0
        ? 0.0
        : (buffered.last.end.inMilliseconds / _duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) {
            _isSeeking = true;
            _hideTimer?.cancel();
          },
          onHorizontalDragUpdate: (d) {
            setState(
              () =>
                  _seekPosition = (d.localPosition.dx / trackW).clamp(0.0, 1.0),
            );
          },
          onHorizontalDragEnd: (_) {
            _isSeeking = false;
            _seek(
              Duration(
                milliseconds: (_seekPosition * _duration.inMilliseconds)
                    .round(),
              ),
            );
            _startHideTimer();
          },
          child: SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track
                Container(
                  height: _isSeeking ? 5 : 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Buffered
                FractionallySizedBox(
                  widthFactor: bufferedFraction,
                  child: Container(
                    height: _isSeeking ? 5 : 3,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Played
                FractionallySizedBox(
                  widthFactor: _isSeeking ? _seekPosition : _progressFraction,
                  child: Container(
                    height: _isSeeking ? 5 : 3,
                    decoration: BoxDecoration(
                      color: _kAccentGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left:
                      ((_isSeeking ? _seekPosition : _progressFraction) *
                              trackW)
                          .clamp(0, trackW - 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: _isSeeking ? 16 : 12,
                    height: _isSeeking ? 16 : 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Utils.colorWithOpacity(_kAccentRed, 0.6),
                          blurRadius: _isSeeking ? 8 : 0,
                          spreadRadius: _isSeeking ? 2 : 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar icon button with active state
// ─────────────────────────────────────────────────────────────────────────────
class _TopBarBtn extends StatelessWidget {
  const _TopBarBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? const Color(0xFF53BC77).withOpacity(0.25)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF53BC77) : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Speed bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SpeedSheet extends StatelessWidget {
  const _SpeedSheet({
    required this.speeds,
    required this.current,
    required this.onSelect,
  });

  final List<double> speeds;
  final double current;
  final void Function(double) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Playback Speed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...speeds.map(
          (s) => InkWell(
            onTap: () => onSelect(s),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '$s ×',
                    style: TextStyle(
                      color: s == current
                          ? const Color(0xFFE53935)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: s == current
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  if (s == current) ...[
                    const Spacer(),
                    const Icon(
                      Icons.check_rounded,
                      color: Color(0xFFE53935),
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small circle icon button
// ─────────────────────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Utils.colorWithOpacity(Colors.white, 0.1),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SwipeZone — vertical drag for brightness/volume that doesn't block scrolling.
// Only consumes the gesture if the drag is slow/deliberate (velocity < 800).
// Fast flicks pass through to the parent ListView as scroll events.
// ─────────────────────────────────────────────────────────────────────────────
class _SwipeZone extends StatefulWidget {
  const _SwipeZone({
    required this.onSwipeStart,
    required this.onSwipeUpdate,
    required this.onSwipeEnd,
  });

  final void Function(DragStartDetails) onSwipeStart;
  final void Function(DragUpdateDetails) onSwipeUpdate;
  final VoidCallback onSwipeEnd;

  @override
  State<_SwipeZone> createState() => _SwipeZoneState();
}

class _SwipeZoneState extends State<_SwipeZone> {
  bool _isTracking = false;
  Offset _startPosition = Offset.zero;

  static const double _minDragDistance = 8.0; // px before we decide intent

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _isTracking = false;
        _startPosition = e.position;
      },
      onPointerMove: (e) {
        final delta = e.position - _startPosition;
        if (!_isTracking && delta.distance > _minDragDistance) {
          // Decide: more vertical than horizontal = swipe intent
          if (delta.dy.abs() > delta.dx.abs()) {
            _isTracking = true;
            widget.onSwipeStart(
              DragStartDetails(
                globalPosition: _startPosition,
                localPosition: _startPosition,
              ),
            );
          }
        }
        if (_isTracking) {
          widget.onSwipeUpdate(
            DragUpdateDetails(
              globalPosition: e.position,
              localPosition: e.localPosition,
              delta: e.delta,
              primaryDelta: null,
            ),
          );
        }
      },
      onPointerUp: (_) {
        if (_isTracking) {
          _isTracking = false;
          widget.onSwipeEnd();
        }
      },
      onPointerCancel: (_) {
        _isTracking = false;
      },
      child: const SizedBox.expand(),
    );
  }
}
