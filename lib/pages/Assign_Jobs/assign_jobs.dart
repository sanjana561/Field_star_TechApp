import 'package:field_star_technician_app/component/jobcard.dart';
import 'package:field_star_technician_app/model/assignedjob_model.dart';
import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignJobs extends StatefulWidget {
  const AssignJobs({super.key});

  @override
  State<AssignJobs> createState() => _AssignJobsState();
}

class _AssignJobsState extends State<AssignJobs> {
  final database = DatabaseOpration();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2126),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
//=======================Good morning Greerting==================================
            Text(
              DatabaseOpration().getGreeting(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
//==============================Get job completed status=================================
          Stack(
            children: [
              Container(height: 240, color: const Color(0xFF1D2126)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    database.gettechprofile(), 
                    database.getTechStats(),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final tech = snapshot.data?[0] as AssignedjobModel?;
                    final stats =
                        (snapshot.data?[1] as Map<String, int>?) ??
                        {
                          'jobsToday': 0,
                          'completed': 0,
                          'inProgress': 0,
                          'pending': 0,
                        };

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                      
                        Text(
                          tech?.fullName ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                       
                        Text(
                          '${tech?.techId ?? ''} • Senior Technician',
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 30),
//=========================Job completed status card======================================
                        Row(
                          children: [
                            _buildStatCard(
                              stats['jobsToday'].toString(),
                              'Jobs Today',
                              Colors.orange.shade100,
                              Icons.build,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              stats['completed'].toString(),
                              'Completed',
                              Colors.green.shade100,
                              Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              stats['inProgress'].toString(),
                              'In Progress',
                              Colors.blue.shade100,
                              Icons.access_time,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              stats['pending'].toString(),
                              'Pending',
                              Colors.yellow.shade100,
                              Icons.error_outline,
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
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assigned Jobs',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
//===========================All job assised based on tech ID===================================
          Expanded(
            child: FutureBuilder<List<RaiseComplaintModel>>(
              future: database.fetchComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final complaints = snapshot.data ?? [];

                if (complaints.isEmpty) {
                  return const Center(child: Text('No complaints assigned.'));
                }
                return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];

                    // Map priority string → color
                    Color priorityColor;
                    switch (complaint.priority.toLowerCase()) {
                      case 'high':
                        priorityColor = Colors.red;
                        break;
                      case 'medium':
                        priorityColor = Colors.orange;
                        break;
                      default:
                        priorityColor = Colors.green;
                    }
//===========================Job assigned job card design==================================
                    return JobCard(
                      id: complaint.id,
                      title: complaint.title,
                      type: complaint.type,
                      issue: complaint.issue,
                      location: complaint.location,
                      distance: complaint.technician?.location ?? 'N/A',
                      eta: 'N/A', 
                      priority: complaint.priority,
                      priorityColor: priorityColor,
                      onTap: () {
                        context.go('/jobdetails', extra: complaint);
                      },
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // Helper widget to create the repetitive cards
  Widget _buildStatCard(
    String count,
    String label,
    Color iconBg,
    IconData icon,
  ) {
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

 
}
