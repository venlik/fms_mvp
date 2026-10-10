# Billing Business Policies

## Purpose

Defines configurable business policies governing the operation of the Billing module.

Unlike Business Rules, Business Policies MAY vary between businesses and MAY change over time.

---

# Document Numbering

## BP-NUM-001

The Business SHALL define numbering policies for financial documents.

The policy SHALL include:

- Format (prefix, date component, counter, suffix)
- Sequence scope (Business-wide)
- Reset behavior (Never, Yearly, Monthly)

See [[01-Requirements/billing/Document-Numbering|Document Numbering]].

---

## BP-NUM-002

Invoice and Receipt numbering SHALL use independent sequences.

---

## BP-NUM-003

Number prefixes MAY be configured.

Examples

INV-

REC-

---

## BP-NUM-004

Document numbering MAY reset according to business policy.

Examples

- Never (default)
- Yearly
- Monthly

Reset behavior SHALL NOT affect existing documents.

Existing Document Numbers SHALL remain unchanged when a reset occurs.

---

## BP-NUM-005

Document Numbers SHALL be assigned at issuance.

Draft Invoices SHALL NOT consume sequence numbers.

---

## BP-NUM-006

Document Numbers SHALL NOT be reused.

Gaps in sequences SHALL be permitted.

---

## BP-NUM-007

Changing the numbering policy SHALL NOT alter existing Document Numbers.

New documents SHALL follow the current policy.

---

# Currency Policies

## BP-CUR-001

The Business SHALL define a default operating currency.

Every financial document SHALL use the Business default currency at the time the document is created.

---

## BP-CUR-002

Future versions MAY allow multiple operating currencies.

Version 1 SHALL operate using a single Business default currency.

Historical documents SHALL retain the currency they were issued with, even if the Business default later changes.

See [[02-architecture/Multi-Currency-Transition|Multi-Currency Transition]].

---

## BP-CUR-003

The Business MAY change its default operating currency.

Changing the default currency SHALL NOT alter the currency of existing financial documents.

New documents SHALL use the new currency.

---

# Tax Policies

## BP-TAX-001

The Business MAY define one or more Tax Rates.

Each Tax Rate SHALL include:

- A unique code within the Business.
- A display name.
- A percentage between 0 and 100.

See [[03-domain/billing/value objects/Tax-Rate|Tax Rate]].

---

## BP-TAX-002

Taxes MAY be applied automatically.

When automatic application is enabled, the Business MAY define default Tax Rates for new Invoice Items.

---

## BP-TAX-003

Taxes MAY be disabled entirely.

When disabled:

- No taxes SHALL be applied to new Invoice Items.
- Existing Invoices SHALL retain their tax snapshots.

---

## BP-TAX-004

Tax Rates SHALL be applied per Invoice Item.

An Invoice MAY contain items with different tax treatments.

---

## BP-TAX-005

Tax calculation in Version 1 SHALL be tax-exclusive.

Tax-exclusive means taxes are added to the Invoice Item Line Discounted Subtotal.

Tax-inclusive pricing is out of scope for Version 1.

---

## BP-TAX-006

Historical Invoices SHALL preserve their applied tax snapshots.

Changes to Tax Rates SHALL NOT alter issued Invoices.

---

## BP-TAX-007

Compounding taxes are out of scope for Version 1.

Taxes SHALL NOT be applied to previously-taxed amounts within the same Invoice Item.

---

# Discount Policies

## BP-DIS-001

Discounts MAY be applied per Invoice Item.

Discounts MAY be Percentage or Fixed.

See [[03-domain/billing/value objects/Discount|Discount]].

---

## BP-DIS-002

Discounts MAY be applied at the Invoice level.

An Invoice MAY have zero or one Invoice-level discount.

---

## BP-DIS-003

The maximum permitted discount MAY be configured.

Business Policy MAY limit:

- Maximum percentage per discount.
- Maximum total discount per Invoice Item.
- Maximum total discount per Invoice.

If not configured, the invariant limits apply:

- Invoice Item discounts SHALL NOT exceed Line Subtotal.
- Invoice-level discount SHALL NOT exceed the sum of Line Discounted Subtotals.

---

## BP-DIS-004

### Discount Calculation Order

Discounts SHALL be applied before tax calculation.

This is the Version 1 default and only supported order.

Discount calculation order in Version 1:

1. Line Subtotal = Quantity × Unit Price
2. Line Discounted Subtotal = Line Subtotal − applied discounts
3. Line Taxes = Line Discounted Subtotal × Tax Rates
4. Line Total = Line Discounted Subtotal + Line Taxes

Discount-after-tax policies are reserved for future versions.

---

## BP-DIS-005

### Multiple Discounts

An Invoice Item MAY have multiple discounts applied.

Discounts are applied sequentially in the order they were added.

The order of application SHALL be preserved.

---

## BP-DIS-006

### Historical Discount Snapshots

Applied discounts SHALL be captured as snapshots on Invoice Items at issuance.

Changes to Business discount configuration SHALL NOT alter issued Invoices.

Historical Invoices SHALL retain their discount snapshots.

---

# Payment Policies

## BP-PAY-001

The Business SHALL determine whether partial payments are permitted.

Default: Permitted.

---

## BP-PAY-002

The system SHALL support configurable handling of payments that exceed the outstanding invoice balance.

Version 1 supports:

1. **Reject** (default) — payment that exceeds outstanding balance is rejected in full.
2. **Accept and record Customer Credit** — outstanding balance is settled; excess is recorded as Customer Credit on the Customer.

Automatic allocation of excess to other invoices is out of scope for Version 1.

Customer Credit:

- SHALL be tracked per Customer.
- SHALL be available for application to future Invoices of the same Customer.
- SHALL NOT modify historical Invoice financial content.
- SHALL be recorded through Credit Movement records.

---

## BP-PAY-003

The Business MAY define default payment terms.

Examples

- Due on Receipt
- Net 7
- Net 30

---

### BP-PAY-004

The Business SHALL determine whether Customer Credit MAY be applied to Invoices.

Default: Permitted.

If permitted:

- Customer Credit SHALL only be applied to Invoices of the same Customer.
- Application SHALL be recorded as a Payment with Payment Method = `Customer Credit`.
- A Receipt SHALL be generated through the standard payment flow.
- Credit application SHALL respect Invoice status (Issued or Partially Paid).

---

### BP-PAY-005

The Business MAY accept Customer Deposits — payments received from a Customer that are not tied to any Invoice.

Deposits:

- SHALL increase Customer Credit.
- SHALL be recorded as Credit Movements with direction `Granted` and reason `Deposit`.
- SHALL NOT reference any Invoice.
- SHALL NOT generate a Receipt against an Invoice.

Default: Not enabled in Version 1. Reserved for future versions.

---

### BP-PAY-006

The Business MAY permit Customers to use Customer Credit as a prepayment mechanism for offline payment environments.

When enabled:

- Customers MAY deposit funds in advance.
- Deposited funds SHALL be tracked as Customer Credit.
- Customer Credit MAY be applied to future Invoices without external payment infrastructure.

Default: Not enabled in Version 1. Reserved for future versions.

---

# Customer Policies

## BP-CUS-001

Customer codes MAY be generated automatically.

---

## BP-CUS-002

Customer archiving MAY require confirmation.

---

# Document Policies

## BP-DOC-001

Documents MAY include a Business logo.

---

## BP-DOC-002

Documents MAY include payment instructions.

---

## BP-DOC-003

Document templates MAY be customized.

---

# PDF Policies

## BP-PDF-001

Generated PDFs SHALL follow the configured document template.

---

## BP-PDF-002

Paper size MAY be configurable.

Examples

- A4
- Letter

---

# Invoice Policies

## BP-INV-001

### Draft Invoice Deletion

Draft Invoices MAY be deleted without additional authorization in Version 1.

Default: Deletion permitted for Draft Invoices.

Rationale

Draft Invoices have not yet become official business documents and therefore may be discarded without affecting financial records or audit history.

Future versions MAY introduce authorization requirements when multi-user support is added.

See [[01-Requirements/common/Future-Authorization|Future Authorization Model]].

---

## BP-INV-002

### Invoice Archival Policy

The system SHALL support configurable archival of historical Invoices.

Organizations MAY configure one or more archival policies, including:

- Manual archival (default).
- Automatic archival upon reaching Paid status.
- Automatic archival after a configurable retention period for paid invoices.
- Any combination of the above.

Archival SHALL:
- Preserve the complete business history of the Invoice.
- Maintain Invoice availability for reporting, auditing, and historical reference.
- NOT modify the financial content of the Invoice.

Default: Manual archival only. Users SHALL explicitly archive Paid Invoices.

---

### Rationale

Invoice retention requirements differ between organizations and jurisdictions. Making archival policy configurable allows the system to support different operational and regulatory requirements without changing the Domain model.

---

## BP-INV-003

### Issued Invoice Modification Policy

The Business SHALL determine whether Issued Invoices MAY be modified.

Possible policies include:

- No modification permitted after issuance (default).
- Modifications permitted but create a new version with audit trail.

Authorization-based modification policies are reserved for future versions.

If modifications are permitted:
- The system SHALL preserve the original Invoice content.
- The system SHALL record the modification as a separate version.
- The system SHALL preserve a complete history of the original and modified versions.

Historical preservation is achieved through structural immutability.

See [[02-architecture/Audit-Strategy|Audit Strategy]]

Default: No modification permitted after issuance. Corrections require creating a Credit Note and a new Invoice.

See [[01-Requirements/common/Future-Authorization|Future Authorization Model]].

---

## BP-INV-004

### Invoice Voiding Policy

***This policy is reserved for future versions.

The Business SHALL determine whether Issued Invoices MAY be voided.

Voiding changes the business state of an Invoice to Void.

Voiding does NOT erase the Invoice.

Voiding does NOT remove the Invoice from the system.

Voiding preserves:

- The Invoice Identifier
- The Document Number
- The financial history
- The audit trail

Voiding invalidates the Invoice for business purposes but the record remains as historical reference.

Possible policies include:

- Voiding not permitted (default).
- Voiding permitted for unpaid Invoices only.

Authorization-based voiding policies are reserved for future versions.

If voiding is permitted:
- The system SHALL record the void with a timestamp.
- The system SHALL mark the Invoice as Void.
- The system SHALL preserve the Document Number without reuse.
- The voided Invoice SHALL remain in the system as historical record.

Historical preservation is achieved through structural immutability.

See [[02-architecture/Audit-Strategy|Audit Strategy]].

Default: Voiding not permitted. Use Credit Notes instead.

See [[01-Requirements/common/Future-Authorization|Future Authorization Model]].

---

# Future Policies

Additional policies MAY be introduced without affecting existing Business Rules.