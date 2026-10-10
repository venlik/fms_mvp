# Domain Error

## Purpose

Defines the requirements governing Domain Errors.

Domain Errors represent expected business failures.

---

## Responsibilities

Domain Errors SHALL:

- Describe business rule violations.
- Communicate why an operation could not succeed.
- Support consistent error handling throughout the Domain.

---

## Constraints

- Domain Errors SHALL represent expected failures.
- Domain Errors SHALL NOT represent programming defects.
- Domain Errors SHALL contain sufficient information for diagnosis.
- Domain Errors SHALL remain independent of presentation concerns.

---

## Related Business Rules

- [[01-Requirements/common/common#BR-COM-002|BR-COM-002]]

---

## Related Concepts

- Result
- Business Rule
- Validation

---

## Future Considerations

Future versions MAY categorize Domain Errors by business module.