import 'package:field_star_technician_app/model/customer_model.dart';
import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/pages/Assign_Jobs/inspection_page.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Jobdetails extends StatefulWidget {
  final RaiseComplaintModel complaint;
  const Jobdetails({super.key, required this.complaint});

  @override
  State<Jobdetails> createState() => _JobdetailsState();
}

class _JobdetailsState extends State<Jobdetails> {
  final database = DatabaseOpration();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              print('No previous route to pop');
            }
          },
        ),
        title:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<RaiseComplaintModel?>
            (future: database.fetchComplaintByTicketId(widget.complaint.id),
             builder: (context,snapshot){
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
                    return    Text(
              '${complaint.id}',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            );
             }),
         
            Text(
              'Service Request Details',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
          FutureBuilder<List<CustomerModel>>(
  future: database.fetchcustomer(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    final customers = snapshot.data ?? [];

    if (customers.isEmpty) {
      return const Center(child: Text('No customers found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.hotelName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "Contact: ${customer.customerName}\nPhone: ${customer.phone}",
              style: const TextStyle(color: Colors.grey),
            ),

            Text(
              "Location: ${customer.location}, ${customer.place}",
              style: const TextStyle(color: Colors.grey),
            ),

            Text(
              "Total Equipment: ${customer.totalEquipment}",
              style: const TextStyle(color: Colors.grey),
            ),

            Text(
              "Complaints: ${customer.complaintCount}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  },
),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call),
                    label: const Text("Call Customer"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text("SMS"),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Service Location
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange),
                SizedBox(width: 5),
                Text(
                  "Service Location",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Text(
              "Main Kitchen, 5th Floor\nOff Western Express Highway, Santacruz East",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _launchGoogleMaps();
                },
                icon: const Icon(Icons.navigation),
                label: const Text("Get Directions (2.3 km)"),
              ),
            ),
            const Divider(height: 30),

            // Equipment Info
            const Text(
              "Equipment Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            FutureBuilder<RaiseComplaintModel?>
            (future: database.Fetchcomplaintdetais(widget.complaint.id),
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
                          child: Text('No complaints details found'),
                        ),
                      );
                    }

                    final complaint = snapshot.data!;
                    return    Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                      '${complaint.type}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text("Service Required: ${complaint.title}"),
                  Divider(),
                  Text(
                    "Reported Issue:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${complaint.issue}'
                   ,
                  ),
                ],
              ),
            );
            },),
         
            const Divider(height: 30),

            // Service History
            const Text(
              "Previous Service History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildHistoryItem(
              "Routine Maintenance",
              "Oil filter replacement, sensor calibration",
              "Mar 15, 2026",
              "Amit Patel (TECH-182)",
            ),
            _buildHistoryItem(
              "Emergency Repair",
              "Heating element replacement",
              "Jan 08, 2026",
              "Suresh Menon (TECH-156)",
            ),

            SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "Important Notes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Customer requires completion before lunch service (12 PM)",
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    "• Equipment is critical for daily operations",
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    "• Spare temperature controller available in van inventory",
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
        

          
            const Divider(height: 30),
            Row(
              children: [
                
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                    
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // Light grey outline
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Mark En Route",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), 
              
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InspectionPage(
                        complaintId: widget.complaint.dbId!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Start Inspection",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String desc,
    String date,
    String tech,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$desc\nBy: $tech"),
        trailing: Text(date, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  //Google Map
  Future<void> _launchGoogleMaps() async {
    const String address = "1600 Amphitheatre Pkwy, Mountain View, CA";

    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );

    final bool launched = await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not launch Google Maps');
    }
  }
}
