# Finance Management System

# Glossary

## Purpose

This document defines the common business terminology used throughout the Finance Management System.

All documentation, software design, source code, and discussions SHALL use these definitions consistently.

The glossary establishes the project's ubiquitous language.

---

# General Terms

## Business

An organization or individual using the Finance Management System to manage financial operations.

---

## User

A person authorized to use the system.

Examples include:

- Business owner.
- Accountant.
- Cashier.
- Sales representative.

---

## Customer

A person or organization that purchases products or services from the business.

Customers may own multiple invoices and receipts.

---

## Financial Document

A business document that records a financial transaction or financial intent.

Examples include:

- Invoice.
- Receipt.

Future examples MAY include:

- Quotation.
- Credit Note.
- Debit Note.
- Purchase Order.

---

# Billing Terms

## Invoice

A financial document requesting payment from a customer for supplied goods or services.

An invoice records the products or services provided and the amount owed.

---

## Receipt

A financial document acknowledging that payment has been received.

A receipt SHALL reference the payment it represents.

---

## Invoice Item

A single line within an invoice representing one product or service.

Each invoice SHALL contain one or more invoice items.

---

## Payment

A transfer of value from a customer to the business in settlement of an invoice.

Version 1 records payments through receipts.

---

## Balance

The remaining unpaid amount of an invoice.

---

# Financial Terms

## Money

A value object representing a monetary value in a specific currency.

Money SHALL consist of:

- Amount
- Currency

---

## Currency

The monetary unit used by Money.

Examples include:

- Kenyan Shilling (KES)
- United States Dollar (USD)

Version 1 SHALL operate using a single configured business currency.

---

## Tax

A financial charge applied to an invoice.

Version 1 MAY support configurable taxes.

---

## Discount

A reduction applied to the price of an invoice or invoice item.

---

## Total

The final monetary amount after applying all calculations.

---

## Payment amount

Represents amount actually received from customer.

---

## Applied amount 

Represents portion allocated to the Invoice.

---
## Customer Credit amount

Represents excess not allocated to the Invoice

---

# Customer Terms

## Billing Address

The address associated with customer billing.

---

## Contact Information

Customer communication details.

Examples include:

- Phone number.
- Email address.

---

## Customer Credit

A monetary balance owed by the Business to a Customer.

Customer Credit typically arises from an accepted overpayment or a deposit and MAY be applied to future Invoices.

---

## Credit Movement

An immutable record of a change to a Customer's credit balance.

Credit Movements provide the audit trail for Customer Credit.

---

# Document Terms

## Document Number

A human-readable business reference assigned to a financial document.

A Document Number SHALL NOT be used as the aggregate identifier.

---

## Identifier

An internal value used to uniquely identify an entity or aggregate.

Identifiers SHALL remain independent of business meaning.

---

# Domain Terms

## Entity

A domain object defined primarily by identity.

---

## Value Object

A domain object defined entirely by its values.

---

## Aggregate

A cluster of related domain objects treated as a single consistency boundary.

---

## Aggregate Root

The primary entity responsible for maintaining the consistency of an aggregate.

---

## Domain Service

A domain concept representing business behavior that does not naturally belong to a single entity or value object.

---

## Business Rule

A rule defining valid business behavior.

Business rules SHALL be enforced by the domain model.

---

## Invariant

A condition that SHALL always remain true throughout the lifetime of a domain object.

---

## Result

Represents the outcome of a business operation.

A Result SHALL represent either:

- Success
- Failure

---

## Domain Error

Represents an expected business failure.

Domain Errors SHALL communicate business problems without using exceptions.

---

## Audit

The ability to reconstruct the history of business records and operations.

In Version 1, audit is achieved through structural immutability of financial records.

See [[02-architecture/Audit-Strategy|Audit Strategy]].

---

## Domain Record

A documented business fact that is immutable and lives outside any Aggregate.

A Domain Record is not an Entity, not a Value Object, and not an Aggregate Root.

---

# Future Terms

The glossary SHALL evolve together with the domain model.

New terminology SHALL be added before introducing new concepts into the system.

Existing definitions SHOULD remain stable to preserve a consistent ubiquitous language.

## Authorization

The process of determining whether a User is permitted to perform a specific operation.

Authorization is not implemented in Version 1.

See [[01-Requirements/common/Future-Authorization|Future Authorization Model]].

## Audit Event

A recorded business or system event with actor, timestamp, and change details.

Not implemented in Version 1.

See [[02-architecture/Audit-Strategy|Audit Strategy]].

---

## Role

A named collection of Permissions assigned to a User.

Roles are not implemented in Version 1.

---

## Permission

A specific operation that a User MAY be authorized to perform.

Permissions are not implemented in Version 1.