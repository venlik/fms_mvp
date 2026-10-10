# UC-INV-007 — Issue Invoice

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-INV-007|UC-INV-007]]

## Application Service

`IssueInvoiceService`

## Purpose

Transition a Draft Invoice to Issued status, assigning a Document Number.

---

# Preconditions

- The Invoice exists.
- The Invoice is in Draft status.
- The Invoice contains at least one Invoice Item.
- The Business's numbering policy is configured.

---

# Postconditions

- The Invoice is in Issued status.
- The Invoice has a unique Document Number.
- The Document Number is immutable.
- The Invoice is no longer editable structurally.

---

# Aggregates Involved

- Invoice (modification)
- Document Number Sequence (modification)

---

# Transaction Required?

Yes.

The Invoice status transition and the Document Number assignment must commit together.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

---

# Domain Operations Invoked

- `Invoice.Issue()` — Domain validates issuance preconditions but does not assign a number
- `InvoiceRepository.save(invoice)`

---

# Application-Owned Logic

The Application Service assigns the Document Number.

See [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]].

Steps:

1. Open a transaction
2. Load the Invoice
3. Call `Invoice.Issue()` — Domain returns SuccessResult or ErrorResult
4. On success, compute the next Document Number
5. Attempt to persist
6. Retry on conflict (bounded)
7. Commit

---

# Cross-Aggregate Conditions

None beyond the Document Number Sequence coordination.

---

# Failure Modes

| Failure | Domain Error |
|---------|--------------|
| Invoice contains no items | Business Rule Violation |
| Invoice already Issued | Conflict |
| Invalid lifecycle transition | Business Rule Violation |
| Sequence exhausted | Resource Exhausted |
| Conflict persists after retries | Persistence Integrity |
| Missing sequence configuration | Configuration Error |

---

# References

- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[01-Requirements/billing/InvoiceStatus|Invoice Status]]
- [[01-Requirements/billing/Document-Numbering|Document Numbering]]
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]
- [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]]