import 'package:flutter/material.dart';
import '../models/medication.dart';

class EditMedicationScreen extends StatefulWidget {
  final Medication medication;
  
  const EditMedicationScreen({super.key, required this.medication});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _notesController;
  late TextEditingController _prescribedByController;
  late TextEditingController _instructionsController;
  
  late List<TimeOfDay> _selectedTimes;
  late DateTime _startDate;
  DateTime? _endDate;
  int? _daysSupply;
  late String _selectedColor;
  
  final List<Map<String, dynamic>> _colorOptions = [
    {'color': '0xFF20B2AA', 'name': 'Teal'},
    {'color': '0xFFE53935', 'name': 'Red'},
    {'color': '0xFF8E24AA', 'name': 'Purple'},
    {'color': '0xFF1E88E5', 'name': 'Blue'},
    {'color': '0xFFF57C00', 'name': 'Orange'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _doseController = TextEditingController(text: widget.medication.dose);
    _notesController = TextEditingController(text: widget.medication.notes ?? '');
    _prescribedByController = TextEditingController(text: widget.medication.prescribedBy ?? '');
    _instructionsController = TextEditingController(text: widget.medication.instructions ?? '');
    
    _selectedTimes = widget.medication.times.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
    
    _startDate = widget.medication.startDate;
    _endDate = widget.medication.endDate;
    _daysSupply = widget.medication.daysSupply;
    _selectedColor = widget.medication.iconColor;
  }

  void _addTimeSlot() {
    setState(() {
      _selectedTimes.add(const TimeOfDay(hour: 20, minute: 0));
    });
  }

  void _removeTimeSlot(int index) {
    if (_selectedTimes.length > 1) {
      setState(() {
        _selectedTimes.removeAt(index);
      });
    }
  }

  Future<void> _pickTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    
    if (picked != null) {
      setState(() {
        _selectedTimes[index] = picked;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    
    setState(() {
      _endDate = picked;
    });
  }

  void _updateMedication() {
    if (_formKey.currentState!.validate()) {
      // Create updated medication object
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: _nameController.text,
        dose: _doseController.text,
        times: _selectedTimes.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList(),
        startDate: _startDate,
        endDate: _endDate,
        prescribedBy: _prescribedByController.text.isNotEmpty ? _prescribedByController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        daysSupply: _daysSupply,
        iconColor: _selectedColor,
      );
      
      Navigator.pop(context, updatedMedication);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Medication updated successfully'),
          backgroundColor: Color(0xFF20B2AA),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF20B2AA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).cardTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Medication',
          style: TextStyle(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _updateMedication,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Name
              _buildSectionTitle('Medication Details'),
              SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  label: 'Medication Name',
                  icon: Icons.medication,
                  hint: 'e.g., Aspirin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Dose
              TextFormField(
                controller: _doseController,
                decoration: _buildInputDecoration(
                  label: 'Dose',
                  icon: Icons.science,
                  hint: 'e.g., 100mg, 1 tablet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dose';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              // Time Slots
              _buildSectionTitle('Time(s) to Take'),
              SizedBox(height: 12),
              ..._selectedTimes.asMap().entries.map((entry) {
                int index = entry.key;
                TimeOfDay time = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickTime(index),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color ?? Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFBAC2CC)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Color(0xFF20B2AA)),
                                SizedBox(width: 12),
                                Text(
                                  time.format(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_selectedTimes.length > 1)
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeTimeSlot(index),
                        ),
                    ],
                  ),
                );
              }).toList(),
              
              TextButton.icon(
                onPressed: _addTimeSlot,
                icon: Icon(Icons.add_circle, color: Color(0xFF20B2AA)),
                label: Text(
                  'Add Another Time',
                  style: TextStyle(color: Color(0xFF20B2AA)),
                ),
              ),
              SizedBox(height: 24),
              
              // Dates
              _buildSectionTitle('Duration'),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartDate,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFBAC2CC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA8B4),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Color(0xFF20B2AA), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndDate,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFBAC2CC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date (Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA8B4),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.event, color: Color(0xFF20B2AA), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Select',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _endDate != null ? Colors.black : Color(0xFF9CA8B4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Color Selection
              _buildSectionTitle('Color Tag'),
              SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final colorOption = _colorOptions[index];
                    final isSelected = _selectedColor == colorOption['color'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorOption['color'];
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Color(int.parse(colorOption['color'])),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Theme.of(context).cardTheme.color, size: 30)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              
              // Additional Information
              _buildSectionTitle('Additional Information (Optional)'),
              SizedBox(height: 12),
              TextFormField(
                controller: _prescribedByController,
                decoration: _buildInputDecoration(
                  label: 'Prescribed By',
                  icon: Icons.person,
                  hint: 'Doctor name',
                ),
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _instructionsController,
                decoration: _buildInputDecoration(
                  label: 'Instructions',
                  icon: Icons.info_outline,
                  hint: 'e.g., Take with food',
                ),
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  label: 'Notes',
                  icon: Icons.note,
                  hint: 'Any additional notes',
                ),
              ),
              SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF20B2AA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Update Medication',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C4858),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Color(0xFF20B2AA)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFBAC2CC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFBAC2CC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF20B2AA), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    _prescribedByController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
