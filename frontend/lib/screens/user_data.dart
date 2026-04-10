class UserData {
  String name;
  String email;
  String bloodType;
  int age;
  double height;  // in cm
  double weight;  // in kg

  // Backend fields — null when running in offline-only mode
  int? backendId;   // user.id returned by the backend
  String? token;    // auth token returned by backend login/register

  // Health vitals
  int? heartRate;  // bpm
  int? systolic;   // blood pressure
  int? diastolic;  // blood pressure
  double? bloodSugar;  // mg/dL fasting
  double? postMealSugar;  // mg/dL post-meal
  double? bodyTemp;  // °C
  int? spo2;  // %

  UserData({
    this.name = 'John Doe',
    this.email = 'john.doe@example.com',
    this.bloodType = 'O+',
    this.age = 32,
    this.height = 175.0,
    this.weight = 70.0,
    this.backendId,
    this.token,
    this.heartRate,
    this.systolic,
    this.diastolic,
    this.bloodSugar,
    this.postMealSugar,
    this.bodyTemp,
    this.spo2,
  });

  UserData copyWith({
    String? name,
    String? email,
    String? bloodType,
    int? age,
    double? height,
    double? weight,
    int? backendId,
    String? token,
    int? heartRate,
    int? systolic,
    int? diastolic,
    double? bloodSugar,
    double? postMealSugar,
    double? bodyTemp,
    int? spo2,
  }) {
    return UserData(
      name: name ?? this.name,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      backendId: backendId ?? this.backendId,
      token: token ?? this.token,
      heartRate: heartRate ?? this.heartRate,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      postMealSugar: postMealSugar ?? this.postMealSugar,
      bodyTemp: bodyTemp ?? this.bodyTemp,
      spo2: spo2 ?? this.spo2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bloodType': bloodType,
      'age': age,
      'height': height,
      'weight': weight,
      'backendId': backendId,
      'token': token,
      'heartRate': heartRate,
      'systolic': systolic,
      'diastolic': diastolic,
      'bloodSugar': bloodSugar,
      'postMealSugar': postMealSugar,
      'bodyTemp': bodyTemp,
      'spo2': spo2,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] ?? 'John Doe',
      email: json['email'] ?? 'john.doe@example.com',
      bloodType: json['bloodType'] ?? 'O+',
      age: json['age'] ?? 32,
      height: (json['height'] ?? 175.0).toDouble(),
      weight: (json['weight'] ?? 70.0).toDouble(),
      backendId: json['backendId'] as int?,
      token: json['token'] as String?,
      heartRate: json['heartRate'],
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      bloodSugar: json['bloodSugar']?.toDouble(),
      postMealSugar: json['postMealSugar']?.toDouble(),
      bodyTemp: json['bodyTemp']?.toDouble(),
      spo2: json['spo2'],
    );
  }

  // Calculate BMI from the user data
  double calculateBMI() {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}
