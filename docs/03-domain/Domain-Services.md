# Domain Services

## Purpose

This document records the Domain Services within the Finance Management System.

It exists to make an explicit statement about Version 1's design, and to preserve guidance for future evolution.

---

# Version 1 Status

Version 1 defines no Domain Services.

All business behavior is owned by Aggregates, Entities, and Value Objects.

The absence of Domain Services indicates that Aggregate boundaries are correctly aligned with business responsibilities.

---

# Guiding Principle

Domain Services SHALL be introduced only when business behavior genuinely does not belong to a single Aggregate or Value Object.

See [[02-architecture/Principles#AP-012|AP-012 — Progressive Complexity]].

Additional abstractions SHALL be introduced only when justified by evolving requirements.

---

# Definition

A Domain Service represents business behavior that does not naturally belong to a single Entity or Value Object.

See [[00-Overview/Terminology#Domain Service|Terminology — Domain Service]].

---

# When to Introduce a Domain Service

A Domain Service is justified when:

- The behavior spans multiple Aggregates.
- The behavior does not naturally belong to any single Aggregate.
- The behavior requires coordination between independent business concepts.
- The behavior has a business name that is not an operation on an existing concept.
- The behavior cannot be placed inside any Aggregate without violating Aggregate boundaries.

A Domain Service SHALL NOT be introduced to:

- Hold business rules that belong inside an Aggregate.
- Compensate for poorly designed Aggregate boundaries.
- Coordinate infrastructure concerns (those belong to the Application layer).
- Provide utility functionality unrelated to business behavior.

---

# Version 1 Verification

The following business behaviors were evaluated during design.

Each was successfully placed inside an existing Aggregate or Value Object.

| Business Behavior | Owned By | Notes |
|-------------------|----------|-------|
| Invoice total calculation | Invoice Aggregate | BR-INV-007 |
| Payment recording | Invoice Aggregate | Payment is an Entity within the Invoice Aggregate |
| Invoice Balance calculation | Invoice Aggregate | BR-INV-008 |
| Invoice status transitions | Invoice Aggregate | Lifecycle managed within the Aggregate |
| Customer Credit application | Invoice operation + Customer state update | Application layer coordinates two-step update |
| Overpayment handling | Invoice operation + Customer state update | Application layer coordinates; policy-driven |
| Receipt generation | Application layer | Coordinated after successful Payment recording |
| Document Number uniqueness | Application layer + repository query | Domain does not enforce uniqueness directly |
| Customer Credit balance | Customer Aggregate | Customer Credit Value Object |

No behavior required a Domain Service.

---

# Candidates Under Observation

The following patterns are candidates for future Domain Services if complexity demands.

They are NOT Domain Services in Version 1.


| Pattern | Currently Handled By | Would Become a Service If... |
|---------|---------------------|------------------------------|
| Customer Credit application | Invoice operation + Customer state update | Coordination logic grows beyond a simple two-step update, or becomes policy-driven across multiple scenarios |
| Overpayment handling | Invoice operation + Customer state update | Rules become configurable across multiple interacting policies |
| Document Number generation | Application layer + repository uniqueness check | Numbering strategies become multiple, configurable, and business-rule-driven |
| Receipt generation | Application layer coordinating Payment + Invoice | Receipt rules become independent of the underlying Payment |
| Invoice total calculation | Invoice Aggregate | Calculation complexity grows beyond what the Invoice Aggregate can maintain coherently — for example, jurisdictional tax rules, proration, or advanced allocation across multiple Invoices |

Introducing any of these prematurely would add abstraction without business value.

---

# Anti-Patterns to Avoid

## Anaemic Domain Model

Moving business rules out of Aggregates into Domain Services produces anaemic Aggregates.

Business rules SHALL remain inside the Aggregates that own the relevant state.

## Service Explosion

Creating a Domain Service for every cross-Aggregate interaction produces unnecessary indirection.

Simple coordination belongs in the Application layer.

## Infrastructure Services Disguised as Domain Services

Behaviors involving persistence, email, PDF generation, or external systems are NOT Domain Services.

These belong to the Application or Infrastructure layers.

## Utility Services

Stateless helper methods are not Domain Services.

These belong in shared utility modules outside the Domain.

---

# Future Considerations

Future versions MAY introduce Domain Services for:

- Multi-currency conversion (when multiple currencies are supported).
- Tax calculation across jurisdictions (when tax rules become complex).
- Advanced discount rules (when discount policies span Aggregates).
- Payment allocation across multiple Invoices (when Version 1's single-Invoice model is extended).

Each SHALL be introduced only when justified by demonstrated business need.

Each introduction SHALL be documented in this file.

---

# Review

This document SHALL be updated whenever a Domain Service is introduced or retired.

The presence of this document is itself an architectural statement: Version 1 has no Domain Services because none were needed.