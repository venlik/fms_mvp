# Invoice Item Business Rules

## Purpose

Defines business rules governing Invoice Items.

Invoice Items represent individual products or services billed on an Invoice.

---

## Rules

### BR-ITM-001

Every Invoice Item SHALL belong to exactly one Invoice.

---

### BR-ITM-002

Invoice Item quantity SHALL be greater than zero.

---

### BR-ITM-003

Invoice Item unit price SHALL be greater than or equal to zero.

---

### BR-ITM-004

Invoice Item description SHALL NOT be empty.

---

### BR-ITM-005

Invoice Item subtotal SHALL equal:

Quantity × Unit Price

---

### BR-ITM-006

Sum of applied discounts on an Invoice Item SHALL NOT exceed the Line Subtotal.

Discounts SHALL be applied sequentially in the order they were added.

See [[01-Requirements/billing/Discount|Discount Business Rules]].

---

### BR-ITM-007

Invoice Item taxes SHALL be calculated according to the configured tax policy.

Taxes SHALL be applied to the Line Discounted Subtotal.

Tax snapshots SHALL be captured at Invoice issuance.

See [[01-Requirements/billing/Tax|Tax Business Rules]].

---

### BR-ITM-008

Invoice Item total SHALL NOT be negative.

---

### BR-ITM-009

Invoice Item Line Subtotal SHALL equal:

Quantity × Unit Price

---

### BR-ITM-010

Invoice Item Line Total SHALL equal:

Line Discounted Subtotal + Sum of Applied Taxes

---

### BR-ITM-011

Applied taxes SHALL be captured as snapshots at Invoice issuance.

---

### BR-ITM-012

Invoice Item Line Discounted Subtotal SHALL equal:

Line Subtotal − Sum of Applied Discounts

---

### BR-ITM-013

Invoice Item Line Total SHALL equal:

Line Discounted Subtotal + Sum of Applied Taxes

---

### BR-ITM-014

Applied discounts SHALL be captured as snapshots at Invoice issuance.

---

## Related Documents

- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate Specification]]
