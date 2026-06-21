import 'package:field_star_technician_app/model/assignedjob_model.dart';

class RaiseComplaintModel {
  final int? dbId;            // ← numeric DB id for foreign keys
  final String id;            // ← tickectid for display (TCK-001)
  final String title;
  final String type;
  final String issue;
  final String location;
  final String date;
  final String priority;
  final String status;
  final String techStatus;
  final AssignedjobModel? technician;
  final String? customerId; 
  final String technicianName;
  RaiseComplaintModel({
    this.dbId,                // ← optional
    required this.id,
    required this.title,
    required this.type,
    required this.issue,
    required this.location,
    required this.date,
    required this.priority,
    required this.status,
    required this.techStatus,
    this.technician, required this.technicianName, this.customerId,
    
  });

  factory RaiseComplaintModel.fromMap(Map<String, dynamic> map) {
    final techMap = map['technician'] as Map<String, dynamic>?;

    return RaiseComplaintModel(
      dbId: map['id'] as int?,                              // ← numeric DB id
      id: map['tickectid']?.toString() ?? '',               // ← display ticket id
      title: map['service_required'] ?? '',
      type: map['Category_name'] ?? '',
      issue: map['problem'] ?? '',
      location: techMap?['Location'] ?? '',
      date: map['Date']?.toString() ?? '',
      priority: map['priority_level'] ?? 'Low',
      status: map['complaint_status'] ?? 'Pending',
      techStatus: map['tech_status'] ?? 'Pending',
      technicianName: map['technician_name'] ?? '',
       customerId: map['customer_id']?.toString(),
      technician: techMap != null
          ? AssignedjobModel.fromMap(techMap)
          : null,
    );
  }
}