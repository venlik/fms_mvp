# Audit Strategy

## Purpose

This document defines how the Finance Management System achieves auditability.

It exists to make explicit how business history is preserved, without introducing a dedicated audit infrastructure.

It does NOT introduce an audit log or event store into Version 1.

---

# Version 1 Approach

Version 1 achieves auditability through structural immutability.

Financial records are immutable after creation.

Business history is preserved by the structure of the Domain model itself, not by a separate audit mechanism.

No dedicated audit trail is implemented in Version 1.

---

# What Is Auditable

The following concepts are auditable by construction.

| Concept | How Audit Is Achieved |
|---------|----------------------|
| Payment | Immutable after recording |
| Receipt | Immutable after generation |
| Issued Invoice | Immutable financial content after issuance |
| Document Number | Assigned once, never reused |
| Credit Movement | Immutable append-only record |
| Customer Credit balance | Reconstructable from Credit Movements |
| Invoice lifecycle | Enforced by state transitions; status history implicit in state changes |
| Historical financial documents | Preserved per BR-BIL-007 |

---

# How Audit Is Achieved

## Structural Immutability

Financial records SHALL NOT be modified after creation.

Corrections are made by creating new records, not by modifying existing ones.

Example — Incorrect Receipt:

1. The Receipt cannot be edited.
2. The underlying Payment cannot be edited.
3. Version 1 provides no correction, reversal, or voiding operation.
4. The Receipt and Payment remain as historical records.
5. Payment and Receipt correction are reserved for a future version.

See [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]].

Example — Correcting an Issued Invoice:

1. The Issued Invoice cannot be modified.
2. Corrections are made by issuing a Credit Note (future) and a new Invoice.
3. The original Invoice remains as historical record.

## Immutable Document Numbers

Document Numbers are assigned once and never reused.

Gaps are permitted.

Deleted Drafts do not free their assigned number for reuse.

See [[01-Requirements/billing/Document-Numbering|Document Numbering]].

## Append-Only Movement Records

Customer Credit movements are recorded as Credit Movements.

Credit Movements are append-only.

Credit Movements provide the historical record from which the balance can be independently verified


See [[03-domain/billing/Credit-Movement|Credit Movement]].

## Lifecycle State

Invoice lifecycle states (Draft, Issued, Partially Paid, Paid, Archived) provide an implicit trail of business progression.

Each state reflects a business outcome.

---

# What Is NOT Audited

The following are NOT audited in Version 1.

| Concept | Why Not |
|---------|---------|
| Field-level changes to Drafts | Drafts are working documents; final state is what matters |
| Customer information changes | Customer state is current; historical customer info is not preserved per-version |
| Business configuration changes | Current configuration is what applies; historical configs are not preserved |
| User actions | No user model exists in V1 (see [[Future-Authorization|Future Authorization Model]]) |
| Read access | V1 does not track who viewed what |
| Search queries | Not audited |
| Report generation | Not audited |

These gaps are acceptable given Version 1's scope and single-user assumption.

---

# What Future Versions MAY Add

Future versions MAY introduce a dedicated audit trail.

Anticipated concepts:

- Audit Event
- Audit Event Store
- Audit Event Query
- Actor (User) reference
- Timestamp
- Before / After snapshots

Anticipated triggers:

- Business configuration changes
- Customer information changes
- Invoice lifecycle events
- Payment recording
- Receipt generation
- Customer Credit movement
- Authorization decisions

The introduction of a dedicated audit trail SHALL be documented through an Architecture Decision Record.

---

# Relationship to Regulatory Constraints

- [[01-Requirements/common/Constraints#CON-REG-001|CON-REG-001]] — Long-term document retention
- [[01-Requirements/common/Constraints#CON-REG-002|CON-REG-002]] — Historical records reproducible

Both constraints are satisfied by structural immutability.

No additional audit infrastructure is required to satisfy these constraints in Version 1.

---

# Anti-Patterns to Avoid

## Premature Audit Infrastructure

Introducing an event store before it is justified by business or regulatory requirements.

## Mutable Audit Records

Audit records that can be modified undermine their purpose.

## Silent Modification

Modifying financial records without creating a corresponding historical record.

## Audit Logs Without Retention Policy

Storing audit data without defining retention and access rules.

---

# Related Documents

- [[01-Requirements/billing/Document-Numbering|Document Numbering]]
- [[03-domain/billing/Credit-Movement|Credit Movement]]
- [[02-architecture/Persistence-Strategy|Persistence Strategy]]
- [[02-architecture/Error-Handling|Error Handling]]
- [[01-Requirements/common/Future-Authorization|Future Authorization Model]]
- [[01-Requirements/common/Future-Payment-Correction|Future Payment Correction Model]]