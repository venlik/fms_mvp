# Invoice Duplication

## Purpose

Defines how an existing Invoice is duplicated to create a new Draft Invoice.

Duplication is a productivity feature: it allows users to reuse an existing Invoice as a starting point for a new one.

Duplication SHALL NOT create financial obligations. The duplicate starts as a Draft and must be issued through the normal lifecycle.

---

# Scope

Applies to the Billing module.

Applies to Invoices only.

Receipts and Payments are not duplicated by this operation.

---

# Trigger

A user requests to duplicate an existing Invoice.

See [[01-Requirements/common/Use-Cases#UC-INV-005|UC-INV-005]].

---

# Preconditions

- The source Invoice exists.
- The source Invoice belongs to the active Business.
- No other precondition applies based on source Invoice status (any status is duplicable).

---

# What Is Copied

The duplicate receives the following from the source:

- Business reference (by Identifier)
- Customer reference (by Identifier)
- All Invoice Items (description, quantity, unit price)
- Applied Discount configuration on each Invoice Item (type, value, label)
- Applied Tax Rate references on each Invoice Item
- Invoice-level Discount configuration (if any)
- Invoice notes (if any)

## Commercial Configuration vs Snapshots

Duplication copies the **draftable commercial structure** of the source Invoice:

- Discount configuration (as business references)
- Tax Rate references (as business references)

Duplication does NOT copy issuance snapshots:

- Tax amount snapshots
- Discount amount snapshots
- Issuance-captured snapshot state

Snapshots only exist on issued Invoices. The duplicate starts as a Draft and has not been issued.

When the duplicate is issued, applicable snapshots SHALL be captured from the current Business configuration, matching how a fresh Draft Invoice would be issued.

See [[03-domain/billing/aggregates/Invoice#Discount and Tax Integration|Invoice — Discount and Tax Integration]].

---

# What Is NOT Copied

The duplicate does NOT receive:

- Invoice Identifier (a new one is assigned)
- Document Number (assigned at issuance per [[01-Requirements/billing/Document-Numbering#DN-002|DN-002]])
- Invoice Status (starts as Draft)
- Payments (financial records are not copied)
- Receipts (financial records are not copied)
- Outstanding Balance (recalculated from zero payments)
- Creation date (a new one is recorded)
- Modification date (a new one is recorded)

---

# Source Reference

The duplicate SHALL store an optional read-only reference to the source Invoice Identifier.

This reference:

- SHALL be immutable after duplication.
- SHALL NOT affect behavior of either Invoice.
- SHALL be available for display and reporting.

The source Invoice SHALL NOT be modified by the duplication operation.

---

# Initial Status

The duplicate SHALL start in Draft status.

Drafts are editable.

The duplicate MUST be reviewed and issued through the normal lifecycle before becoming an official business document.

---

# Source Invoice Status

Any Invoice status is duplicable:

- Draft
- Issued
- Partially Paid
- Paid
- Archived

Duplication does not alter the source Invoice in any way.

---

# Customer Handling

The duplicate SHALL reference the same Customer as the source Invoice.

If the Customer has been archived:

- Duplication SHALL be permitted.
- The duplicate SHALL reference the archived Customer.
- The user MAY change the Customer on the Draft.

See [[01-Requirements/billing/Customer#BR-CUS-003|BR-CUS-003]].

---

# Invoice Item Handling

Invoice Items SHALL be copied as-is.

Item descriptions, quantities, and unit prices SHALL be preserved.

Currency SHALL match the Business default currency (per [[01-Requirements/billing/Currency-Enforcement#BR-CUR-001|BR-CUR-001]]).

---

# Postconditions

After duplication:

- A new Draft Invoice exists.
- The source Invoice is unchanged.
- The new Draft Invoice references the source via `duplicatedFromId`.
- The new Draft Invoice has no Document Number.
- The new Draft Invoice has no Payments.
- The new Draft Invoice has no Receipts.

---

# Failure Cases

## FC-DUP-001 — Source Invoice Not Found

If the source Invoice does not exist, the operation SHALL return a Domain Error.

## FC-DUP-002 — Source Invoice Belongs to Different Business

If the source Invoice belongs to a different Business, the operation SHALL return a Domain Error.

## FC-DUP-003 — Customer Not Accessible

If the Customer cannot be referenced, the operation SHALL return a Domain Error.

Archived Customers do not trigger this error.

## FC-DUP-004 — Invoice Item Copy Failure

If any Invoice Item cannot be copied (e.g., corrupted state), the operation SHALL return a Domain Error.

---

# Related Requirements

- [[01-Requirements/common/Functional-Requirements#FR-013|FR-013]] — Duplicate Invoice
- [[01-Requirements/common/Functional-Requirements#FR-043|FR-043]] — Duplication source reference
- [[01-Requirements/common/Use-Cases#UC-INV-005|UC-INV-005]]

---

# Related Business Rules

- [[01-Requirements/billing/Invoice#BR-INV-014|BR-INV-014]] — Duplication rules

---

# Related Documents

- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]
- [[01-Requirements/billing/Document-Numbering|Document Numbering]]