import 'dart:io';

import 'package:field_star_technician_app/model/assignedjob_model.dart';
import 'package:field_star_technician_app/model/customer_model.dart';
import 'package:field_star_technician_app/model/inspectionmodel.dart';
import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/model/spareparts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseOpration {
  final supabase = Supabase.instance.client;
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ';
    if (hour < 17) return 'Good Afternoon ';
    return 'Good Evening ';
  }

  //=============Fetch Assigned jobs ==============================
  Future<List<RaiseComplaintModel>> fetchComplaints() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) throw Exception('Not logged in');
      final techResponse = await supabase
          .from('technician')
          .select('id')
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (techResponse == null) {
        throw Exception('No technician profile found for this account');
      }

      final technicianId = techResponse['id'];

      final response = await supabase
          .from('Raise_complaint')
          .select('''
          *,
          technician (
            id,
            "TechID",
            "Full_name",
            "Phone_no",
            "Location",
            "Specialization",
            techstatus
          )
        ''')
          .eq('technician_id', technicianId)
       .order('created_at', ascending: false);

      return (response as List)
          .map((item) => RaiseComplaintModel.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch: $e');
    }
  }

  //========================Fetch Customer============================
 Future<List<CustomerModel>> fetchcustomer() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final customers = await supabase
        .from('customer')
        .select('*, Raise_complaint(id)')
        .eq('id', user.id)         
        .order('created_at', ascending: false);

    return (customers as List).map((json) {
      final complaints = json['Raise_complaint'] as List? ?? [];
      final enriched = Map<String, dynamic>.from(json);
      enriched['complaint_count'] = complaints.length;
      return CustomerModel.fromMap(enriched);
    }).toList();
  } catch (e) {
    print('fetchcustomer error: $e');
    rethrow;
  }
}
  //=========================Getname and techID===============================
  Future<AssignedjobModel?> gettechprofile()async{
    final user =supabase.auth.currentUser;
    if(user==null)
    return null;

    final response=await supabase
    .from('technician')
    .select()
    .eq('user_id', user.id)
    .maybeSingle();
    if(response==null)return null;
      return AssignedjobModel.fromMap(response);
  }

  Future<Map<String, int>> getTechStats() async {
  final user = supabase.auth.currentUser;
  if (user == null) return {};

 
  final techResponse = await supabase
      .from('technician')
      .select('id')
      .eq('user_id', user.id)
      .maybeSingle();

  if (techResponse == null) return {};
  final technicianId = techResponse['id'];
  final response = await supabase
      .from('Raise_complaint')
      .select('tech_status')
      .eq('technician_id', technicianId);

  final complaints = response as List;

  // Count stats
  final today = DateTime.now();
  int jobsToday = complaints.length;
  int completed = complaints
      .where((c) => c['tech_status'] == 'Completed').length;
  int inProgress = complaints
      .where((c) => c['tech_status'] == 'In Progress').length;
  int pending = complaints
      .where((c) => c['tech_status'] == 'Pending').length;

  return {
    'jobsToday': jobsToday,
    'completed': completed,
    'inProgress': inProgress,
    'pending': pending,
  };
}
 
  //======================Save inpection=======================
  Future<void> submitInspection({
    required int complaintId,
    required List<String> checklistLabels,
    required List<bool> checks,
    required String diagnosis,
    required String additionalNotes,
    List<String> photoUrls = const [],
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // Get technician id
    final techResponse = await supabase
        .from('technician')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (techResponse == null) throw Exception('Technician not found');

    // Build checklist jsonb
    final checklistItems = List.generate(checklistLabels.length, (i) => {
      'label': checklistLabels[i],
      'checked': checks[i],
    });

    final model = InspectionModel(
      complaintId: complaintId,
      technicianId: techResponse['id'],
      checklistItems: checklistItems,
      completedCount: checks.where((c) => c).length,
      diagnosis: diagnosis,
      additionalNotes: additionalNotes,
      photoUrls: photoUrls,
      status: 'Completed',
    );

    await supabase.from('inspection').insert(model.toMap());
  }

  //============================Fetch techid of technician=========================
  
//=================================FetchComplaints by ID================================
  Future<RaiseComplaintModel?> fetchComplaintByTicketId(String ticketId) async {
  final response = await supabase
      .from('Raise_complaint')
      .select()
      .eq('tickectid', ticketId)
      .maybeSingle();

  if (response == null) return null;

  return RaiseComplaintModel.fromMap(response);
}

Future<RaiseComplaintModel?> Fetchcomplaintdetais(String ticketId) async{

   final response = await supabase
      .from('Raise_complaint')
      .select()
      .eq('tickectid', ticketId)
      .maybeSingle();

  if (response == null) return null;

  return RaiseComplaintModel.fromMap(response);
  
}

//=================================ADD Spare Parts========================================
Future<void> addSparePart(SparePartModel part) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final techResponse = await supabase
        .from('technician')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (techResponse == null) throw Exception('Technician not found');

    await supabase.from('spare_parts').insert({
      ...part.toMap(),
      'technician_id': techResponse['id'],
    });
  }

  //===================================Fetch spare Parts=================================
    Future<List<SparePartModel>> fetchSpareParts(int complaintId) async {
    final response = await supabase
        .from('spare_parts')
        .select()
        .eq('complaint_id', complaintId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((item) => SparePartModel.fromMap(item))
        .toList();
  }
  //============================Delete Spare Parts===============================
   Future<void> deleteSparePart(int id) async {
    await supabase.from('spare_parts').delete().eq('id', id);
  }
}

