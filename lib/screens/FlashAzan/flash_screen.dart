import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_multiplayer/config/app_config.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';

class FlashNumbersView extends StatefulWidget {
  const FlashNumbersView({super.key});

  @override
  State<FlashNumbersView> createState() => _FlashNumbersViewState();
}

class _FlashNumbersViewState extends State<FlashNumbersView> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = AppConfig.flashDurationSec; // e.g. 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        context.read<GameService>().startAnswering();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameService>().state;
    // Calculate which number to show based on elapsed seconds
    final elapsedSec = AppConfig.flashDurationSec - _secondsLeft;
    final totalNumbers = state.numbers.isEmpty ? 1 : state.numbers.length;
    final secPerNumber = AppConfig.flashDurationSec / totalNumbers;
    final index = (elapsedSec / secPerNumber).floor().clamp(
      0,
      totalNumbers - 1,
    );

    // Format timer display string (e.g. 00:10)
    final formattedTimer = '00:${_secondsLeft.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Top Timer Container (170x84 proportional design)
            Container(
              width: 110,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161111),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                formattedTimer,
                style: GoogleFonts.intelOneMono(
                  color: const Color(0xFF81F1FB),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Player Cards Row
            Row(
              children: [
                Expanded(
                  child: _PlayerCard(label: state.playerId ?? 'PLAYER 1'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PlayerCard(label: state.opponentId ?? 'PLAYER 2'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Central Main Container (623x1210 proportional design)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF161111),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    state.numbers.isEmpty ? '...' : '${state.numbers[index]}',
                    style: GoogleFonts.intelOneMono(
                      color: const Color(0xFF6EDDFF),
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String label;

  const _PlayerCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF161111),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.intelOneMono(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
