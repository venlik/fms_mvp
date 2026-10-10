# Customer Credit Business Rules

## Purpose

Defines business rules governing Customer Credit within the Billing module.

Customer Credit represents a monetary balance owed by the Business to a Customer, typically arising from an accepted overpayment.

See [[Billing-Policies#BP-PAY-002|BP-PAY-002]].

---

## Rules

### BR-CC-001

Customer Credit Amount SHALL be greater than or equal to zero.

---

### BR-CC-002

Customer Credit Currency SHALL match the Business default currency.

---

### BR-CC-003

Customer Credit SHALL be immutable.

Each change produces a new Customer Credit Value Object on the Customer.

---

### BR-CC-004

Every Credit Movement SHALL reference exactly one Customer.

---

### BR-CC-005

Every Credit Movement SHALL have a non-zero amount.

---

### BR-CC-006

Credit Movements SHALL be immutable after creation.

---

### BR-CC-007

Credit Movements SHALL be recorded atomically with the Customer Credit change they represent.

### Atomicity Requirement

The following three changes SHALL be committed in a single Application-layer transaction:

1. Update of the Customer’s Customer Credit Value Object
2. Persistence of the corresponding Credit Movement record
3. (When applicable) the related Invoice Payment / Balance / Status change

If any of the three fails, the entire transaction SHALL be rolled back.
No partial state (Customer Credit updated without a matching Credit Movement, or vice versa) SHALL ever be visible.

---

### BR-CC-008

Applying Customer Credit to an Invoice SHALL NOT make the Invoice Balance negative.

---

### BR-CC-009

Applying Customer Credit SHALL NOT exceed the available Customer Credit balance.

---

### BR-CC-010

Customer Credit application SHALL be recorded as a Payment with Payment Method = `Customer Credit`.

---

### BR-CC-011

Customer Credit SHALL only be applied to Invoices belonging to the same Customer.

---

### BR-CC-012

Customer Credit SHALL only be applied to Invoices in Issued or Partially Paid status.

---

### BR-CC-013

Applying Customer Credit SHALL generate a Receipt through the standard payment flow.

---

### BR-CC-014

The current Customer Credit amount SHALL always equal the net sum of all Credit Movements belonging to that Customer:

  Σ(Granted) − Σ(Applied) − Σ(Refunded) ± Σ(Adjusted)

This invariant SHALL be maintained by the Application layer when recording movements and MAY be verified by the Persistence or Domain layers as an integrity check.

---

## Related Documents

- [[Billing-Policies#BP-PAY-002|BP-PAY-002]]
- [[Billing-Policies#BP-PAY-004|BP-PAY-004]]
- [[01-Requirements/billing/Payment|Payment Business Rules]]
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]