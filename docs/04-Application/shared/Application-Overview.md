# Application Overview

## Purpose

This document defines the role, responsibilities, and boundaries of the Application layer within the Finance Management System.

The Application layer coordinates business operations. It orchestrates Domain objects, manages transactions, and produces operation outcomes — but does not itself contain business rules.

---

# Role

The Application layer sits between the User Interface and the Domain.

It is responsible for:

- Executing use cases
    
- Coordinating Domain objects
    
- Managing transactions
    
- Communicating with repositories
    
- Returning operation results
    

It is NOT responsible for:

- Enforcing business rules (Domain's responsibility)
    
- Rendering user interfaces (UI's responsibility)
    
- Implementing persistence (Persistence's responsibility)
    
- Deciding what is valid business behavior (Domain's responsibility)
    

---

# Position in the Architecture

User Interface  
↓  
Application ← this layer  
↓  
Domain  
↑  
Persistence

- The UI calls Application services.
    
- Application services invoke Domain behavior.
    
- Application services talk to Persistence through Domain-defined repository contracts.
    

See [[02-architecture/Layered-Architecture|Layered Architecture]].

---

# What the Application Layer Does

## Orchestrates Use Cases

Each use case is realized as a single Application Service (or handler) that:

1. Validates request shape (not business rules)
    
2. Loads the required Aggregates through repositories
    
3. Invokes Domain operations
    
4. Coordinates cross-Aggregate changes when atomicity is required
    
5. Persists the results through repositories
    
6. Returns a Result to the caller
    

See [[04-Application/shared/Application-Services|Application Services]].

## Manages Transactions

The Application layer defines transaction boundaries.

Transactions that touch multiple Aggregates are coordinated here.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

## Preserves Result Model

The Result pattern flows from the Domain through the Application to the UI.

Application services SHALL preserve Result semantics — they SHALL NOT convert Domain Errors into exceptions.

See [[04-Application/shared/Result-Propagation|Result Propagation]].

## Coordinates Cross-Aggregate Operations

Some operations span multiple Aggregates (e.g., Recording a Payment that generates Customer Credit).

The Application layer coordinates these operations atomically.

See [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]].

---

# What the Application Layer Does NOT Do

## No Business Rules

If a rule is a Business Rule, it lives in the Domain.

If a policy is configurable, it lives in the Domain's configuration.

The Application layer MAY invoke policy-driven behavior, but SHALL NOT implement the policy.

## No Domain Logic Duplication

Application services SHALL NOT re-validate what the Domain already validates.

They SHALL trust the Domain to reject invalid operations via Result.

## No Persistence Implementation

Application services talk to repository interfaces. They do not know about databases, ORMs, or file systems.

## No UI Concerns

Application services return Domain-friendly Result objects. They do not format them for display, translate them to user messages, or decide what to show.

---

# Application Layer Concepts

|Concept|Description|
|---|---|
|Application Service|One handler per use case|
|Repository Contract|Domain-defined interface used by Application services|
|Transaction|Atomic unit of work coordinated by the Application layer|
|Result Propagation|Passing Result objects cleanly between layers|
|Cross-Aggregate Coordination|Coordinated changes across multiple Aggregates|

---

# Organization

The Application layer is organized by business module:

```Text
04-Application/  
├── shared/ ← Cross-module patterns  
│ ├── Application-Overview  
│ ├── Application-Services  
│ ├── Transaction-Management  
│ ├── Result-Propagation  
│ └── Cross-Aggregate-Coordination  
│  
└── billing/ ← Billing module  
  ├── Document-Number-Assignment  
  └── use-cases/ ← One file per use case
```

This mirrors the structure of `03-domain/`.

See [[02-architecture/Feature-Oriented Package Structure|Feature-Oriented Package Structure]].

---

# Related Documents

- [[02-architecture/Layered-Architecture|Layered Architecture]]
    
- [[02-architecture/Feature-Oriented Package Structure|Feature-Oriented Package Structure]]
    
- [[02-architecture/Dependency-Rules|Dependency Rules]]
    
- [[04-Application/shared/Application-Services|Application Services]]
    
- [[04-Application/shared/Transaction-Management|Transaction Management]]
    
- [[04-Application/shared/Result-Propagation|Result Propagation]]
    
- [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]]
    
- [[02-architecture/adr/ADR-003|ADR-003 — Application Service Structure]]
    

---