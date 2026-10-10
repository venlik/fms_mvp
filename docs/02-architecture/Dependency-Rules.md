# Finance Management System

# Dependency Rules

## Purpose

This document defines the permitted dependency relationships between architectural layers and business modules.

Dependency Rules preserve architectural integrity by preventing lower-level concerns from influencing higher-level business concepts.

---

# Goals

Dependency Rules SHALL:

- Preserve separation of concerns.
- Protect the Domain from infrastructure.
- Reduce coupling.
- Improve maintainability.
- Support independent evolution of modules.

---

# Architectural Dependency Direction

Compile-time dependencies SHALL follow the following direction:

User Interface

↓

Application

↓

Domain

The Persistence layer implements contracts defined by the Domain.

Therefore:

Persistence

↓

Domain

NOT

Domain

↓

Persistence

---

# Layer Dependencies

## User Interface

The User Interface MAY depend upon:

- Application

The User Interface SHALL NOT depend directly upon:

- Domain
- Persistence

---

## Application

The Application layer MAY depend upon:

- Domain

The Application SHALL NOT depend directly upon:

- User Interface
- Persistence implementations

---

## Domain

The Domain MAY depend upon:

- Shared Domain Concepts

The Domain SHALL NOT depend upon:

- User Interface
- Application
- Persistence
- Frameworks
- Databases

---

## Persistence

Persistence MAY depend upon:

- Domain

Persistence SHALL implement Domain-defined contracts.

Persistence SHALL NOT introduce business behavior.

---

# Repository Ownership

Repository interfaces belong to the Domain.

Repository implementations belong to Persistence.

Example

Domain

InvoiceRepository

↓

Persistence

IsarInvoiceRepository

SQLiteInvoiceRepository

MemoryInvoiceRepository

The Domain SHALL remain unaware of repository implementations.

---

# Module Dependencies

Business modules MAY depend upon Shared modules.

Example

Billing

↓

Shared

Shared modules SHALL NOT depend upon Billing.

---

# Communication Rules

Communication between layers SHALL occur through well-defined interfaces.

Layers SHALL NOT bypass intermediate layers.

Example

User Interface

↓

Application

↓

Domain

Direct User Interface access to Persistence SHALL NOT occur.

---

# Dependency Inversion

High-level business concepts SHALL define abstractions.

Lower-level infrastructure SHALL implement those abstractions.

Example

Domain

InvoiceRepository

↓

Persistence

IsarInvoiceRepository

---

# Circular Dependencies

Circular dependencies SHALL NOT exist.

Modules SHALL remain acyclic.

---

# Future Modules

Future business modules SHALL follow the same dependency rules.

Examples

- Inventory
- Accounting
- Expenses
- Payroll

---

# Review

Exceptions to these Dependency Rules SHALL require an approved Architecture Decision Record (ADR).