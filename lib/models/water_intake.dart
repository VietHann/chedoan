class WaterIntake {
  final String? id;
  final DateTime date;
  final int amount;  // in ml
  final DateTime createdAt;

  WaterIntake({
    this.id,
    required this.date,
    required this.amount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    DateTime parsedCreatedAt;
    if (map['createdAt'] is String) {
      try {
        parsedCreatedAt = DateTime.parse(map['createdAt']);
      } catch (_) {
        parsedCreatedAt = DateTime.now();
      }
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return WaterIntake(
      id: map['id'],
      date: parsedDate,
      amount: map['amount'] ?? 0,
      createdAt: parsedCreatedAt,
    );
  }
}