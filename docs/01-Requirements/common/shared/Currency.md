# Currency

## Purpose

Defines the requirements governing Currency within the Finance Management System.

Currency identifies the monetary unit associated with financial values.

---

## Responsibilities

Currency SHALL:

- Identify the monetary unit of Money.
- Ensure monetary values are interpreted consistently.
- Provide a common currency reference throughout the Billing module.
- Support future expansion to multiple currencies.

---

## Constraints

- Every Currency SHALL have a unique identifier or code.
- Currency SHALL remain immutable once defined.
- Version 1 SHALL operate using a single configured Business Currency.
- Currency SHALL NOT perform monetary calculations.
- Currency SHALL NOT enforce Business-level currency policies. Those are enforced through Business Rules.

---

## Single-Currency Enforcement

Enforcement of single-currency operation is a Business Rule concern, not a Currency concern.

Currency remains currency-agnostic and reusable across currencies.

See [[01-Requirements/billing/Currency-Enforcement|Currency Enforcement Business Rules]] and [[02-architecture/Multi-Currency-Transition|Multi-Currency Transition]].

---

## Related Business Rules

- [[01-Requirements/common/shared/Money#BR-MON-001|BR-MON-001]]
- [[01-Requirements/common/shared/Money#BR-MON-002|BR-MON-002]]
- [[01-Requirements/common/shared/Money#BR-MON-005|BR-MON-005]]

---

## Related Concepts

- Money
- Business
- Invoice
- Receipt
- Payment

---

## Future Considerations

Future versions MAY support:

- Multiple business currencies.
- Exchange rates.
- Currency conversion.
- Currency formatting rules.