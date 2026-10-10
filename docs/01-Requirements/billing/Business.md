# Business Rules

## Purpose

Defines business rules governing the Business aggregate.

The Business aggregate represents the organization issuing financial documents.

---

## Rules

### BR-BUS-001

Exactly one active Business SHALL exist within a Version 1 installation.

---

### BR-BUS-002

Every Business SHALL have a unique Identifier.

---

### BR-BUS-003

Every Business SHALL have a legal or trading name.

---

### BR-BUS-004

A Business SHALL define a default operating currency.

---

### BR-BUS-005

A Business MAY define contact information.

---

### BR-BUS-006

A Business MAY define one or more addresses.

---

### BR-BUS-007

A Business SHALL own its document numbering policies.

---

### BR-BUS-008

Changes to Business information SHALL NOT invalidate previously issued financial documents.

---

## Related Documents

- [[Business-Rules]]
- [[03-domain/billing/aggregates/Business|Business Aggregate Specification]]