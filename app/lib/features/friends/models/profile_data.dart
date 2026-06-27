class ProfileData {
  final String displayName;
  final String? username;
  final String? bio;
  final String? photoUrl;
  final String? coverUrl;
  final int totalMeals;
  final int monthMeals;
  final int monthFoods;
  final int monthRestaurants;
  final int friendsCount;

  ProfileData({
    required this.displayName,
    this.username,
    this.bio,
    this.photoUrl,
    this.coverUrl,
    required this.totalMeals,
    required this.monthMeals,
    required this.monthFoods,
    required this.monthRestaurants,
    this.friendsCount = 0,
  });
}
