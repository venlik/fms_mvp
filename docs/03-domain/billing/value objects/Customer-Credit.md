# Customer Credit

## Purpose

Customer Credit represents a monetary balance owed by the Business to a Customer.

It is an immutable Value Object held by the Customer Aggregate.

Any change to a Customer's credit produces a new Customer Credit instance. The previous instance is discarded. Movement history is preserved separately through Credit Movement records.

---

# Classification

Customer Credit is an immutable Value Object.

- Defined entirely by its values (amount, currency).
- No identity beyond its value.
- Equality determined by value.
- Replaced — never mutated.

---

# Responsibilities

Customer Credit SHALL be responsible for:

- Representing the current credit balance owed to a Customer.
- Preserving currency consistency.
- Preventing invalid credit values.

Customer Credit SHALL NOT be responsible for:

- Recording credit movements.
- Applying credit to Invoices.
- Tracking its own history.
- Currency conversion.

---

# Business Rules

Customer Credit SHALL enforce the following Business Rules:

- [[01-Requirements/billing/Customer-Credit#BR-CC-001|BR-CC-001]] — Amount SHALL be greater than or equal to zero.
- [[01-Requirements/billing/Customer-Credit#BR-CC-002|BR-CC-002]] — Currency SHALL match the Business default currency.
- [[01-Requirements/billing/Customer-Credit#BR-CC-003|BR-CC-003]] — Customer Credit SHALL be immutable.

---

# State

Customer Credit maintains:

- A monetary amount.
- A currency.

Together these form a complete credit balance.

---

# Operations

Customer Credit supports:

- Equality evaluation.
- Zero-value evaluation.
- Conversion to Money.

Customer Credit SHALL NOT record credit movements.

---

# Invariants

- Amount SHALL NOT be negative.
- Currency SHALL match the Business default currency.
- Amount and currency SHALL NOT change after construction.

---

# Collaborators

Customer Credit collaborates with:

- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Currency|Currency]]
- [[03-domain/billing/Credit-Movement|Credit Movement]]

---

# Dependencies

Customer Credit depends upon:

- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Currency|Currency]]

Customer Credit SHALL NOT depend upon:

- Invoice
- Payment
- Receipt
- Persistence
- User Interface

---

# Validation

Customer Credit validates:

- Amount is non-negative.
- Currency is present.
- Currency matches Business default.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

- Negative credit amount.
- Missing currency.
- Currency mismatch with Business default.

Expected failures SHALL be represented through the Result model.

---

# Related Requirements

Business Rules

- [[01-Requirements/billing/Customer-Credit#BR-CC-001|BR-CC-001]]
- [[01-Requirements/billing/Customer-Credit#BR-CC-002|BR-CC-002]]
- [[01-Requirements/billing/Customer-Credit#BR-CC-003|BR-CC-003]]

Business Policies

- [[Billing-Policies#BP-PAY-002|BP-PAY-002]]

---

# Design Rationale

Customer Credit is modeled as a Value Object because it represents a monetary quantity, not a thing with identity.

Immutability ensures that any change to a Customer's credit is explicit — a new value replaces the old. Movement history is preserved separately through Credit Movement records, decoupling the current balance from its history.

---

# Future Considerations

Future versions MAY introduce:

- Credit expiration policies.
- Multi-currency credits.
- Credit transfer between Customers.
- Credit withdrawal / refund operations.
- Customer deposits (standalone credit grants not tied to an Invoice).
- Prepaid wallet behavior for offline payment environments.