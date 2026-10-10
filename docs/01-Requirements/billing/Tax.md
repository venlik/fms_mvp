# Tax Business Rules

## Purpose

Defines business rules governing taxes within the Billing module.

Taxes are configurable per Business and applied per Invoice Item.

See [[03-domain/billing/value objects/Tax-Rate|Tax Rate]] and [[Billing-Policies#BP-TAX-001|BP-TAX-001]].

---

## Rules

### BR-TAX-001

Tax Rates SHALL be defined by the Business.

---

### BR-TAX-002

Tax Rates SHALL have a unique code within the Business.

---

### BR-TAX-003

Tax Rate percentage SHALL be between 0 and 100 (inclusive).

---

### BR-TAX-004

Tax Rates SHALL be immutable after configuration.

Changes to a Tax Rate produce a new Tax Rate instance.

---

### BR-TAX-005

Taxes SHALL be applied per Invoice Item.

An Invoice MAY contain items with different tax treatments.

---

### BR-TAX-006

An Invoice Item MAY have zero or more taxes applied.

---

### BR-TAX-007

Tax calculation SHALL be applied to the Invoice Item Line Discounted Subtotal.

Line Subtotal equals Quantity × Unit Price.
Line Discounted Subtotal = Line Subtotal - discount applied.

---

### BR-TAX-008

Tax amounts SHALL be rounded to the currency precision of the Invoice.

Rounding SHALL be applied per Invoice Item.

---

### BR-TAX-009

Taxed amounts SHALL NOT be re-taxed within the same Invoice Item.

Compounding taxes are out of scope for Version 1.

---

### BR-TAX-010

Applied taxes SHALL be captured as snapshots on Invoice Items at issuance.

Changes to Business tax configuration SHALL NOT alter issued Invoices.

---

### BR-TAX-011

Tax calculation MAY be disabled entirely through Business configuration.

When disabled:

- No taxes SHALL be applied.
- Existing snapshots SHALL remain valid.
- New Invoices SHALL have no taxes applied.

---

### BR-TAX-012

Historical Invoices SHALL preserve their tax snapshots.

See [[01-Requirements/billing/Business-Rules#BR-BIL-007|BR-BIL-007]].

---

### BR-TAX-013

Taxes SHALL NOT be applied to Payments or Receipts.

Taxes apply only to Invoice Items.

---

## Related Documents

- [[Billing-Policies#BP-TAX-001|BP-TAX-001]] through [[Billing-Policies#BP-TAX-005|BP-TAX-005]]
- [[01-Requirements/billing/InvoiceItem|Invoice Item Business Rules]]
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[03-domain/billing/value objects/Tax-Rate|Tax Rate]]