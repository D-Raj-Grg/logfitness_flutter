// The collection sheet's one non-negotiable property: a refund and a
// reversal are never folded into the takings, and never into each other.
//
// A refund says cash left the drawer. A reversal says a note that was rung up
// never arrived. A branch that is 20,000 short has a different problem in each
// case, and a single net figure hides which.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/payments/collection_sheet_screen.dart';

DailyCollectionRow _row({
  String branchId = 'branch-1',
  String branchName = 'Thamel',
  String? staffId = 'staff-1',
  String? staffName = 'Sita',
  PaymentMethod method = PaymentMethod.cash,
  PaymentKind kind = PaymentKind.payment,
  int txnCount = 1,
  required int amountPaisa,
}) => DailyCollectionRow(
  branchId: branchId,
  branchName: branchName,
  staffId: staffId,
  staffName: staffName,
  method: method,
  kind: kind,
  txnCount: txnCount,
  amountPaisa: amountPaisa,
);

void main() {
  test('an empty day groups to nothing', () {
    expect(groupCollection(const <DailyCollectionRow>[]), isEmpty);
  });

  test('payments, refunds and reversals stay three separate figures', () {
    final List<BranchCollection> groups = groupCollection(<DailyCollectionRow>[
      _row(amountPaisa: 1000000, txnCount: 4),
      // The RPC returns both of these negative.
      _row(kind: PaymentKind.refund, amountPaisa: -250000),
      _row(kind: PaymentKind.reversal, amountPaisa: -150000),
    ]);

    expect(groups, hasLength(1));
    final BranchCollection branch = groups.single;

    expect(branch.collectedPaisa, 1000000);
    expect(branch.refundedPaisa, -250000);
    expect(branch.neverReceivedPaisa, -150000);

    // The net is derived from the three, so the four figures on screen can
    // never disagree with one another.
    expect(branch.netPaisa, 600000);
    expect(
      branch.netPaisa,
      branch.collectedPaisa +
          branch.refundedPaisa +
          branch.neverReceivedPaisa,
    );
  });

  test('a refund is not counted as a reversal, and vice versa', () {
    final BranchCollection refundsOnly = groupCollection(<DailyCollectionRow>[
      _row(amountPaisa: 500000),
      _row(kind: PaymentKind.refund, amountPaisa: -500000),
    ]).single;

    final BranchCollection reversalsOnly = groupCollection(<DailyCollectionRow>[
      _row(amountPaisa: 500000),
      _row(kind: PaymentKind.reversal, amountPaisa: -500000),
    ]).single;

    // Identical nets, different stories. This is exactly the pair a single
    // "net collected" number would make indistinguishable.
    expect(refundsOnly.netPaisa, reversalsOnly.netPaisa);
    expect(refundsOnly.refundedPaisa, -500000);
    expect(refundsOnly.neverReceivedPaisa, 0);
    expect(reversalsOnly.refundedPaisa, 0);
    expect(reversalsOnly.neverReceivedPaisa, -500000);
  });

  test('every kind keeps its own detail line rather than being merged', () {
    final BranchCollection branch = groupCollection(<DailyCollectionRow>[
      _row(amountPaisa: 500000),
      _row(kind: PaymentKind.refund, amountPaisa: -100000),
      _row(kind: PaymentKind.reversal, amountPaisa: -50000),
    ]).single;

    expect(branch.collectors, hasLength(1));
    expect(branch.collectors.single.rows, hasLength(3));
    expect(
      branch.collectors.single.rows.map((DailyCollectionRow r) => r.kind),
      containsAll(<PaymentKind>[
        PaymentKind.payment,
        PaymentKind.refund,
        PaymentKind.reversal,
      ]),
    );
  });

  test('branches and collectors are grouped and named in order', () {
    final List<BranchCollection> groups = groupCollection(<DailyCollectionRow>[
      _row(branchId: 'b-2', branchName: 'Patan', amountPaisa: 100000),
      _row(staffId: 'staff-2', staffName: 'Anil', amountPaisa: 200000),
      _row(amountPaisa: 300000),
    ]);

    expect(
      groups.map((BranchCollection b) => b.branchName),
      <String>['Patan', 'Thamel'],
    );
    final BranchCollection thamel = groups.last;
    expect(
      thamel.collectors.map((CollectorLines c) => c.staffName),
      <String>['Anil', 'Sita'],
    );
    expect(thamel.collectedPaisa, 500000);
  });

  test('a row with no collector is kept, not dropped', () {
    // A payment whose collector was removed, or one taken by a function, is a
    // real row and real money.
    final BranchCollection branch = groupCollection(<DailyCollectionRow>[
      _row(staffId: null, staffName: null, amountPaisa: 400000),
    ]).single;

    expect(branch.collectors, hasLength(1));
    expect(branch.collectors.single.staffId, isNull);
    expect(branch.collectedPaisa, 400000);
  });

  test('transaction counts are summed per collector and per branch', () {
    final BranchCollection branch = groupCollection(<DailyCollectionRow>[
      _row(amountPaisa: 100000, txnCount: 3),
      _row(
        method: PaymentMethod.esewa,
        amountPaisa: 200000,
        txnCount: 2,
      ),
      _row(
        staffId: 'staff-2',
        staffName: 'Anil',
        amountPaisa: 50000,
        txnCount: 1,
      ),
    ]).single;

    expect(branch.txnCount, 6);
    expect(branch.collectors.first.txnCount, 1); // Anil sorts first
    expect(branch.collectors.last.txnCount, 5);
    expect(branch.collectors.last.netPaisa, 300000);
  });
}
