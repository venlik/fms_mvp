# Invoice Item

## Purpose

Invoice Item represents a single billable line within an Invoice.

It describes a specific product, service, or charge together with its pricing information.

Invoice Items SHALL exist only as part of an Invoice Aggregate.

---

# Responsibilities

Invoice Item SHALL be responsible for:

- Representing a billable line.
- Maintaining item details.
- Maintaining pricing information.
- Calculating its line total.
- Preserving its own consistency.

Invoice Item SHALL NOT be responsible for:

- Managing Invoice lifecycle.
- Accepting Payments.
- Calculating Invoice totals.
- Managing Customer information.
- Existing independently of an Invoice.

---

# Business Rules

Invoice Item SHALL enforce the following Business Rules:

- Every Invoice Item belongs to exactly one Invoice.
- Quantity SHALL be greater than zero.
- Unit Price SHALL be valid.
- Line Subtotal SHALL equal Quantity × Unit Price.
- Sum of applied discounts SHALL NOT exceed Line Subtotal.
- Line Discounted Subtotal SHALL equal Line Subtotal minus applied discounts.
- Line Total SHALL equal Line Discounted Subtotal plus the sum of applied taxes.
- Applied discounts and taxes SHALL be captured as snapshots at Invoice issuance.
- Currency SHALL remain consistent with the owning Invoice.

---

# State

Invoice Item maintains:

- Its identity.
- Description.
- Quantity.
- Unit Price.
- Line Subtotal.
- Applied Discounts (snapshot).
- Line Discounted Subtotal.
- Applied Taxes (snapshot).
- Line Total.

Additional descriptive information MAY be maintained where required.

---

# Operations

Invoice Item supports the following business operations:

- Create Item.
- Update Description.
- Update Quantity.
- Update Unit Price.
- Apply Discount.
- Remove Discount.
- Apply Tax Rate.
- Remove Tax Rate.
- Calculate Line Subtotal.
- Calculate Line Discounted Subtotal.
- Calculate Line Total.

Invoice Item operations SHALL preserve consistency.

---

# Invariants

The following conditions SHALL always hold:

- Invoice Item belongs to one Invoice.
- Quantity is greater than zero.
- Unit Price is valid.
- Line Subtotal accurately reflects Quantity × Unit Price.
- Sum of applied discounts SHALL NOT exceed Line Subtotal.
- Line Discounted Subtotal accurately reflects Line Subtotal minus applied discounts.
- Applied discounts and taxes accurately reflect snapshots at issuance.
- Line Total accurately reflects Line Discounted Subtotal plus taxes.
- Currency remains consistent with the Invoice.

---

# Discount Application

An Invoice Item MAY have zero or more discounts applied.

Discounts are applied sequentially in the order they were added.

The order of discount application SHALL be preserved.

Discount calculation:

1. Line Subtotal = Quantity × Unit Price
2. Apply first discount → intermediate amount
3. Apply second discount → intermediate amount
4. Continue until all discounts applied
5. Line Discounted Subtotal = final intermediate amount

Discounts SHALL NOT exceed Line Subtotal at any step.

Percentage discounts apply to the running amount.

Fixed discounts subtract an absolute amount.

See [[03-domain/billing/value objects/Discount|Discount]] and [[01-Requirements/billing/Discount|Discount Business Rules]].

---

# Tax Application

Taxes are applied to the Line Discounted Subtotal.

Discount-before-tax order is the Version 1 default.

See [[Billing-Policies#BP-DIS-004|BP-DIS-004]].

An Invoice Item MAY have zero or more taxes applied.

Applied taxes are captured as snapshots of the applicable Tax Rate at Invoice issuance.

Tax calculation:

1. Line Discounted Subtotal = Line Subtotal minus applied discounts
2. Line Tax = Line Discounted Subtotal × Tax Rate (per tax)
3. Line Total = Line Discounted Subtotal + Sum of Line Taxes

Applied discounts and taxes are captured as snapshots at Invoice issuance.

Changes to the Business discount or tax configuration SHALL NOT alter issued documents.

See [[03-domain/billing/value objects/Tax-Rate|Tax Rate]] and [[01-Requirements/billing/Tax|Tax Business Rules]].

---

# Aggregate Ownership

## Owned Concepts

Invoice Item owns no other Domain concepts.

---

## Owned By

Invoice Item is owned by:

- [[03-domain/billing/aggregates/Invoice|Invoice]]

Invoice Item SHALL NOT exist independently of its owning Invoice.

---

## Referenced Concepts

Invoice Item references:

- [[03-domain/shared/Money|Money]]

---

# Collaborators

Invoice Item collaborates with:

- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/shared/Money|Money]]

---

# Dependencies

Invoice Item depends upon:

Shared Concepts

- [[03-domain/shared/Identifier|Identifier]]
- [[03-domain/shared/Money|Money]]
- [[03-domain/shared/Result|Result]]
- [[DomainError|Domain Error]]

Billing Concepts

- [[03-domain/billing/aggregates/Invoice|Invoice]]

Invoice Item SHALL NOT depend upon:

- Payment
- Receipt
- Customer
- Business

---

# Validation

Invoice Item validates:

- Quantity.
- Unit Price.
- Line Total consistency.
- Currency compatibility.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

Expected business failures include:

- Invalid quantity.
- Invalid unit price.
- Currency mismatch.
- Invalid line total calculation.

Expected failures SHALL be represented using the Result model.

Unexpected system failures remain outside the responsibility of Invoice Item.

---

# Related Requirements

Functional Requirements

- Invoice Item Management

Business Rules

- [[01-Requirements/billing/InvoiceItem#BR-ITM-001|BR-ITM-001]] to [[01-Requirements/billing/InvoiceItem#BR-ITM-014|BR-ITM-014]]
- [[01-Requirements/billing/Invoice#BR-INV-003|BR-INV-003]]
- [[01-Requirements/billing/Invoice#BR-INV-007|BR-INV-007]]

Business Policies

None.

---

# Design Rationale

Invoice Item models a single billable component of an Invoice.

Ownership by the Invoice Aggregate ensures that all structural modifications occur through the Aggregate Root, preserving consistency and preventing orphaned Invoice Items.

---

# Future Considerations

Future versions MAY introduce:

- Item discounts.
- Item taxes.
- Measurement units.
- Product references.
- Service duration.
- Inventory integration.

Such additions SHALL preserve Invoice Item as a component owned by the Invoice Aggregate.