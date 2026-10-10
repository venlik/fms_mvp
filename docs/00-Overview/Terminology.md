# Finance Management System

# Terminology

## Purpose

This document defines the terminology conventions used throughout the Finance Management System.

Its purpose is to establish a consistent ubiquitous language across documentation, design, implementation, and discussion.

All project artifacts SHOULD follow these conventions.

---

# Requirement Keywords

The following requirement keywords SHALL be interpreted according to their defined meanings.

## SHALL

Indicates a mandatory requirement.

A requirement using "SHALL" is considered part of the system contract.

Example

The system SHALL generate an invoice number.

---

## SHOULD

Indicates a recommended requirement.

Alternative implementations MAY exist provided the overall system objectives are preserved.

Example

Repositories SHOULD remain persistence-oriented.

---

## MAY

Indicates an optional capability.

Its absence SHALL NOT be considered a defect.

Example

Future versions MAY support inventory management.

---

## MUST NOT

Indicates prohibited behavior.

Example

Money MUST NOT perform currency conversion.

---

# Naming Conventions

Documentation SHALL prefer business terminology over technical terminology.

Examples

**Preferred

Customer

Invoice

Receipt

Payment

Business Rule

Money

Currency

**Avoid

DTO

Record

POJO

Bean

Database Row

Object Model

These implementation concepts belong in technical documentation rather than business documentation.

---

# Domain Terminology

The following terms SHALL have distinct meanings.

## Customer

Represents the business party purchasing products or services.

Customer SHALL NOT be used interchangeably with User.

---

## User

Represents a person operating the software.

A User MAY create invoices on behalf of multiple customers.

---

## Identifier

Represents the internal identity of an entity.

Identifiers SHALL remain stable throughout the lifetime of the entity.

---

## Document Number

Represents a business reference assigned to a financial document.

Document Numbering Policies MAY change according to business policy.

Once assigned, a Document Number SHALL NOT change.

Document Numbers SHALL NOT be used as aggregate identifiers.

---

## Payment

Represents the transfer of money from a customer to the business.

---

## Receipt

Represents documentary evidence that a payment has been received.

Receipt SHALL NOT be considered synonymous with Payment.

---

## Money

Represents a monetary value.

Money SHALL NOT be considered a currency.

---

## Currency

Represents the monetary unit associated with Money.

Currency SHALL NOT represent an amount.

---

# Domain Modeling Terminology

## Entity

An object defined primarily by identity.

---

## Value Object

An object defined entirely by its values.

---

## Aggregate

A consistency boundary containing related domain objects.

---

## Aggregate Root

The single entry point through which an Aggregate is modified.

---

## Domain Service

Represents business behavior that does not naturally belong to an Entity or Value Object.

---

## Repository

Provides access to Aggregate persistence.

Repositories SHALL NOT contain business rules.

---

## Business Rule

A rule governing valid business behavior.

Business Rules SHALL be enforced within the Domain layer.

---

## Validation

Verification that supplied information satisfies required constraints.

Validation SHALL NOT be confused with business policy.

---

# Error Terminology

## Exception

Represents an unexpected failure.

Exceptions SHALL be reserved for programming defects, infrastructure failures, or violated API contracts.

---

## Domain Error

Represents an expected business failure.

Domain Errors SHALL be returned through Result.

---

## Result

Represents the outcome of a business operation.

A Result SHALL represent exactly one outcome.

- Success
- Failure

---

# Documentation Principles

Documentation SHALL describe:

- Intent
- Responsibilities
- Constraints
- Business behavior

Documentation SHOULD avoid implementation details unless required to clarify an architectural decision.

---

# Evolution

This terminology document SHALL evolve together with the domain model.

Existing terminology SHOULD remain stable.

New terminology SHALL be introduced before adding new business concepts to the system.