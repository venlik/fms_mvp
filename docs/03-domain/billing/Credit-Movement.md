# Credit Movement

## Purpose

Credit Movement represents a single, immutable record of a change to a Customer's credit balance.

Every change — grant, application, refund, or adjustment — produces exactly one Credit Movement.

Credit Movement serves as the authoritative audit trail for Customer Credit.

---

# Classification

Credit Movement is an immutable Domain Record.

A Domain Record:

- Documents a business fact.
- Is immutable after creation.
- Is not an Entity (no behavior, no lifecycle transitions).
- Is not a Value Object (has identity for reference).
- Lives outside any Aggregate.
- Is persisted through its own Repository.

---

# Responsibilities

Credit Movement SHALL be responsible for:

- Recording a credit change.
- Recording the direction of the change.
- Recording the reason.
- Recording references to source or target business concepts.
- Providing an audit trail for credit.

Credit Movement SHALL NOT be responsible for:

- Calculating credit balance.
- Enforcing credit limits.
- Applying credit.
- Modifying Customer state.

---

# Business Rules

Credit Movement SHALL enforce the following Business Rules:

- [[01-Requirements/billing/Customer-Credit#BR-CC-004|BR-CC-004]] — Reference exactly one Customer.
- [[01-Requirements/billing/Customer-Credit#BR-CC-005|BR-CC-005]] — Have a non-zero amount.
- [[01-Requirements/billing/Customer-Credit#BR-CC-006|BR-CC-006]] — Be immutable after creation.
- [[01-Requirements/billing/Customer-Credit#BR-CC-007|BR-CC-007]] — Be recorded atomically with the Customer credit change it represents.

---

# State

Credit Movement maintains:

- Its identity.
- The Customer it belongs to.
- Amount.
- Currency.
- Direction.
- Reason.
- Timestamp.
- Source reference (optional).
- Target reference (optional).

---

# Directions

| Direction | Meaning | Source / Target |
|-----------|---------|-----------------|
| Granted | Credit added to Customer | Source: Invoice (overpayment) or Deposit reference |
| Applied | Credit consumed by an Invoice | Target: Invoice |
| Refunded | Credit returned to Customer | — |
| Adjusted | Manual correction | — |

---

# Operations

Credit Movement supports:

- Recording (creation).
- Querying by Customer.
- Querying by date range.
- Querying by direction.

Credit Movement SHALL NOT support modification after creation.

---

# Invariants

- Identity SHALL remain immutable.
- Amount SHALL be non-zero.
- Direction SHALL be valid.
- Timestamp SHALL be recorded at creation.
- Customer reference SHALL be present.

---

# Atomicity Requirement

The following three changes SHALL be committed in a single Application-layer transaction:

1. Update of the Customer’s Customer Credit Value Object
2. Persistence of the corresponding Credit Movement record
3. (When applicable) the related Invoice Payment / Balance / Status change

If any of the three fails, the entire transaction SHALL be rolled back.
No partial state (Customer Credit updated without a matching Credit Movement, or vice versa) SHALL ever be visible.

---

# Collaborators

Credit Movement collaborates with:

- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/shared/Money|Money]]

---

# Dependencies

Credit Movement depends upon:

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/billing/aggregates/Customer|Customer]] (by reference)

Credit Movement SHALL NOT depend upon:

- Payment implementation
- Receipt implementation
- Persistence technology

---

# Validation

Credit Movement validates:

- Customer reference is present.
- Amount is non-zero.
- Direction is valid.
- Timestamp is present.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

- Missing Customer reference.
- Zero or invalid amount.
- Invalid direction.
- Missing timestamp.

Expected failures SHALL be represented through the Result model.

---

# Related Requirements

Business Rules

- [[01-Requirements/billing/Customer-Credit#BR-CC-004|BR-CC-004]] through [[01-Requirements/billing/Customer-Credit#BR-CC-010|BR-CC-010]]

---

# Design Rationale

Credit Movement is modeled as a Domain Record because it documents historical facts that must be preserved for audit and reporting.

Keeping movements separate from the Customer Aggregate:

- Preserves the Customer Aggregate's small boundary.
- Allows unlimited movement history without bloating the Aggregate.
- Enables movement queries independent of Customer loading.
- Maintains clean separation between current state (Customer Credit VO) and history (Credit Movements).

---

# Audit Role

Credit Movement serves as the authoritative audit trail for Customer Credit.

Every change to a Customer's credit balance produces exactly one Credit Movement.

Credit Movements are:

- Immutable after creation.
- Append-only.
- Never modified, only added to.
- Retained indefinitely.

The current Customer Credit balance on the Customer Aggregate SHALL be reconstructable at any time by replaying the ordered Credit Movements for that Customer. The two values SHALL never diverge.

This satisfies the audit requirements for Customer Credit without requiring a dedicated audit infrastructure.

See [[02-architecture/Audit-Strategy|Audit Strategy]].

---

# Future Considerations

Future versions MAY introduce:

- Event-sourced reconstruction of Customer Credit.
- Movement categorization.
- Batch movement operations.
- Movement reversal (as compensating movements, not mutations).