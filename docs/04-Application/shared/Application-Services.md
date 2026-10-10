# Application Services

## Purpose

This document defines the pattern, structure, and conventions for Application Services within the Finance Management System.

An Application Service is the application-layer realization of a single use case.

---

# Definition

An Application Service is a single unit of application logic that executes one business operation.

One use case → one Application Service.

Application Services SHALL be named after the use case they realize.

Example: `UC-INV-002 — Issue Invoice` → `IssueInvoiceService`.

---

# Responsibilities

An Application Service SHALL be responsible for:

- Receiving a request (a plain data structure or parameters)
    
- Validating request shape (not business rules)
    
- Loading the required Aggregates through repositories
    
- Invoking Domain operations on those Aggregates
    
- Coordinating cross-Aggregate changes when atomicity is required
    
- Persisting the results through repositories
    
- Returning a Result
    

An Application Service SHALL NOT be responsible for:

- Enforcing Business Rules
    
- Rendering UI
    
- Implementing persistence
    
- Making business decisions
    

---

# Structure

Every Application Service SHALL follow the same general shape:

1. Parse the incoming request
    
2. Load required Aggregates
    
3. Invoke the Domain operation
    
4. Handle the Result
    
5. Persist what changed (in a transaction if needed)
    
6. Return a Result
    

Application Services SHALL be small. If an Application Service becomes large, it usually indicates a missing Domain concept.

---

# Naming Convention

Application Service names SHALL follow:

<Verb><Noun>Service

Examples:

- `RegisterCustomerService`
    
- `IssueInvoiceService`
    
- `RecordPaymentService`
    
- `ApplyCustomerCreditService`
    

The name SHALL match the use case name.

---

# Input and Output

## Input

Application Services MAY accept:

- An explicit request object with named fields
    
- Individual parameters (for very simple use cases)
    

The input shape SHALL be explicit. No implicit context.

## Output

Application Services SHALL return a Result.

- Success carries the operation outcome (e.g., the identifier of a newly created Invoice)
    
- Failure carries a Domain Error
    

See [[04-Application/shared/Result-Propagation|Result Propagation]].

---

# Dependencies

An Application Service MAY depend upon:

- Repository interfaces (defined by the Domain)
    
- Other Application Services (rare; usually a sign of a missing use case)
    
- Domain concepts (Aggregates, Entities, Value Objects)
    

An Application Service SHALL NOT depend upon:

- UI components
    
- Persistence implementations
    
- Frameworks
    
- Databases
    

See [[02-architecture/Dependency-Rules|Dependency Rules]].

---

# One Handler Per Use Case

The Application layer uses one handler per use case — not one service per Aggregate, and not one service per business operation cluster.

## Rationale

- Direct correspondence with Use Case identifiers
    
- Each handler is small and testable
    
- Document numbering retries, cross-aggregate coordination, and transaction boundaries can be tailored to each use case
    
- No "god services" that accumulate unrelated operations
    

## Example Mapping

| Use Case | Application Service |
|----------|---------------------|
| UC-CUS-001 Register Customer | RegisterCustomerService |
| UC-CUS-003 Archive Customer | ArchiveCustomerService |
| UC-CUS-005 View Customer Credit | ViewCustomerCreditService |
| UC-CUS-006 View Customer Credit History | ViewCustomerCreditHistoryService |
| UC-INV-001 Create Invoice | CreateInvoiceService |
| UC-INV-002 Edit Invoice | EditInvoiceService |
| UC-INV-005 Duplicate Invoice | DuplicateInvoiceService |
| UC-INV-007 Issue Invoice | IssueInvoiceService |
| UC-REC-001 Record Payment | RecordPaymentService |
| UC-REC-002 Generate Receipt | GenerateReceiptService |
| UC-INV-006 Apply Customer Credit | ApplyCustomerCreditService |
| UC-REP-001..004 Reporting Services | Generate*ReportService |

See [[02-architecture/adr/ADR-003|ADR-003 — Application Service Structure]].

---

# Relationship to Domain

Application Services invoke Domain behavior but do not implement it.

Example:

- Application Service: `IssueInvoiceService`
    
- Domain behavior: `Invoice.Issue()` returns `Result`
    
- Application Service calls `Invoice.Issue()`, then persists the updated Invoice.
    

Business rules like "Invoice must have items before issuance" live inside `Invoice.Issue()`, not in `IssueInvoiceService`.

---

# Relationship to Persistence

Application Services interact with the Domain through repository interfaces.

They SHALL NOT:

- Construct persistence-specific objects
    
- Reference database schemas
    
- Perform queries directly
    
- Know about transactions at the storage level
    

See [[02-architecture/Persistence-Strategy|Persistence Strategy]].

---

# Testability

Application Services SHALL be testable without a UI.

Tests SHOULD:

- Use in-memory repository implementations
    
- Verify that the correct Domain operations were invoked
    
- Verify the returned Result
    
- Verify cross-aggregate coordination when applicable
    

See [[02-architecture/Testing-Strategy|Testing Strategy]].

---

# Anti-Patterns to Avoid

## Business Logic in Application Services

If a rule answers "is this valid business behavior?", it belongs in the Domain.

## God Services

One service that handles many use cases drifts toward a procedural god object.

## Anemic Application Services

If an Application Service only forwards a call to a repository, it may indicate a missing use case or an unnecessary layer.

## Exception-Based Control Flow

Application Services SHALL NOT throw exceptions for expected business failures.

Expected failures are Results.

---

# Related Documents

- [[04-Application/shared/Application-Overview|Application Overview]]
    
- [[04-Application/shared/Transaction-Management|Transaction Management]]
    
- [[04-Application/shared/Result-Propagation|Result Propagation]]
    
- [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]]
    
- [[02-architecture/adr/ADR-003|ADR-003 — Application Service Structure]]
    
- [[02-architecture/Testing-Strategy|Testing Strategy]]
    

---