# Invoice

## Purpose

Invoice represents a formal request for payment issued by a Business to a Customer for goods or services provided.

Invoice is the central Aggregate of the Billing module and serves as the authoritative record of a financial obligation between a Business and a Customer.

Every Invoice SHALL belong to exactly one Business and exactly one Customer.

---

# Responsibilities

Invoice SHALL be responsible for:

- Representing a financial obligation.
- Managing its own lifecycle.
- Maintaining its collection of Invoice Items.
- Calculating financial totals.
- Recording outstanding balances.
- Accepting valid Payments.
- Determining its current status.
- Preserving Aggregate consistency.

Invoice SHALL NOT be responsible for:

- Managing Business information.
- Managing Customer information.
- Rendering PDF documents.
- Persisting itself.
- Processing external payment providers.

---

# Aggregate Boundary

Invoice is the Aggregate Root of the Invoice Aggregate.

The Aggregate consists of:

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates components/InvoiceItem|Invoice Items]]
- [[03-domain/billing/aggregates components/Payment|Payments]]

Other Domain concepts, including Business, Customer, and Receipt, interact with the Invoice through the Aggregate Root.

Invoice SHALL be the only externally accessible entry point into the Aggregate.

All structural changes to Invoice Items and all recording of Payments SHALL occur through the Invoice Aggregate Root.

See [[03-domain/Aggregate-Map|Aggregate Map]] for the full map of Aggregates and their reference directions.

---

# Business Rules

Invoice SHALL enforce the following Business Rules:

- Every Invoice belongs to exactly one Business.
- Every Invoice belongs to exactly one Customer.
- Every Issued Invoice has a unique Document Number.
- A Draft Invoice MAY exist without Invoice Items.
- Every Issued Invoice SHALL contain at least one Invoice Item.
- Invoice totals SHALL equal the sum of their Invoice Items subtotals.
- Invoice status SHALL follow the documented lifecycle.
- Payments SHALL NOT cause the outstanding balance to become negative.
- Applying Customer Credit SHALL follow [[01-Requirements/billing/Customer-Credit|Customer Credit Business Rules]].

---

# State

Invoice maintains:

- Its identity.
- Its Document Number (once issued).
- The owning Business.
- The Customer.
- Its collection of Invoice Items.
- Invoice-level discount (optional).
- Financial totals.
- Outstanding balance.
- Invoice Status.
- Important business dates.
- An optional reference to a source Invoice Identifier (for duplicated Invoices).

Invoice SHALL be the authoritative owner of this state.

---

# Operations

Invoice supports the following business operations:

- Create Invoice.
- Duplicate Invoice (from an existing source).
- Add Invoice Item.
- Remove Invoice Item.
- Update Invoice Item.
- Apply Discount to Invoice Item.
- Remove Discount from Invoice Item.
- Apply Tax Rate to Invoice Item.
- Remove Tax Rate from Invoice Item.
- Apply Invoice-level Discount.
- Remove Invoice-level Discount.
- Issue Invoice.
- Record Payment.
- Calculate Totals.
- Archive Invoice.

---

# Invariants

The following conditions SHALL always hold:

- Invoice identity SHALL remain immutable.
- Every Invoice belongs to one Business.
- Every Invoice belongs to one Customer.
- Outstanding Balance SHALL NOT be negative.
- Financial totals SHALL remain internally consistent.
- Invoice Status SHALL represent a valid lifecycle state.
- A duplicated Invoice's `duplicatedFromId` SHALL remain immutable after duplication.
- A duplicated Invoice SHALL NOT reference itself.
- Applied discounts and taxes SHALL remain consistent with captured snapshots.
- Invoice-level discount SHALL NOT exceed the sum of Line Discounted Subtotals.

---

# Discount and Tax Integration

Invoice totals SHALL reflect both discounts and taxes.

## Calculation Order

1. For each Invoice Item:
   - Line Subtotal = Quantity × Unit Price
   - Line Discounted Subtotal = Line Subtotal minus applied discounts
   - Line Taxes = Line Discounted Subtotal × each Tax Rate
   - Line Total = Line Discounted Subtotal + Sum of Line Taxes

2. For the Invoice:
   - Invoice Subtotal = Sum of Line Discounted Subtotals
   - Invoice-level Discount reduces Invoice Subtotal
   - Invoice Total = (Invoice Subtotal − Invoice-level Discount) + Sum of Line Taxes

## Version 1 Calculation Policy

Invoice-level discount SHALL NOT recalculate line taxes.

Line taxes remain calculated on Line Discounted Subtotals only.

This is the chosen Version 1 calculation policy.

Alternative policies — for example, where invoice-level discount reduces the taxable base — are reserved for future versions.

See [[Billing-Policies#BP-DIS-004|BP-DIS-004]].

## Snapshots

Discount snapshots and tax snapshots are preserved on Invoice Items at issuance.

Changes to the Business discount or tax configuration SHALL NOT affect issued Invoices.

See [[01-Requirements/billing/Discount|Discount Business Rules]] and [[01-Requirements/billing/Tax|Tax Business Rules]].

---

# Duplication Rationale

Invoice duplication is a productivity feature.

Duplication does not create financial obligations. The duplicate starts as a Draft and must follow the normal lifecycle.

Duplication copies the draftable commercial structure of the source Invoice:

- Customer reference
- Invoice Items (description, quantity, unit price)
- Discount configuration (business references)
- Tax Rate configuration (business references)

Duplication does NOT copy:

- Payments
- Receipts
- Historical issuance snapshots
- Document Number

Payments and Receipts are financial records tied to specific Invoices and SHALL NOT be copied.

Snapshots only exist on issued Invoices. When the duplicate is issued, snapshots SHALL be captured from current Business configuration.

The source reference (`duplicatedFromId`) provides traceability without modifying the source Invoice.

See [[01-Requirements/billing/Invoice-Duplication|Invoice Duplication]].

---

# Collaborators

Invoice collaborates with the following Domain concepts:

- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/billing/aggregates/Receipt|Receipt]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/billing/value objects/Invoice-Status|Invoice Status]]

Invoice owns the following Domain components:

- [[03-domain/billing/aggregates components/InvoiceItem|Invoice Item]]
- [[03-domain/billing/aggregates components/Payment|Payment]]

Invoice SHALL remain responsible only for its own Aggregate.

---

# Dependencies

Invoice depends upon:

Shared Concepts

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Result|Result]]
- [[DomainError|Domain Error]]

Billing Concepts

- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/billing/aggregates components/InvoiceItem|Invoice Item]]
- [[Invoice-Status|invoice Status]]

Invoice SHALL NOT depend upon:

- Persistence
- User Interface
- External payment providers
- PDF generation
- Framework-specific components

---

# Validation

Invoice validates:

- Business ownership.
- Customer association.
- Invoice Item consistency.
- Financial totals.
- Lifecycle transitions.
- Payment acceptance.
- Outstanding balance consistency.

Document Number uniqueness is enforced through the workflow defined in [[01-Requirements/billing/Document-Numbering|Document Numbering]].

The Invoice Aggregate assigns a Document Number only at issuance.

Uniqueness is enforced by the Persistence layer through a unique constraint.

---

# Failure Cases

Expected business failures include:

- Invoice contains no Invoice Items.
- Invoice has already been issued.
- Invalid lifecycle transition.
- Payment exceeds outstanding balance.
- Duplicate Document Number.
- Invalid Business or Customer association.
- Currency mismatch.
- Operation not permitted for the current Invoice Status.

Expected failures SHALL be represented using the Result model.

Unexpected system failures remain outside the responsibility of the Invoice Aggregate.

---

# Related Requirements

Functional Requirements

- Invoice Management
- Invoice Creation
- Invoice Editing
- Invoice Issuance
- Payment Recording

Business Rules

- [[01-Requirements/billing/Invoice#BR-INV-001|BR-INV-001]] to [[01-Requirements/billing/Invoice#BR-INV-015|BR-INV-015]]
- [[01-Requirements/billing/Payment#BR-PAY-001|BR-PAY-001]] to [[01-Requirements/billing/Payment#BR-PAY-011|BR-PAY-011]]
- [[01-Requirements/billing/Document#BR-DOC-001|BR-DOC-001]] to [[01-Requirements/billing/Document#BR-DOC-010|BR-DOC-010]]
- [[01-Requirements/billing/Business-Rules#BR-BIL-001|BR-BIL-001]]
- [[01-Requirements/billing/Business-Rules#BR-BIL-006|BR-BIL-006]]
- [[01-Requirements/billing/Business-Rules#BR-BIL-007|BR-BIL-007]]

---

# Future Considerations

Future versions MAY introduce:

- Credit Notes.
- Recurring Invoices.
- Installment Plans.
- Multi-currency Invoices.
- Approval workflows.
- Invoice revisions.

Such additions SHALL preserve Invoice as the Aggregate Root of the Invoice Aggregate.