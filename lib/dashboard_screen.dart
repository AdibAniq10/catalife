import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catalife_pj/firebase_service.dart';
import 'package:catalife_pj/sensor_tile.dart';
import 'package:catalife_pj/auth_service.dart';
import 'package:catalife_pj/status_card.dart';
import 'package:catalife_pj/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeService themeService;

  const DashboardScreen({super.key, required this.themeService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cipta satu 'instance' (objek) dari FirebaseService
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  final String _dashboardImage =
      'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CATALiFE Apps'),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              widget.themeService.toggleTheme();
            },
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Light Mode'
                : 'Dark Mode',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Signed out successfully'),
                        ],
                      ),
                      backgroundColor: Color(0xFF6366F1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'account',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Logged in',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Color(0xFFEF4444)),
                    SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _firebaseService.getSensorDataStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Connecting to Firebase...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please wait while we fetch sensor data",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Connection Error",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Trigger rebuild to retry
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // No data state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Icon(
                        Icons.sensors_off,
                        size: 64,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No Data Available",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No sensor data found at /sensors",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success state - Display sensor data
          final sensorData = snapshot.data!;

          // Helper function to check if water quality is good
          final bool isWaterGood = sensorData['water_quality'] == "GOOD";
          final double? tempValue = sensorData['temperature'] is num
              ? (sensorData['temperature'] as num).toDouble()
              : null;
          final bool isTempOptimal =
              tempValue != null && tempValue >= 26 && tempValue <= 32;

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final gradientColors = isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFE0E7FF), const Color(0xFFF1F5F9)];

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              children: [
                // Network image background
                Positioned.fill(
                  child: Opacity(
                    opacity: isDark ? 0.08 : 0.05,
                    child: CachedNetworkImage(
                      imageUrl: _dashboardImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(),
                      errorWidget: (context, url, error) => const SizedBox(),
                    ),
                  ),
                ),
                // Content
                Column(
                  children: [
                    // Enhanced Header section - More compact
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sensor Dashboard",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Live",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Cards Row - More compact
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatusCard(
                              title: "System Status",
                              subtitle: isWaterGood ? "Optimal" : "Warning",
                              icon: Icons.check_circle_outline,
                              color: isWaterGood
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              isActive: isWaterGood,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatusCard(
                              title: "Temperature",
                              subtitle: isTempOptimal ? "Normal" : "Check",
                              icon: Icons.thermostat,
                              color: isTempOptimal
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFF59E0B),
                              isActive: isTempOptimal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sensor tiles list - Ordered to match Arduino LCD display
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 16, top: 4),
                        children: [
                          SensorTile(
                            title: "Temperature",
                            value: sensorData['temperature'],
                            unit: "°C",
                            icon: Icons.thermostat,
                          ),
                          SensorTile(
                            title: "Food Free Space",
                            value: sensorData['distance'],
                            unit: "cm",
                            icon: Icons.inbox,
                          ),
                          SensorTile(
                            title: "TDS Value",
                            value: sensorData['tds'],
                            unit: "ppm",
                            icon: Icons.opacity,
                          ),
                          SensorTile(
                            title: "Turbidity",
                            value: sensorData['turbidity_status'],
                            unit: "",
                            icon: Icons.waves,
                          ),
                          SensorTile(
                            title: "Water Quality",
                            value: sensorData['water_quality'],
                            unit: "",
                            icon: Icons.analytics_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
