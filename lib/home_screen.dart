import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// The main dashboard screen. Stateful - Data Changes
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Map<String, double>> _activityData = {
    "2025-10-01": {"weight": 70.0},
    "2025-10-10": {"weight": 69.5},
    "2025-10-20": {"weight": 68.5},
  };
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
        decodedData.forEach((key, value) {
          _activityData[key] = Map<String, double>.from(value);
        });
      });
    }
  }

  Future<void> _saveActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = jsonEncode(_activityData);
    await prefs.setString('activityData', dataString);
  }
  
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showLogOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Log Entry", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.monitor_weight), title: const Text("Weight (kg)"), onTap: () => _logItem("weight")),
            ListTile(leading: const Icon(Icons.directions_walk), title: const Text("Steps"), onTap: () => _logItem("steps")),
            ListTile(leading: const Icon(Icons.local_fire_department), title: const Text("Calories"), onTap: () => _logItem("calories")),
            ListTile(leading: const Icon(Icons.water_drop), title: const Text("Water Intake (ml)"), onTap: () => _logItem("water")),
            ListTile(leading: const Icon(Icons.bedtime), title: const Text("Sleep (hours)"), onTap: () => _logItem("sleep")),
          ],
        ),
      ),
    );
  }

  void _logItem(String type) {
    Navigator.pop(context);
    final controller = TextEditingController();
    String label = "Enter total ${type} for today";
    if (type == 'water') label = "Enter water in ml";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Log $type"),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                double finalValue = value;
                if (type == 'water') {
                  finalValue = value / 1000;
                }
                final todayKey = _formatDate(DateTime.now());
                setState(() {
                  if (!_activityData.containsKey(todayKey)) {
                    _activityData[todayKey] = {};
                  }
                  _activityData[todayKey]![type] = finalValue;
                });
                _saveActivityData();
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = _formatDate(DateTime.now());
    final todaysData = _activityData[todayKey] ?? {};
    final waterIntake = todaysData['water'] ?? 0;
    final sleep = todaysData['sleep'] ?? 0;
    final calories = todaysData['calories'] ?? 0;
    final weight = todaysData['weight'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLogOptions,
        backgroundColor: const Color(0xFF5D82F8),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(widget.userName),
              const SizedBox(height: 20),
              _buildWeeklyDashboard(context),
              const SizedBox(height: 20),
              _buildWeightChartCard(),
              const SizedBox(height: 20),
              _buildHeartRateCard(context),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.9, // Adjusted aspect ratio for better height
                children: [
                  _buildWaterIntakeCard(waterIntake),
                  _buildSleepCard(sleep),
                  _buildCaloriesCard(calories),
                  _buildWeightCard(weight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/ensayo_black.png', height: 25),
              const SizedBox(height: 8),
              Text("Welcome Back", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(name, style: GoogleFonts.poppins(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1),
              ),
            ],
          ),
        ),
        Row(
          children: [
             Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.notifications, size: 28, color: Colors.grey),
              ),
            IconButton(icon: const Icon(Icons.logout, size: 28, color: Colors.grey), onPressed: _logout),
          ]
        ),
      ],
    );
  }

  Widget _buildWeeklyDashboard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFFEAF0FE), Color(0xFFE9EDFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text("Weekly Activity", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis)),
              ToggleButtons(
                isSelected: [_selectedMetric == 'steps', _selectedMetric == 'calories'],
                onPressed: (index) => setState(() => _selectedMetric = (index == 0) ? 'steps' : 'calories'),
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF5D82F8),
                constraints: const BoxConstraints(minHeight: 30, minWidth: 60),
                children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Steps")), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Calories"))],
              ),
            ]
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
                        const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
                  return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: value, color: const Color(0xFFa1c4fd), width: 16, borderRadius: BorderRadius.circular(4))]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChartCard() {
    final weightEntries = _activityData.entries.where((entry) => entry.value.containsKey('weight')).toList();
    weightEntries.sort((a, b) => a.key.compareTo(b.key));

    final spots = weightEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value['weight']!);
    }).toList();

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.monitor_weight, color: Color(0xFF5D82F8)), const SizedBox(width: 8), Text("Weight Trend", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF5D82F8)))]),
          const SizedBox(height: 4),
          Text("Your progress over time", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Expanded(
            child: spots.isEmpty
                ? Center(child: Text("No weight data logged yet.", style: GoogleFonts.poppins()))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: max(1, (spots.length / 4).floorToDouble()),
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= spots.length) return const SizedBox();
                              final dateString = weightEntries[value.toInt()].key;
                              final dateParts = dateString.split('-');
                              return Text("${dateParts[1]}/${dateParts[2]}", style: GoogleFonts.poppins(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: const Color(0xFF5D82F8),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF5D82F8).withOpacity(0.3), const Color(0xFF5D82F8).withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                          spots: spots,
                        ),
                      ],
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Heart Rate", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF5D82F8))),
          const SizedBox(height: 4),
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
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF5D82F8).withOpacity(0.3), const Color(0xFF5D82F8).withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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

  Widget _buildWaterIntakeCard(double waterIntake) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.water_drop, color: Color(0xFF5D82F8)), const SizedBox(width: 8), Text("Water", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))]),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text("${waterIntake.toStringAsFixed(1)} L", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF5D82F8)))),
          const Spacer(),
          LinearProgressIndicator(
             value: (waterIntake / 3.7).clamp(0, 1), // Assumes a 3.7L daily goal
             backgroundColor: const Color(0xFF5D82F8).withOpacity(0.2),
             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5D82F8)),
             minHeight: 8,
             borderRadius: BorderRadius.circular(4),
          ),
           const SizedBox(height: 4),
          Text("Goal: 3.7 L", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildSleepCard(double sleepHours) {
    final List<double> weeklySleep = _currentWeekDays.map((day) => _activityData[_formatDate(day)]?['sleep'] ?? 0).toList();

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.bedtime, color: Color(0xFF5D82F8)), const SizedBox(width: 8), Text("Sleep", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))]),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text("${sleepHours.toStringAsFixed(1)} hours", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF5D82F8)))),
          const Spacer(),
          Expanded(
            child: BarChart(
              BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  barGroups: weeklySleep.asMap().entries.map((entry) {
                    return BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: entry.value, color: const Color(0xFFa1c4fd), width: 8, borderRadius: BorderRadius.circular(2))]);
                  }).toList(),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['M','T','W','T','F','S','S'].map((day) => Text(day, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))).toList())
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(double calories) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.local_fire_department, color: Color(0xFF5D82F8)), const SizedBox(width: 8), Flexible(child: Text("Calories Burned", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text("${calories.toStringAsFixed(0)} kCal", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF5D82F8)))),
          const Spacer(),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 80, height: 80,
                child: CustomPaint(
                  painter: _CircularProgressPainter((calories / 2500).clamp(0, 1)),
                  child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text("${(2500 - calories).clamp(0, 2500).toStringAsFixed(0)}\nkCal left", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87), textAlign: TextAlign.center))),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildWeightCard(double weight) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFEAF0FE)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [const Icon(Icons.monitor_weight, color: Color(0xFF5D82F8)), const SizedBox(width: 8), Flexible(child: Text("Current Weight", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis))]),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("${weight.toStringAsFixed(1)} kg", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF5D82F8))),
            ),
          ),
          const SizedBox(height: 10) // Spacer to provide padding at the bottom.
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 10;
    double radius = size.width / 2 - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint backgroundPaint = Paint()..color = const Color(0xFF5D82F8).withOpacity(0.2)..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    Paint progressPaint = Paint()..shader = SweepGradient(startAngle: -pi / 2, endAngle: 3 * pi / 2, colors: [const Color(0xFFa1c4fd), const Color(0xFF5D82F8)]).createShader(Rect.fromCircle(center: center, radius: radius))..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    
    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
