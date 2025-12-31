import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Full-screen guided meditation / breathing timer.
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  static const Map<String, Duration> _presets = {
    '5 min': Duration(minutes: 5),
    '10 min': Duration(minutes: 10),
    '15 min': Duration(minutes: 15),
    '30 min': Duration(minutes: 30),
    '45 min': Duration(minutes: 45),
    '1 hour': Duration(hours: 1),
    'Custom': Duration.zero,
  };

  String _selectedPreset = '10 min';
  int _customMinutes = 20;

  Duration _elapsed = Duration.zero;
  Duration _target = const Duration(minutes: 10);
  Timer? _timer;
  bool _isRunning = false;

  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _target = _presets[_selectedPreset]!;
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  Duration get _effectiveTarget {
    if (_selectedPreset == 'Custom') {
      return Duration(minutes: _customMinutes.clamp(1, 120));
    }
    return _presets[_selectedPreset] ?? const Duration(minutes: 10);
  }

  double get _progress {
    if (_target.inSeconds == 0) return 0;
    return (_elapsed.inSeconds / _target.inSeconds).clamp(0.0, 1.0);
  }

  void _startSession() {
    final target = _effectiveTarget;
    if (target.inSeconds <= 0) return;

    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _target = target;
      _isRunning = true;
    });

    _breathController
      ..reset()
      ..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
        if (_elapsed >= _target) {
          _elapsed = _target;
          _isRunning = false;
          timer.cancel();
          _breathController.stop();
        }
      });
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _breathController.stop();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final target = _effectiveTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPresetPicker(target),
                const SizedBox(height: 24),
                _buildBreathingAnimation(),
                const SizedBox(height: 24),
                _buildTimingRow(target),
                const SizedBox(height: 24),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetPicker(Duration target) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22D3EE).withOpacity(0.45),
                      blurRadius: 24,
                      spreadRadius: -10,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: const Icon(Icons.self_improvement, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your calm window',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pick a quick reset or deeper session. We\'ll guide your breathing.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPreset,
            decoration: const InputDecoration(
              labelText: 'Session length',
            ),
            dropdownColor: const Color(0xFF020617),
            items: _presets.keys
                .map(
                  (label) => DropdownMenuItem<String>(
                    value: label,
                    child: Text(label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedPreset = value;
                _target = _effectiveTarget;
              });
            },
          ),
          if (_selectedPreset == 'Custom') ...[
            const SizedBox(height: 16),
            Text(
              'Custom length: $_customMinutes min',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _customMinutes.toDouble(),
              min: 1,
              max: 120,
              divisions: 119,
              label: '$_customMinutes min',
              onChanged: (value) {
                setState(() {
                  _customMinutes = value.round();
                  _target = _effectiveTarget;
                });
              },
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Target: ${_formatDuration(target)}',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    final animation = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final scale = 0.9 + 0.2 * animation.value;
          final rotation = animation.value * 2 * math.pi;
          return Transform.rotate(
            angle: rotation / 32,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [
                Color(0xFF22D3EE),
                Color(0xFF6366F1),
                Color(0xFFA855F7),
                Color(0xFF22D3EE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.55),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF020617),
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRunning ? 'Breathe' : 'Ready to unwind?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_elapsed),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimingRow(Duration target) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elapsed',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(_elapsed),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Remaining',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(target - _elapsed),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: _progress,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(0.08),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3EE)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isRunning ? _stopSession : _startSession,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            icon: Icon(_isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(_isRunning ? 'Stop session' : 'Start session'),
          ),
        ),
      ],
    );
  }
}


