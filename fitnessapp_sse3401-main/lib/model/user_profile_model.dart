class UserProfileModel {
  String firstName;
  String lastName;
  String goal;
  String goalDetails;
  String height;
  String weight;
  String bmi;

  UserProfileModel({
    this.firstName = "",
    this.lastName = "",
    this.goal = "",
    this.goalDetails = "",
    this.height = "",
    this.weight = "",
    this.bmi = "",
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      firstName: map['firstName'] ?? "",
      lastName: map['lastName'] ?? "",
      goal: map['goal'] ?? "",
      goalDetails: map['goal_description'] ?? "",
      height: map['height'] ?? "",
      weight: map['weight'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'goal': goal,
      'goal_description': goalDetails,
      'height': height,
      'weight': weight,
    };
  }

  String calculateBMI() {
    try {
      double heightInM = double.parse(height) / 100;
      double weightInKg = double.parse(weight);
      double bmi = weightInKg / (heightInM * heightInM);
      return bmi.toStringAsFixed(1);
    } catch (e) {
      return "--";
    }
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }
}
