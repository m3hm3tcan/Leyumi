class BabyProfile {
  final String name;
  final String gender;
  final DateTime birthDate;
  final int weight; // GR
  final int height;
  final int? headCircumference;
  final int? waistCircumference;

  BabyProfile({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.waistCircumference,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "gender": gender,
        "birthDate": birthDate.toIso8601String(),
        "weight": weight,
        "height": height,
        "headCircumference": headCircumference,
        "waistCircumference": waistCircumference,
      };

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      name: json["name"],
      gender: json["gender"],
      birthDate: DateTime.parse(json["birthDate"]),
      weight: json["weight"], // GR
      height: json["height"],
      headCircumference: json["headCircumference"],
      waistCircumference: json["waistCircumference"],
    );
  }
}
