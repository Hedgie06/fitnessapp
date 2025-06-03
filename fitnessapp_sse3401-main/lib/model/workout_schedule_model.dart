class WorkoutScheduleModel {
  String? id;
  String? userId;
  String? workoutName;
  String? difficulty;
  DateTime? dateTime;
  int? repetitions;
  double? weights;
  bool? isCompleted;

  WorkoutScheduleModel({
    this.id,
    this.userId,
    this.workoutName,
    this.difficulty,
    this.dateTime,
    this.repetitions,
    this.weights,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workoutName': workoutName,
      'difficulty': difficulty,
      'dateTime': dateTime?.toIso8601String(),
      'repetitions': repetitions,
      'weights': weights,
      'isCompleted': isCompleted,
    };
  }

  static WorkoutScheduleModel fromMap(Map<String, dynamic> map) {
    return WorkoutScheduleModel(
      id: map['id'],
      userId: map['userId'],
      workoutName: map['workoutName'],
      difficulty: map['difficulty'],
      dateTime: DateTime.parse(map['dateTime']),
      repetitions: map['repetitions'],
      weights: map['weights'],
      isCompleted: map['isCompleted'],
    );
  }
}
