class Medication {
  final String id;
  final String name;
  final String dose;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? notes;
  final String? instructions;
  final List<String>? interactions;
  final int? daysSupply;
  final DateTime? refillDate;
  final String iconColor;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.times,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.notes,
    this.instructions,
    this.interactions,
    this.daysSupply,
    this.refillDate,
    this.iconColor = '0xFF20B2AA',
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      try { return DateTime.parse(val.toString()); } catch (_) { return DateTime.now(); }
    }
    DateTime? parseDateNullable(dynamic val) {
      if (val == null) return null;
      try { return DateTime.parse(val.toString()); } catch (_) { return null; }
    }
    List<String> parseTimes(dynamic val) {
      if (val == null) return ['08:00'];
      if (val is List) return val.map((e) => e.toString()).toList();
      return ['08:00'];
    }
    return Medication(
      id: json['id'].toString(),
      name: json['name'] as String,
      dose: json['dose'] as String? ?? '',
      times: parseTimes(json['times']),
      startDate: parseDate(json['start_date']),
      endDate: parseDateNullable(json['end_date']),
      prescribedBy: json['prescribed_by'] as String?,
      notes: json['notes'] as String?,
      instructions: json['instructions'] as String?,
      iconColor: json['icon_color'] as String? ?? '0xFF20B2AA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'times': times,
      'start_date': startDate.toIso8601String().split('T').first,
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first,
      if (prescribedBy != null && prescribedBy!.isNotEmpty) 'prescribed_by': prescribedBy,
      if (instructions != null && instructions!.isNotEmpty) 'instructions': instructions,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'icon_color': iconColor,
    };
  }

  Medication copyWith({
    String? id, String? name, String? dose, List<String>? times,
    DateTime? startDate, DateTime? endDate, String? prescribedBy,
    String? notes, String? instructions, List<String>? interactions,
    int? daysSupply, DateTime? refillDate, String? iconColor,
  }) {
    return Medication(
      id: id ?? this.id, name: name ?? this.name, dose: dose ?? this.dose,
      times: times ?? this.times, startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate, prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes, instructions: instructions ?? this.instructions,
      interactions: interactions ?? this.interactions, daysSupply: daysSupply ?? this.daysSupply,
      refillDate: refillDate ?? this.refillDate, iconColor: iconColor ?? this.iconColor,
    );
  }
}

class MedicationDose {
  final String medicationId;
  final String medicationName;
  final String dose;
  final String time;
  final DateTime scheduledDate;
  bool isTaken;
  DateTime? takenAt;

  MedicationDose({
    required this.medicationId,
    required this.medicationName,
    required this.dose,
    required this.time,
    required this.scheduledDate,
    this.isTaken = false,
    this.takenAt,
  });

  bool get isMissed {
    if (isTaken) return false;
    final now = DateTime.now();
    final scheduled = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day,
        int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));
    return now.isAfter(scheduled.add(const Duration(hours: 1)));
  }

  bool get isDue {
    if (isTaken) return false;
    final now = DateTime.now();
    final scheduled = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day,
        int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));
    return now.isAfter(scheduled.subtract(const Duration(minutes: 30))) &&
        now.isBefore(scheduled.add(const Duration(hours: 1)));
  }
}
