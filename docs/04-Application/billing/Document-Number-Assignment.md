# Document Number Assignment

## Purpose

This document defines how Document Numbers are assigned within the Application layer.

It resolves the application-level workflow referenced by [[01-Requirements/billing/Document-Numbering|Document Numbering]].

---

# Scope

Applies to:

- Invoice Document Numbers
    
- Receipt Document Numbers
    

Applies to the Billing module.

---

# Reference

See [[01-Requirements/billing/Document-Numbering|Document Numbering]] for:

- Uniqueness rules
    
- Assignment on issuance
    
- Immutability
    
- No reuse
    
- Gaps permitted
    
- Policy-driven format
    

---

# Application Layer Responsibilities

## Roles

|Layer|Responsibility|
|---|---|
|Domain|Defines Document Number rules; does not generate or enforce uniqueness|
|Application|Coordinates number generation; invokes repository; retries on conflict|
|Persistence|Enforces uniqueness constraint; persists sequentially|

## Application-Owned Logic

The Application layer SHALL:

- Compute the next Document Number from the configured sequence
    
- Compose it according to the Business's numbering format
    
- Attempt to persist
    
- Retry on conflict (bounded)
    
- Return a Domain Error if retries are exhausted
    

---

# Workflow

When an Application Service assigns a Document Number:

1. The Application Service queries the sequence for the Business and document type.
    
2. The Application Service composes the next Document Number per the configured format.
    
3. The Application Service attempts to persist the document with the composed number.
    
4. If Persistence rejects the write (uniqueness violation):
    
    - The Application Service increments the sequence candidate.
        
    - The Application Service retries.
        
5. Retries SHALL be bounded (e.g., 3 attempts).
    
6. If retries are exhausted, the Application Service returns a Domain Error.
    

Steps 3 through 5 SHALL occur within a single transaction where possible.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

---

# Use Cases That Assign Document Numbers

| Use Case | Document Type |
|----------|---------------|
| UC-INV-007 Issue Invoice | Invoice |
| UC-REC-001 Record Payment | Receipt (via standard flow) |
| UC-INV-006 Apply Customer Credit | Receipt (via standard flow) |
| UC-REC-002 Generate Receipt | Receipt |

Receipt Document Numbers are assigned when a Receipt is generated.

---

# Example — Issue Invoice

`IssueInvoiceService` assigns a Document Number to an Invoice at the moment of issuance.

It:

1. Opens a transaction
    
2. Loads the Invoice Aggregate
    
3. Calls `Invoice.Issue()` — the Domain verifies issuance is valid but does not assign a number
    
4. Computes the next Document Number
    
5. Attempts to persist
    
6. Retries on conflict
    
7. Commits the transaction
    

The Document Number is immutable once assigned.

See [[04-Application/billing/use-cases/UC-INV-007-Issue-Invoice|UC-INV-007]].

---

# Failure Cases

|Failure|Response|
|---|---|
|Sequence exhausted|Domain Error; manual intervention|
|Conflict persists after retries|Domain Error; persistence integrity concern|
|Missing sequence configuration|Domain Error; Business configuration incomplete|

See [[01-Requirements/billing/Document-Numbering#Failure Cases|Document Numbering — Failure Cases]].

---

# Interaction with Transaction

The Document Number assignment and the Invoice status transition SHALL commit together.

If the Invoice fails to persist with the assigned number, the transaction rolls back and the sequence counter is not advanced.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

---

# Sequence Storage

A sequence SHALL be tracked per:

- Business
    
- Document Type (Invoice, Receipt)
    

Sequences MAY reset per Business policy.

See [[01-Requirements/billing/Document-Numbering|Document Numbering]].

The Application layer is responsible for querying the sequence and composing the next number. Sequence storage is a Persistence concern.

---

# Retries

Retries SHALL be bounded.

Retries SHALL be safe (idempotent in effect — the sequence is only advanced on successful commit).

The Application layer SHALL NOT retry indefinitely.

---

# Related Documents

- [[01-Requirements/billing/Document-Numbering|Document Numbering]]
- [[04-Application/shared/Application-Services|Application Services]]
- [[04-Application/shared/Transaction-Management|Transaction Management]]
- [[04-Application/billing/use-cases/UC-INV-007-Issue-Invoice|UC-INV-007]]