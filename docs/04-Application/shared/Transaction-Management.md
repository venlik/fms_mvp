# Transaction Management

## Purpose

This document defines how transactions are scoped, opened, and coordinated within the Application layer.

It exists to make atomicity explicit for operations that touch more than one Aggregate.

---

# Principles

## TM-001 — One Aggregate, One Consistency Boundary

An Aggregate maintains its own consistency.

Operations that touch only one Aggregate are naturally atomic.

## TM-002 — Cross-Aggregate Operations Require Explicit Transactions

Operations that modify multiple Aggregates MUST be coordinated within a single Application-layer transaction.

## TM-003 — The Application Layer Owns Transaction Boundaries

Transaction boundaries are declared by the Application Service that executes the use case.

Domain code does not open transactions. Persistence code does not decide boundaries.

## TM-004 — All-or-Nothing

A transaction SHALL either:

- Commit fully
    
- Fail without persisting anything
    

Partial persistence SHALL NOT occur.

See [[02-architecture/Persistence-Strategy|Persistence Strategy]].

---

# When Transactions Are Required

|Scenario|Transaction Needed?|
|---|---|
|Read-only operation|No|
|Operation on a single Aggregate|No (aggregate-level atomicity is implicit)|
|Operation that modifies two or more Aggregates|Yes|
|Operation that modifies one Aggregate + persists a Domain Record|Yes|
|Operation that modifies one Aggregate + triggers a side effect requiring consistency|Yes|

---

# Transaction Scopes by Use Case

| Use Case | Transaction Required? | Aggregates / Records Involved |
|----------|-----------------------|-------------------------------|
| UC-CUS-001 Register Customer | No | Customer only |
| UC-CUS-002 Update Customer | No | Customer only |
| UC-CUS-003 Archive Customer | No | Customer only |
| UC-INV-001 Create Invoice | No | Invoice only |
| UC-INV-002 Edit Invoice | No | Invoice only |
| UC-INV-005 Duplicate Invoice | No | Invoice only |
| UC-INV-007 Issue Invoice | Yes | Invoice + Document Number Sequence |
| UC-REC-001 Record Payment | No (single-aggregate) / Yes (overpayment) | Invoice only / + Customer + Credit Movement |
| UC-INV-006 Apply Customer Credit | Yes | Invoice + Customer + Credit Movement |

---

# Coordination Pattern

When an operation requires a transaction, the Application Service SHALL:

1. Open a transaction
    
2. Load the required Aggregates
    
3. Invoke Domain operations (respecting each Aggregate's own consistency)
    
4. Persist all changes through repositories
    
5. Commit
    
6. On any failure, roll back
    

The Domain does not know a transaction exists.

See [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]].

---

# Example — Apply Customer Credit

The Apply Customer Credit operation modifies three things atomically:

- Invoice (records Payment, updates Balance, transitions Status)
    
- Customer (updates Customer Credit Value Object)
    
- Credit Movement (persists a new record)
    

The Application Service coordinates these within a single transaction.

See [[04-Application/billing/use-cases/UC-INV-006-Apply-Customer-Credit|UC-INV-006]].

---

# Example — Issue Invoice

The Issue Invoice operation modifies two things atomically:

- Invoice (assigns Document Number, transitions Status to Issued)
    
- Document Number Sequence (increments the counter)
    

Because Document Numbers must be unique, the transaction is required.

See [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]].

---

# Interaction with Persistence

The Persistence layer provides the transaction mechanism.

The Application layer decides when to use it.

Persistence SHALL NOT decide transaction boundaries.

See [[02-architecture/Persistence-Strategy|Persistence Strategy]].

---

# Rollback Behavior

On failure, the transaction SHALL roll back completely.

The caller receives a Result with a Domain Error.

No partial state SHALL remain.

---

# Retries

Some failure modes (e.g., Document Number conflict) MAY be handled by retry within the Application Service.

Retries SHALL be bounded.

Retried operations SHALL occur within the same or a new transaction, depending on the failure mode.

See [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]].

---

# Anti-Patterns to Avoid

## Cross-Aggregate Invariants

Do not enforce an invariant that spans Aggregates inside any single Aggregate.

Cross-Aggregate checks belong in the Application layer.

## Distributed Transactions

V1 runs on a single device. There is no need for cross-process transaction coordination.

## Long-Running Transactions

Transactions SHALL be short and scoped to a single use case.

## Transactions Without Need

Do not open transactions for single-Aggregate operations. The Aggregate already provides consistency.

---

# Related Documents

- [[04-Application/shared/Application-Overview|Application Overview]]
    
- [[04-Application/shared/Application-Services|Application Services]]
    
- [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]]
    
- [[03-domain/Aggregate-Map|Aggregate Map]]
    
- [[02-architecture/Persistence-Strategy|Persistence Strategy]]