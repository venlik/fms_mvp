# Discount

## Purpose

Discount represents a configurable reduction applied to an Invoice Item or an Invoice.

Discount defines the type, value, and label of a reduction within the Billing module.

Discount is an immutable Value Object.

---

# Classification

Discount is an immutable Value Object.

- Defined entirely by its values (type, value, label).
- No identity beyond its value.
- Equality determined by value.
- Replaced — never mutated.

---

# Responsibilities

Discount SHALL be responsible for:

- Representing a reduction.
- Identifying the type of reduction (percentage or fixed).
- Providing the discount value.
- Preserving discount immutability.

Discount SHALL NOT be responsible for:

- Calculating discounted amounts.
- Managing discount policy across the Business.
- Determining which items are discountable.
- Applying itself to amounts.

---

# Business Rules

Discount SHALL enforce the following Business Rules:

- Every Discount SHALL have a type.
- Discount type SHALL be either Percentage or Fixed.
- Percentage discounts SHALL be between 0 and 100 (inclusive).
- Fixed discounts SHALL be greater than or equal to zero.
- Fixed discounts SHALL use the same currency as the amount being discounted.
- Discount SHALL be immutable after construction.

---

# Discount Types

The Billing module defines two Discount types:

| Type | Value Range | Meaning |
|------|-------------|---------|
| Percentage | 0 to 100 | Percentage of the discounted amount |
| Fixed | ≥ 0, currency-specific | Absolute amount subtracted from the discounted amount |

---

# State

Discount maintains:

- Its type (Percentage or Fixed).
- Its value.
- An optional label (e.g., `Seasonal Sale`, `Loyalty`).
- Currency (for Fixed discounts only).

---

# Operations

Discount supports:

- Equality evaluation.
- Type retrieval.
- Value retrieval.

Discount SHALL NOT perform discount calculation.

Discount calculation is performed by the concept applying the Discount.

---

# Invariants

The following conditions SHALL always hold:

- Type SHALL be valid.
- Percentage value SHALL be between 0 and 100.
- Fixed value SHALL be non-negative.
- Currency SHALL be present for Fixed discounts.
- Discount SHALL NOT change after construction.

---

# Collaborators

Discount collaborates with:

- [[03-domain/billing/aggregates components/InvoiceItem|Invoice Item]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates/Business|Business]]

---

# Dependencies

Discount depends upon:

- [[03-domain/shared/Money|Money]] (for Fixed discounts)
- [[03-domain/shared/Currency|Currency]] (for Fixed discounts)

Discount SHALL NOT depend upon:

- Tax Rate
- Payment
- Receipt
- Persistence

---

# Validation

Discount validates:

- Type is Percentage or Fixed.
- Percentage is within [0, 100].
- Fixed amount is non-negative.
- Currency is present for Fixed discounts.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

- Invalid discount type.
- Percentage outside [0, 100].
- Negative fixed amount.
- Missing currency for Fixed discount.

Expected failures SHALL be represented through the Result model.

---

# Related Requirements

Business Rules

- [[01-Requirements/billing/Discount#BR-DIS-001|BR-DIS-001]] through [[01-Requirements/billing/Discount#BR-DIS-015|BR-DIS-015]]

Business Policies

- [[Billing-Policies#BP-DIS-001|BP-DIS-001]] through [[Billing-Policies#BP-DIS-006|BP-DIS-006]]

---

# Design Rationale

Discount is modeled as a Value Object because it represents configuration data, not a business entity.

Mirroring Tax Rate's design promotes consistency: both are immutable, snapshot-able, and applied per level (item or invoice).

Any change to a Discount produces a new instance. Invoice Items and Invoices capture snapshots at issuance.

---

# Future Considerations

Future versions MAY introduce:

- Discount reason codes.
- Customer-specific discount eligibility.
- Time-limited discount campaigns.
- Discount approval workflows.
- Discount stacking rules beyond sequential application.