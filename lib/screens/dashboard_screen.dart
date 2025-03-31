import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterproject/%20blocs/auth_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/dynamic_widget_renderer.dart';
import '../services/config_service.dart';
import 'app_tour_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _uiConfig;
  bool _loadingConfig = true;
  int _currentIndex = 0;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  final List<String> _flutterImages = [
    'https://imgs.search.brave.com/1ADYV2fleBwTneWAMKsKLYTnsb2sazjp42ZhyV4CH74/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9zdG9y/YWdlLmdvb2dsZWFw/aXMuY29tL2Ntcy1z/dG9yYWdlLWJ1Y2tl/dC9pbWFnZXMvRmx1/dHRlcl9ncHUud2lk/dGgtNjM1LnBuZw', // Flutter logo
    'https://imgs.search.brave.com/kmfmz5aAMe3wTJNlBUzUsoNIRGAt2Un_cavBLmu8Z28/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9mbHV0/dGVyZ2Vtcy5kZXYv/bWVkaWEvbG9nby5w/bmc', // Flutter UI showcase
    'https://imgs.search.brave.com/rsK3q-2UsUBtso9p7ab45oJyQ67uszkv7lPc_JDF23A/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS1wc2Qv/aW52ZXN0bWVudC1t/b2JpbGUtYXBwLXVp/LWtpdF81NTM0MTMt/MTI2OS5qcGc_c2Vt/dD1haXNfaHlicmlk', // Flutter design
    'https://imgs.search.brave.com/bH7SyYydnwbp03wrnJYKcPPDr7c3bLSUpFKJBap2DdE/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9jYW1v/LmdpdGh1YnVzZXJj/b250ZW50LmNvbS9j/NTA5NzNjMTVmYzBl/MDM5YThkODYzOWU4/ZWQwMGIzM2ExNWUw/NDhmMmYwMmJlZGNl/YzljN2ZkNDY4OGE5/NDg5LzY4NzQ3NDcw/NzMzYTJmMmY3Mzc0/NmY3MjYxNjc2NTJl/Njc2ZjZmNjc2YzY1/NjE3MDY5NzMyZTYz/NmY2ZDJmNjM2ZDcz/MmQ3Mzc0NmY3MjYx/Njc2NTJkNjI3NTYz/NmI2NTc0MmY2MzM4/MzIzMzY1MzUzMzYy/MzM2MTMxNjEzNzYy/MzA2NDMzMzY2MTM5/MmU3MDZlNjc.jpeg', // Food delivery UI
    'https://localizely.com/next-opt/flutter-localization.e54c7796-opt-3840.WEBP', // App showcase
  ];

  final List<Map<String, dynamic>> _dashboardItems = [
    {
      'title': 'Active Projects',
      'value': '12',
      'icon': Icons.work,
      'color': Color(0xFF4285F4),
    },
    {
      'title': 'Completed Tasks',
      'value': '48',
      'icon': Icons.check_circle,
      'color': Color(0xFF0F9D58),
    },
    {
      'title': 'Pending Reviews',
      'value': '6',
      'icon': Icons.pending_actions,
      'color': Color(0xFFF4B400),
    },
    {
      'title': 'Team Members',
      'value': '9',
      'icon': Icons.people,
      'color': Color(0xFFDB4437),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
    _loadUIConfig();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUIConfig() async {
    final configService = context.read<ConfigService>();
    try {
      final config = await configService.loadUIConfig('dashboard');
      setState(() {
        _uiConfig = config;
        _loadingConfig = false;
      });
    } catch (e) {
      setState(() {
        _loadingConfig = false;
      });
    }
  }

  // Get the current screen based on the selected tab index
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        // Custom Dashboard content
        return _buildCustomDashboard();
      case 1:
        // App Tour content
        return const AppTourScreen();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildCustomDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        // Simulate refresh
        setState(() {});
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04), // Responsive padding
          children: [
            _buildWelcomeCard(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            _buildStatisticsSection(constraints),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildSectionTitle('Featured Flutter Designs'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            _buildImageCarousel(constraints),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildSectionTitle('Recent Activities'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            _buildRecentActivities(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Dynamic UI from config if available
            if (!_loadingConfig && _uiConfig != null)
              DynamicWidgetRenderer(jsonData: _uiConfig),
          ],
        );
      }),
    );
  }

  Widget _buildWelcomeCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animationController.value) * 100),
          child: Opacity(
            opacity: _animationController.value,
            child: Card(
              elevation: 8,
              shadowColor: Colors.blue.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 200, // Fixed height to prevent layout issues
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  // Adjust layout based on screen width
                  final bool isSmallScreen = constraints.maxWidth < 350;

                  return Column(
                    mainAxisSize: MainAxisSize.min, // Fixes layout issue
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isSmallScreen ? 25 : 30,
                            backgroundColor: Colors.white,
                            backgroundImage: const NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Alex Johnson',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: 16), // Fixed height instead of percentage
                      Text(
                        'You have 3 tasks due today',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: 10), // Fixed height instead of percentage
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4285F4),
                          padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 12,
                              horizontal: isSmallScreen ? 16 : 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('View Tasks'),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsSection(BoxConstraints parentConstraints) {
    // Calculate how many cards per row based on screen width
    int crossAxisCount = 2;
    if (parentConstraints.maxWidth > 600) {
      crossAxisCount = 4; // For tablets and larger screens
    }

    return SizedBox(
      height: 300, // Fixed height for the grid
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _dashboardItems.length,
        itemBuilder: (context, index) {
          // Ensure animation intervals stay within 0.0-1.0 range
          final double startInterval = (index * 0.15).clamp(0.0, 0.8);
          final double endInterval = (startInterval + 0.2).clamp(0.0, 1.0);

          final Animation<double> animation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (animation.value * 0.5), // Scale from 0.5 to 1.0
                child: Opacity(
                  opacity: animation.value,
                  child: _buildStatCard(
                    _dashboardItems[index]['title'],
                    _dashboardItems[index]['value'],
                    _dashboardItems[index]['icon'],
                    _dashboardItems[index]['color'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final bool isSmallCard = constraints.maxWidth < 120;

          return Column(
            mainAxisSize: MainAxisSize.min, // Fixes layout issue
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isSmallCard ? 24 : 32,
              ),
              // SizedBox(height: 8), // Fixed height instead of percentage
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallCard ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallCard ? 12 : 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 350 ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(BoxConstraints parentConstraints) {
    // Adjust height based on screen size
    final double carouselHeight =
        MediaQuery.of(context).size.width < 400 ? 150 : 180;
    final double cardWidth = parentConstraints.maxWidth > 600
        ? parentConstraints.maxWidth * 0.4
        : 280;

    return SizedBox(
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _flutterImages.length,
        itemBuilder: (context, index) {
          // Fix animation intervals to be within 0.0-1.0
          final double startInterval = (0.4 + (index * 0.1)).clamp(0.0, 0.8);
          final double endInterval = (startInterval + 0.2).clamp(0.0, 1.0);

          final Animation<double> animation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset((1 - animation.value) * 100, 0),
                child: Opacity(
                  opacity: animation.value,
                  child: Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: _flutterImages[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentActivities() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'UI Design Updates',
        'description': 'You completed the dashboard design',
        'time': '2 hours ago',
        'icon': Icons.design_services,
        'color': Colors.purple,
      },
      {
        'title': 'New Comment',
        'description': 'Sarah commented on your Flutter tutorial',
        'time': '4 hours ago',
        'icon': Icons.comment,
        'color': Colors.blue,
      },
      {
        'title': 'Task Completed',
        'description': 'Animation implementation completed',
        'time': 'Yesterday',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        // Fix animation intervals to be within 0.0-1.0
        final double startInterval = (0.6 + (index * 0.1)).clamp(0.0, 0.8);
        final double endInterval = (startInterval + 0.2).clamp(0.0, 1.0);

        final Animation<double> animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - animation.value) * 50),
              child: Opacity(
                opacity: animation.value,
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          activities[index]['color'].withOpacity(0.2),
                      child: Icon(
                        activities[index]['icon'],
                        color: activities[index]['color'],
                        size: MediaQuery.of(context).size.width < 350 ? 18 : 24,
                      ),
                    ),
                    title: Text(
                      activities[index]['title'],
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 350 ? 14 : 16,
                      ),
                    ),
                    subtitle: Text(
                      activities[index]['description'],
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 350 ? 12 : 14,
                      ),
                    ),
                    trailing: Text(
                      activities[index]['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize:
                            MediaQuery.of(context).size.width < 350 ? 10 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen metrics
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: screenSize.width < 350 ? 18 : 20,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF4285F4),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: _getCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tour),
            label: 'App Tour',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4285F4),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
