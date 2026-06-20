class AssignedjobModel {
  final String? techId;
  final String? fullName;
  final String? phoneNo;
  final String? location;
  final String? specialization;
  final String? techStatus;

  AssignedjobModel({
     this.techId,
    this.fullName,
    this.phoneNo,
    this.location,
    this.specialization,
    this.techStatus,
  });
    factory AssignedjobModel.fromMap(Map<String, dynamic> map) {
    return AssignedjobModel(
      techId: map['TechID'],
      fullName: map['Full_name'],
      phoneNo: map['Phone_no'],
      location: map['Location'],
      specialization: map['Specialization'],
      techStatus: map['techstatus'],
    );
  }
}
