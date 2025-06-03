class UserModel {
  String? uid;
  String? name;
  String? email;
  String? height;
  String? weight;
  String? goal;
  String? bmi;
  String? bmiStatus;
  DateTime? lastBmiUpdate;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.height,
    this.weight,
    this.goal,
    this.bmi,
    this.bmiStatus,
    this.lastBmiUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'goal': goal,
      'bmi': bmi,
      'bmiStatus': bmiStatus,
      'lastBmiUpdate': lastBmiUpdate?.toIso8601String(),
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      height: map['height'],
      weight: map['weight'],
      goal: map['goal'],
      bmi: map['bmi'],
      bmiStatus: map['bmiStatus'],
      lastBmiUpdate: map['lastBmiUpdate'] != null
          ? DateTime.parse(map['lastBmiUpdate'])
          : null,
    );
  }
}
