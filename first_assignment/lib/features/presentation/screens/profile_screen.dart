import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primary = Color(0xFFE8824A);
  static const Color _bg = Color(0xFFFFF5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionTitle('Account'),
            _buildSettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your name and photo',
              onTap: () => _showErrorPage(context),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text('Sign Out',
                    style: GoogleFonts.poppins(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8824A), Color(0xFFFF9A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: _primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 46),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Chef Alex',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2D2D))),
          Text('Phone: +251 912517713',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF888888))),
          Text('Email: alex@example.com',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF888888))),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: _primary, size: 14),
                const SizedBox(width: 4),
                Text('Home Kitchen',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF888888),
              letterSpacing: 0.8)),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D))),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: const Color(0xFF888888))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  backgroundColor: const Color(0xFFFFF5EE),
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8E8E8))),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Color(0xFFE8824A), size: 18),
                      ),
                    ),
                    title: Text('Oops!',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF2D2D2D),
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    centerTitle: true,
                  ),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECCC),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Center(
                                  child: Icon(Icons.breakfast_dining_rounded,
                                      size: 70, color: Color(0xFF4A4458)),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFE54D4D),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.priority_high_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text('Something burned!',
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2D2D2D))),
                          const SizedBox(height: 12),
                          Text(' Please check\nyour connection and try again.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF888888),
                                  height: 1.6)),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFBEAEA),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.warning_amber_rounded,
                                      color: Color(0xFFE54D4D), size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Network Error',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: const Color(0xFF2D2D2D))),
                                      Text('Code 503 - service unavailable',
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: const Color(0xFF888888))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text('Try Again',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8824A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.popUntil(
                                context, (route) => route.isFirst),
                            child: Text('Go back home',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF888888))),
                          ),
                        ],
                      ),
                    ),
                  ),
                )));
  }
}
