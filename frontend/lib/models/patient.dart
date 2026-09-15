class Patient {
  final String? id;
  final String? abhaId;
  final String? name;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? bloodGroup;
  final List<String>? allergies;
  final String? emergencyContact;
  final bool? isMinor;
  final String? guardianName;
  final String? guardianPhone;
  final String? preferredLanguage;

  const Patient({
    this.id,
    this.abhaId,
    this.name,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.bloodGroup,
    this.allergies,
    this.emergencyContact,
    this.isMinor,
    this.guardianName,
    this.guardianPhone,
    this.preferredLanguage,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String?,
        abhaId: json['abhaId'] as String?,
        name: json['fullName'] as String? ?? json['name'] as String?,
        phone: json['phone'] as String?,
        gender: json['gender'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'] as String)
            : null,
        address: json['address'] as String?,
        bloodGroup: json['bloodGroup'] as String?,
        allergies: (json['allergies'] as List?)?.cast<String>(),
        emergencyContact: json['emergencyContact'] as String?,
        isMinor: json['isMinor'] as bool?,
        guardianName: json['guardianName'] as String?,
        guardianPhone: json['guardianPhone'] as String?,
        preferredLanguage: json['preferredLanguage'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'abhaId': abhaId,
        'fullName': name,
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'address': address,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'emergencyContact': emergencyContact,
        'isMinor': isMinor,
        'guardianName': guardianName,
        'guardianPhone': guardianPhone,
        'preferredLanguage': preferredLanguage,
      };

  Patient copyWith({
    String? id,
    String? abhaId,
    String? name,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? bloodGroup,
    List<String>? allergies,
    String? emergencyContact,
    bool? isMinor,
    String? guardianName,
    String? guardianPhone,
    String? preferredLanguage,
  }) =>
      Patient(
        id: id ?? this.id,
        abhaId: abhaId ?? this.abhaId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        address: address ?? this.address,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        allergies: allergies ?? this.allergies,
        emergencyContact: emergencyContact ?? this.emergencyContact,
        isMinor: isMinor ?? this.isMinor,
        guardianName: guardianName ?? this.guardianName,
        guardianPhone: guardianPhone ?? this.guardianPhone,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      );
}