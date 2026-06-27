class FriendProfile {
  final String id;
  final String displayName;
  final String? username;
  final String? bio;
  final String? photoUrl;
  final String? friendStatus; // 'active', 'pending', null

  FriendProfile({
    required this.id,
    required this.displayName,
    this.username,
    this.bio,
    this.photoUrl,
    this.friendStatus,
  });

  factory FriendProfile.fromJson(Map<String, dynamic> json) {
    return FriendProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      friendStatus: json['friend_status'] as String?,
    );
  }

  FriendProfile copyWith({String? friendStatus}) {
    return FriendProfile(
      id: id,
      displayName: displayName,
      username: username,
      bio: bio,
      photoUrl: photoUrl,
      friendStatus: friendStatus ?? this.friendStatus,
    );
  }
}

class FeedPost {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final DateTime date;
  final String? time;
  final String? restaurantName;
  final String? branchName;
  final double? price;
  final String? heaviness;
  final String? feeling;
  final String? note;
  final List<String> foods;
  final String? thumbnailUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final List<CommentPreview> recentComments;

  FeedPost({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.date,
    this.time,
    this.restaurantName,
    this.branchName,
    this.price,
    this.heaviness,
    this.feeling,
    this.note,
    required this.foods,
    this.thumbnailUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.recentComments = const [],
  });
}

class CommentPreview {
  final String userId;
  final String displayName;
  final String body;
  final String createdAt;

  CommentPreview({
    required this.userId,
    required this.displayName,
    required this.body,
    required this.createdAt,
  });
}
