import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Find Your Perfect Seat',
      description: 'Browse real-time seat availability across wings, filter by quiet zones, and book your spot instantly.',
      imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=800&auto=format&fit=crop',
      footerText: 'Campus authentication supported with Student ID',
    ),
    _OnboardingData(
      title: 'Reserve Books Easily',
      description: 'Search over 120,000 catalog volumes and hold academic titles in seconds for quick desk pickup.',
      imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=800&auto=format&fit=crop',
      footerText: 'Free for all students with university card',
    ),
    _OnboardingData(
      title: 'Stay in the Loop',
      description: 'Get notified the moment your book or seat is ready.',
      imageUrl: 'https://images.unsplash.com/photo-1512314889357-e157c22f938d?q=80&w=800&auto=format&fit=crop',
      footerText: 'Biblione Academic Library Pass',
    ),
  ];

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _goToPage(_currentIndex + 1);
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _pages[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ColoredBox(
            color: AppColors.navy,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_library_rounded,
                                color: AppColors.emerald,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Biblione',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'UNIVERSITY LIBRARY',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: widget.onComplete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main Content Area
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Subheader (Library Pass + Step indicator)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.card_membership,
                                        color: Color(0xFF6366F1),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Library Pass',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF4F46E5),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Step ${_currentIndex + 1} of 3',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Sliding Content (Image, Title, Description)
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                itemCount: _pages.length,
                                itemBuilder: (context, index) {
                                  final data = _pages[index];
                                  return Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24),
                                          child: Image.network(
                                            data.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        data.title,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        data.description,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textMuted,
                                          fontSize: 15,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (index == 2) ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _buildCheckBadge('Hold Notifications'),
                                            const SizedBox(width: 8),
                                            _buildCheckBadge('Desk Extensions'),
                                          ],
                                        )
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            // Dots Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentIndex == i ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == i ? AppColors.emerald : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Tab Indicator (Clickable)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  _buildTab('Seats', Icons.chair_alt_rounded, 0),
                                  _buildTab('Books', Icons.menu_book_rounded, 1),
                                  _buildTab('Alerts', Icons.notifications_rounded, 2),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Next/Get Started Button
                            ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emerald,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentIndex == 2 ? 'Get Started' : 'Next',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Footer text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_currentIndex == 2)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6.0),
                                    child: Icon(Icons.check_circle_rounded, color: AppColors.textMuted, size: 16),
                                  ),
                                Text(
                                  currentData.footerText,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
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

  Widget _buildCheckBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.emerald.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.emerald, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.emerald,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _goToPage(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isActive ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.0),
                blurRadius: isActive ? 4 : 0,
                offset: isActive ? const Offset(0, 2) : Offset.zero,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.emerald : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isActive ? AppColors.emerald : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String imageUrl;
  final String footerText;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.footerText,
  });
}
