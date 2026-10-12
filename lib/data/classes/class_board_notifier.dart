// Shared state behind the member Classes and Bookings screens, so a booking
// made on one is immediately visible on the other.
//
// Booking and cancelling are optimistic: the UI changes first, the RPC runs,
// and on failure the previous state is restored and the error rethrown for
// the screen to surface. After a success the board is re-read quietly so
// server truth (seat counts, waitlist promotion) replaces the guess.
//
// Plain (non-annotated) Riverpod on purpose: no codegen needed.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/classes/class_booking.dart';
import 'package:logfitness_flutter/data/classes/class_session.dart';
import 'package:logfitness_flutter/data/classes/classes_repository.dart';
import 'package:logfitness_flutter/domain/classes/class_booking_status.dart';

class ClassBoard {
  const ClassBoard({
    required this.sessions,
    required this.bookings,
    this.busy = const <String>{},
  });

  final List<ClassSession> sessions;
  final List<ClassBooking> bookings;

  /// Session ids and booking ids with a write in flight.
  final Set<String> busy;

  /// The caller's live (booked/waitlisted) booking on [sessionId], if any.
  ClassBooking? liveBookingFor(String sessionId) {
    for (final b in bookings) {
      if (b.sessionId == sessionId && b.status.isLive) return b;
    }
    return null;
  }

  ClassBoard copyWith({
    List<ClassSession>? sessions,
    List<ClassBooking>? bookings,
    Set<String>? busy,
  }) => ClassBoard(
    sessions: sessions ?? this.sessions,
    bookings: bookings ?? this.bookings,
    busy: busy ?? this.busy,
  );
}

class ClassBoardNotifier extends AsyncNotifier<ClassBoard> {
  ClassesRepository get _repo => ref.read(classesRepositoryProvider);

  @override
  Future<ClassBoard> build() => _load();

  Future<ClassBoard> _load() async {
    final results = await Future.wait<Object>([
      _repo.listUpcomingSessions(),
      _repo.listMyBookings(),
    ]);
    return ClassBoard(
      sessions: results[0] as List<ClassSession>,
      bookings: results[1] as List<ClassBooking>,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Re-read without flashing a spinner; keeps current data if it fails.
  Future<void> _quietReload() async {
    try {
      final fresh = await _load();
      final current = state.value;
      state = AsyncData(
        fresh.copyWith(busy: current?.busy ?? const <String>{}),
      );
    } catch (_) {
      // Optimistic state stays; the next manual refresh corrects it.
    }
  }

  void _setBusy(String id, bool on) {
    final current = state.value;
    if (current == null) return;
    final next = {...current.busy};
    on ? next.add(id) : next.remove(id);
    state = AsyncData(current.copyWith(busy: next));
  }

  /// Throws an [AppFailure] (already mapped) after rolling back.
  Future<ClassBookingStatus> book(ClassSession session) async {
    final before = state.value;
    if (before == null || before.busy.contains(session.id)) {
      throw StateError('Board not ready');
    }
    final willWait = session.isFull;
    final optimistic = ClassBooking(
      id: 'pending-${session.id}',
      sessionId: session.id,
      status: willWait
          ? ClassBookingStatus.waitlisted
          : ClassBookingStatus.booked,
      bookedAt: DateTime.now(),
      className: session.className,
      room: session.room,
      startsAt: session.startsAt,
      endsAt: session.endsAt,
    );
    state = AsyncData(
      before.copyWith(
        bookings: [optimistic, ...before.bookings],
        sessions: [
          for (final s in before.sessions)
            if (s.id == session.id && !willWait)
              s.copyWith(bookedCount: s.bookedCount + 1)
            else
              s,
        ],
        busy: {...before.busy, session.id},
      ),
    );
    try {
      final result = await _repo.book(session.id);
      await _quietReload();
      _setBusy(session.id, false);
      return result.status;
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }

  /// Throws an [AppFailure] (already mapped) after rolling back.
  Future<void> cancel(ClassBooking booking) async {
    final before = state.value;
    if (before == null || before.busy.contains(booking.id)) {
      throw StateError('Board not ready');
    }
    final freedSeat = booking.status == ClassBookingStatus.booked;
    state = AsyncData(
      before.copyWith(
        bookings: [
          for (final b in before.bookings)
            if (b.id == booking.id)
              b.copyWith(status: ClassBookingStatus.cancelled)
            else
              b,
        ],
        sessions: [
          for (final s in before.sessions)
            if (s.id == booking.sessionId && freedSeat && s.bookedCount > 0)
              s.copyWith(bookedCount: s.bookedCount - 1)
            else
              s,
        ],
        busy: {...before.busy, booking.id},
      ),
    );
    try {
      await _repo.cancel(booking.id);
      await _quietReload();
      _setBusy(booking.id, false);
    } catch (_) {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final classBoardProvider =
    AsyncNotifierProvider<ClassBoardNotifier, ClassBoard>(
      ClassBoardNotifier.new,
    );
