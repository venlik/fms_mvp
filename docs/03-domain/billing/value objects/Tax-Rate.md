# Tax Rate

## Purpose

Tax Rate represents a configurable tax that may be applied to Invoice Items.

It defines the identity, rate, and calculation behavior of a tax within the Billing module.

Tax Rate is an immutable Value Object.

---

# Classification

Tax Rate is an immutable Value Object.

- Defined entirely by its values (code, name, rate).
- No identity beyond its value.
- Equality determined by value.
- Replaced — never mutated.

---

# Responsibilities

Tax Rate SHALL be responsible for:

- Identifying a tax type (e.g., VAT, Sales Tax).
- Providing the tax rate as a percentage.
- Preserving tax rate immutability.

Tax Rate SHALL NOT be responsible for:

- Calculating tax on amounts.
- Managing tax configuration across the Business.
- Determining which items are taxable.
- Handling tax-inclusive pricing.

---

# Business Rules

Tax Rate SHALL enforce the following Business Rules:

- Every Tax Rate SHALL have a unique code within the Business.
- Tax Rate percentage SHALL be between 0 and 100.
- Tax Rate SHALL be immutable after configuration.
- Tax Rate SHALL be defined by the Business Aggregate.

---

# State

Tax Rate maintains:

- A unique code (e.g., `VAT`, `SALES-TAX`).
- A display name (e.g., `Value Added Tax`).
- A percentage rate (e.g., `16.00`).
- An optional description.

---

# Operations

Tax Rate supports:

- Equality evaluation.
- Rate retrieval.
- Code retrieval.

Tax Rate SHALL NOT perform tax calculation.

Tax calculation is performed by the concept applying the Tax Rate (Invoice Item).

---

# Invariants

The following conditions SHALL always hold:

- Tax Rate code SHALL be non-empty.
- Tax Rate percentage SHALL be between 0 and 100 (inclusive).
- Tax Rate SHALL NOT change after construction.

---

# Collaborators

Tax Rate collaborates with:

- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates components/InvoiceItem|Invoice Item]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]

---

# Dependencies

Tax Rate depends upon:

- [[03-domain/shared/Identifier|Identifier]] (for tax code)

Tax Rate SHALL NOT depend upon:

- Persistence
- User Interface
- External tax services

---

# Validation

Tax Rate validates:

- Code is non-empty.
- Rate is between 0 and 100.
- Name is non-empty.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

- Empty or missing tax code.
- Rate outside [0, 100].
- Missing display name.

Expected failures SHALL be represented through the Result model.

---

# Related Requirements

Business Rules

- [[01-Requirements/billing/Tax#BR-TAX-001|BR-TAX-001]] through [[01-Requirements/billing/Tax#BR-TAX-010|BR-TAX-010]]

Business Policies

- [[Billing-Policies#BP-TAX-001|BP-TAX-001]] through [[Billing-Policies#BP-TAX-005|BP-TAX-005]]

---

# Design Rationale

Tax Rate is modeled as a Value Object because it represents configuration data, not a business entity.

Any change to a Tax Rate produces a new instance. Invoice Items capture a snapshot of the applicable Tax Rate at issuance, preserving historical financial accuracy.

This design supports multiple taxes per item, configurable rates per Business, and future evolution toward tax-inclusive pricing without changing the core model.

---

# Future Considerations

Future versions MAY introduce:

- Tax-inclusive pricing.
- Compound taxes.
- Tax exemptions per Customer.
- Jurisdiction-based tax rules.
- Tax groups (a set of taxes applied together).
- Tax reporting.