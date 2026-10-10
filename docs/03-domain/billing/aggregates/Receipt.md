# Receipt

## Purpose

Receipt represents the official acknowledgement of a successfully recorded Payment.

It provides documentary evidence that a Payment has been received by the Business.

Every Receipt SHALL correspond to exactly one successfully recorded Payment.

---

# Responsibilities

Receipt SHALL be responsible for:

- Acknowledging receipt of a Payment.
- Maintaining receipt information.
- Providing evidence of payment.
- Supporting financial record keeping.

Receipt SHALL NOT be responsible for:

- Recording Payments.
- Managing Invoice lifecycle.
- Calculating financial values.
- Managing Customer information.

---

# Business Rules

Receipt SHALL enforce the following Business Rules:

- Every Receipt SHALL correspond to exactly one Payment.
- A Receipt SHALL only be generated for a successfully recorded Payment.
- Receipt identity SHALL remain immutable.
- Receipt content SHALL accurately reflect the recorded Payment.

---

# State

Receipt maintains:

- Its identity.
- Document Number.
- Associated Payment.
- Associated Invoice.
- Receipt Date.
- Receipt Amount.

Additional receipt information MAY be maintained according to business requirements.

---

# Operations

Receipt supports the following business operations:

- Generate Receipt.
- Retrieve Receipt.
- Verify Receipt.

Receipt SHALL NOT support editing.

A Receipt, once generated, is immutable.

## No Correction Operations in Version 1

Version 1 defines no Receipt correction, reversal, or voiding operations.

If a Receipt is incorrect because of an underlying Payment error, Version 1 provides no corrective mechanism.

The Receipt remains as a historical record.

The underlying Payment is also immutable.

Payment and Receipt correction are reserved for a future version.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

Direct correction of a Receipt is not permitted.

---

# Invariants

The following conditions SHALL always hold:

- Every Receipt corresponds to one Payment.
- Receipt Amount equals the recorded Payment Amount.
- Receipt identity remains immutable.
- Receipt SHALL never exist without its associated Payment.
- Receipt SHALL NOT be modified after generation.
- A Receipt SHALL NOT be corrected, reversed, or voided in Version 1.

---

# Aggregate Ownership

## Owned Concepts

Receipt owns no other Domain concepts.

See [[03-domain/Aggregate-Map|Aggregate Map]] for the full map of Aggregates and their reference directions.

---

## Referenced Concepts

Receipt references:

- [[03-domain/billing/aggregates components/Payment|Payment]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]

Receipt SHALL NOT own either concept.

---

## Referenced By

No other Billing Aggregate depends upon Receipt for business consistency.

Receipt primarily serves reporting, auditing, and documentary purposes.

---

# Collaborators

Receipt collaborates with:

- [[03-domain/billing/aggregates components/Payment|Payment]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates/Customer|Customer]]

Receipt SHALL remain responsible only for documenting completed Payments.

---

# Dependencies

Receipt depends upon:

Shared Concepts

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Result|Result]]
- [[DomainError]]

Billing Concepts

- [[03-domain/billing/aggregates components/Payment|Payment]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]

Receipt SHALL NOT depend upon:

- Payment processing
- PDF rendering
- Persistence
- User Interface

---

# Validation

Receipt validates:

- Payment association.
- Receipt integrity.
- Receipt amount consistency.
- Receipt uniqueness.

Validation SHALL preserve documentary consistency.

---

# Failure Cases

Expected business failures include:

- Payment not found.
- Payment not successfully recorded.
- Duplicate Receipt Document Number.
- Receipt generation not permitted.

---

# Related Requirements

Functional Requirements

- Receipt Generation
- Receipt Management

Business Rules

- [[01-Requirements/billing/Receipt#BR-REC-001|BR-REC-001]] to [[01-Requirements/billing/Receipt#BR-REC-009|BR-REC-009]]
- [[01-Requirements/billing/Payment#BR-PAY-007|BR-PAY-007]]

Business Policies

- BP-PDF-001

Architecture

- Validation Strategy
- Error Handling Strategy

---

# Design Rationale

Receipt is an independent Aggregate. It represents documentary evidence of a successfully recorded Payment.

A Receipt acknowledges an existing Payment. It does not create or modify financial obligations.

Receipts are immutable after generation. This preserves their evidentiary value and reflects the fact that the underlying Payment is also immutable.

Corrections require correcting the underlying Payment (or issuing a new Payment if the original was wrong), then generating a new Receipt. This keeps the audit trail clean: every Receipt matches exactly one Payment, and every Payment has a clear history.

Receipt references the Payment and the related Invoice. It does not own either concept.

---

# Future Considerations

Future versions MAY introduce:

- Receipt cancellation.
- Digital signatures.
- QR code verification.
- Electronic receipt delivery.
- Multiple receipt templates.

Such additions SHALL preserve Receipt as an immutable acknowledgement of a successfully recorded Payment.