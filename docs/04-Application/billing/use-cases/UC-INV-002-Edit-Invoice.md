# UC-INV-002 — Edit Invoice

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-INV-002|UC-INV-002]]

## Application Service

`EditInvoiceService`

## Purpose

Modify a Draft Invoice before it is issued.

Only Draft Invoices may be edited. Issued, Partially Paid, Paid, and Archived Invoices are not editable.

---

# Preconditions

- The Invoice exists.
- The Invoice is in Draft status.
- The Customer referenced by the Invoice still exists.

---

# Postconditions

- The Draft Invoice reflects the requested changes.
- The Invoice remains in Draft status.
- No Document Number is assigned.
- No Payments or Receipts are affected.

---

# Aggregates Involved

- Invoice (modification)

---

# Transaction Required?

No.

The Invoice Aggregate maintains its own consistency.

---

# Editable Fields

Draft Invoices support editing of:

- Invoice Items (add, remove, update description/quantity/unit price)
- Applied Discounts (add, remove)
- Applied Tax Rates (add, remove)
- Invoice-level Discount (add, remove)
- Invoice notes

Draft Invoices do NOT support editing of:

- Invoice Identifier
- Owning Business
- Owning Customer
- Document Number (not assigned)
- Invoice Status (via this operation)

---

# Domain Operations Invoked

- `Invoice.AddItem(...)`
- `Invoice.RemoveItem(...)`
- `Invoice.UpdateItem(...)`
- `Invoice.ApplyDiscount(...)`
- `Invoice.RemoveDiscount(...)`
- `Invoice.ApplyTaxRate(...)`
- `Invoice.RemoveTaxRate(...)`
- `Invoice.ApplyInvoiceDiscount(...)`
- `Invoice.RemoveInvoiceDiscount(...)`
- `InvoiceRepository.save(invoice)`

Each operation validates the Aggregate's invariants before applying.

---

# Cross-Aggregate Conditions

None.

All cross-Aggregate references (Customer, Business) were established when the Invoice was created.

---

# Failure Modes

| Failure | Domain Error |
|---------|--------------|
| Invoice not found | Resource Not Found |
| Invoice is not in Draft status | Business Rule Violation |
| Invoice Item validation fails | Validation Error |
| Discount exceeds Line Subtotal | Business Rule Violation |
| Invalid Invoice Item identifier | Resource Not Found |

---

# Related Requirements

- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[01-Requirements/billing/InvoiceItem|Invoice Item Business Rules]]
- [[01-Requirements/billing/Billing-Policies#BP-INV-003|BP-INV-003]] — Issued Invoice modification policy (Issued only; not applicable to Drafts)
- [[01-Requirements/billing/InvoiceStatus|Invoice Status]]
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]

---

# References

- [[04-Application/shared/Application-Services|Application Services]]
- [[04-Application/shared/Transaction-Management|Transaction Management]]
- [[04-Application/shared/Result-Propagation|Result Propagation]]