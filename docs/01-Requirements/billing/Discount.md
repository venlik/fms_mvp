# Discount Business Rules

## Purpose

Defines business rules governing discounts within the Billing module.

Discounts may be applied per Invoice Item or at the Invoice level.

See [[03-domain/billing/value objects/Discount|Discount]] and [[Billing-Policies#BP-DIS-001|BP-DIS-001]].

---

## Rules

### BR-DIS-001

Discounts SHALL be defined as Discount Value Objects.

---

### BR-DIS-002

Discount type SHALL be either Percentage or Fixed.

---

### BR-DIS-003

Percentage discounts SHALL be between 0 and 100 (inclusive).

---

### BR-DIS-004

Fixed discounts SHALL be non-negative.

---

### BR-DIS-005

Fixed discounts SHALL use the same currency as the discounted amount.

---

### BR-DIS-006

Discounts SHALL be immutable after construction.

---

### BR-DIS-007

Discounts MAY be applied per Invoice Item.

An Invoice Item MAY have zero or more discounts applied.

---

### BR-DIS-008

Discounts MAY be applied at the Invoice level.

An Invoice MAY have zero or one Invoice-level discount.

---

### BR-DIS-009

Sum of applied discounts on an Invoice Item SHALL NOT exceed the Line Subtotal.

---

### BR-DIS-010

Invoice-level discount SHALL NOT exceed the sum of Line Discounted Subtotals.

---

### BR-DIS-011

Discounts SHALL be applied sequentially in the order they were added.

The order of application SHALL be preserved.

---

### BR-DIS-012

Discounts SHALL be applied before tax calculation.

See [[Billing-Policies#BP-DIS-004|BP-DIS-004]].

---

### BR-DIS-013

Applied discounts SHALL be captured as snapshots on Invoice Items at issuance.

Changes to Business discount configuration SHALL NOT alter issued Invoices.

---

### BR-DIS-014

Historical Invoices SHALL preserve their discount snapshots.

See [[01-Requirements/billing/Business-Rules#BR-BIL-007|BR-BIL-007]].

---

### BR-DIS-015

Discounts SHALL NOT be applied to Payments or Receipts.

Discounts apply only to Invoice Items and Invoices.

---

## Related Documents

- [[Billing-Policies#BP-DIS-001|BP-DIS-001]] through [[Billing-Policies#BP-DIS-006|BP-DIS-006]]
- [[01-Requirements/billing/InvoiceItem|Invoice Item Business Rules]]
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[01-Requirements/billing/Tax|Tax Business Rules]]
- [[03-domain/billing/value objects/Discount|Discount]]