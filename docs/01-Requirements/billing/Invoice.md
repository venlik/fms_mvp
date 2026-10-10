# Invoice Business Rules

## Purpose

Defines business rules governing Invoices.

Invoices represent requests for payment issued by the Business.

---

## Rules

### BR-INV-001

Every Invoice SHALL belong to exactly one Customer.

---

### BR-INV-002

Every Invoice SHALL belong to exactly one Business.

---

### BR-INV-003

Every Issued Invoice SHALL contain one or more Invoice Items. A Draft Invoice MAY contain zero.

---

### BR-INV-004

Every Invoice SHALL have exactly one Identifier.

---

### BR-INV-005

Every Issued Invoice SHALL have exactly one Document Number.

Draft Invoices SHALL NOT have a Document Number.

---

### BR-INV-006

Issued Invoice Document Numbers SHALL be unique within the Business.

Uniqueness is enforced by the Persistence layer through a unique constraint and coordinated by the Application layer.

See [[01-Requirements/billing/Document-Numbering|Document Numbering]].

---

### BR-INV-007

Invoice Total SHALL be calculated as:

Sum of Line Discounted Subtotals
− Invoice-level Discount (if any)
+ Sum of Line Taxes

Where:

- Line Subtotal = Quantity × Unit Price
- Line Discounted Subtotal = Line Subtotal − Applied Discounts
- Line Taxes = Line Discounted Subtotal × Tax Rates

See [[01-Requirements/billing/Discount|Discount Business Rules]] and [[01-Requirements/billing/Tax|Tax Business Rules]].

---

### BR-INV-008

Invoice Balance SHALL equal:

Invoice Total − Total Payments applied to the Invoice.

Payments are owned by the Invoice Aggregate and are applied through the Invoice Aggregate Root.

---

### BR-INV-009

Invoice Balance SHALL never become negative.

When a payment exceeds the outstanding balance and the Business overpayment policy permits acceptance, the excess SHALL be recorded as Customer Credit and SHALL NOT reduce Invoice Balance below zero.

---

### BR-INV-010

Issued Invoices SHALL preserve historical financial accuracy.

---

### BR-INV-011

An Invoice SHALL NOT be modified after finalization except through approved business operations.

---

### BR-INV-012

Only Invoices in Draft status MAY be deleted.

Issued, Partially Paid, Paid, and Archived Invoices SHALL NOT be deleted.

---

### BR-INV-013

Invoice Document Numbers SHALL be assigned at issuance, not at Draft creation.

Draft Invoices SHALL NOT have a Document Number.

---

### BR-INV-014

An Invoice MAY be duplicated regardless of its status.

A duplicated Invoice SHALL:

- Start in Draft status.
- Receive a new Invoice Identifier.
- Receive no Document Number until issuance.
- Copy Business, Customer, Invoice Items, and notes from the source.
- NOT copy Payments, Receipts, Outstanding Balance, or Document Number.
- Store an optional read-only reference to the source Invoice Identifier.

The source Invoice SHALL NOT be modified by duplication.

See [[01-Requirements/billing/Invoice-Duplication|Invoice Duplication]].

---

### BR-INV-015

Invoice-level discount SHALL NOT exceed the sum of Line Discounted Subtotals.

Invoice-level discount SHALL NOT recalculate line taxes.


---

## Related Documents

- [[Billing-Policies#BP-INV-001|BP-INV-001]]
- [[Billing-Policies#BP-INV-003|BP-INV-003]]
- [[01-Requirements/billing/InvoiceItem|Invoice Item]]
- [[01-Requirements/billing/Payment|Payment]]
