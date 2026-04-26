import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'host_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, size: 32, color: Colors.black),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 32, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Hero Banner
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'assets/images/hero.png',
                      fit: BoxFit.cover, // FIXED: User requested fix to entire widget
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.3,
                  children: [
                    _buildActionCard(
                      context,
                      'Create Quiz',
                      const Color(0xFF8CFF91),
                      'assets/images/create_quiz.png',
                      '/create-quiz',
                      alignment: Alignment.bottomRight,
                    ),
                    _buildActionCard(
                      context,
                      'Join Quiz',
                      const Color(0xFFFED19A),
                      'assets/images/join_quiz.png',
                      '/join-quiz',
                      alignment: Alignment.topRight,
                    ),
                    _buildActionCard(
                      context,
                      'Explore',
                      const Color(0xFFEFFF3D),
                      null, 
                      '/explore',
                      fallbackIcon: Icons.public,
                      alignment: Alignment.bottomRight,
                    ),
                    _buildActionCard(
                      context,
                      'Create Study Groups',
                      const Color(0xFFBB9CFF),
                      null, 
                      '/create-group',
                      fallbackIcon: Icons.school,
                      smallText: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Recent Section
                Text(
                  'Recent',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showQuizBottomSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
                      borderRadius: BorderRadius.circular(4), // the image shows relatively sharp corners for the outer box
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The Logo Box
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Q',
                                    style: GoogleFonts.outfit(
                                      fontSize: 40,
                                      height: 1.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 10,
                                width: double.infinity,
                                color: const Color(0xFF6EFA70), // bright green bottom strip
                                border: const Border(top: BorderSide(color: Colors.black, width: 1.5)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quiz 1',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Study Groups Section
                Text(
                  'Study Groups',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: Text(
                      'You haven\'t joined any groups yet',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, 
    String title, 
    Color color, 
    String? imagePath,
    String route, {
    IconData? fallbackIcon,
    bool smallText = false,
    Alignment alignment = Alignment.center,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (imagePath != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.6,
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: smallText ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              if (fallbackIcon != null && imagePath == null)
                Positioned.fill(
                  child: Align(
                    alignment: alignment,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(fallbackIcon, size: 60, color: Colors.black12),
                    ),
                  ),
                ),

              Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        boxShadow: [
                           BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1))
                        ]
                      ),
                      child: Icon(
                        imagePath != null ? Icons.arrow_forward : fallbackIcon, 
                        size: 24, 
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F9FE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, bottom: 32, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'JD',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'John Doe',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'john@gmail.com',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _drawerItem(context, Icons.dashboard_rounded, 'Dashboard', '/dashboard', const Color(0xFF6A11CB)),
                _drawerItem(context, Icons.person_rounded, 'Profile', '/profile', const Color(0xFF2575FC)),
                _drawerItem(context, Icons.settings_rounded, 'Settings', '/settings', const Color(0xFF11998E)),
                _drawerItem(context, Icons.help_rounded, 'Help Center', '/help', const Color(0xFFF37335)),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94057).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE94057).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: Color(0xFFE94057)),
                    const SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE94057),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: activeColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  void _showQuizBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        bool showSlider = false;
        final List<int> limitOptions = [20, 30, 40, 50, 100, 200, 300, 500];
        int limitIndex = 0; // default represents 20
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
          // Upgraded: premium light background and elegantly rounded top corners
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.only(top: 24, bottom: 32, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Position unchanged, upgraded icon styles
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 24, color: Colors.black87),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Logo and Title Row: Position unchanged, upgraded border/shadow
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Q',
                                style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  height: 1.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6A11CB),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF38EF7D), Color(0xFF11998E)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Quiz 1',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Action Buttons Row (Horizontal Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: _buildActionBtn(
                        'Host Live', 
                        () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HostPage(
                                quizId: 'quiz_1_mock',
                                limit: limitOptions[limitIndex],
                              ),
                            ),
                          );
                        }, 
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: _buildActionBtn('Assign', () {}),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: _buildActionBtn('Connect to\nScreen', () {}),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130,
                      child: _buildActionBtn('Add to\nStudy Groups', () {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Participants Limit Row: Upgraded badge and interactive conditional slider
              GestureDetector(
                onTap: () {
                  setState(() {
                    showSlider = !showSlider;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      'Participants Limit',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2575FC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2575FC).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 16, color: Color(0xFF2575FC)),
                          const SizedBox(width: 6),
                          Text(
                            limitOptions[limitIndex].toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2575FC),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            showSlider ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: const Color(0xFF2575FC),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showSlider) ...[
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF2575FC),
                    inactiveTrackColor: const Color(0xFF2575FC).withOpacity(0.2),
                    thumbColor: const Color(0xFF2575FC),
                    overlayColor: const Color(0xFF2575FC).withOpacity(0.1),
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: limitIndex.toDouble(),
                    min: 0,
                    max: (limitOptions.length - 1).toDouble(),
                    divisions: limitOptions.length - 1,
                    onChanged: (val) {
                      setState(() {
                        limitIndex = val.toInt();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: limitOptions.map((val) => Text(
                      val.toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    )).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              
              // Questions Section
              Text(
                'Questions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Horizontal Questions list: Position unchanged, upgraded card style
              SizedBox(
                height: 150, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Question ${index + 1}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6A11CB),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
        });
      },
    );
  }

  Widget _buildActionBtn(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64, // Slightly taller for premium feel
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isPrimary ? null : Colors.white,
          gradient: isPrimary ? const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          border: isPrimary ? null : Border.all(color: Colors.black.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(20), // Premium rounded corners
          boxShadow: isPrimary ? [
            BoxShadow(
              color: const Color(0xFF2575FC).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
              color: isPrimary ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
