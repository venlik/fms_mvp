# Concurrency Strategy

## Purpose

This document defines the concurrency strategy for the Finance Management System.

It exists to make an explicit statement about Version 1's concurrency model.

It does NOT introduce concurrency control mechanisms into Version 1.

---

# Version 1 Status

Version 1 operates as a single-user, single-device application.

See [[01-Requirements/common/Assumptions#ASM-OPS-001|ASM-OPS-001]] and [[01-Requirements/common/Assumptions#ASM-USR-004|ASM-USR-004]].

Version 1 SHALL NOT implement concurrency control mechanisms.

Concurrent modification of the same Aggregate is NOT supported in Version 1.

---

# Rationale

The following assumptions hold in Version 1:

- One user operates the application.
- One device runs the application.
- One active window is expected at a time.
- No external systems modify the same data concurrently.

Given these assumptions, concurrency conflicts cannot arise through normal use.

Introducing concurrency control would add complexity without business value.

---

# Expected Operation

## Single Window

The application expects a single active window editing business data.

## Single User

The application expects a single user operating it.

## Single Device

The application runs locally. No distributed access.

## Offline Operation

The application operates without network connectivity.

No remote writes occur.

---

# Explicit Non-Support

## Multiple Windows

Version 1 does NOT support multiple concurrent windows editing the same business data.

If a user opens multiple windows:

- Behavior is undefined.
- Last-write-wins semantics apply.
- The application MAY prevent opening multiple windows.

Preventing multiple windows is a UI concern, not a Domain concern.

## Multiple Users

Version 1 does NOT support multiple users.

See [[01-Requirements/common/Constraints#CON-USR-001|CON-USR-001]].

## Background Writes

Version 1 does NOT perform background writes to business data.

All writes occur in response to user actions.

## External Writers

Version 1 does NOT support external processes modifying business data.

---

# Domain Implications

The Domain model SHALL NOT include:

- Version fields for optimistic locking.
- Timestamps for conflict detection.
- Merging logic for conflicting writes.
- Conflict resolution rules.

These would introduce complexity without current benefit.

---

# Persistence Implications

The Persistence layer SHALL NOT include:

- Optimistic locking infrastructure.
- Distributed transactions.
- Conflict detection.
- Rollback on concurrent modification.

The Persistence layer SHALL assume single-writer access.

---

# UI Implications

The User Interface SHOULD:

- Prevent opening multiple windows if feasible.
- Warn the user if multiple windows are detected.
- Not assume data is unchanged since load.

These are guidance only. Version 1 MAY not implement them.

---

# Future Considerations

Future versions MAY introduce concurrency control when:

- Multi-user support is added.
- Multi-device support is added.
- Background processing is introduced.
- External integrations write to business data.

When introduced, the strategy SHALL be:

- Optimistic locking via version numbers.
- Conflict detection on save.
- Explicit conflict resolution UI.
- Domain errors for conflicts.

The introduction of concurrency control SHALL be documented through an Architecture Decision Record.

---

# Anti-Patterns to Avoid

## Premature Optimistic Locking

Adding version fields to Aggregates before multi-user support.

## Distributed Transactions

Introducing cross-process transaction coordination for a single-device app.

## Complex Merge Logic

Building conflict resolution for conflicts that cannot occur.

## Implicit Concurrency Assumptions

Assuming concurrent access exists when it does not.

---

# Related Assumptions

- [[01-Requirements/common/Assumptions#ASM-OPS-001|ASM-OPS-001]] — Single device operation
- [[01-Requirements/common/Assumptions#ASM-USR-004|ASM-USR-004]] — Single-user operation

---

# Related Constraints

- [[01-Requirements/common/Constraints#CON-USR-001|CON-USR-001]] — No authorization in Version 1
- [[01-Requirements/common/Constraints#CON-PRO-006|CON-PRO-006]] — No cloud synchronization

---

# Related Documents

- [[02-architecture/Persistence-Strategy|Persistence Strategy]]
- [[02-architecture/Layered-Architecture|Layered Architecture]]
- [[02-architecture/Error-Handling|Error Handling]]