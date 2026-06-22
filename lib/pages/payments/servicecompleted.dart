import 'dart:async';
import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceCompletedPage extends StatefulWidget {
    final RaiseComplaintModel complaint;
  const ServiceCompletedPage({super.key, required this.complaint});

  @override
  State<ServiceCompletedPage> createState() => _ServiceCompletedPageState();
}

class _ServiceCompletedPageState extends State<ServiceCompletedPage> {
  late final Timer _timer;
final database=DatabaseOpration();
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.go('/Home');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0xffD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xff10B981),
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Service Completed!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),
               FutureBuilder<RaiseComplaintModel?>(
              future: database.fetchComplaintByTicketId(widget.complaint.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No complaints found'),
                    ),
                  );
                }

                final complaint = snapshot.data!;

              return  Text(
                '${complaint.id} has been successfully closed',
                
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              );
              }
               ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Invoice generated and sent to customer',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Redirecting to dashboard...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}