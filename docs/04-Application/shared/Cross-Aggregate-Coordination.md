# Cross-Aggregate Coordination

## Purpose

This document defines how the Application layer coordinates operations that span multiple Aggregates.

It exists to make cross-Aggregate coordination consistent across the Billing module and to prepare for future modules.

---

# Principle

Aggregates maintain their own consistency independently.

Cross-Aggregate operations are coordinated by the Application layer.

No Aggregate directly modifies another Aggregate.

See [[03-domain/Aggregate-Map#Rule 2 — Aggregate Consistency and Cross-Aggregate Operations|Aggregate Map — Rule 2]].

---

# When Coordination Is Needed

Cross-Aggregate coordination is needed when a single use case:

- Modifies two or more Aggregates
    
- Modifies one Aggregate and persists a Domain Record
    
- Requires atomic commit across multiple persistence operations
    

---

# Coordination Pattern

The Application Service SHALL:

1. Open a transaction (if not already open)
    
2. Load the required Aggregates
    
3. Invoke Domain operations on each Aggregate
    
4. Ensure each Aggregate maintains its own invariants
    
5. Verify any cross-Aggregate business conditions
    
6. Persist changes through repositories
    
7. Commit the transaction
    
8. On failure, roll back
    

Each Aggregate is modified only through its Aggregate Root.

---

# Billing Module Examples

## Record Payment

Only touches the Invoice Aggregate.

Not a cross-Aggregate operation.

## Apply Customer Credit

Touches:

- Invoice Aggregate (records Payment, updates Balance, transitions Status)
    
- Customer Aggregate (updates Customer Credit Value Object)
    
- Credit Movement (persists a new Domain Record)
    

Requires cross-Aggregate coordination.

See [[04-Application/billing/use-cases/UC-INV-006-Apply-Customer-Credit|UC-INV-006]].

## Issue Invoice with Document Number

Touches:

- Invoice Aggregate (assigns Document Number, transitions Status)
    
- Document Number Sequence (increments a persisted counter)
    

Requires cross-Aggregate coordination of a special kind (transaction + retry).

See [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]].

---

# Cross-Aggregate Business Conditions

Some business conditions involve multiple Aggregates.

Example — Apply Customer Credit:

- The Invoice must belong to the Customer.
    
- The Customer must have sufficient Credit.
    
- The Invoice must be in Issued or Partially Paid status.
    

These conditions SHALL be checked by the Application layer before invoking Domain operations.

The Domain SHALL NOT enforce cross-Aggregate invariants.

See [[03-domain/Aggregate-Map#Rule 4 — No Cross-Aggregate Invariants|Aggregate Map — Rule 4]].

---

# Atomicity Requirements

Cross-Aggregate operations SHALL be atomic.

If any step fails, the entire operation SHALL roll back.

No partial state SHALL remain.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

---

# Order of Operations

When coordinating cross-Aggregate changes, the Application Service SHALL order operations carefully:

1. Load all Aggregates
    
2. Validate cross-Aggregate conditions
    
3. Invoke Domain operations in a valid order
    
4. Persist changes
    
5. Commit
    

The order SHOULD minimize the risk of partial success if an unexpected failure occurs mid-operation.

---

# Interaction with Domain Records

Domain Records (e.g., Credit Movement) are persisted through their own repository.

The Application layer coordinates:

- Aggregate updates
    
- Domain Record creation
    

...within the same transaction.

See [[03-domain/billing/Credit-Movement|Credit Movement]].

---

# Future Modules

Future business modules MAY introduce their own cross-Aggregate operations.

The coordination pattern in this document SHALL be reused.

---

# Anti-Patterns to Avoid

## Aggregate Manipulates Another Aggregate

An Aggregate SHALL NOT load or modify another Aggregate directly.

## Cross-Aggregate Invariants Inside an Aggregate

An Aggregate SHALL NOT enforce invariants that depend on another Aggregate's state.

## Distributed Transactions

V1 is single-device. Cross-process transaction coordination is unnecessary.

## Partial Commit

Partial success is not acceptable. Roll back on failure.

---

# Related Documents

- [[04-Application/shared/Transaction-Management|Transaction Management]]
    
- [[04-Application/shared/Application-Services|Application Services]]
    
- [[03-domain/Aggregate-Map|Aggregate Map]]
    
- [[03-domain/billing/Customer-Credit-Workflow|Customer Credit Workflow]]
    
- [[03-domain/billing/Credit-Movement|Credit Movement]]