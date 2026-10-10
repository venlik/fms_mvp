# Finance Management System

# Validation Strategy

## Purpose

This document defines the architectural strategy for validation throughout the Finance Management System.

Validation ensures that data and business operations satisfy the required constraints before affecting the Domain.

---

# Goals

The validation strategy SHALL:

- Preserve Domain integrity.
- Prevent invalid business state.
- Clearly separate validation responsibilities.
- Promote consistent validation across modules.
- Minimize duplicated validation logic.

---

# Validation Levels

Validation occurs at multiple architectural layers.

Each layer validates according to its responsibility.

---

# User Interface Validation

## Responsibility

The User Interface SHALL validate information necessary to provide a good user experience.

Examples include:

- Required fields.
- Numeric input.
- Date selection.
- Input formatting.

User Interface validation SHALL NOT replace Domain validation.

---

# Application Validation

## Responsibility

The Application layer validates use case requirements before coordinating Domain operations.

Examples include:

- Request completeness.
- Authorization.
- Resource existence.
- Transaction coordination.

The Application layer SHALL NOT enforce Business Rules owned by the Domain.

---

# Domain Validation

## Responsibility

The Domain SHALL enforce Business Rules and Domain invariants.

Examples include:

- Invoice must contain at least one item.
- Payment amount must be positive.
- Invoice cannot be paid twice.
- Money values must share the same currency.

The Domain SHALL remain the final authority on business validity.

---

# Tax Validation

Tax validation occurs at multiple points:

## Business Configuration Validation

Tax Rates SHALL be validated on configuration:

- Unique code within the Business.
- Percentage between 0 and 100.
- Non-empty display name.

## Invoice Item Validation

Invoice Item taxes SHALL be validated:

- Applied Tax Rate SHALL exist in the Business configuration at time of application.
- Snapshot SHALL match the applicable Tax Rate at issuance.
- Line Total SHALL accurately reflect Line Subtotal plus applied taxes.

## Currency Precision Validation

Tax amounts SHALL be rounded to the Invoice currency precision.

Rounding SHALL occur per Invoice Item.

---

# Discount Validation

Discount validation occurs at multiple points:

## Business Policy Validation

Business Policies MAY constrain:

- Maximum percentage per discount.
- Maximum total discount per Invoice Item.
- Maximum total discount per Invoice.

## Invoice Item Validation

Invoice Item discounts SHALL be validated:

- Sum of applied discounts SHALL NOT exceed Line Subtotal.
- Each Discount SHALL have a valid type (Percentage or Fixed).
- Percentage discounts SHALL be within [0, 100].
- Fixed discounts SHALL be non-negative and use the Invoice currency.
- Discounts SHALL be applied sequentially in the recorded order.

## Invoice Validation

Invoice-level discount SHALL be validated:

- Invoice-level discount SHALL NOT exceed the sum of Line Discounted Subtotals.
- Only one Invoice-level discount MAY be applied per Invoice.

## Snapshot Validation

Applied discounts and taxes SHALL be captured as snapshots on Invoice Items at issuance.

Snapshots SHALL accurately reflect the discount configuration at issuance.

Changes to Business discount configuration SHALL NOT alter existing snapshots.

---

# Persistence Validation

## Responsibility

Persistence SHALL validate storage integrity.

Examples include:

- Unique constraints.
- Referential integrity.
- Serialization integrity.

Persistence validation SHALL NOT replace Domain validation.

---

# Validation Ownership

Validation SHALL occur as close as practical to the responsibility that owns the rule.

Examples

Input formatting

→ User Interface

Business Rules

→ Domain

Storage constraints

→ Persistence

---

# Validation Duplication

Validation MAY exist in multiple layers for different purposes.

Example

The User Interface may prevent empty input.

The Domain SHALL still reject missing required information.

Domain validation SHALL never rely upon earlier validation.

---

# Validation Results

Business validation SHALL produce Domain Errors through the documented Result model.

Validation failures SHALL NOT be represented using exceptions.

---

# Domain Invariants

Every Domain object SHALL preserve its invariants throughout its lifetime.

Operations that would violate invariants SHALL fail.

No invalid Domain object SHALL exist after construction or successful modification.

---

# Construction Validation

Object construction SHALL validate all mandatory invariants.

Invalid Domain objects SHALL NOT be created.

---

# Operation Validation

Every business operation SHALL validate the rules affected by that operation.

Successful operations SHALL leave the Domain in a valid state.

---

# Benefits

This strategy provides:

- Consistent validation.
- Explicit business failures.
- Strong Domain integrity.
- Reduced duplication.
- Predictable behavior.

---

# Review

Changes to the validation strategy SHALL be documented through an Architecture Decision Record (ADR).