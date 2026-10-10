# Business

## Purpose

Business represents the organization operating within the Billing module.

It establishes the organizational context in which billing activities occur and owns business-specific billing configuration.

Every billing operation SHALL belong to exactly one Business.


---

# Responsibilities

Business SHALL be responsible for:

- Representing the billing organization.
- Maintaining business identity.
- Maintaining business information.
- Owning billing configuration.
- Providing organizational context for billing operations.

Business SHALL NOT be responsible for:

- Managing Invoice lifecycle.
- Recording Payments.
- Generating Receipts.
- Calculating financial values.

See [[03-domain/Aggregate-Map|Aggregate Map]] for the full map of Aggregates and their reference directions.

---

# Business Rules

Business SHALL enforce the following Business Rules:

- Every Business SHALL have a unique identity.
- Every Business SHALL maintain required business information.
- Billing operations SHALL belong to a Business.
- Business identity SHALL remain immutable.

---

# State

Business maintains:

- Its identity.
- Business name.
- Business contact information.
- Business branding.
- Billing preferences.
- Document numbering configuration.
- PDF template configuration.
- Tax configuration (zero or more Tax Rates).
- Default currency.

Additional organizational information MAY be maintained as required.

---

# Operations

Business supports the following operations:

- Register Business.
- Update Business Information.
- Configure Billing Preferences.
- Configure Document Numbering.
- Configure PDF Templates.
- Configure Tax Rates.
- Enable or Disable Tax Calculation.

Business operations SHALL preserve organizational consistency.

---

# Invariants

The following conditions SHALL always hold:

- Every Business has a valid identity.
- Every Business has a valid name.
- Business identity SHALL NOT change.
- Billing configuration SHALL remain internally consistent.
- Tax Rates SHALL have unique codes within the Business.
- Tax configuration SHALL remain internally consistent.

---

# Tax Configuration

The Business owns zero or more Tax Rates.

Tax Rates are managed through the Business Aggregate.

If a Tax Rate is changed, existing Invoice Items retain the tax snapshot applied at issuance.

Tax calculation MAY be disabled entirely through Business configuration.

See [[03-domain/billing/value objects/Tax-Rate|Tax Rate]] and [[01-Requirements/billing/Tax|Tax Business Rules]].

---

# Collaborators

Business collaborates with:

- [[03-domain/billing/aggregates/Customer|Customer]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates components/Payment|Payment]]
- [[03-domain/billing/aggregates/Receipt|Receipt]]
- [[03-domain/billing/value objects/Document-Number|Document Number]]

---

# Dependencies

Business depends upon:

- [[03-domain/shared/Identifier|Identifier]]

Business MAY depend upon shared configuration concepts introduced in future versions.

Business SHALL NOT depend upon Invoice or Payment implementations.

---

# Validation

Business validates:

- Required business information.
- Billing configuration.
- Document numbering configuration.
- PDF configuration.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

Expected business failures include:

- Missing required business information.
- Invalid billing configuration.
- Invalid numbering configuration.
- Duplicate business registration where prohibited.

Unexpected system failures remain outside the responsibility of Business.

---

# Related Requirements

Functional Requirements

- [[Functional-Requirements#FR-001|FR-001]]
- [[Functional-Requirements#FR-026|FR-026]]
- [[Functional-Requirements#FR-027|FR-027]]

Business Policies

- [[Billing-Policies#BP-PDF-001|BP-PDF-001]]

Business Rules

- [[Document#BR-DOC-001|BR-DOC-001]]
- [[Document#BR-DOC-005|BR-DOC-005]]

---

# Design Rationale

Business represents the organizational boundary of the Billing module.

Business-specific configuration is centralized within this Aggregate to ensure consistent billing behavior across Customers, Invoices, Payments, and Receipts.

---

# Future Considerations

Future versions MAY introduce:

- Multiple business locations.
- Multiple business branches.
- Organization-specific tax configuration.
- Multiple branding profiles.
- Multi-tenant support.

Such additions SHALL preserve Business as the organizational root of the Billing module.