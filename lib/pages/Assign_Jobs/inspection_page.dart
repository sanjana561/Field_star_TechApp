import 'dart:io';

import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/pages/Assign_Jobs/spare_parts.dart';
import 'package:field_star_technician_app/service/database_operation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InspectionPage extends StatefulWidget {
      final RaiseComplaintModel complaint;
  const InspectionPage({super.key, required this.complaint});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final database = DatabaseOpration();
  final List<String> _uploadedPhotoUrls = [];
  final List<XFile> _selectedImages = [];
  bool _isUploading = false;
//=====================List of CheckList=============================
  final List<String> checklist = [
    "Visual inspection of exterior condition",
    "Check electrical connections and wiring",
    "Test temperature controller functionality",
    "Inspect heating elements",
    "Check thermostat calibration",
    "Verify safety cutoff mechanisms",
    "Test oil filtration system",
    "Check for oil leaks",
  ];

  final List<bool> _checks = List.generate(8, (_) => false);

  final TextEditingController _diagCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  int get completedCount => _checks.where((c) => c).length;

  bool get isValid =>completedCount == checklist.length && _diagCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _diagCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / checklist.length;

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspection Workflow',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //========================Progress bar=====================================
                  Row(
                    children: [
                      const Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$completedCount/${checklist.length}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  //======================Inspection started container==============================
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Inspection Started",
                                style: TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Today, 11:05 AM • Location verified ✓",
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_box_outlined,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  //===================================inspection checklist================================
                  const Text(
                    "Inspection Checklist",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(checklist.length, (i) {
                    final checked = _checks[i];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _checks[i] = !_checks[i];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? const Color(0xFFD1FAE5)
                              : Colors.white,
                          border: Border.all(
                            color: checked
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: checked
                                    ? const Color(0xFF10B981)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: checked
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: checked
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                checklist[i],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  //===========================upload Photo====================================
                  const SizedBox(height: 18),

                  const Text(
                    "Photo Documentation",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Show selected images
                        if (_selectedImages.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(_selectedImages[index].path),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Delete button
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                            _uploadedPhotoUrls.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 10),

 //============================================Upload button============================================
                        GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _isUploading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 20,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Upload Photos",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _selectedImages.isEmpty
                                            ? "Before, during, and after repair"
                                            : "${_selectedImages.length} photo(s) uploaded",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
//===========================Diagnosis & Findings text area====================================
                  const Text(
                    "Diagnosis & Findings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _textArea(
                    controller: _diagCtrl,
                    hint: "Describe the root cause and recommended solution...",
                  ),

                  const SizedBox(height: 22),
 //========================Additional textarea=====================================
                  const Text(
                    "Additional Notes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _textArea(
                    controller: _notesCtrl,
                    hint:
                        "Any additional observations, recommendations, or safety concerns...",
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
//=================================Continue Spareparts buttom===============================
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 251, 135, 12),
                  foregroundColor: Colors.white,

                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: isValid
                    ? () async {
                        try {
                          await DatabaseOpration().submitInspection(
                            complaintId: widget.complaint.dbId!,
                            checklistLabels: checklist,
                            checks: _checks,
                            diagnosis: _diagCtrl.text.trim(),
                            additionalNotes: _notesCtrl.text.trim(),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpareParts(
                                 complaint: widget.complaint, 
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e')),
                          );
                        }
                      }
                    : null,
                child: const Text(
                  "Continue to Spare Parts",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 //=======================TextArea design styling=======================================
  Widget _textArea({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
      ),
    );
  }

 //===============================Pick image================================
  Future<void> _pickAndUploadImage() async {
    // Request permission first
    final status = await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please allow photo access in settings'),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      final fileName =
          'inspection_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'inspections/$fileName';

      await Supabase.instance.client.storage
          .from('inspection-photos')
          .uploadBinary(path, bytes);

      final url = Supabase.instance.client.storage
          .from('inspection-photos')
          .getPublicUrl(path);

      setState(() {
        _uploadedPhotoUrls.add(url);
        _selectedImages.add(image);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }
}
