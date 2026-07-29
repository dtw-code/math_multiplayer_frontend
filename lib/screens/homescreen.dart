import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Removed the AppBar completely
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          // 2. Used a Stack to overlay the sign-out button on top of your content
          child: Stack(
            children: [
              // Main content Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Top "BUNDLED IQ" Banner
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'BUNDLED IQ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Middle Row of Interactive Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconBtn(
                        icon: Icons.bug_report_outlined,
                        color: const Color(0xFF328B8B),
                        onTap: () {
                          print("Axe icon tapped");
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildIconBtn(
                        icon: Icons.face,
                        color: const Color(0xFF14541B),
                        onTap: () {
                          print("Mask icon tapped");
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildIconBtn(
                        icon: Icons.colorize,
                        color: const Color(0xFF6B1B1A),
                        onTap: () {
                          print("Sword icon tapped");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 120),

                  // Big "Flicker Fomo" Button
                  Material(
                    color: const Color(0xFF1E2827),
                    borderRadius: BorderRadius.circular(32),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () {
                        print("Flicker Fomo tapped");
                      },
                      child: Container(
                        width: 260,
                        height: 220,
                        alignment: Alignment.center,
                        child: const Text(
                          'Flicker\nFomo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // "How to play" Link/Button
                  InkWell(
                    onTap: () {
                      print("How to play tapped");
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'How to play',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Positioned the Sign Out button at the top-right
              Positioned(
                top: 8,
                right: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors
                        .white, // Made white to stand out on the background
                    size: 28,
                  ),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await AuthService().signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create the square rounded icon buttons with InkWell
  Widget _buildIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(icon, color: Colors.black87, size: 32),
        ),
      ),
    );
  }
}
