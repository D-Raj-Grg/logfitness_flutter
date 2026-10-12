// One upcoming `class_sessions` row with its parent class's name and room.
//
// Hand-written rather than freezed on purpose (Phase 6 parallel work, no
// build_runner). Convert to freezed in a later codegen pass if wanted.
class ClassSession {
  const ClassSession({
    required this.id,
    required this.classId,
    required this.className,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedCount,
    this.room,
    this.description,
  });

  final String id;
  final String classId;
  final String className;
  final String? room;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;

  /// Seats held by `booked` rows only; waitlisted rows do not count.
  final int bookedCount;

  int get spotsLeft => (capacity - bookedCount).clamp(0, capacity);
  bool get isFull => bookedCount >= capacity;

  ClassSession copyWith({int? bookedCount}) => ClassSession(
    id: id,
    classId: classId,
    className: className,
    startsAt: startsAt,
    endsAt: endsAt,
    capacity: capacity,
    bookedCount: bookedCount ?? this.bookedCount,
    room: room,
    description: description,
  );

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    final cls = json['classes'] as Map<String, dynamic>?;
    return ClassSession(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      className: (cls?['name'] as String?) ?? 'Class',
      room: cls?['room'] as String?,
      description: cls?['description'] as String?,
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
      capacity: json['capacity'] as int,
      bookedCount: json['booked_count'] as int,
    );
  }
}
