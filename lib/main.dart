import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
// Note: import 'dart:html' as html; toh already hoga aapki file mein.
import 'dart:html' as html;

import 'firebase_options.dart';
import 'dart:ui'; // 🌟 NEW: For Glassmorphism effects
import 'views/customer_menu_view.dart';
import 'views/waiter_menu_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BiteAndBurpWebApp());
}

class BiteAndBurpWebApp extends StatelessWidget {
  const BiteAndBurpWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LandingPageView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ),
        GoRoute(
          path: '/privacy-policy',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PrivacyPolicyView()),
        ),
        GoRoute(
          path: '/terms-and-conditions',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TermsAndConditionsView()),
        ),
        GoRoute(
          path: '/help-support',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HelpSupportView()),
        ),
        GoRoute(
          path: '/menu/:hotelId/:tableId',
          builder: (context, state) {
            final hotelId = state.pathParameters['hotelId'] ?? '';
            final tableId = state.pathParameters['tableId'] ?? 'Unknown';
            // 🌟 FIX: Safely extract 'key' from URL and pass it forward
            final key = state.uri.queryParameters['key'];
            return CustomerMenuView(
              hotelId: hotelId,
              tableId: tableId,
              urlKey: key,
            );
          },
        ),
        GoRoute(
          path: '/waiter/:hotelId',
          builder: (context, state) {
            final hotelId = state.pathParameters['hotelId'] ?? '';
            return WaiterMenuView(hotelId: hotelId);
          },
        ),
      ],
    );

    // 🌟 FIX: File ke ekdum top par imports ke sath yeh line zaroor dalna:
    // import 'package:google_fonts/google_fonts.dart';

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bite & Burp | Advanced POS Ecosystem',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        primaryColor: Colors.deepPurple,
        // 🌟 FIX: Poori app ka global default font ab Poppins ho gaya hai
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}

// =========================================================
// 🌟 1. SPLASH SCREEN
// =========================================================
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // 🌟 FAST OPTIMIZATION: Reduced duration to 1200ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _bootstrapAppSession();
  }

  Future<void> _bootstrapAppSession() async {
    await _controller.forward();
    if (!mounted) return;

    // Simulate fast minimal load since there's no auth in landing yet
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFDFBFF), Color(0xFFF3E8FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _SplashBackgroundPainter()),
              ),
              _buildFloatingIcons(isMobile),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 40 : 60),
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            height: isMobile ? 180 : 220,
                            width: isMobile ? 180 : 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7E3FF2,
                                  ).withOpacity(0.2),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/Logo.png',
                                height: isMobile ? 110 : 140,
                                width: isMobile ? 110 : 140,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.storefront_rounded,
                                      size: 70,
                                      color: Color(0xFF4A148C),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 40 : 50),
                      FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "NAMASTE",
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: isMobile ? 26 : 36,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF311B92),
                                      letterSpacing: isMobile ? 12.0 : 18.0,
                                      shadows: [
                                        Shadow(
                                          color: const Color(
                                            0xFF311B92,
                                          ).withOpacity(0.5),
                                          offset: const Offset(2, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: isMobile ? 40 : 60,
                                    height: 1,
                                    color: const Color(
                                      0xFF512DA8,
                                    ).withOpacity(0.3),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Icon(
                                      Icons.spa_rounded,
                                      color: Color(0xFF512DA8),
                                      size: 18,
                                    ),
                                  ),
                                  Container(
                                    width: isMobile ? 40 : 60,
                                    height: 1,
                                    color: const Color(
                                      0xFF512DA8,
                                    ).withOpacity(0.3),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Welcome to ",
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 15,
                                        color: const Color(
                                          0xFF4527A0,
                                        ).withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Bite&Burp POS",
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 15,
                                        color: const Color(0xFF4527A0),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingIcons(bool isMobile) {
    final Color iconColor = const Color(0xFF7E3FF2).withOpacity(0.10);
    return Stack(
      children: [
        Positioned(
          top: isMobile ? 80 : 120,
          left: isMobile ? 15 : 150,
          child: Icon(
            Icons.room_service_outlined,
            size: isMobile ? 35 : 40,
            color: iconColor,
          ),
        ),
        Positioned(
          top: isMobile ? 130 : 150,
          right: isMobile ? 15 : 200,
          child: Icon(
            Icons.receipt_outlined,
            size: isMobile ? 40 : 45,
            color: iconColor,
          ),
        ),
        Positioned(
          top: isMobile ? 450 : 300,
          left: isMobile ? 10 : 100,
          child: Icon(
            Icons.soup_kitchen_outlined,
            size: isMobile ? 45 : 50,
            color: iconColor,
          ),
        ),
        Positioned(
          top: isMobile ? 400 : 250,
          right: isMobile ? 10 : 120,
          child: Icon(
            Icons.point_of_sale_rounded,
            size: isMobile ? 30 : 35,
            color: iconColor,
          ),
        ),
        Positioned(
          bottom: isMobile ? 120 : 350,
          left: isMobile ? 20 : 220,
          child: Icon(
            Icons.shopping_bag_outlined,
            size: isMobile ? 40 : 45,
            color: iconColor,
          ),
        ),
        Positioned(
          bottom: isMobile ? 160 : 400,
          right: isMobile ? 20 : 180,
          child: Icon(
            Icons.bar_chart_rounded,
            size: isMobile ? 35 : 40,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height * 0.42;

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF7E3FF2).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(cx, cy), size.width * 0.25, ringPaint);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.35, ringPaint);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.48, ringPaint);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.65, ringPaint);

    final Paint wavePaint1 = Paint()
      ..color = const Color(0xFFD8B4FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final Paint wavePaint2 = Paint()
      ..color = const Color(0xFFB47CFF).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final Paint wavePaint3 = Paint()
      ..color = const Color(0xFF9C4DFF).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Path path1 = Path();
    path1.moveTo(0, size.height * 0.85);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.78,
      size.width * 0.5,
      size.height * 0.85,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.92,
      size.width,
      size.height * 0.80,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, wavePaint1);

    final Path path2 = Path();
    path2.moveTo(0, size.height * 0.90);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.98,
      size.width * 0.6,
      size.height * 0.90,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.85,
      size.width,
      size.height * 0.88,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wavePaint2);

    final Path path3 = Path();
    path3.moveTo(0, size.height * 0.95);
    path3.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.88,
      size.width * 0.7,
      size.height * 0.96,
    );
    path3.quadraticBezierTo(
      size.width * 0.85,
      size.height * 1.0,
      size.width,
      size.height * 0.94,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, wavePaint3);

    final Paint dotPaint = Paint()
      ..color = const Color(0xFFB45CFF).withOpacity(0.6);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      2.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      1.5,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.55),
      2.0,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.6),
      2.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================
// 🌟 2. LANDING PAGE VIEW
// =========================================================
class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 🌟 FIX: The Missing build() method is back!
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 1024;
    bool isTablet = width > 600 && width <= 1024;
    bool isMobile = width <= 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: Drawer(
        backgroundColor: const Color(0xFFFDFBFF), // Premium off-white
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/Logo.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.restaurant,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "BITE & BURP",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Mobile Nav items removed
            const Divider(color: Colors.black12, height: 20),
            ListTile(
              leading: const Icon(
                Icons.star_border_rounded,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "App Features",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go('/features'); // GoRouter me add karna padega
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: Colors.deepPurple,
              ),
              title: const Text(
                "Privacy Policy",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context); // Close Drawer
                context.go('/privacy-policy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
              title: const Text(
                "Help & Support",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context); // Close Drawer
                context.go('/help-support');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBar: _buildHeader(isDesktop, isTablet),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _blurOrb(400, Colors.deepPurpleAccent.withAlpha(38))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .move(
                  begin: const Offset(-20, -20),
                  end: const Offset(30, 30),
                  duration: 6.seconds,
                ),
          ),
          Positioned(
            top: 400,
            right: -100,
            child: _blurOrb(500, Colors.orangeAccent.withAlpha(30))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .move(
                  begin: const Offset(20, 0),
                  end: const Offset(-30, -20),
                  duration: 5.seconds,
                ),
          ),

          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: isMobile ? 100 : 140),
                _buildHeroSection(isDesktop, isTablet, isMobile),
                _buildTrustStrip(isDesktop),
                _buildFeatureGrid(isDesktop, isTablet, isMobile),
                _buildPricingSection(isDesktop),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.deepPurple),
            SizedBox(width: 10),
            Text(
              "Coming Soon!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: const Text(
          "The Bite & Burp App will be available on the PlayStore very shortly. Stay tuned for the ultimate POS experience!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Got it!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerNav(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      onTap: () {},
    );
  }

  PreferredSizeWidget _buildHeader(bool isDesktop, bool isTablet) {
    return AppBar(
      backgroundColor: Colors.white.withAlpha(230),
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: Colors.deepPurple.withAlpha(50),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 24,
              height: 24,
              errorBuilder: (c, e, s) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "BITE",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                TextSpan(
                  text: " & ",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: "BURP",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (isDesktop || isTablet) ...[
          // Removed nav items to keep a clean single landing page
        ] else ...[
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.deepPurple,
                size: 32,
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _headerNav(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet, bool isMobile) {
    bool isWide = isDesktop || isTablet;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 20),
      child: Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: isWide
                ? MediaQuery.of(context).size.width * 0.45
                : double.infinity,
            child: Column(
              crossAxisAlignment: isWide
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple.withAlpha(102)),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.deepPurple.withAlpha(20),
                  ),
                  child: const Text(
                    "✨ THE NEXT-GEN RESTAURANT OS",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 25),
                Text(
                  "Run Your Restaurant Like A Masterpiece.",
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 60 : (isTablet ? 45 : 38),
                    color: Colors.black,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                const SizedBox(height: 25),
                Text(
                  "Stop managing multiple tools. Handle Billing, Inventory, Waiter KOTs, and Customer QR Orders from a single, ultra-fast cinematic dashboard.",
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMobile ? 15 : 17,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                      onPressed: () => html.window.open(
                        'https://play.google.com/store/apps/details?id=com.biteandburp',
                        '_blank',
                      ),
                      icon: const Icon(
                        Icons.shop,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        "Download from Playstore",
                        style: TextStyle(
                          fontSize: isWide ? 18 : 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 20,
                          vertical: isWide ? 22 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 12,
                        shadowColor: Colors.deepPurple.withAlpha(150),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1, end: 1.02, duration: 1.seconds)
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.2),
              ],
            ),
          ),
          if (!isWide) const SizedBox(height: 10),
          SizedBox(
            width: isWide
                ? MediaQuery.of(context).size.width * 0.40
                : double.infinity,
            height: isWide ? 600 : 210,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _build3DHeroMockup(isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DHeroMockup(bool isDesktop) {
    return SizedBox(
      width: 650,
      height: 450,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(-0.1)
                  ..rotateY(-0.15 + (_scrollOffset * 0.0005)),
                alignment: FractionalOffset.center,
                child: Container(
                  width: 550,
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white.withAlpha(230),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withAlpha(38),
                        blurRadius: 40,
                        spreadRadius: -5,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withAlpha(13),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (index) => Icon(
                              index == 0
                                  ? Icons.dashboard
                                  : (index == 1
                                        ? Icons.receipt_long
                                        : Icons.inventory_2),
                              color: index == 0
                                  ? Colors.orangeAccent
                                  : Colors.black26,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Live Analytics",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withAlpha(51),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Online",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _mockStatCard(
                                    "Today's Sales",
                                    "₹ 84,280",
                                    Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _mockStatCard(
                                    "Active Tables",
                                    "14 / 20",
                                    Colors.orangeAccent,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withAlpha(8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.deepPurple.withAlpha(13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -10, end: 10, duration: 4.seconds),
          Positioned(
            top: 40,
            right: 10,
            child: _floatingTag(
              Icons.notifications_active,
              "New QR Order",
              Colors.orangeAccent,
              3.seconds,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 10,
            child: _floatingTag(
              Icons.check_circle,
              "KOT Printed",
              Colors.green,
              4.seconds,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mockStatCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingTag(IconData icon, String text, Color color, Duration dur) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -8, end: 8, duration: dur);
  }

  Widget _buildFeatureGrid(bool isDesktop, bool isTablet, bool isMobile) {
    final features = [
      {
        "t": "Contactless QR Menu",
        "d":
            "Customers scan, order, and pay directly. Speeds up table turnover by 30%.",
        "i": Icons.qr_code_scanner,
        "c": Colors.orangeAccent.shade700,
      },
      {
        "t": "Captain Waiter Pad",
        "d":
            "Equip staff with mobile devices. Punch KOTs right from the table directly to the kitchen.",
        "i": Icons.touch_app,
        "c": Colors.blueAccent,
      },
      {
        "t": "Smart Inventory",
        "d":
            "Connect recipes to items. Auto-deduct raw materials like Maida/Oil the moment a dish sells.",
        "i": Icons.inventory_2_outlined,
        "c": Colors.green.shade600,
      },
      {
        "t": "Live Cashbook",
        "d":
            "Manage vendor payouts, staff salaries, cash, and UPI settlements in one integrated ledger.",
        "i": Icons.account_balance_wallet,
        "c": Colors.deepPurple,
      },
      {
        "t": "Offline Resilience",
        "d":
            "Internet down? No problem. Continue billing and sync everything when you're back online.",
        "i": Icons.wifi_off,
        "c": Colors.cyan.shade700,
      },
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "CORE ECOSYSTEM",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Everything you need.\nZero chaos.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 45,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: features.map((f) {
              return StatefulBuilder(
                builder: (context, setState) {
                  bool isHovered = false;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: isMobile
                          ? double.infinity
                          : (isTablet ? 300 : 340),
                      padding: EdgeInsets.all(isMobile ? 20 : 30),
                      transform: Matrix4.identity()
                        ..scale(isHovered ? 1.03 : 1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        border: Border.all(
                          color: isHovered
                              ? (f['c'] as Color).withAlpha(127)
                              : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isHovered
                                ? (f['c'] as Color).withAlpha(38)
                                : Colors.black.withAlpha(8),
                            blurRadius: isHovered ? 30 : 15,
                            spreadRadius: isHovered ? 5 : 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (f['c'] as Color).withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              f['i'] as IconData,
                              color: f['c'] as Color,
                              size: 35,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            f['t'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            f['d'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 60)],
      ),
    );
  }

  Widget _buildTrustStrip(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: Colors.deepPurple.withAlpha(13),
      child: Opacity(
        opacity: 0.6,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              10,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "BITE & BURP POS",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: 100,
      ),
      child: Column(
        children: [
          const Text(
            "PRICING",
            style: TextStyle(
              letterSpacing: 3,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Scale your restaurant",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: isDesktop ? 40 : 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 15), // Reduced Gap
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _pricingCard(
                "PREMIUM SOFTWARE",
                "₹3,999",
                "",
                [
                  "Advanced Multi-Terminal POS Billing Engine",
                  "Real-time Analytics Dashboard & Sales Tracking",
                  "Automated Inventory & Dynamic Stock Alerts",
                  "Multi-Node Client Connection Limit: 4",
                ],
                false,
                isDesktop,
              ),
              _pricingCard(
                "THERMAL PRINTER + SOFTWARE",
                "₹5,499",
                "",
                [
                  "Everything in Premium Software Pack",
                  "High-Speed 58mm Premium Thermal Printer",
                  "Plug & Play Bluetooth / WiFi Printing",
                  "1-Year Replacement Warranty",
                ],
                true,
                isDesktop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingCard(
    String title,
    String price,
    String suffix,
    List<String> features,
    bool isHighlighted,
    bool isDesktop,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            constraints: BoxConstraints(
              minHeight: isDesktop ? 580 : 0,
            ), // Equal Heights on Desktop
            width: isDesktop ? 350 : double.infinity,
            padding: EdgeInsets.all(isDesktop ? 40 : 20),
            transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isHighlighted ? Colors.deepPurple : Colors.black12,
                width: isHighlighted ? 2 : 1,
              ),
              color: isHighlighted ? Colors.deepPurple : Colors.white,
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withAlpha(76),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHighlighted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "MOST POPULAR",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    color: isHighlighted ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: isHighlighted ? Colors.white : Colors.black,
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      suffix,
                      style: TextStyle(
                        color: isHighlighted ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Column(
                  children: features
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: isHighlighted
                                    ? Colors.orangeAccent
                                    : Colors.deepPurple,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isHighlighted
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () => html.window.open(
                    'https://play.google.com/store/apps/details?id=com.biteandburp',
                    '_blank',
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.white
                          : Colors.deepPurple.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          "Select Plan",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  // --- NEW LEGAL & SUPPORT DIALOG FUNCTIONS ---
  final String legalTermsAndConditions =
      """1. ACCEPTANCE OF TERMS & SCOPE\nBy accessing or using Bite & Burp POS, you agree to these Terms and Conditions. The application is intended solely for business operations, including billing, menu management, inventory control, customer management, reporting, and related business services.\n\n2. ACCOUNT & STAFF SECURITY\nYou are responsible for maintaining the confidentiality of your account credentials, access codes, and staff PINs. Any activity performed under your business account is your responsibility. Please assign staff roles and permissions carefully.\n\n3. DEVICE COMPATIBILITY & SYSTEM REQUIREMENTS\nCertain features require compatible hardware, supported operating systems, internet connectivity, and device permissions. Some operating system settings may need to be enabled for features such as wireless device connectivity and printing.\n\n4. AI-POWERED FEATURES\nBite & Burp POS may provide AI-assisted features to help generate menus, promotional content, or business suggestions. AI-generated content is provided for convenience only and should always be reviewed and verified before business use.\n\n5. SUBSCRIPTION & ACTIVE DEVICES\nYour subscription determines the number of devices or sessions that may access your business account simultaneously. Exceeding the permitted limit may automatically end or restrict additional active sessions.\n\n6. LIMITATION OF LIABILITY\nBite & Burp POS is provided on an "as-is" and "as-available" basis. We are not liable for losses resulting from hardware failures, internet interruptions, incorrect user configurations, data entered by users, or business decisions made using the application. Users remain responsible for verifying financial, tax, and accounting records where required by applicable laws.""";

  // --- LEGACY DIALOGS REMOVED FOR DEDICATED ROUTES ---

  Widget _buildFooter() {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isDesktop ? 60 : 20,
      ),
      color: const Color(0xFF0F0B1E), // Deep corporate purple
      child: Column(
        children: [
          Wrap(
            spacing: 60,
            runSpacing: 40,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Column 1: Brand & Address
              SizedBox(
                width: isDesktop ? 300 : double.infinity,
                child: Column(
                  crossAxisAlignment: isDesktop
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: isDesktop
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/Logo.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "BITE & BURP POS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Address",
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: isDesktop
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, color: Colors.white54, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "+91 99250 95175",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: isDesktop
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          color: Colors.white54,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "support@biteandburp.com",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Column 2: Legal Links
              SizedBox(
                width: isDesktop ? 200 : double.infinity,
                child: Column(
                  crossAxisAlignment: isDesktop
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Legal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => context.go('/privacy-policy'),
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/terms-and-conditions'),
                      child: const Text(
                        "Terms & Conditions",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/help-support'),
                      child: const Text(
                        "Help & Support",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
              // Column 3: Demo CTA
              SizedBox(
                width: isDesktop ? 200 : double.infinity,
                child: Column(
                  crossAxisAlignment: isDesktop
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          context.go('/help-support'), // Demo link request
                      child: const Text(
                        "Take a free demo",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          const Text(
            "© 2026 Bite and burp PVT LTD All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🚀 DEDICATED PREMIUM PAGES (ADD AT BOTTOM)
// ==========================================

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 40,
          vertical: 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Last Updated: Sept 2026",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildSectionTitle("1. ACCOUNT INFORMATION"),
                _buildSectionBody(
                  "We collect basic account information such as your name, email address, profile picture (where available), and a unique account identifier to create, authenticate, and manage your business account securely.",
                ),
                _buildSectionTitle("2. BUSINESS & CUSTOMER DATA"),
                _buildSectionBody(
                  "To provide POS functionality, we securely process and store business information including sales records, inventory data, customer information, tax details, reports, and other information that you choose to enter into the application. Customer information remains under your control.",
                ),
                _buildSectionTitle("3. DEVICE PERMISSIONS"),
                _buildSectionBody(
                  "Depending on the features you use, the application may request the following permissions:\n• Camera: Used for QR code scanning and business-related functions.\n• Nearby Devices / Bluetooth: Used to connect with supported wireless devices such as printers.\n• Location: May be required by your device's OS for Bluetooth discovery.\n• Storage: Used to save reports, images, invoices, and other business files.\n• Audio: Used to play notification sounds and alerts.",
                ),
                _buildSectionTitle("4. THIRD-PARTY SERVICES"),
                _buildSectionBody(
                  "We use trusted third-party service providers to deliver secure authentication, cloud storage, application infrastructure, analytics, and AI-powered features. These providers process data only as necessary to provide the requested services.",
                ),
                _buildSectionTitle("5. LOCAL DEVICE STORAGE"),
                _buildSectionBody(
                  "The application stores certain settings, preferences, paired devices, and temporary business information locally on your device to improve performance, enable offline functionality, and provide a better user experience.",
                ),
                _buildSectionTitle("6. DATA PROTECTION & RETENTION"),
                _buildSectionBody(
                  "Your business data is securely isolated from other users' data. We do not sell your business or customer information to advertisers. You may request deletion of your account and associated business data in accordance with our data retention policies and applicable laws.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }
}

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 600 ? 20 : 40,
          vertical: 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Last Updated: Sept 2026",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _buildSectionTitle("1. ACCEPTANCE OF TERMS & SCOPE"),
                _buildSectionBody(
                  "By accessing or using Bite & Burp POS, you agree to these Terms and Conditions. The application is intended solely for business operations, including billing, menu management, inventory control, customer management, reporting, and related business services.",
                ),
                _buildSectionTitle("2. ACCOUNT & STAFF SECURITY"),
                _buildSectionBody(
                  "You are responsible for maintaining the confidentiality of your account credentials, access codes, and staff PINs. Any activity performed under your business account is your responsibility. Please assign staff roles and permissions carefully.",
                ),
                _buildSectionTitle(
                  "3. DEVICE COMPATIBILITY & SYSTEM REQUIREMENTS",
                ),
                _buildSectionBody(
                  "Certain features require compatible hardware, supported operating systems, internet connectivity, and device permissions. Some operating system settings may need to be enabled for features such as wireless device connectivity and printing.",
                ),
                _buildSectionTitle("4. AI-POWERED FEATURES"),
                _buildSectionBody(
                  "Bite & Burp POS may provide AI-assisted features to help generate menus, promotional content, or business suggestions. AI-generated content is provided for convenience only and should always be reviewed and verified before business use.",
                ),
                _buildSectionTitle("5. SUBSCRIPTION & ACTIVE DEVICES"),
                _buildSectionBody(
                  "Your subscription determines the number of devices or sessions that may access your business account simultaneously. Exceeding the permitted limit may automatically end or restrict additional active sessions.",
                ),
                _buildSectionTitle("6. LIMITATION OF LIABILITY"),
                _buildSectionBody(
                  "Bite & Burp POS is provided on an \"as-is\" and \"as-available\" basis. We are not liable for losses resulting from hardware failures, internet interruptions, incorrect user configurations, data entered by users, or business decisions made using the application. Users remain responsible for verifying financial, tax, and accounting records where required by applicable laws.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }
}

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});
  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSubmitted = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final String userId = _userIdController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String reason = _reasonController.text.trim();

    final String subject = Uri.encodeComponent("Support Request from $userId");
    final String body = Uri.encodeComponent(
      "App User ID / Restaurant ID: $userId\n"
      "Registered Email: $email\n"
      "Phone Number: $phone\n\n"
      "Detailed Reason / Comments:\n$reason",
    );

    String encodedSubject = Uri.encodeComponent(subject);
    String encodedBody = Uri.encodeComponent(body);

    if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      html.window.open(
        'https://mail.google.com/mail/?view=cm&fs=1&to=support@biteandburp.com&su=$encodedSubject&body=$encodedBody',
        '_blank',
      );
    } else {
      html.window.open(
        'mailto:support@biteandburp.com?subject=$encodedSubject&body=$encodedBody',
        '_blank',
      );
    }

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          "Help & Support",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1035),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E0B36), Color(0xFF3B1569)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 50 : 20,
                horizontal: isDesktop ? 80 : 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Help & Support",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 32 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "We're here to help you with any questions or issues you may have. Our team is ready to assist you!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isDesktop ? 15 : 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.headset_mic_rounded,
                    size: isDesktop ? 90 : 46,
                    color: Colors.deepPurpleAccent.shade100,
                  ),
                ],
              ),
            ),
            // Content Cards Layout
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24,
                horizontal: isDesktop ? 40 : 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildContactCard(isDesktop)),
                            const SizedBox(width: 40),
                            Expanded(child: _buildDeletionForm(isDesktop)),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _buildContactCard(isDesktop),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: _buildDeletionForm(isDesktop),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            // Footer Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "© 2025 Bite & Burp POS. All rights reserved.",
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Get Support",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Our dedicated support team is available to help you.",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: Colors.deepPurple,
              ),
            ),
            title: const Text(
              "Email Us",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("support@biteandburp.com"),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.access_time_rounded, color: Colors.blue),
            ),
            title: const Text(
              "Quick Response",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("We respond within 24 hours"),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const Divider(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Colors.green,
              ),
            ),
            title: const Text(
              "Secure & Reliable",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Your information is safe with us"),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: isDesktop
                ? Row(
                    children: [
                      const Icon(
                        Icons.help_outline_rounded,
                        color: Colors.deepPurple,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Need Immediate Help?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              "Check our FAQ section for quick answers",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "View FAQs →",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: Colors.deepPurple,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Need Immediate Help?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Check our FAQ section for quick answers",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "View FAQs →",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletionForm(bool isDesktop) {
    if (_isSubmitted) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 40 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Request Submitted",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your request has been forwarded to our support team. We will process it within 24-48 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.reset();
                setState(() => _isSubmitted = false);
              },
              child: const Text("Submit Another Request"),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Submit a Request",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Fill out the form below and we'll get back to you as soon as possible.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _userIdController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline_rounded),
                labelText: "App User ID / Restaurant ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) => v!.trim().isEmpty ? "Required field" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.mail_outline_rounded),
                labelText: "Registered Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) =>
                  !v!.contains('@') ? "Enter a valid email" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined),
                labelText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) => v!.trim().isEmpty ? "Required field" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(
                    bottom: 60.0,
                  ), // Icon ko thoda upar align karne ke liye
                  child: Icon(Icons.chat_bubble_outline_rounded),
                ),
                labelText: "Detailed Reason / Comments",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v!.trim().length < 10 ? "Please provide more details" : null,
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors
                      .transparent, // Background transparent karenge taki gradient dikhe
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Send Request",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
