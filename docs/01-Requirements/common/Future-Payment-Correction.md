# Future Payment Correction Model

## Purpose

Version 1 does not support Payment correction, reversal, or voiding.

This document records the requirements anticipated for a future version of the Finance Management System.

It does NOT affect Version 1 behavior.

Its purpose is to preserve design intent so that Payment correction can be introduced in Version 2 without disrupting the existing Domain model.

---

# Version 1 Boundary

Version 1 SHALL NOT support Payment correction, reversal, or voiding.

A recorded Payment is final.

A Receipt is final once generated.

See [[01-Requirements/common/Constraints#CON-PAY-001|CON-PAY-001]].

Version 1 users SHALL be informed of this limitation at onboarding and in user documentation.

See [[01-Requirements/billing/Payment#BR-PAY-011|BR-PAY-011]].

---

# Rationale

Payment correction is inherently complex in any system that preserves historical financial records.

The complexity arises from coordination across multiple concerns:

- Invoice Balance recalculation
- Invoice Status reversal
- Customer Credit balance adjustment (when overpayment was involved)
- Receipt semantics
- Reporting and audit consistency
- Review and authorization workflow (in multi-user scenarios)

Designing Payment correction properly requires resolved decisions on all of the above.

Version 1 does not commit to those decisions.

Payment correction is therefore designed as a Version 2 feature with the benefit of real-world usage data from Version 1.

---

# Anticipated Concepts

Future versions MAY introduce:

- Payment Wrong Status
- Payment Correction (a new Payment referencing the original)
- Payment Reversal
- Payment Void
- Receipt Void
- Invoice Status Reversal
- Customer Credit Reversal
- Correction Reason (mandatory)
- Correction Flag (for review)

Each concept SHALL be introduced only when justified by demonstrated business need.

---

# Anticipated Scenarios

## Scenario 1 — Wrong Amount Recorded

A Payment was recorded for 500 KES instead of 5000 KES.

Anticipated resolution: mark the original Payment Wrong with a mandatory reason; record a new Payment for the correct amount.

## Scenario 2 — Wrong Payment Method

A Payment was recorded as Cash instead of Mobile Money.

Anticipated resolution: mark the original Payment Wrong; record a new Payment with the correct method.

## Scenario 3 — Wrong Invoice

A Payment was recorded against the wrong Invoice.

Anticipated resolution: mark the original Payment Wrong; record a new Payment against the correct Invoice.

## Scenario 4 — Wrong Customer

A Payment was recorded against the wrong Customer.

Anticipated resolution: mark the original Payment Wrong; record a new Payment against the correct Customer.

## Scenario 5 — Duplicate Payment

A Payment was recorded twice by mistake.

Anticipated resolution: mark one of the duplicate Payments Wrong.

## Scenario 6 — Reversed Payment

A customer's cheque bounced after the Payment was recorded.

Anticipated resolution: record a Payment Reversal (or mark the Payment Wrong with a reversal reason).

Each scenario may require slightly different handling.

The final design SHALL address each scenario explicitly.

---

# Anticipated Rules

## R1 — Immutability Preserved

Payment correction SHALL NOT modify the original Payment.

The original Payment remains as a historical record.

Correction SHALL be recorded as a new Payment that references the original.

## R2 — Mandatory Reason

Every correction Payment SHALL carry a mandatory reason.

The reason SHALL describe why the correction was made.

## R3 — Invoice Balance Recalculation

Invoice Balance SHALL exclude Wrong Payments when calculated.

Invoice Balance SHALL include correction Payments.

## R4 — Invoice Status Reversal

Marking a Payment Wrong MAY require the Invoice Status to revert.

Example: an Invoice at Paid status may revert to Partially Paid or Issued.

The exact reversal rules SHALL be defined before implementation.

## R5 — Customer Credit Reversal

If the original Payment generated Customer Credit (via overpayment handling), that Credit SHALL be adjusted accordingly.

The exact reversal rules SHALL be defined before implementation.

## R6 — Receipt Handling

Receipts for corrected Payments SHALL remain as historical records.

Whether a Receipt is marked Void or left untouched SHALL be decided during design.

## R7 — Review Workflow

In multi-user scenarios, corrections MAY require authorization.

Version 1's single-user assumption means review workflow is deferred.

When multi-user support is added, corrections SHALL participate in the authorization model.

See [[01-Requirements/common/Future-Authorization|Future Authorization Model]].

---

# Anticipated Impact on Existing Concepts

## Payment

Payment MAY gain:

- A status field (Active / Wrong)
- An optional reference to a correction Payment
- A mandatory correction reason (when Wrong)
- A timestamp (when marked Wrong)

## Receipt

Receipt MAY gain:

- A status field (Active / Void)

## Invoice

Invoice Balance calculation MAY change to exclude Wrong Payments.

Invoice Status lifecycle MAY need to support reversal.

## Customer Credit

Customer Credit adjustment logic MAY be required when overpayment-based credit is reversed.

## Reporting

Reports MAY need to distinguish Active Payments from Wrong Payments.

---

# Architectural Considerations

## Domain Impact

Payment correction is a Domain concern.

The Domain SHALL define the correction rules.

The Application layer SHALL coordinate cross-Aggregate changes when required.

## Audit Impact

Payment correction SHALL preserve structural auditability.

Original Payments SHALL NOT be modified.

Correction Payments SHALL be immutable once recorded.

## Migration Impact

Version 1 installations have no correction mechanisms.

When Version 2 is introduced, no historical correction data exists to migrate.

Existing Payments remain valid.

---

# Design Constraints

## DC-1 — Immutability

Payment correction SHALL NOT introduce mutability into Payment or Receipt.

## DC-2 — Audit Preservation

Corrections SHALL preserve the full history.

Original Payments SHALL remain visible.

## DC-3 — Aggregate Consistency

Corrections SHALL respect Aggregate boundaries.

Cross-Aggregate coordination SHALL occur through the Application layer.

See [[03-domain/Aggregate-Map#Rule 2 — Aggregate Consistency and Cross-Aggregate Operations|Aggregate Map — Rule 2]].

## DC-4 — Incremental Introduction

Correction features SHALL be introduced incrementally, not all at once.

Simpler corrections (amount, method) MAY precede complex ones (reversal, wrong customer).

---

# Design Decisions Required

Before Version 2 implementation:

1. Can a Wrong Payment be un-marked?
2. Does marking a Payment Wrong require authorization?
3. What is the exact Invoice Status reversal behavior?
4. How is Customer Credit reversed when the original Payment generated it?
5. Is a Receipt for a Wrong Payment marked Void, or left untouched?
6. Can a Payment be corrected more than once?
7. Can a correction Payment reference multiple original Payments?
8. How does reporting distinguish Active vs. Wrong Payments?

Each decision SHALL be documented in an ADR when Version 2 is designed.

---

# Evolution

This document SHALL evolve as Payment correction requirements become concrete.

Payment correction SHALL NOT be introduced until:

- Real-world usage patterns from Version 1 are available.
- Design decisions are documented in ADRs.
- The Domain model changes are reviewed for consistency with existing invariants.

---

# Related Documents

- [[01-Requirements/billing/Payment|Payment Business Rules]]
- [[01-Requirements/billing/Receipt|Receipt Business Rules]]
- [[03-domain/billing/aggregates components/Payment|Payment Aggregate Component]]
- [[03-domain/billing/aggregates/Receipt|Receipt Aggregate]]
- [[02-architecture/Audit-Strategy|Audit Strategy]]
- [[01-Requirements/common/Future-Authorization|Future Authorization Model]]
- [[01-Requirements/common/Constraints|Constraints]]