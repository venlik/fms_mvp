# Invoice Status

## Purpose

Invoice Status represents the current business state of an Invoice.

It communicates the Invoice's position within its lifecycle and determines which business operations are permitted.

Invoice Status SHALL serve as the standard representation of Invoice lifecycle state throughout the Billing module.

---

# Responsibilities

Invoice Status SHALL be responsible for:

- Representing the current lifecycle state of an Invoice.
- Supporting lifecycle validation.
- Determining whether business operations are permitted.
- Preserving lifecycle consistency.

Invoice Status SHALL NOT be responsible for:

- Managing Invoice data.
- Performing lifecycle transitions.
- Recording Payments.
- Calculating financial values.

Lifecycle transitions remain the responsibility of the Invoice Aggregate.

---

# Business Rules

Invoice Status SHALL enforce the following Business Rules:

- Every Invoice SHALL have exactly one Invoice Status.
- Invoice Status SHALL be immutable.
- Invoice Status SHALL represent a valid lifecycle state.
- Lifecycle transitions SHALL follow the approved lifecycle policy.

---

# Lifecycle States

The Billing module defines the following Invoice lifecycle states:

- Draft
- Issued
- Partially Paid
- Paid
- Archived

An Invoice SHALL always exist in exactly one of these states.

---

# State

Invoice Status maintains:

- The lifecycle state.

No additional business data is maintained.

---

# Operations

Invoice Status supports:

- Equality evaluation.
- State comparison.
- Operation permission queries.

Invoice Status SHALL NOT modify the Invoice.

---

# Invariants

The following conditions SHALL always hold:

- Every Invoice Status represents exactly one lifecycle state.
- Lifecycle state SHALL remain valid.
- Invoice Status SHALL remain immutable.

---

# Collaborators

Invoice Status collaborates with:

- [[03-domain/billing/aggregates/Invoice|Invoice]]

---

# Dependencies

Invoice Status SHALL NOT depend upon:

- Payment
- Receipt
- Persistence
- User Interface

---

# Validation

Invoice Status validates:

- Construction invariants.
- Lifecycle state validity.

Validation of lifecycle transitions belongs to the Invoice Aggregate.

---

# Failure Cases

Expected business failures include:

- Invalid lifecycle state.
- Invalid lifecycle transition.

Expected failures SHALL be represented using the Result model.

Unexpected system failures remain outside the responsibility of Invoice Status.

---

# Related Requirements

Functional Requirements

- [[Functional-Requirements#FR-008|FR-008]]
- [[Functional-Requirements#FR-011|FR-011]]

Business Rules

- [[01-Requirements/billing/Invoice#BR-INV-011|BR-INV-011]]

Business Policies

- [[Billing-Policies#Invoice Policies|Invoice lifecycle policies.]]
---

# Design Rationale

Invoice Status is modeled as a Value Object because it represents business state rather than business behavior.

Separating lifecycle state from the Invoice Aggregate improves readability while keeping lifecycle decisions within the Invoice Aggregate.

---

# Future Considerations

Future versions MAY introduce:

- Overdue.
- Cancelled.
- Void.
- Disputed.
- Written Off.

Such additions SHALL preserve Invoice Status as an immutable Value Object.