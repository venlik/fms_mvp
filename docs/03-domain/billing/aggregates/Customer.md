# Customer

## Purpose

Customer represents an individual or organization that conducts business with a Business.

Customers receive business documents, incur financial obligations, and make Payments within the Billing module.

Every Customer SHALL belong to exactly one Business.

---

# Responsibilities

Customer SHALL be responsible for:

- Representing customer identity.
- Maintaining customer information.
- Maintaining customer contact information.
- Serving as the recipient of business documents.
- Maintaining customer billing information.

Customer SHALL NOT be responsible for:

- Managing Invoice lifecycle.
- Recording Payments.
- Calculating financial values.
- Managing Business configuration.

---

# Business Rules

Customer SHALL enforce the following Business Rules:

- Every Customer SHALL have a unique identity within its Business.
- Every Customer SHALL belong to exactly one Business.
- Required customer information SHALL be maintained.
- Customer identity SHALL remain immutable.

---

# State

Customer maintains:

- Its identity.
- The Business to which it belongs.
- Customer name.
- Contact information.
- Billing information.
- **Customer Credit (Value Object).**
- Optional notes.

Additional information MAY be maintained according to business requirements.

---

# Operations

Customer supports the following operations:

- Register Customer.
- Update Customer Information.
- Update Contact Information.
- Update Billing Information.
- Deactivate Customer.
- Reactivate Customer.
- Grant Credit.
- Apply Credit.
- View Credit History.

Customer operations SHALL preserve business consistency.

---

# Invariants

The following conditions SHALL always hold:

- Every Customer belongs to one Business.
- Every Customer has a valid identity.
- Every Customer has a valid name.
- Customer identity SHALL remain immutable.
- Customer Credit amount SHALL never be negative.
- Customer Credit currency SHALL match the Business default currency.

---

# Owned Value Objects

Customer owns:

- [[03-domain/billing/value objects/Customer-Credit|Customer Credit]]

Customer owns the **current** Customer Credit value.

Customer Credit changes are tracked through [[03-domain/billing/Credit-Movement|Credit Movement]] records.

Credit Movements are Domain Records that live **outside** the Customer Aggregate.

The Customer Aggregate holds only the current balance.

Movement history is preserved separately and independently of Customer loading.

See [[03-domain/Aggregate-Map#Why Credit Movement is outside Customer|Aggregate Map — Why Credit Movement is outside Customer]].

---

# Collaborators

Customer collaborates with:

- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/billing/aggregates/Invoice|Invoice]]
- [[03-domain/billing/aggregates components/Payment|Payment]]
- [[03-domain/billing/aggregates/Receipt|Receipt]]

---

# Dependencies

Customer depends upon:

- [[03-domain/billing/aggregates/Business|Business]]
- [[03-domain/shared/Identifier|Identifier]]

Customer SHALL NOT depend upon Invoice or Payment implementations.

---

# Validation

Customer validates:

- Required customer information.
- Contact information.
- Business ownership.

Validation failures SHALL produce Domain Errors.

---

# Failure Cases

Expected business failures include:

- Missing required customer information.
- Duplicate customer where prohibited.
- Invalid customer information.
- Customer not found.

Unexpected system failures remain outside the responsibility of Customer.

---

# Related Requirements

Functional Requirements

- Customer Management
- Customer Registration
- Customer Information Management

Business Rules

- Customer-related Business Rules

Business Policies

- Customer-related Business Policies

---

# Design Rationale

Customer centralizes all information describing the recipient of billing activities.

Invoices, Payments, and Receipts reference Customers rather than duplicating customer information.

---

# Future Considerations

Future versions MAY introduce:

- Customer categories.
- Customer addresses.
- Tax identification.
- Multiple contact persons.
- Credit limits.
- Customer account status.

Such additions SHALL preserve Customer as the business representation of a billing recipient.