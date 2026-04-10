import 'package:flutter/material.dart';
import '../models/medication.dart';
import 'edit_medication_screen.dart';

class MedicationDetailScreen extends StatefulWidget {
  final Medication medication;
  const MedicationDetailScreen({super.key, required this.medication});
  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Color(int.parse(widget.medication.iconColor)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMedicationScreen(medication: widget.medication),
                    ),
                  );
                  if (result != null && result is Medication) {
                    Navigator.pop(context, result);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _showDeleteConfirmation(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.medication.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(int.parse(widget.medication.iconColor)),
                      Color(int.parse(widget.medication.iconColor)).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.medication, size: 80, color: Colors.white54),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    title: 'Medication Details',
                    icon: Icons.medication,
                    children: [
                      _buildInfoRow('Dose', widget.medication.dose),
                      _buildInfoRow('Times', widget.medication.times.join(', ')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Duration',
                    icon: Icons.calendar_today,
                    children: [
                      _buildInfoRow('Start Date', _formatDate(widget.medication.startDate)),
                      if (widget.medication.endDate != null)
                        _buildInfoRow('End Date', _formatDate(widget.medication.endDate!)),
                      if (widget.medication.daysSupply != null)
                        _buildInfoRow('Days Supply', '${widget.medication.daysSupply} days'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (widget.medication.prescribedBy != null || widget.medication.refillDate != null)
                    _buildInfoCard(
                      title: 'Prescription Information',
                      icon: Icons.receipt_long,
                      children: [
                        if (widget.medication.prescribedBy != null)
                          _buildInfoRow('Prescribed By', widget.medication.prescribedBy!),
                        if (widget.medication.refillDate != null)
                          _buildInfoRow(
                            'Refill Date',
                            _formatDate(widget.medication.refillDate!),
                            valueColor: _getRefillColor(),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  if (widget.medication.instructions != null || widget.medication.interactions != null)
                    _buildWarningCard(
                      title: 'Instructions & Warnings',
                      children: [
                        if (widget.medication.instructions != null)
                          _buildWarningItem(
                            icon: Icons.info,
                            text: widget.medication.instructions!,
                            color: const Color(0xFFFF6F00),
                          ),
                        if (widget.medication.interactions != null)
                          ...widget.medication.interactions!.map(
                            (i) => _buildWarningItem(
                              icon: Icons.warning,
                              text: i,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  if (widget.medication.notes != null)
                    _buildInfoCard(
                      title: 'Notes',
                      icon: Icons.note,
                      children: [
                        Text(
                          widget.medication.notes!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF20B2AA), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWarningCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2010) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: const Color(0xFFFFB74D).withOpacity(0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFFF6F00), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Theme.of(context).textTheme.titleMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Color _getRefillColor() {
    if (widget.medication.refillDate == null) {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
    final days = widget.medication.refillDate!.difference(DateTime.now()).inDays;
    if (days <= 3) return const Color(0xFFD32F2F);
    if (days <= 7) return const Color(0xFFFF6F00);
    return const Color(0xFF4CAF50);
  }

  void _showDeleteConfirmation() {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFD32F2F)),
              const SizedBox(width: 12),
              Text(
                'Delete Medication?',
                style: TextStyle(color: Theme.of(dialogContext).textTheme.titleMedium?.color),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${widget.medication.name}? This action cannot be undone.',
            style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(outerContext, widget.medication.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
