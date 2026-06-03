class GrowthEntry {
  final DateTime date;
  final int weight; // GR
  final int height;
  final int? headCircumference;
  final int? waistCircumference;

  GrowthEntry({
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.waistCircumference,
  });

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "weight": weight,
        "height": height,
        "headCircumference": headCircumference,
        "waistCircumference": waistCircumference,
      };

  factory GrowthEntry.fromJson(Map<String, dynamic> json) {
    return GrowthEntry(
      date: DateTime.parse(json["date"]),
      weight: json["weight"], // GR
      height: json["height"],
      headCircumference: json["headCircumference"],
      waistCircumference: json["waistCircumference"],
    );
  }
}
