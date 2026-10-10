# Receipt Business Rules

## Purpose

Defines business rules governing Receipts.

Receipts acknowledge payments received for Invoices.

---

## Rules

### BR-REC-001

Every Receipt SHALL belong to exactly one Business.

---

### BR-REC-002

Every Receipt SHALL reference exactly one Invoice.

---

### BR-REC-003

Every Receipt SHALL represent one recorded payment.

---

### BR-REC-004

Receipt Amount SHALL be greater than zero.

---

### BR-REC-005

A Receipt SHALL only be generated for a successfully recorded Payment.

---

### BR-REC-006

Every Receipt SHALL have exactly one Identifier.

---

### BR-REC-007

Every Receipt SHALL have exactly one Document Number.

---

### BR-REC-008

Receipt Document Numbers SHALL be unique within the Business.

---

### BR-REC-009

Receipts SHALL be immutable after generation.

A Receipt SHALL NOT be modified in any way once it has been generated.

Version 1 provides no Receipt correction, reversal, or voiding operation.

Payment and Receipt correction are reserved for a future version.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

---
## Related Documents

- [[Billing-Policies#BP-PAY-002|BP-PAY-002]]
- [[01-Requirements/billing/Payment|Payment]]
- [[01-Requirements/billing/Invoice|Invoice]]
