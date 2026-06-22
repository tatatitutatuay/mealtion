class ProfileData {
  final String displayName;
  final String? username;
  final String? bio;
  final String? photoUrl;
  final int totalMeals;
  final int monthMeals;
  final int monthFoods;
  final int monthRestaurants;

  ProfileData({
    required this.displayName,
    this.username,
    this.bio,
    this.photoUrl,
    required this.totalMeals,
    required this.monthMeals,
    required this.monthFoods,
    required this.monthRestaurants,
  });
}
