# Document Business Rules

## Purpose

Defines business rules common to all financial documents.

---

## Rules

### BR-DOC-001

Every financial document SHALL have an internal Identifier.

---

### BR-DOC-002

Every official financial document SHALL have a Document Number.

A financial document becomes official when it transitions from Draft to an issued state.

See [[01-Requirements/billing/Document-Numbering#DN-002|DN-002]].

---

### BR-DOC-003

Identifiers SHALL remain immutable.

---

### BR-DOC-004

Document Numbers SHALL follow the configured numbering policy.

Numbering policy includes format, sequence scope, and reset behavior.

See [[01-Requirements/billing/Document-Numbering|Document Numbering]].

---

### BR-DOC-005

Every financial document SHALL record its creation date.

---

### BR-DOC-006

Historical financial documents SHALL remain reproducible.

---

### BR-DOC-007

Exported documents SHALL accurately represent persisted business data.

---

### BR-DOC-008

Document Numbers SHALL be assigned at the moment the document becomes an official business record.

For Invoices, this is the moment of issuance.

For Receipts, this is the moment of generation.

---

### BR-DOC-009

Document Numbers SHALL NOT be reused.

Deleted documents SHALL NOT free their assigned number for reuse.

---

### BR-DOC-010

Gaps in Document Number sequences SHALL be permitted.

Gaps SHALL NOT be filled retroactively.

---

## Related Documents

- [[01-Requirements/billing/Business|Business]]
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
- [[01-Requirements/billing/Receipt|Receipt Business Rules]]

---
## References
- [[Terminology#Business Rule]]
- [[Glossary#Financial Document]]