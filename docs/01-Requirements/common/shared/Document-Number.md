# Document Number

## Purpose

Defines the requirements governing Document Numbers.

Document Numbers provide human-readable references for financial documents.

---

## Responsibilities

Document Numbers SHALL:

- Identify financial documents for users.
- Support business record keeping.
- Support document retrieval.
- Follow the configured numbering policy.

---

## Constraints

- Every financial document SHALL have one Document Number.
- Document Numbers SHALL be unique according to Business policy.
- Document Numbers MAY contain business meaning.
- Document Numbers SHALL NOT replace internal Identifiers.

---

## Related Business Rules

- [[Document#BR-DOC-002|BR-DOC-002]]
- [[Document#BR-DOC-004|BR-DOC-004]]
- [[01-Requirements/billing/Invoice#BR-INV-005|BR-INV-005]]
- [[01-Requirements/billing/Receipt#BR-REC-007|BR-REC-007]]

---

## Related Concepts

- Invoice
- Receipt
- Business
- Identifier

---

## Future Considerations

Future versions MAY support configurable numbering strategies.