import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/dynamic_widget_renderer.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({Key? key}) : super(key: key);

  @override
  _AppTourScreenState createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> _tourPages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTourData();
  }

  Future<void> _loadTourData() async {
    try {
      // Load JSON from asset file
      final String jsonString =
          await rootBundle.loadString('assets/app_tour.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        _tourPages = List<Map<String, dynamic>>.from(jsonData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading tour data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _tourPages.length,
                itemBuilder: (context, index) {
                  return _buildTourPage(_tourPages[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTourPage(Map<String, dynamic> pageData) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Hero(
              tag: pageData['title'],
              child: Image.asset(
                pageData['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  pageData['title'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  pageData['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _tourPages.length,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Previous'),
                )
              : const SizedBox(width: 80),
          _currentPage < _tourPages.length - 1
              ? ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Next'),
                )
              : ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
        ],
      ),
    );
  }
}
