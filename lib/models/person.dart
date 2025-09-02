class Person {
  final int? id;
  final String name;
  final String? job;
  final String? bio;
  final int? parentId;

  Person({
    this.id,
    required this.name,
    this.job,
    this.bio,
    this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'bio': bio,
      'parentId': parentId,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      name: map['name'] as String,
      job: map['job'] as String?,
      bio: map['bio'] as String?,
      parentId: map['parentId'] as int?,
    );
  }
}