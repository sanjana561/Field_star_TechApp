import 'dart:core';

import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/model/spareparts.dart';
import 'package:field_star_technician_app/pages/payments/completeservice.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:flutter/material.dart';

class SpareParts extends StatefulWidget {
    final RaiseComplaintModel complaint;
  const SpareParts({super.key, required this.complaint});

  @override
  State<SpareParts> createState() => _SparePartsState();
}

class _SparePartsState extends State<SpareParts> {
  final partCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final costCtrl = TextEditingController();
  bool _isSaving =false;
  bool inStock = true;
  bool showAddForm = false;
 late Future<List<SparePartModel>>  _parts;

  @override
  void dispose() {
    partCtrl.dispose();
    descCtrl.dispose();
    qtyCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }
@override
  void initState() {
    super.initState();
    _refreshParts(); 
  }

  void _refreshParts() {
    setState(() {
      _parts = DatabaseOpration().fetchSpareParts(widget.complaint.dbId!);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: const BackButton(color: Colors.black),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spare Parts Entry',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
           
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Row(
            children: [
              Text(
                'Add Parts Required',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              
            ],
          ),
          const SizedBox(height: 12),
//==========================List of spare parts added
         FutureBuilder<List<SparePartModel>>(
            future: _parts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final parts = snapshot.data ?? [];

              if (parts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'No parts added yet',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                );
              }

              return Column(
                children: parts.map((part) => _partCard(part)).toList(),
              );
            },
          ),

          const SizedBox(height: 12),
         

          showAddForm ? addPartForm() : addAnotherButton(),

          const SizedBox(height: 14),
//========================Payment List======================================

          card(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Labor & Service Charges',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                PriceRow('Inspection Fee', '₹500'),
                PriceRow('Repair Labor (2 hours)', '₹800'),
                PriceRow('Calibration & Testing', '₹500'),
              ],
            ),
          ),

          const SizedBox(height: 14),

           FutureBuilder<List<SparePartModel>>(
            future: _parts,
            builder: (context, snapshot) {
              final parts = snapshot.data ?? [];
              final partsTotal =
                  parts.fold<double>(0, (sum, p) => sum + p.subtotal);
              final labor = 1800.0;
              final subtotal = partsTotal + labor;
              final gst = subtotal * 0.18;
              final total = subtotal + gst;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xff21262D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cost Summary',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    PriceRow(
                      'Parts Total',
                      '₹${partsTotal.toStringAsFixed(0)}',
                      dark: true,
                    ),
                    const PriceRow('Labor & Service', '₹1,800', dark: true),
                    PriceRow(
                      'Subtotal',
                      '₹${subtotal.toStringAsFixed(0)}',
                      dark: true,
                    ),
                    PriceRow(
                      'GST (18%)',
                      '₹${gst.toStringAsFixed(0)}',
                      dark: true,
                    ),
                    const Divider(color: Colors.white24),
                    PriceRow(
                      'Total Amount',
                      '₹${total.toStringAsFixed(0)}',
                      dark: true,
                      bold: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CompleteServicePage(
                complaint: widget.complaint,
              )),
            );
          },
          style: btnStyle(Colors.deepOrange),
          child: const Text('Proceed to Service Completion'),
        ),
      ),
    );
  }

//==========================Helper Function======================================
  Widget _partCard(SparePartModel part) {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 14),
              const SizedBox(width: 8),
              Text(
                part.partNumber,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await DatabaseOpration().deleteSparePart(part.id!);
                  _refreshParts();
                },
                child: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(part.description,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Qty: ${part.quantity}   ₹${part.costPerUnit.toStringAsFixed(0)} each',
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
              const SizedBox(width: 10),
              Chip(
                label: Text(
                  part.inStock ? 'In Stock' : 'Out of Stock',
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: part.inStock
                    ? const Color(0xffD1FAE5)
                    : const Color(0xffFEE2E2),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Text('Subtotal',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
              const Spacer(),
              Text(
                '₹${part.subtotal.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addAnotherButton() {
    return InkWell(
      onTap: () => setState(() => showAddForm = true),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 8),
            Text('Add Another Part',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget addPartForm() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Part',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          input('Part Number', 'e.g., HEAT-ELEM-456', partCtrl),
          input('Description', 'e.g., Heating Element - 240V', descCtrl),
          Row(
            children: [
              Expanded(child: input('Quantity', '', qtyCtrl)),
              const SizedBox(width: 10),
              Expanded(child: input('Cost (₹)', '', costCtrl)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: inStock,
                onChanged: (v) => setState(() => inStock = v ?? false),
              ),
              const Text('Part available in van inventory',
                  style: TextStyle(fontSize: 11)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (partCtrl.text.isEmpty || costCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please fill required fields')),
                            );
                            return;
                          }

                          setState(() => _isSaving = true);

                          try {
                            await DatabaseOpration().addSparePart(
                              SparePartModel(
                                complaintId: widget.complaint.dbId,
                                partNumber: partCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                quantity: int.tryParse(qtyCtrl.text) ?? 1,
                                costPerUnit:
                                    double.tryParse(costCtrl.text) ?? 0,
                                inStock: inStock,
                              ),
                            );

                            partCtrl.clear();
                            descCtrl.clear();
                            qtyCtrl.text = '1';
                            costCtrl.clear();

                            setState(() => showAddForm = false);
                            _refreshParts(); // ← refresh list

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Part added successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add: $e')),
                            );
                          } finally {
                            setState(() => _isSaving = false);
                          }
                        },
                  style: btnStyle(Colors.deepOrange),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Part'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => showAddForm = false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget card({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: child,
      );

  Widget input(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  ButtonStyle btnStyle(Color color) => ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}

class PriceRow extends StatelessWidget {
  final String title, amount;
  final bool dark, bold;

  const PriceRow(
    this.title,
    this.amount, {
    super.key,
    this.dark = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: dark ? Colors.white : Colors.blueGrey,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              color: dark ? Colors.white : Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
