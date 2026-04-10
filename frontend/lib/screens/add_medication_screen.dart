import 'package:flutter/material.dart';
import '../models/medication.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prescribedByController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int? _daysSupply;
  String _selectedColor = '0xFF20B2AA';
  
  final List<Map<String, dynamic>> _colorOptions = [
    {'color': '0xFF20B2AA', 'name': 'Teal'},
    {'color': '0xFFE53935', 'name': 'Red'},
    {'color': '0xFF8E24AA', 'name': 'Purple'},
    {'color': '0xFF1E88E5', 'name': 'Blue'},
    {'color': '0xFFF57C00', 'name': 'Orange'},
  ];

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

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    // Create medication object
    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dose: _doseController.text.trim(),
      times: _selectedTimes
          .map((t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList(),
      startDate: _startDate,
      endDate: _endDate,
      prescribedBy: _prescribedByController.text.isNotEmpty
          ? _prescribedByController.text.trim()
          : null,
      notes: _notesController.text.isNotEmpty
          ? _notesController.text.trim()
          : null,
      instructions: _instructionsController.text.isNotEmpty
          ? _instructionsController.text.trim()
          : null,
      daysSupply: _daysSupply,
      iconColor: _selectedColor,
    );

    // Pop FIRST, then show snackbar on parent's context
    if (!mounted) return;
    Navigator.pop(context, medication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF20B2AA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Medication',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveMedication,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
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
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFBAC2CC),
                              ),
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
                      if (_selectedTimes.length > 1) ...[
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeTimeSlot(index),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addTimeSlot,
                icon: Icon(Icons.add_circle, color: Color(0xFF20B2AA)),
                label: Text(
                  'Add Another Time',
                  style: TextStyle(color: Color(0xFF20B2AA)),
                ),
              ),
              SizedBox(height: 24),
              
              // Start and End Date
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
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF334155)
                                : const Color(0xFFBAC2CC),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color,
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
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF334155)
                                : const Color(0xFFBAC2CC),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date (Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color,
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
                                    color: _endDate != null
                                        ? Theme.of(context).textTheme.bodyLarge?.color
                                        : Theme.of(context).textTheme.bodySmall?.color,
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
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Color(int.parse(colorOption['color'])).withOpacity(0.6),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ] : [],
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 30)
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
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFBAC2CC);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF20B2AA)),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF20B2AA), width: 2),
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
