
# Payment

## Purpose

Payment represents the settlement of all or part of an Invoice's outstanding financial obligation.

A Payment records the transfer of monetary value from a Customer to a Business.

Every Payment is an Entity within the Invoice Aggregate and SHALL NOT exist independently of its owning Invoice.

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
- Existing independently of an Invoice.

---

# Business Rules

Payment SHALL enforce the following Business Rules:

- Every Payment is part of exactly one Invoice.
- Payment Amount SHALL be greater than zero.
- Payment Currency SHALL match the Invoice Currency.
- Payment SHALL comply with the configured Overpayment Policy.
- Successfully recorded Payments SHALL be immutable.

See [[03-domain/billing/aggregates components/Payment#Related Requirements|Related Requirements]].

---

# State

Payment maintains:

- Its identity.
- The owning Invoice (implicit through Aggregate membership).
- Payment Amount.
- Payment Method.
- Payment Date.
- Payment Reference (where applicable).

Additional information MAY be maintained according to business requirements.

---

# Operations

Payment supports the following business operations:

- Record Payment (invoked through the Invoice Aggregate Root).
- Validate Payment.
- Verify Payment Reference.

Payment operations SHALL be initiated through the Invoice Aggregate Root to preserve Aggregate consistency.

## No Correction Operations in Version 1

Version 1 defines no Payment correction operations.

A recorded Payment SHALL NOT be edited, corrected, reversed, or voided.

Payment correction is reserved for a future version.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

---

# Invariants

The following conditions SHALL always hold:

- Every Payment is part of one Invoice.
- Payment Amount is greater than zero.
- Payment Currency matches the Invoice Currency.
- Recorded Payments remain immutable.
- Payment SHALL NOT exist without its owning Invoice.

---

# Aggregate Ownership

## Owned Concepts

Payment owns no other Domain concepts.

---

## Owned By

Payment is owned by:

- [[03-domain/billing/aggregates/Invoice|Invoice]]

Payment SHALL NOT exist independently of its owning Invoice.

---

## Referenced Concepts

Payment references:

- [[03-domain/shared/Money|Money]]
- [[03-domain/billing/value objects/Payment-Method|Payment Method]]

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
- [[03-domain/billing/value objects/Payment-Method|Payment Method]]

Each collaborator fulfills a distinct business responsibility.

Payment SHALL remain responsible only for recording and preserving payment information.

---

# Dependencies

Payment depends upon:

Shared Concepts

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Result|Result]]
- [[03-domain/shared/DomainError|Domain Error]]

Billing Concepts

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/value objects/Payment-Method|Payment Method]]

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

- Invoice association (established through Aggregate membership).
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

Unexpected system failures remain outside the responsibility of the Payment Entity.

---

# Related Requirements

Functional Requirements

- Payment Recording
- Payment Management

Business Rules

- [[01-Requirements/billing/Payment#BR-PAY-001|BR-PAY-001]] to [[01-Requirements/billing/Payment#BR-PAY-011|BR-PAY-011]]
- [[01-Requirements/billing/Currency-Enforcement#BR-CUR-002|BR-CUR-002]]
- [[01-Requirements/billing/Invoice#BR-INV-008|BR-INV-008]]
- [[01-Requirements/billing/Invoice#BR-INV-009|BR-INV-009]]
- [[01-Requirements/common/shared/Money#BR-MON-001|BR-MON-001]]
- [[01-Requirements/common/shared/Money#BR-MON-002|BR-MON-002]]

---

# Design Rationale

Payment is modeled as an Entity owned by the Invoice Aggregate.

Once successfully recorded, a Payment becomes part of the financial history and SHALL NOT be modified.

Invoice maintains the outstanding obligation and owns the collection of Payments that settle it.

Recording a Payment is an Invoice operation so that balance updates and lifecycle transitions remain inside a single consistency boundary.

This preserves auditability (immutable payment records) while keeping financial consistency within the Invoice Aggregate.

---
# Future Considerations

Future versions MAY introduce:

- Payment correction (referencing the original Payment).
- Payment reversal.
- Payment void.
- Refunds.
- Split payments.
- Scheduled payments.
- Payment allocations across multiple invoices.
- External payment gateway integration.

Payment correction is anticipated as a Version 2 priority.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

Such additions SHALL preserve Payment as an immutable financial record owned by the Invoice Aggregate.