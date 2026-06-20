class SparePartModel {
  final int? id;
  final int? complaintId;
  final int? technicianId;
  final String partNumber;
  final String description;
  final int quantity;
  final double costPerUnit;
  final double subtotal;
  final bool inStock;

  SparePartModel({
    this.id,
    this.complaintId,
    this.technicianId,
    required this.partNumber,
    required this.description,
    required this.quantity,
    required this.costPerUnit,
    required this.inStock,
  }) : subtotal = quantity * costPerUnit;

  Map<String, dynamic> toMap() {
    return {
      'complaint_id': complaintId,
      'technician_id': technicianId,
      'part_number': partNumber,
      'description': description,
      'quantity': quantity,
      'cost_per_unit': costPerUnit,
      'in_stock': inStock,
    };
  }

  factory SparePartModel.fromMap(Map<String, dynamic> map) {
    return SparePartModel(
      id: map['id'],
      complaintId: map['complaint_id'],
      technicianId: map['technician_id'],
      partNumber: map['part_number'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 1,
      costPerUnit: (map['cost_per_unit'] as num?)?.toDouble() ?? 0.0,
      inStock: map['in_stock'] ?? true,
    );
  }
}