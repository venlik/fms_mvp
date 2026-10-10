
# Money

## Purpose

Money represents a monetary value within the Finance Management System.

It combines a numeric amount with a currency to ensure financial calculations are accurate, consistent, and meaningful.

Money SHALL serve as the standard representation of monetary values throughout the Domain.

---

# Responsibilities

Money SHALL be responsible for:

- Representing monetary values.
- Preserving currency information.
- Supporting financial arithmetic.
- Preventing invalid monetary operations.
- Preserving financial precision.

Money SHALL NOT be responsible for:

- Currency conversion.
- Exchange rates.
- Tax calculation.
- Formatting for presentation.

---

# Business Rules

Money SHALL enforce the following Business Rules:

- Monetary values SHALL always have an associated Currency.
- Arithmetic operations SHALL only occur between compatible currencies.
- Money SHALL remain immutable.
- Invalid Money values SHALL NOT be created.

---

# State

Money maintains:

- A monetary amount.
- A currency.

Together these form a complete monetary value.

---

# Operations

Money supports the following operations:

- Addition
- Subtraction
- Multiplication
- Division
- Comparison
- Equality evaluation
- Zero-value evaluation

Each operation SHALL preserve Domain consistency.

---

# Invariants

The following conditions SHALL always hold:

- Every Money instance has exactly one Currency.
- Currency SHALL NOT change after creation.
- Amount SHALL NOT change after creation.
- Results of operations SHALL preserve currency consistency.

---
## Negative Values

Money MAY represent positive, zero, or negative monetary values.

The validity of a negative monetary value SHALL be determined by the business concept using Money rather than by Money itself.

Examples:

- Invoice Item MAY reject negative amounts.
- Payment MAY reject negative amounts.
- Refund MAY permit negative adjustments.
- Account Balance MAY legitimately become negative.

Money SHALL remain independent of these business decisions.

---

## Design Rationale

Money is a shared Value Object used throughout the Domain.

Restricting the sign of the amount would introduce billing-specific assumptions into a generic financial concept.

Business concepts SHALL enforce their own monetary constraints according to their responsibilities.

This separation promotes reusability while preserving clear ownership of business rules.

---
# Collaborators

Money collaborates with:

- Currency
- Invoice
- Invoice Item
- Payment
- Receipt

---

# Dependencies

Money depends upon:

- Currency

Money SHALL NOT depend upon any billing concepts.

---

# Validation

Money validates:

- Currency compatibility for arithmetic operations.
- Construction invariants.

Validation failures SHALL produce Domain Errors through the Result model where applicable.

---

# Failure Cases

Expected business failures include:

- Currency mismatch during arithmetic.
- Invalid monetary construction.

Unexpected system failures are outside the responsibility of Money.

---

# Related Requirements

Shared Requirements

- Money
- Currency

Business Rules

- BR-INV-006
- BR-PAY-002

Business Policies

None.

---

# Future Considerations

Future versions MAY introduce:

- Configurable rounding strategies.
- Currency precision rules.
- Tax-aware calculations.
- Exchange-rate services.

Such additions SHALL preserve the core responsibilities of Money.