class Candidate {
  String id;
  String name;
  String voting;
  String createdAt;
  String updatedAt;
  String? description;
  String? image;
  int votes;

  Candidate({
    required this.id,
    required this.name,
    required this.voting,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.image,
    required this.votes,
  });

  static Candidate fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['_id'],
      name: json['name'],
      voting: json['voting'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      description: json['description'],
      image: json['image'],
      votes: json['votes'],
    );
  }
}
