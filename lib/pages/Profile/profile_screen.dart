import 'package:field_star_technician_app/model/assignedjob_model.dart';
import 'package:field_star_technician_app/model/customer_model.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final database = DatabaseOpration();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2126),
        title: Row(
          spacing: 15,
          children: [
            IconButton(
              onPressed: () {
                context.push('/Home');
              },
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),

            Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(height: 350, color: const Color(0xFF1D2126)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: FutureBuilder<List<dynamic>>(
                    future: Future.wait([
                      database.gettechprofile(),
                      database.getTechStatsprofile(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final tech = snapshot.data?[0] as AssignedjobModel?;

                      final stats =
                          (snapshot.data?[1] as Map<String, dynamic>?) ??
                          {'jobsDone': 0, 'jobsCompleted': 0, 'rating': 0.0};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),

                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.deepOrange,
                                child: Text(
                                  (tech?.fullName ?? '').trim().isNotEmpty
                                      ? tech!.fullName!.trim()[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                tech?.fullName?.isNotEmpty == true
                                    ? tech!.fullName!
                                    : 'Loading...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                tech?.techId?.isNotEmpty == true
                                    ? 'Technician ID : ${tech!.techId}'
                                    : '',
                                style: const TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            spacing: 12,
                            children: [
                              _buildStatCard(
                                '${stats['jobsDone']}',
                                'Jobs Done',
                                Colors.white,
                                Icons.work_outline,
                              ),
                              _buildStatCard(
                                '${stats['jobsCompleted']}',
                                'Completed',
                                Colors.white,
                                Icons.check_circle_outline,
                              ),
                              _buildStatCard(
                                '${stats['rating']}',
                                'Rating',
                                Colors.white,
                                Icons.star_outline,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            //============================ contact info========================================
            FutureBuilder<AssignedjobModel?>(
              future: database.fetchTechnician(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No technician found');
                }

                final technician = snapshot.data!;

                return _buildContactDetails(technician);
              },
            ),
            const SizedBox(height: 15),

            FutureBuilder<Map<String, dynamic>>(
              future: database.getgrapcount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final stats = snapshot.data ?? {};
                final assignedPerDay =
                    (stats['assignedPerDay'] as List<double>?) ??
                    List.filled(7, 0);
                final donePerDay =
                    (stats['donePerDay'] as List<double>?) ?? List.filled(7, 0);
                final totalAssigned = stats['totalAssigned'] ?? 0;
                final jobsCompleted = stats['jobsCompleted'] ?? 0;
                final rating = stats['rating'] ?? 0.0;
                return _buildWeeklyChart(
                  assigned: assignedPerDay,
                  done: donePerDay,
                  totalAssigned: totalAssigned,
                  jobsCompleted: jobsCompleted,
                  avgRating: rating,
                );
              },
            ),
            //===========================CATEGORY LIST=======================
            const SizedBox(height: 15),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: database.fetchCategoryJobCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return const Text("No category jobs found");
                }

                return _buildEquipmentSpecializations(categories);
              },
            ),
            const SizedBox(height: 40),

            Card(
              child: ListTile(
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _handleSignOut(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _iconBox(IconData icon, Color bg, Color color) => Container(
  width: 34,
  height: 34,
  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
  child: Icon(icon, size: 16, color: color),
);

Widget _buildStatCard(String count, String label, Color iconBg, IconData icon) {
  return Expanded(
    child: Container(
      height: 115,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C333A), // Card color
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

//===========================Graph =======================================
Widget _buildWeeklyChart({
  required List<double> assigned,
  required List<double> done,
  required int totalAssigned,
  required int jobsCompleted,
  required double avgRating,
}) {
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            _legend(Colors.blue.shade200, 'Assigned'),
            const SizedBox(width: 12),
            _legend(Colors.green, 'Done'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: assigned[i],
                      color: Colors.blue.shade200,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: done[i],
                      color: Colors.green,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('$totalAssigned', 'Assigned', Colors.blue),
            _statItem('$jobsCompleted', 'Completed', Colors.green),
            _statItem('$avgRating', 'Avg / Day', Colors.orange),
          ],
        ),
      ],
    ),
  );
}

Widget _legend(Color color, String label) {
  return Row(
    children: [
      CircleAvatar(radius: 5, backgroundColor: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
    ],
  );
}

Widget _statItem(String value, String label, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
    ],
  );
}

//=============================Contact info=====================================
Widget _buildContactDetails(AssignedjobModel? tech) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEEEEEE)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact & Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _contactItem(
          icon: Icons.phone_outlined,
          value: tech?.phoneNo ?? '-',
          label: 'Mobile',
        ),
        _divider(),
        _contactItem(
          icon: Icons.email_outlined,
          value: tech?.fullName != null
              ? '${tech!.fullName!.toLowerCase().replaceAll(' ', '.')}@fieldstar.in'
              : '-',
          label: 'Work Email',
          valueColor: Colors.deepOrange,
        ),
        _divider(),
        _contactItem(
          icon: Icons.location_on_outlined,
          value: tech?.location ?? '-',
          label: 'Service Territory',
        ),
        _divider(),
        _contactItem(
          icon: Icons.build_outlined,
          value: tech?.specialization ?? '-',
          label: 'Commercial Kitchen Equipment',
        ),
      ],
    ),
  );
}

Widget _contactItem({
  required IconData icon,
  required String value,
  required String label,
  Color valueColor = const Color(0xFF0F172A),
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _handleSignOut(BuildContext context) async {
  try {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    context.go('/login');
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error signing out: $e")));
  }
}

//===========================CATEGORY JOB COUNT ===============================
Widget _buildEquipmentSpecializations(List<Map<String, dynamic>> categories) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Equipment Specializations",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 14),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(height: 22),
          itemBuilder: (context, index) {
            final item = categories[index];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['category'].toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${item['count']} jobs",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

Widget _divider() => const Divider(height: 1, color: Color(0xFFF1F5F9));
