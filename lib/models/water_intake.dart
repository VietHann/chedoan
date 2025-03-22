class WaterIntake {
  final String? id;
  final DateTime date;
  final int amount; // in ml
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
      'date': date.toIso8601String().split('T')[0], // Store just the date
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    // Parse date
    DateTime parsedDate;
    if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      // Default to today if cannot parse
      parsedDate = DateTime.now();
    }

    // Parse created_at
    DateTime parsedCreatedAt;
    if (map['created_at'] is String) {
      try {
        parsedCreatedAt = DateTime.parse(map['created_at']);
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

  WaterIntake copyWith({
    String? id,
    DateTime? date,
    int? amount,
    DateTime? createdAt,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}