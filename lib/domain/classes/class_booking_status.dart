/// Mirrors the Postgres enum `class_booking_status`. Values must match exactly.
enum ClassBookingStatus {
  booked,
  waitlisted,
  cancelled,
  attended,
  noShow;

  static ClassBookingStatus fromDb(String value) => switch (value) {
    'booked' => booked,
    'waitlisted' => waitlisted,
    'cancelled' => cancelled,
    'attended' => attended,
    'no_show' => noShow,
    _ => throw FormatException('Unknown class_booking_status: $value'),
  };

  /// Holds a seat or a place in the queue.
  bool get isLive => this == booked || this == waitlisted;

  String get label => switch (this) {
    booked => 'Booked',
    waitlisted => 'Waitlisted',
    cancelled => 'Cancelled',
    attended => 'Attended',
    noShow => 'No-show',
  };
}
