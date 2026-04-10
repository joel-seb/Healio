import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../widgets/page_header.dart';
import '../services/notification_service.dart';
import '../services/notifications_manager.dart';
import '../services/medication_service.dart';
import '../services/dose_taken_service.dart';
import 'add_medication_screen.dart';
import 'medication_detail_screen.dart';

class MedicationManagerScreen extends StatefulWidget {
  const MedicationManagerScreen({super.key});

  @override
  State<MedicationManagerScreen> createState() => _MedicationManagerScreenState();
}

class _MedicationManagerScreenState extends State<MedicationManagerScreen>
    with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  final NotificationsManager _notificationsManager = NotificationsManager();
  final MedicationService _medicationService = MedicationService();
  final DoseTakenService _doseTakenService = DoseTakenService.instance;

  List<Medication> medications = [];
  List<MedicationDose> todaysDoses = [];
  List<MedicationDose> missedDoses = [];
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _streakController;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedications();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 2000), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  Future<void> _loadMedications() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      // Prune taken records older than 7 days (housekeeping)
      await _doseTakenService.pruneOldRecords();

      final meds = await _medicationService.fetchMedications();
      setState(() { medications = meds; _isLoading = false; });

      // Restore persisted taken state BEFORE generating doses
      await _generateTodaysDoses();

      try {
        await _notificationService.scheduleAllMedications(medications);
      } catch (_) {}
      _checkAndPostMissedAlerts();
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Failed to load medications.'; });
    }
  }

  Future<void> _generateTodaysDoses() async {
    todaysDoses.clear();
    missedDoses.clear();
    final today = DateTime.now();

    // Load persisted taken doses for today from SharedPreferences
    final takenToday = await _doseTakenService.getTakenDosesForToday();

    final activeMeds = medications.where((med) {
      if (med.endDate != null) {
        return !DateTime.now().isAfter(
            DateTime(med.endDate!.year, med.endDate!.month, med.endDate!.day, 23, 59, 59));
      }
      return true;
    }).toList();

    for (var med in activeMeds) {
      for (var time in med.times) {
        final wasTaken = takenToday.contains('${med.id}|$time');
        final dose = MedicationDose(
          medicationId: med.id,
          medicationName: med.name,
          dose: med.dose,
          time: time,
          scheduledDate: today,
          isTaken: wasTaken,          // ← restore persisted state
          takenAt: wasTaken ? today : null,
        );
        todaysDoses.add(dose);
        if (dose.isMissed) missedDoses.add(dose);
      }
    }

    if (mounted) setState(() {});
  }

  void _checkAndPostMissedAlerts() {
    for (final dose in missedDoses) {
      _notificationsManager.addMissedDoseAlert(
        medicationName: dose.medicationName, dose: dose.dose, time: dose.time);
    }
  }

  void _markAsTaken(MedicationDose dose) {
    setState(() {
      dose.isTaken = true;
      dose.takenAt = DateTime.now();
      missedDoses.remove(dose);
    });

    // Persist so the taken state survives navigation and restarts
    _doseTakenService.markTaken(dose.medicationId, dose.time);

    // Cancel today notification and reschedule for tomorrow
    _notificationService.cancelDoseNotification(dose.medicationId, dose.time);
    // Find the medication object to reschedule for tomorrow
    final med = medications.firstWhere(
      (m) => m.id == dose.medicationId,
      orElse: () => medications.first,
    );
    _notificationService.rescheduleMedicationForTomorrow(med, dose.time);

    // Remove only "Time to take" / missed alerts for this specific dose, then add confirmation
    _notificationsManager.removeDoseAlert(dose.medicationName, dose.time);
    _notificationsManager.addTakenConfirmation(
        medicationName: dose.medicationName, dose: dose.dose);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${dose.medicationName} marked as taken ✓'),
      backgroundColor: const Color(0xFF20B2AA),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final upcomingDoses = todaysDoses.where((d) => !d.isTaken).toList();
    final takenCount = todaysDoses.where((d) => d.isTaken).length;
    final percentage = todaysDoses.isNotEmpty
        ? (takenCount / todaysDoses.length * 100).round() : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              PageHeader(
                title: 'Medication Manager',
                subtitle: 'Track your medications',
                icon: Icons.medication_outlined,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : RefreshIndicator(
                            onRefresh: _loadMedications,
                            color: const Color(0xFF20B2AA),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (todaysDoses.isNotEmpty) ...[
                                      _buildProgressCard(percentage, takenCount),
                                      const SizedBox(height: 20),
                                    ],
                                    if (missedDoses.isNotEmpty) ...[
                                      _buildMissedAlert(),
                                      const SizedBox(height: 16),
                                    ],
                                    Row(children: [
                                      Icon(Icons.schedule,
                                          color: Theme.of(context).textTheme.titleMedium?.color,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text("Today's Schedule",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                                              color: Theme.of(context).textTheme.titleMedium?.color)),
                                    ]),
                                    const SizedBox(height: 16),
                                    if (upcomingDoses.isEmpty && missedDoses.isEmpty)
                                      medications.isEmpty ? _buildNoMedsState() : _buildAllTakenState()
                                    else
                                      ...upcomingDoses.map(_buildDoseCard),
                                    const SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          Icon(Icons.medical_services,
                                              color: Theme.of(context).textTheme.titleMedium?.color, size: 20),
                                          const SizedBox(width: 8),
                                          Text('All Medications',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).textTheme.titleMedium?.color)),
                                        ]),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF20B2AA).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text('${medications.length} active',
                                              style: const TextStyle(fontSize: 12,
                                                  fontWeight: FontWeight.bold, color: Color(0xFF20B2AA))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...medications.map(_buildMedicationCard),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
          Positioned(
            left: 20, right: 20, bottom: 20,
            child: _buildAddMedicationButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: Color(0xFF20B2AA)),
        const SizedBox(height: 16),
        Text('Loading your medications…',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 15)),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off, size: 64, color: Color(0xFFFF6B6B)),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadMedications,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20B2AA), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildProgressCard(int percentage, int takenCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF20B2AA).withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Text('$percentage%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF20B2AA)))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's Progress",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color)),
          const SizedBox(height: 4),
          Text('$takenCount of ${todaysDoses.length} taken',
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ])),
      ]),
    );
  }

  Widget _buildMissedAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Missed Medications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('You have ${missedDoses.length} missed dose${missedDoses.length > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ])),
        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      ]),
    );
  }

  Widget _buildDoseCard(MedicationDose dose) {
    final isDue = dose.isDue;
    final isMissed = dose.isMissed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isDue ? const LinearGradient(colors: [Color(0xFF20B2AA), Color(0xFF1A9E98)]) : null,
        color: isDue ? null : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: isDue ? const Color(0xFF20B2AA).withOpacity(0.3) : Colors.black.withOpacity(0.05),
          blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(color: Colors.transparent, child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: isDue ? Colors.white.withOpacity(0.2) : const Color(0xFF20B2AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.access_time, color: isDue ? Colors.white : const Color(0xFF20B2AA), size: 20),
              const SizedBox(height: 4),
              Text(dose.time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                  color: isDue ? Colors.white : const Color(0xFF20B2AA))),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dose.medicationName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                color: isDue ? Colors.white : Theme.of(context).textTheme.titleMedium?.color)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.medication, size: 14,
                  color: isDue ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 4),
              Text(dose.dose, style: TextStyle(fontSize: 14,
                  color: isDue ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color)),
            ]),
            if (isMissed) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber, size: 12, color: Color(0xFFFF6B6B)),
                  SizedBox(width: 4),
                  Text('Missed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B))),
                ]),
              ),
            ),
          ])),
          if (!dose.isTaken)
            ElevatedButton(
              onPressed: () => _markAsTaken(dose),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDue ? Colors.white : const Color(0xFF20B2AA),
                foregroundColor: isDue ? const Color(0xFF20B2AA) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, size: 18), SizedBox(width: 6),
                Text('Take', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF20B2AA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: Color(0xFF20B2AA), size: 18), SizedBox(width: 6),
                Text('Taken', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF20B2AA))),
              ]),
            ),
        ]),
      )),
    );
  }

  Widget _buildMedicationCard(Medication med) {
    final color = Color(int.parse(med.iconColor));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => MedicationDetailScreen(medication: med)));
          if (result != null) {
            if (result is String) {
              try {
                await _medicationService.deleteMedication(result);
                setState(() { medications.removeWhere((m) => m.id == result); });
                await _generateTodaysDoses();
                await _notificationService.scheduleAllMedications(medications);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Medication deleted'),
                    backgroundColor: Color(0xFF20B2AA), behavior: SnackBarBehavior.floating));
              } catch (e) {
                // Still remove from UI even if backend fails
                setState(() { medications.removeWhere((m) => m.id == result); });
                await _generateTodaysDoses();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted locally (sync failed: $e)'),
                      backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
              }
            } else if (result is Medication) {
              try {
                final updated = await _medicationService.updateMedication(result);
                setState(() {
                  final idx = medications.indexWhere((m) => m.id == updated.id);
                  if (idx != -1) medications[idx] = updated;
                  _generateTodaysDoses();
                });
                await _notificationService.scheduleAllMedications(medications);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
              }
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.6), color],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle),
            child: const Icon(Icons.medication, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(med.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color)),
            const SizedBox(height: 6),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(med.dose,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ),
              const SizedBox(width: 8),
              Text('${med.times.length}x daily',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155) : const Color(0xFFE8ECF0),
              shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodyMedium?.color, size: 16),
          ),
        ])),
      )),
    );
  }

  Widget _buildNoMedsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF20B2AA).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.medication_outlined, size: 64, color: Color(0xFF20B2AA)),
        ),
        const SizedBox(height: 20),
        Text('No Medications Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color)),
        const SizedBox(height: 12),
        Text('Add your first medication using the button below.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
      ]),
    );
  }

  Widget _buildAllTakenState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF20B2AA), Color(0xFF1A9E98)]),
              shape: BoxShape.circle),
          child: Icon(Icons.check_circle, size: 64,
              color: Theme.of(context).cardTheme.color ?? Colors.white),
        ),
        const SizedBox(height: 20),
        Text('🎉 All Caught Up!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color)),
        const SizedBox(height: 12),
        Text("You've taken all your medications for now.\nKeep up the great work!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
      ]),
    );
  }

  Widget _buildAddMedicationButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF20B2AA), Color(0xFF1A9E98)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF20B2AA).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddMedicationScreen()));
          if (result != null && result is Medication) {
            try {
              final saved = await _medicationService.addMedication(result);
              setState(() { medications.add(saved); _generateTodaysDoses(); });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Medication added successfully'),
                    backgroundColor: Color(0xFF20B2AA),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              try {
                await _notificationService.scheduleAllMedications(medications);
              } catch (_) {}
              _notificationsManager.addMedicationAddedAlert(
                  medicationName: saved.name, dose: saved.dose);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red));
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Add Medication',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ),
      )),
    );
  }
}
