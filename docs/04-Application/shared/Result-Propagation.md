# Result Propagation

## Purpose

This document defines how Result objects flow from the Domain through the Application layer to the User Interface.

It exists to ensure consistent handling of expected business outcomes across the system.

---

# Core Principle

Expected business failures SHALL be represented using Result.

Expected business failures SHALL NOT be represented using exceptions.

See [[02-architecture/Error-Handling|Error Handling]].

---

# Result Model (Recap)

Result  
├── SuccessResult<T>  
└── ErrorResult

- `SuccessResult<T>` carries the operation outcome.
    
- `ErrorResult` carries a Domain Error.
    

See [[03-domain/shared/Result|Result]].

---

# Propagation Rules

## Domain → Application

Domain operations return Result.

Application Services SHALL NOT unwrap Result and convert it to an exception.

If a Domain operation returns ErrorResult, the Application Service SHALL propagate it.

## Application → UI

Application Services return Result to the UI.

The UI presents Domain Errors to the user in a human-readable way.

The UI SHALL NOT reinterpret Domain Errors as different business meanings.

## Cross-Application-Service Coordination

When an Application Service invokes another Application Service, it SHALL propagate the Result directly.

No conversion. No swallowing.

---

# Handling Failure

## What the Application Layer Does with ErrorResult

- Propagate the failure to the caller
    
- Roll back any open transaction
    
- Not retry unless the use case explicitly allows retry (e.g., Document Number conflict)
    

## What the Application Layer Does NOT Do with ErrorResult

- Log it as an error (expected failures are not errors)
    
- Wrap it in an exception
    
- Translate it to a different type
    
- Discard it
    

---

# Handling Success

## What the Application Layer Does with SuccessResult

- Commit any open transaction
    
- Return the Result to the caller
    

The success value MAY carry:

- An identifier of a newly created Aggregate
    
- A summary of the operation
    
- Nothing (when no data is relevant)
    

---

# Unexpected Failures

Unexpected system failures (e.g., disk full, database corruption, programming defects) SHALL use exceptions.

They SHALL NOT be converted to Domain Errors.

The Application layer MAY translate infrastructure exceptions into Domain-independent exceptions, but SHALL NOT convert them into Result failures.

See [[02-architecture/Error-Handling|Error Handling]].

---

# Examples

## Example — Successful Issue

`IssueInvoiceService` calls `Invoice.Issue()`.

The Domain returns SuccessResult carrying the assigned Document Number.

Application Service commits the transaction.

Application Service returns SuccessResult to the UI.

## Example — Domain Rejects Operation

`IssueInvoiceService` calls `Invoice.Issue()`.

The Domain returns ErrorResult because the Invoice has no items.

Application Service rolls back (no changes were made).

Application Service returns the ErrorResult to the UI.

The UI displays the Domain Error message to the user.

## Example — Infrastructure Failure

`IssueInvoiceService` attempts to persist changes.

The Persistence layer throws an infrastructure exception.

The Application Service propagates the exception (not a Result).

The caller handles it as an unexpected failure.

---

# UI Responsibilities

The UI SHALL:

- Display Domain Errors in human-readable form
    
- Not attempt to interpret Domain Errors differently
    
- Not suppress Domain Errors
    
- Not treat Domain Errors as catastrophic
    

Domain Errors are expected business outcomes.

See [[04-Application/shared/Application-Services|Application Services]].

---

# Anti-Patterns to Avoid

## Exception for Expected Failure

Throwing an exception when a Domain rule rejects an operation.

## Swallowing Domain Errors

Ignoring an ErrorResult and proceeding as if the operation succeeded.

## Re-Wrapping Domain Errors

Converting Domain Errors into different error types unnecessarily.

## Silent Success

Returning SuccessResult when the operation actually failed.

---

# Related Documents

- [[02-architecture/Error-Handling|Error Handling]]
    
- [[03-domain/shared/Result|Result]]
    
- [[03-domain/shared/DomainError|Domain Error]]
    
- [[04-Application/shared/Application-Services|Application Services]]