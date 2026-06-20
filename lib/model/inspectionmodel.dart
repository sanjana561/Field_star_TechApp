class InspectionModel {
  final int? id;
  final int? complaintId;
  final int? technicianId;
  final List<Map<String, dynamic>> checklistItems; 
  final int completedCount;
  final String? diagnosis;
  final String? additionalNotes;
  final List<String> photoUrls;
  final String? status;

  InspectionModel({
    this.id,
    this.complaintId,
    this.technicianId,
    required this.checklistItems,
    required this.completedCount,
    this.diagnosis,
    this.additionalNotes,
    this.photoUrls = const [],
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaint_id': complaintId,
      'technician_id': technicianId,
      'checklist_items': checklistItems,  
      'completed_count': completedCount,
      'diagnosis': diagnosis,
      'additional_notes': additionalNotes,
      'photo_urls': photoUrls,
      'status': status ?? 'In Progress',
    };
  }

  factory InspectionModel.fromMap(Map<String, dynamic> map) {
    return InspectionModel(
      id: map['id'],
      complaintId: map['complaint_id'],
      technicianId: map['technician_id'],
      checklistItems: List<Map<String, dynamic>>.from(
        (map['checklist_items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)), ),
      completedCount: map['completed_count'] ?? 0,
      diagnosis: map['diagnosis'],
      additionalNotes: map['additional_notes'],
      photoUrls: List<String>.from(map['photo_urls'] ?? []),
      status: map['status'],
    );
  }
}