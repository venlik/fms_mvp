# Identifier

## Purpose

Defines the requirements governing Identifiers.

Identifiers uniquely distinguish entities throughout the Finance Management System.

---

## Responsibilities

Identifiers SHALL:

- Uniquely identify an Entity.
- Remain stable throughout an Entity's lifetime.
- Support reliable referencing between aggregates.

---

## Constraints

- Every Entity SHALL have exactly one Identifier.
- Identifiers SHALL be immutable.
- Identifiers SHALL NOT encode business meaning.
- Identifiers SHALL remain unique within their scope.

---

## Related Business Rules

- [[01-Requirements/billing/Business#BR-BUS-001|BR-BUS-001]]
- [[01-Requirements/billing/Business#BR-BUS-002|BR-BUS-002]]
- [[01-Requirements/billing/Customer#BR-CUS-001|BR-CUS-001]]

---

## Related Concepts

- Business
- Customer
- Invoice
- Receipt
- Payment
- Document Number

---

## Future Considerations

Future versions MAY introduce multiple identifier generation strategies.