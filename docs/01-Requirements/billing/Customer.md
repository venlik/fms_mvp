# Customer Business Rules

## Purpose

Defines business rules governing Customers within the Billing module.

Customers represent individuals or organizations purchasing goods or services from the Business.

See [[Glossary#Customer|Glossary]] & [[Terminology#Customer|Terminology]]

---

## Rules

### BR-CUS-001

Every Customer SHALL have a unique Identifier.

---

### BR-CUS-002

Every Customer SHALL belong to exactly one Business.

---

### BR-CUS-003

Archived Customers SHALL remain available for historical financial documents.

---

### BR-CUS-004

A Customer MAY own multiple Invoices.

---

### BR-CUS-005

A Customer MAY own multiple Receipts.

---

### BR-CUS-006

Deleting a Customer SHALL NOT invalidate historical financial records.

---

### BR-CUS-007

Customer contact information MAY change without modifying previously issued financial documents.

---

## Related Documents

-  [[01-Requirements/billing/Business|Billing Business Rules]]
