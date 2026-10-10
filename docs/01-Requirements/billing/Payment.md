# Payment Business Rules

## Purpose

Defines business rules governing Payments.

Payments represent transfers of monetary value from Customers to the Business.

---

## Rules

### BR-PAY-001

Every Payment SHALL be part of exactly one Invoice.

---

### BR-PAY-002

Every Payment SHALL have a positive monetary value.

---

### BR-PAY-003

The portion of a Payment applied to an Invoice SHALL reduce the outstanding Invoice Balance.

The applied amount SHALL NOT exceed the outstanding balance.

---

### BR-PAY-004

Payments SHALL NOT cause Invoice Balance to become negative.

When a payment amount exceeds the outstanding Invoice Balance:

- If the Business overpayment policy is Reject (default): the payment SHALL be rejected in full.
- If the Business overpayment policy is Accept and record Customer Credit: the outstanding balance SHALL be settled in full, and the excess SHALL be recorded as Customer Credit on the Customer.

Automatic allocation of excess to other invoices is out of scope for Version 1.

See [[Billing-Policies#BP-PAY-002|BP-PAY-002]].

---

### BR-PAY-005

Payments SHALL be recorded chronologically.

---

### BR-PAY-006

An Invoice SHALL be considered fully paid when its outstanding Balance reaches zero.

---

### BR-PAY-007

Every Receipt SHALL acknowledge exactly one Payment.

---

### BR-PAY-008

Payments SHALL be recorded only through their owning Invoice.

Payments SHALL NOT exist independently of an Invoice.

---

### BR-PAY-009

A Payment with Payment Method = `Customer Credit` SHALL be applied from the Customer's Customer Credit balance.

The Customer's Customer Credit SHALL be reduced by the applied amount.

A Credit Movement SHALL be recorded with direction `Applied`.

---

### BR-PAY-010

A Payment with Payment Method = `Customer Credit` SHALL NOT require an external payment reference.

The Customer's Customer Credit balance serves as the source of funds.

---

### BR-PAY-011

Recorded Payments SHALL be final.

A Payment SHALL NOT be edited, corrected, reversed, or voided in Version 1.

If a Payment is recorded incorrectly, Version 1 provides no corrective mechanism.

Payment correction is reserved for a future version.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

---
## Related Documents

- [[Billing-Policies#BP-PAY-002|BP-PAY-002]]
- [[01-Requirements/billing/Receipt|Receipt]]
- [[01-Requirements/billing/Invoice|Invoice]]
- [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]]
