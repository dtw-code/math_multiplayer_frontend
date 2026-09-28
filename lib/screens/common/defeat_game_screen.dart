import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';

class DefeatView extends StatelessWidget {
  final int? myScore;
  final int? opponentScore;
  final String? opponentName;
  final VoidCallback? onHome;

  const DefeatView({
    super.key,
    this.myScore,
    this.opponentScore,
    this.opponentName,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    // Read state from GameService only if constructor props aren't provided
    final hasProps = myScore != null && opponentScore != null;
    final flashState = hasProps ? null : context.watch<GameService>().state;
    final finalMyScore = myScore ?? flashState?.myScore ?? 0;
    final finalOpponentScore = opponentScore ?? flashState?.opponentScore ?? 0;
    final finalOpponentName = opponentName ?? flashState?.opponentId ?? 'BOT';

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(
            0xFF0E1A1E,
          ), // Dark slate container matching mockup
          borderRadius: BorderRadius.circular(48),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DEFEAT Title
            Text(
              'DEFEAT',
              style: GoogleFonts.shareTechMono(
                color: const Color(0xFFCC3F42), // Crimson / Coral Red
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 36),

            // Score Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreCard(
                  title: 'YOU',
                  score: '$finalMyScore',
                  scoreColor: const Color(0xFFCC3F42),
                ),
                _buildScoreCard(
                  title: finalOpponentName.toUpperCase(),
                  score: '$finalOpponentScore',
                  scoreColor: const Color(0xFFCC3F42),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Action Button
            InkWell(
              onTap:
                  onHome ??
                  () => Navigator.popUntil(context, (route) => route.isFirst),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF25363C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCC3F42).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'BACK TO HOME',
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for score cards
  Widget _buildScoreCard({
    required String title,
    required String score,
    required Color scoreColor,
  }) {
    return Container(
      width: 108,
      height: 124,
      decoration: BoxDecoration(
        color: const Color(0xFF25363C), // Inner slate card
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.shareTechMono(
              color: const Color(0xFF101B20), // Dark text label matching mockup
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score,
            style: GoogleFonts.shareTechMono(
              color: scoreColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
