# Finance Management System

# Use Cases

## Purpose

This document identifies the primary interactions between users and the Finance Management System.

Detailed use case specifications MAY be added as the system evolves.

---

# Actors

## Primary Actors

- Business Owner
- Accountant
- Cashier

---

## Secondary Actors

- Customer (through generated financial documents)

---

# Customer Management

## UC-CUS-001

Register Customer

### Goal

Create a new customer.

### Primary Actor

User

### Success Outcome

Customer is available for future financial transactions.

---

## UC-CUS-002

Update Customer

### Goal

Modify customer information.

---

## UC-CUS-003

Archive Customer

### Goal

Prevent further business operations while preserving historical records.

---

## UC-CUS-004

Search Customers

### Goal

Locate existing customers.

---

# Invoice Management

## UC-INV-001

Create Invoice

### Goal

Create a new invoice for a customer.

---

## UC-INV-002

Edit Invoice

### Goal

Modify an editable invoice.

---

## UC-INV-003

Review Invoice

### Goal

Preview invoice before finalization or export.

---

## UC-INV-004

Generate Invoice PDF

### Goal

Produce a printable invoice.

---

## UC-INV-005

Duplicate Invoice

### Goal

Create a new Draft Invoice using an existing Invoice as a starting point.

### Primary Actor

User

### Preconditions

- Source Invoice exists.
- Source Invoice belongs to the active Business.

### Postconditions

- A new Draft Invoice exists.
- The source Invoice is unchanged.
- The new Draft Invoice references the source via `duplicatedFromId`.
- No Document Number is assigned to the duplicate.
- No Payments or Receipts are copied.

### Related

- [[01-Requirements/billing/Invoice-Duplication|Invoice Duplication]]

---

## UC-INV-007

Issue Invoice

### Goal

Transition a Draft Invoice to Issued status, assigning a Document Number.

### Primary Actor

User

### Preconditions

- Invoice exists in Draft status.
- Invoice contains at least one Invoice Item.
- Business numbering policy is configured.

### Postconditions

- Invoice is in Issued status.
- Invoice has a unique Document Number.
- Document Number is immutable.
- Invoice is no longer editable structurally.

---

# Receipt Management

## UC-REC-001

Record Payment

### Goal

Record payment received from a customer.

---

## UC-REC-002

Generate Receipt

### Goal

Generate proof of payment.

---

## Reporting

## UC-REP-001

Generate Invoice Report

---

## UC-REP-002

Generate Receipt Report

---

## UC-REP-003

Generate Customer Transaction Report

---

## UC-REP-004

Generate Financial Summary

---

# Data Management

## UC-DAT-001

Export Business Data

---

## UC-DAT-002

Import Business Data (Future)

---

# Customer Credit Management

## UC-CUS-005

View Customer Credit

### Goal

View the current Customer Credit balance for a Customer.

### Primary Actor

User

### Success Outcome

Customer Credit balance is displayed.

---

## UC-CUS-006

View Customer Credit History

### Goal

View the complete movement history of a Customer's credit.

### Primary Actor

User

### Success Outcome

Credit Movements are displayed in chronological order.

---

## UC-INV-006

Apply Customer Credit to Invoice

### Goal

Apply available Customer Credit to reduce an Invoice's outstanding balance.

### Primary Actor

User

### Preconditions

- Customer has available Customer Credit.
- Invoice belongs to the same Customer.
- Invoice is in Issued or Partially Paid status.

### Success Outcome

- Invoice Balance reduced.
- Customer Credit reduced.
- Payment recorded with method `Customer Credit`.
- Receipt generated.
- Credit Movement recorded.

---

# Future Use Cases

Additional use cases MAY be introduced as new business modules are added.