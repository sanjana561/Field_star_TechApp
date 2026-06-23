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
 Future<CustomerModel?> fetchCustomerByTicketId(String ticketId) async {
  // Step 1: get customer_id from Raise_complaint
  final complaintResponse = await Supabase.instance.client
      .from('Raise_complaint')
      .select('customer_id')
      .eq('tickectid', ticketId)
      .maybeSingle();

  if (complaintResponse == null) return null;

  final customerId = complaintResponse['customer_id']?.toString();
  if (customerId == null) return null;

  // Step 2: fetch customer using that customer_id
  final customerResponse = await Supabase.instance.client
      .from('customer')
      .select('id, cust_name, cust_phno, cust_location, cust_place, cust_hotelname, total_equipment, revenue_ytd, Raise_complaint(id, tickectid)')
      .eq('id', customerId)
      .maybeSingle();

  if (customerResponse == null) return null;

  final complaints = customerResponse['Raise_complaint'] as List? ?? [];
  final ticketIds = complaints
      .map((c) => c['tickectid']?.toString() ?? '')
      .where((t) => t.isNotEmpty)
      .toList();

  return CustomerModel.fromMap({
    ...customerResponse,
    'complaint_count': complaints.length,
    'ticket_ids': ticketIds,
  });
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
      .select('complaint_status,tech_status,Date')
      .eq('technician_id', technicianId);

  final complaints = response as List;
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  int jobsToday = complaints.where((c) {
    final raw = c['Date'];
    if (raw == null) return false;
    final date = DateTime.tryParse(raw.toString());
    if (date == null) return false;
    return date.isAfter(todayStart) && date.isBefore(todayEnd);
  }).length;

  int completed = complaints
      .where((c) => c['complaint_status'] == 'Completed').length;
  int inProgress = complaints
      .where((c) => c['tech_status'] == 'Assigned').length;
  int pending = complaints
      .where((c) => c['complaint_status'] == 'pending').length;

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

  //=========================Fetch complete history detils=========================
  Future<List<RaiseComplaintModel>> fetchCompletedHistory(String tickectId) async {
  final response = await supabase
      .from('Raise_complaint')
      .select()
      .eq('tickectid', tickectId)
      .eq('complaint_status', 'completed')
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => RaiseComplaintModel.fromMap(e))
      .toList();
}

}

