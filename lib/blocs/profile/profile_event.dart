abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String email;

  LoadProfile({required this.email});
}

class UpdateProfile extends ProfileEvent {
  final String email;
  final String? name;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final String? activityLevel;

  UpdateProfile({
    required this.email,
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
  });
}
