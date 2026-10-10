# Payment

## Purpose

Payment represents the settlement of all or part of an Invoice's outstanding financial obligation.

A Payment records the transfer of monetary value from a Customer to a Business.

Every Payment SHALL be associated with exactly one Invoice.

---

# Responsibilities

Payment SHALL be responsible for:

- Representing a financial payment.
- Recording the payment amount.
- Recording the payment date.
- Recording the payment method.
- Recording payment references where applicable.
- Preserving payment integrity.

Payment SHALL NOT be responsible for:

- Managing Invoice lifecycle.
- Calculating Invoice totals.
- Generating Receipts.
- Managing Business or Customer information.

---

# Business Rules

Payment SHALL enforce the following Business Rules:

- Every Payment belongs to exactly one Invoice.
- Payment Amount SHALL be greater than zero.
- Payment Currency SHALL match the Invoice Currency.
- Payment SHALL comply with the configured Overpayment Policy.
- Successfully recorded Payments SHALL be immutable.

---

# State

Payment maintains:

- Its identity.
- The associated Invoice.
- Payment Amount.
- Payment Method.
- Payment Date.
- Payment Reference (where applicable).

Additional information MAY be maintained according to business requirements.

---

# Operations

Payment supports the following business operations:

- Record Payment.
- Validate Payment.
- Verify Payment Reference.

Payment operations SHALL preserve financial consistency.

---

# Invariants

The following conditions SHALL always hold:

- Every Payment belongs to one Invoice.
- Payment Amount is greater than zero.
- Payment Currency matches the Invoice Currency.
- Recorded Payments remain immutable.

---

# Aggregate Ownership

## Owned Concepts

Payment owns no other Domain concepts.

---

## Referenced Concepts

Payment references:

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/shared/Money|Money]]

Payment SHALL NOT own either concept.

---

## Referenced By

Payment is referenced by:

- [[03-domain/billing/aggregates/Receipt|Receipt]]

A Receipt documents a successfully recorded Payment.

---
# Collaborators

Payment collaborates with:

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates/Receipt|Receipt]]
- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/shared/Money|Money]]
- [[Payment-Method]]

Each collaborator fulfills a distinct business responsibility.

Payment SHALL remain responsible only for recording and preserving payment information.

---

# Dependencies

Payment depends upon:

Shared Concepts

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Result|Result]]
- [[DomainError]]

Billing Concepts

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[Payment-Method]]

Payment SHALL NOT depend upon:

- Receipt implementation
- PDF generation
- Persistence
- User Interface
- External payment gateways

Integration with external payment providers belongs outside the Domain.

---

# Validation

Payment validates:

- Invoice association.
- Payment Amount.
- Currency compatibility.
- Payment Method.
- Overpayment Policy.
- Payment Reference where required.

Validation SHALL preserve financial consistency.

---

# Failure Cases

Expected business failures include:

- Invalid payment amount.
- Currency mismatch.
- Overpayment not permitted.
- Invoice not eligible for payment.
- Missing required payment reference.
- Invalid payment method.
- Operation not permitted for the current Invoice Status.

Expected failures SHALL be represented through the Result model.

Unexpected system failures remain outside the responsibility of the Payment Aggregate.

---

# Related Requirements

Functional Requirements

- Payment Recording
- Payment Management

Business Rules

- BR-PAY-* | see [[01-Requirements/billing/Payment|Payment]]
- BR-INV-* | see [[01-Requirements/billing/Invoice|Invoice]]

Business Policies

- [[Business-Policies#BP-PAY-001]]
- [[Business-Policies#BP-PAY-002]]
- [[Business-Policies#BP-PAY-003]]

Architecture

- Error Handling Strategy
- Validation Strategy

---
# Design Rationale

Payment is modeled as an entity owned by the Invoice Aggregate.

Once successfully recorded, a Payment becomes part of the financial history and SHALL NOT be modified.

Invoice maintains the outstanding obligation and owns the collection of Payments that settle it.
Recording a Payment is an Invoice operation so that balance updates and lifecycle transitions remain inside a single consistency boundary.

This preserves auditability (immutable payment records) while keeping financial consistency within the Invoice Aggregate.

---

# Future Considerations

Future versions MAY introduce:

- Payment reversal.
- Refunds.
- Split payments.
- Scheduled payments.
- Payment allocations across multiple invoices.
- External payment gateway integration.

Such additions SHALL preserve Payment as an immutable financial record.