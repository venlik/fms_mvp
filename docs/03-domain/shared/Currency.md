# Currency

## Purpose

Currency represents the monetary unit associated with a monetary value.

It provides the identity required to distinguish monetary values belonging to different financial systems.

Currency SHALL serve as the standard representation of currencies throughout the Domain.

---

# Responsibilities

Currency SHALL be responsible for:

- Identifying a monetary unit.
- Supporting currency equality.
- Providing information required by Money.
- Preserving currency identity.

Currency SHALL NOT be responsible for:

- Currency conversion.
- Exchange rates.
- Currency formatting.
- Monetary arithmetic.

---

# Business Rules

Currency SHALL enforce the following Business Rules:

- Every Currency SHALL have a unique identity.
- Currency instances SHALL be immutable.
- Currency equality SHALL be determined by currency identity.

---

# State

Currency maintains:

- A unique currency identifier.
- A display name.
- A display symbol.
- Decimal precision.

The exact representation of these values is implementation-dependent.

---

# Operations

Currency supports the following operations:

- Equality evaluation.
- Identity comparison.

Currency SHALL NOT perform financial calculations.

---

# Invariants

The following conditions SHALL always hold:

- Currency identity SHALL NOT change after creation.
- Display information SHALL remain consistent throughout the lifetime of the Currency.
- Decimal precision SHALL remain fixed for a Currency instance.

---

# Collaborators

Currency collaborates with:

- Money

---

# Dependencies

Currency SHALL NOT depend upon any other Domain concept.

---

# Validation

Currency validates:

- Construction invariants.
- Currency identity.

Validation SHALL preserve the consistency of Currency instances.

---

# Failure Cases

Expected business failures include:

- Invalid Currency construction.

Unexpected system failures are outside the responsibility of Currency.

---

# Related Requirements

Shared Requirements

- Currency
- Money

Business Rules

Referenced through Money.

Business Policies

None.

---

# Future Considerations

Future versions MAY introduce:

- ISO 4217 currency definitions.
- Organization-specific currencies.
- Cryptocurrency support.
- Currency localization.

Such additions SHALL preserve Currency as an immutable Value Object.