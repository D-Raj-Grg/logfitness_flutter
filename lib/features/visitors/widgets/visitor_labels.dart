// The words the visitor log uses, in one place.
//
// These match `logfitness_saas/components/visitors/visitors-table.tsx`
// deliberately. `converted` reads as "Joined" and `lost` as "Not joining" on
// both surfaces, because the desk staff reading the phone and the manager
// reading the console are discussing the same person, and the enum name is
// not what either of them calls it. Changing a label here without changing it
// there is how the two clients start describing the same row differently.
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

String visitorStatusLabel(VisitorStatus status) => switch (status) {
      VisitorStatus.isNew => 'New',
      VisitorStatus.contacted => 'Contacted',
      VisitorStatus.converted => 'Joined',
      VisitorStatus.lost => 'Not joining',
    };

String visitorKindLabel(VisitorKind kind) => switch (kind) {
      VisitorKind.enquiry => 'Enquiry',
      VisitorKind.guest => 'Guest',
    };

String visitorStatusFilterLabel(VisitorStatusFilterName name) =>
    switch (name) {
      VisitorStatusFilterName.open => 'Needs a call',
      VisitorStatusFilterName.isNew => 'New',
      VisitorStatusFilterName.contacted => 'Contacted',
      VisitorStatusFilterName.converted => 'Joined',
      VisitorStatusFilterName.lost => 'Not joining',
      VisitorStatusFilterName.all => 'All',
    };

/// The filter chips the log offers, in the order they are shown. `open` leads
/// because it is the only filter that shrinks as the log grows — it is the
/// work, where the rest are the archive.
enum VisitorStatusFilterName { open, isNew, contacted, converted, lost, all }
