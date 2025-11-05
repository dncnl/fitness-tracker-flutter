/// We need `dart:convert` to encode and decode our data into a format (JSON)
/// that can be easily saved to the device.
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE & DATA HANDLING (No changes here, functionality is the same) ---
  Map<String, Map<String, double>> _activityData = {};
  String _selectedMetric = 'steps';
  List<DateTime> _currentWeekDays = [];

  @override
  void initState() {
    super.initState();
    _setupCurrentWeek();
    _loadActivityData();
  }

  void _setupCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _currentWeekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('activityData');
    if (dataString != null) {
      final Map<String, dynamic> decodedData = jsonDecode(dataString);
      setState(() {
        _activityData = decodedData.map((key, value) {
          return MapEntry(key, Map<String, double>.from(value));
        });
      });
    }
  }

  Future<void> _saveActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = jsonEncode(_activityData);
    await prefs.setString('activityData', dataString);
  }
  
  // --- NEW: Logout Functionality ---
  /// This function handles the logout process.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Remove the saved user name from storage.
    await prefs.remove('userName');

    // 2. Navigate back to the LoginScreen.
    // `pushAndRemoveUntil` is used to clear all the previous screens
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // returns false
    );
  }


  void _showLogDialog() {
    final stepsController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          )
        ),
        child: AlertDialog(
          title: Text("Log Today's Activity", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField(controller: stepsController, hintText: "Steps"),
              const SizedBox(height: 16),
              _buildStyledTextField(controller: caloriesController, hintText: "Calories Burned"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)), 
              onPressed: () => Navigator.of(context).pop()
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D82F8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save"),
              onPressed: () {
                final todayKey = _formatDate(DateTime.now());
                final steps = double.tryParse(stepsController.text) ?? 0;
                final calories = double.tryParse(caloriesController.text) ?? 0;

                setState(() {
                  if (!_activityData.containsKey(todayKey)) {
                    _activityData[todayKey] = {'steps': 0, 'calories': 0};
                  }
                  _activityData[todayKey]!['steps'] = (_activityData[todayKey]!['steps'] ?? 0) + steps;
                  _activityData[todayKey]!['calories'] = (_activityData[todayKey]!['calories'] ?? 0) + calories;
                });

                _saveActivityData();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStyledTextField({required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showLogDialog,
        backgroundColor: const Color(0xFF5D82F8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(widget.userName),
              const SizedBox(height: 32),
              _buildWeeklyDashboard(context),
              const SizedBox(height: 32),
              _buildHeartRateCard(context),
              const SizedBox(height: 32),
              _buildLatestWorkouts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back", style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 16)),
            Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black)),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_outlined, size: 28, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            // --- NEW: Logout Button ---
            // This IconButton calls the `_logout` function when tapped.
            IconButton(
              icon: const Icon(Icons.logout, size: 28, color: Colors.grey),
              onPressed: _logout, 
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyDashboard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: [_selectedMetric == 'steps', _selectedMetric == 'calories'],
            onPressed: (index) {
              setState(() {
                _selectedMetric = (index == 0) ? 'steps' : 'calories';
              });
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: const Color(0xFF5D82F8),
            splashColor: const Color(0xFF5D82F8).withOpacity(0.2),
            children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Steps")), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Calories"))],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: _selectedMetric == 'steps' ? 5000 : 500)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(dayLabels[value.toInt()], style: GoogleFonts.poppins(fontSize: 10));
                      },
                    ),
                  ),
                ),
                barGroups: _currentWeekDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  final dateKey = _formatDate(date);
                  final value = _activityData[dateKey]?[_selectedMetric] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [BarChartRodData(toY: value, color: const Color(0xFFa1c4fd), width: 16, borderRadius: BorderRadius.circular(4))],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF5D82F8).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Heart Rate", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF5D82F8))),
              Chip(
                label: Text("3 mins ago", style: GoogleFonts.poppins(fontSize: 10, color: Colors.deepPurple)),
                backgroundColor: Colors.white.withOpacity(0.7),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          Text("78 BPM", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF5D82F8))),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xFF5D82F8),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF5D82F8).withOpacity(0.3), const Color(0xFF5D82F8).withOpacity(0)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter
                      )
                    ),
                    spots: List.generate(20, (i) => FlSpot(i.toDouble(), 65 + Random().nextDouble() * 15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestWorkouts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Latest Workouts", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(onPressed: () {}, child: Text("See more", style: GoogleFonts.poppins(color: const Color(0xFF5D82F8)))),
          ],
        ),
        const SizedBox(height: 8),
        _buildWorkoutListItem("Fullbody Workout", "180 Calories Burn | 20minutes", 'assets/icons/fullbody_workout.svg', const Color(0xFFFEF0F0)),
        const SizedBox(height: 12),
        _buildWorkoutListItem("Lowerbody Workout", "200 Calories Burn | 30minutes", 'assets/icons/lowerbody_workout.svg', const Color(0xFFF0F5FF)),
        const SizedBox(height: 12),
        _buildWorkoutListItem("Ab Workout", "180 Calories Burn | 20minutes", 'assets/icons/ab_workout.svg', const Color(0xFFF0FEF8)),
      ],
    );
  }

  Widget _buildWorkoutListItem(String title, String subtitle, String svgPath, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, size: 24, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
          ),
        ],
      ),
    );
  }
}
