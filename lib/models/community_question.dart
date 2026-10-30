class CommunityQuestion {
  final int id;
  final int userId;
  final String userName;
  final String? userPhoto;
  final String title;
  final String description;
  final List<String>? tags;
  final int views;
  final int answersCount;
  final DateTime createdAt;
  final int votesSum;
  final int userVote; // 1, -1, or 0
  final List<CommunityAnswer> answers;

  bool get isAnswered => answersCount > 0;

  CommunityQuestion({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.title,
    required this.description,
    this.tags,
    required this.views,
    required this.answersCount,
    required this.createdAt,
    this.votesSum = 0,
    this.userVote = 0,
    this.answers = const [],
  });

  factory CommunityQuestion.fromJson(Map<String, dynamic> json) {
    var tagsFromJson = json['tags'];
    List<String>? tagsList;
    if (tagsFromJson != null) {
      if (tagsFromJson is List) {
        tagsList = List<String>.from(tagsFromJson);
      } else if (tagsFromJson is String) {
        tagsList = [tagsFromJson];
      }
    }

    return CommunityQuestion(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: json['user']?['name'] ?? 'Unknown',
      userPhoto: json['user']?['profile_photo'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: tagsList,
      views: _parseInt(json['views']),
      answersCount: _parseInt(json['answers_count']),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      votesSum: _parseInt(json['votes_sum_vote']),
      userVote: (json['votes'] != null && (json['votes'] as List).isNotEmpty)
          ? _parseInt(json['votes'][0]['vote'])
          : 0,
      answers: json['answers'] != null
          ? (json['answers'] as List)
                .map((i) => CommunityAnswer.fromJson(i))
                .toList()
          : [],
    );
  }
}

class CommunityAnswer {
  final int id;
  final int userId;
  final String userName;
  final String? userPhoto;
  final int questionId;
  final String content;
  final bool isAccepted;
  final int votesSum;
  final int userVote;
  final DateTime createdAt;

  CommunityAnswer({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.questionId,
    required this.content,
    required this.isAccepted,
    this.votesSum = 0,
    this.userVote = 0,
    required this.createdAt,
  });

  factory CommunityAnswer.fromJson(Map<String, dynamic> json) {
    return CommunityAnswer(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      userName: json['user']?['name'] ?? 'Unknown',
      userPhoto: json['user']?['profile_photo'],
      questionId: _parseInt(json['question_id']),
      content: json['content'] ?? '',
      isAccepted:
          json['is_accepted'] == true ||
          json['is_accepted'] == 1 ||
          json['is_accepted']?.toString() == '1',
      votesSum: _parseInt(json['votes_sum_vote']),
      userVote: (json['votes'] != null && (json['votes'] as List).isNotEmpty)
          ? _parseInt(json['votes'][0]['vote'])
          : 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
