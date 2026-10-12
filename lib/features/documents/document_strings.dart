// Every word a member reads on a printed document, in one place. English
// only, like `logfitness_saas/lib/print/strings.ts` (Nepali is a stated
// follow-up there too).
//
// House rules carried over: say the amount, never soften it ("Balance due",
// not "outstanding"); no accounting words a member would have to ask about --
// the registration fee that came off is "Registration fee off", never
// "waived".
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';

class DocumentStrings {
  const DocumentStrings();

  String get invoiceTitle => 'Invoice';
  String get receiptTitle => 'Payment receipt';
  String get refundTitle => 'Refund receipt';
  String get correctionTitle => 'Payment correction';

  String get billedTo => 'Billed to';
  String get issuedAt => 'Issued at';
  String get invoiceNo => 'Invoice no.';
  String get receiptNo => 'Receipt no.';
  String get issued => 'Issued';
  String get date => 'Date';
  String get soldBy => 'Sold by';
  String get method => 'Method';
  String get reference => 'Reference';
  String get receivedBy => 'Received by';
  String get refundedBy => 'Refunded by';
  String get correctedBy => 'Corrected by';

  String get description => 'Description';
  String get amount => 'Amount';
  String get membershipDues => 'Membership dues';
  String get openEnded => 'open ended';
  String validTo(String date) => 'valid to $date';
  String sessions(int count) => '$count sessions';

  String get registrationFee => 'Registration fee';
  String get registrationFeeOff => 'Registration fee off';
  String get alreadyPaidOnJoining => 'You paid this when you joined';
  String get coveredByPlan => 'Included in this plan price';

  String get subtotal => 'Subtotal';
  String get discount => 'Discount';
  String get total => 'Total';
  String get paid => 'Paid';
  String get balanceDue => 'Balance due';
  String get paidInFull => 'Paid in full';
  String get creditBalance => 'Credit balance';

  String get youSaved => 'You saved';

  String get amountReceived => 'Amount received';
  String get amountRefunded => 'Amount refunded';
  String get amountReversed => 'Amount reversed — never received';
  String get towards => 'Towards';
  String get againstInvoice => 'Against invoice';
  String get invoiceTotal => 'Invoice total';
  String get paidToDate => 'Paid to date';
  String get reason => 'Reason';

  String get paymentsReceived => 'Payments received';
  String get paymentsLimitedToBranch =>
      'Payment details are limited to your branch. '
      'The totals above are complete.';
  String get refundSuffix => 'refund';
  String get reversalSuffix => 'correction';

  String get computerGenerated => 'Computer generated. Valid without a stamp.';
  String get authorisedSignature => 'Authorised signature';
}

const DocumentStrings documentStrings = DocumentStrings();

/// What to call a discount on paper: the chosen reason, or what the desk typed
/// when they chose "Other". Falls back to the bare word for discounts sold
/// before reasons were captured. Mirrors `discountLabel` in `strings.ts`.
String discountLabel(DiscountReason? reason, String? note) {
  if (reason == null) return documentStrings.discount;
  if (reason == DiscountReason.other) {
    final String? trimmed = note?.trim();
    return (trimmed == null || trimmed.isEmpty)
        ? documentStrings.discount
        : trimmed;
  }
  return discountReasonLabel(reason);
}
