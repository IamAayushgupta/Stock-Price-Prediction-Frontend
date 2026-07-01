import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/startup_controller.dart';
import '../theme/app_theme.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  // Register/Find the controller
  late final StartupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StartupController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;
            final contentWidth = isMobile ? double.infinity : _w(600, isMobile);

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _w(24, isMobile),
                    vertical: _h(30, isMobile),
                  ),
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: _h(20, isMobile)),

                        // 1. Top Section: App Logo & Titles
                        const _AnimatedLogo(),
                        SizedBox(height: _h(20, isMobile)),

                        Text(
                          "Preparing Your AI Market Assistant",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: isMobile ? 22 : _sp(26, isMobile),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryDark,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: _h(8, isMobile)),

                        Text(
                          "Loading today's market highlights...",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: isMobile ? 13 : _sp(15, isMobile),
                                color: AppTheme.textSecondaryDark,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: _h(40, isMobile)),

                        // 2. Middle Section: News Carousel or Finance Facts
                        Align(
                          alignment: Alignment.center,
                          child: Obx(() {
                            final String title =
                                controller.newsList.isEmpty &&
                                    !controller.isLoadingNews.value
                                ? "Market Insights"
                                : "Latest Market News";
                            return Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: isMobile ? 16 : _sp(18, isMobile),
                                    color: AppTheme.textPrimaryDark.withValues(
                                      alpha: 0.9,
                                    ),
                                    letterSpacing: 0.5,
                                  ),
                            );
                          }),
                        ),
                        SizedBox(height: _h(12, isMobile)),

                        Obx(() {
                          if (controller.isLoadingNews.value) {
                            return const _ShimmerNewsCard();
                          } else if (controller.newsList.isNotEmpty) {
                            final news = controller
                                .newsList[controller.currentNewsIndex.value];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    final offsetAnimation = Tween<Offset>(
                                      begin: const Offset(0.1, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                              child: _NewsCard(
                                key: ValueKey<int>(
                                  controller.currentNewsIndex.value,
                                ),
                                title: news.title,
                                description: news.description,
                                source: news.source,
                                publishedAt: news.publishedAt,
                                imageUrl: news.imageUrl,
                                url: news.url,
                              ),
                            );
                          } else {
                            // Fallback to finance facts
                            final fact =
                                StartupController.financeFacts[controller
                                    .currentFactIndex
                                    .value];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              child: _FinanceFactCard(
                                key: ValueKey<int>(
                                  controller.currentFactIndex.value,
                                ),
                                fact: fact,
                              ),
                            );
                          }
                        }),

                        SizedBox(height: _h(40, isMobile)),

                        // 3. Bottom Section: Rotating Status Messages & Progress Indicator
                        Obx(() {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  final offsetAnimation = Tween<Offset>(
                                    begin: const Offset(0.0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: Text(
                              controller.currentStatusMessage.value,
                              key: ValueKey<String>(
                                controller.currentStatusMessage.value,
                              ),
                              style: TextStyle(
                                fontSize: isMobile ? 14 : _sp(16, isMobile),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          );
                        }),

                        SizedBox(height: _h(16, isMobile)),

                        // Sleek Gradient Progress Indicator
                        SizedBox(
                          width: double.infinity,
                          height: _h(4, isMobile),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_r(2, isMobile)),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0xFF161E31),
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),

                        SizedBox(height: _h(20, isMobile)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Animated Pulse Logo ──────────────────────────────────────────────────────
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Hero(
      tag: 'app_logo',
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_r(16, isMobile)),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: _r(96, isMobile),
                  height: _r(96, isMobile),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── News Card Widget ─────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final String title;
  final String description;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;
  final String url;

  const _NewsCard({
    super.key,
    required this.title,
    required this.description,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    required this.url,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.darkCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_r(20, isMobile)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.all(_r(16, isMobile)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(_r(12, isMobile)),
                child: Image.network(
                  imageUrl!,
                  height: _h(160, isMobile),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: _h(160, isMobile),
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: _h(12, isMobile)),
            ],
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isMobile ? 16 : _sp(16, isMobile),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryDark,
                height: 1.3,
              ),
            ),
            SizedBox(height: _h(8, isMobile)),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 13 : _sp(13, isMobile),
                color: AppTheme.textSecondaryDark,
                height: 1.4,
              ),
            ),
            SizedBox(height: _h(14, isMobile)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _w(10, isMobile),
                    vertical: _h(4, isMobile),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_r(6, isMobile)),
                  ),
                  child: Text(
                    source,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : _sp(11, isMobile),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Text(
                  _formatRelativeTime(publishedAt),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : _sp(12, isMobile),
                    color: AppTheme.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Finance Fact Card Widget ─────────────────────────────────────────────────
class _FinanceFactCard extends StatelessWidget {
  final String fact;

  const _FinanceFactCard({super.key, required this.fact});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.darkCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_r(20, isMobile)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.all(_r(24, isMobile)),
        child: Column(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: AppTheme.secondaryColor,
              size: 32,
            ),
            SizedBox(height: _h(16, isMobile)),
            Text(
              fact,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isMobile ? 15 : _sp(15, isMobile),
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimaryDark.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            SizedBox(height: _h(16, isMobile)),
            Text(
              "Financial Fact",
              style: TextStyle(
                fontSize: isMobile ? 11 : _sp(11, isMobile),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppTheme.textSecondaryDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Loading News Card Widget ─────────────────────────────────────────
class _ShimmerNewsCard extends StatelessWidget {
  const _ShimmerNewsCard();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Shimmer.fromColors(
      baseColor: AppTheme.darkCardBackground,
      highlightColor: const Color(0xFF222C44),
      child: Card(
        margin: EdgeInsets.zero,
        color: AppTheme.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_r(20, isMobile)),
          side: const BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: EdgeInsets.all(_r(16, isMobile)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: _h(120, isMobile),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_r(12, isMobile)),
                ),
              ),
              SizedBox(height: _h(12, isMobile)),
              Container(
                height: _h(16, isMobile),
                width: double.infinity,
                color: Colors.white,
              ),
              SizedBox(height: _h(6, isMobile)),
              Container(
                height: _h(16, isMobile),
                width: _w(150, isMobile),
                color: Colors.white,
              ),
              SizedBox(height: _h(12, isMobile)),
              Container(
                height: _h(12, isMobile),
                width: double.infinity,
                color: Colors.white,
              ),
              SizedBox(height: _h(6, isMobile)),
              Container(
                height: _h(12, isMobile),
                width: _w(200, isMobile),
                color: Colors.white,
              ),
              SizedBox(height: _h(16, isMobile)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: _h(20, isMobile),
                    width: _w(80, isMobile),
                    color: Colors.white,
                  ),
                  Container(
                    height: _h(14, isMobile),
                    width: _w(50, isMobile),
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper functions for conditional scaling ─────────────────────────────────
double _w(double value, bool isMobile) => isMobile ? value : value.w;
double _h(double value, bool isMobile) => isMobile ? value : value.h;
double _sp(double value, bool isMobile) => isMobile ? value : value.sp;
double _r(double value, bool isMobile) => isMobile ? value : value.r;
