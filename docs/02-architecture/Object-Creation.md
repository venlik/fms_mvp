# Finance Management System

# Object Creation

## Purpose

This document defines the architectural strategy for creating Domain objects.

The strategy aims to preserve Domain consistency while avoiding unnecessary complexity.

---

# Goals

Object creation SHALL:

- Preserve Domain invariants.
- Produce valid Domain objects.
- Keep construction simple.
- Introduce additional creation mechanisms only when justified.

---

# General Principle

Domain objects SHALL be responsible for protecting their own invariants during creation.

No Domain object SHALL exist in an invalid state.

---

# Constructors

Constructors are the preferred mechanism for object creation.

Constructors SHALL:

- Validate required invariants.
- Initialize all mandatory state.
- Reject invalid construction.

Constructors SHOULD remain simple.

---

# Factories

Factories SHALL be introduced only when object creation becomes sufficiently complex.

Examples include:

- Multiple creation paths.
- Complex initialization.
- Creation requiring external collaboration.

Factories SHALL NOT become the default creation mechanism.

---

# Builders

Builders SHALL NOT be introduced unless object construction demonstrates genuine complexity.

Version 1 SHALL NOT use Builders.

---

# Object Reconstitution

Previously persisted Domain objects MAY be reconstituted without repeating business operations.

Reconstitution SHALL preserve the original business state.

Reconstitution SHALL NOT bypass Domain consistency.

The exact reconstitution mechanism is implementation-dependent.

---

# Aggregate Creation

Aggregate creation SHALL ensure all Aggregate invariants are satisfied before the Aggregate becomes available for use.

Aggregate Roots SHALL be responsible for maintaining Aggregate consistency.

---

# Value Objects

Value Objects SHOULD be immutable.

Construction SHALL fully define the Value Object.

Invalid Value Objects SHALL NOT be created.

---

# Entities

Entities SHALL maintain a stable identity throughout their lifetime.

Creation SHALL establish that identity.

---

# Creation Simplicity

The simplest creation mechanism that satisfies current requirements SHOULD be preferred.

Additional abstractions SHALL emerge from demonstrated need rather than anticipation.

---

# Future Evolution

As the Domain evolves, additional creation mechanisms MAY be introduced.

Examples include:

- Domain Factories
- Abstract Factories
- Object Pools

Such mechanisms SHOULD be justified through an Architecture Decision Record (ADR).