# Document Numbering

## Purpose

Defines how Document Numbers are generated, assigned, and enforced across the Billing module.

This specification resolves the uniqueness enforcement mechanism referenced by [[01-Requirements/billing/Invoice#BR-INV-006|BR-INV-006]] and [[01-Requirements/billing/Document#BR-DOC-004|BR-DOC-004]].

---

# Scope

Applies to:

- Invoice Document Numbers
- Receipt Document Numbers

Future financial documents SHALL follow the same mechanism.

---

# Numbering Principles

## DN-001 — Uniqueness

Document Numbers SHALL be unique within the Business for their document type.

Invoice and Receipt sequences are independent.

---

## DN-002 — Assignment on Issuance

An Invoice Document Number SHALL be assigned at the moment the Invoice transitions from Draft to Issued.

A Receipt Document Number SHALL be assigned at the moment the Receipt is generated.

Drafts SHALL NOT have a Document Number.

---

## DN-003 — Immutability

Once assigned, a Document Number SHALL NOT change.

See [[01-Requirements/common/shared/Document-Number#Constraints|Document Number Constraints]].

---

## DN-004 — No Reuse

Document Numbers SHALL NOT be reused.

Once a Document Number is assigned, it remains permanently associated with that document.

---

## DN-005 — Gaps Permitted

Gaps in the sequence MAY occur.

Gaps SHALL NOT be considered errors.

Gaps SHALL NOT be filled retroactively.

---

## DN-006 — Policy-Driven Format

The Business SHALL configure the format of Document Numbers.

Format configuration MAY include:

- Prefix (e.g., `INV-`, `REC-`)
- Date component (Year, Month, or none)
- Sequential counter
- Suffix (optional)

See [[Billing-Policies#BP-NUM-001|BP-NUM-001]] through [[Billing-Policies#BP-NUM-004|BP-NUM-004]].

---

## DN-007 — Single Source of Truth

Uniqueness SHALL be enforced by the Persistence layer through a unique constraint on `(businessId, documentType, documentNumber)`.

The Application layer SHALL coordinate number assignment and retry on conflict.

---

# Enforcement Architecture

## Responsibilities

| Layer | Responsibility |
|-------|----------------|
| Domain | Defines Document Number rules; does not generate or enforce uniqueness |
| Application | Coordinates number generation; invokes repository; retries on conflict |
| Persistence | Enforces uniqueness constraint; persists sequentially |

## Enforcement Flow

1. Application receives request to assign a Document Number.
2. Application queries the current sequence for the Business and document type.
3. Application composes the next Document Number per configured format.
4. Application attempts to persist the document with the composed number.
5. Persistence rejects the write if the number already exists.
6. Application retries with the next number.
7. On success, the Document Number is assigned.

## Race Condition Handling

If two concurrent operations attempt to assign the same number:

- Persistence accepts one write.
- Persistence rejects the other with a uniqueness violation.
- Application catches the violation and retries with the next number.

Retries SHALL be bounded (e.g., 3 attempts) before returning a Domain Error.

---

# Sequence Storage

## Sequence Scope

A sequence SHALL be tracked per:

- Business
- Document Type (Invoice, Receipt)

## Reset Policy

Per [[Billing-Policies#BP-NUM-004|BP-NUM-004]], sequences MAY reset:

- Never (default)
- Yearly
- Monthly

When a reset occurs:

- A new sequence SHALL begin.
- The previous sequence SHALL remain unchanged.
- Historical documents SHALL retain their original numbers.

## Sequence Format

A sequence SHALL store:

- Current counter value
- Reset period (Never / Yearly / Monthly)
- Last reset date

---

# Numbering Policy Changes

## Effect on Existing Documents

Changing the numbering policy SHALL NOT alter existing Document Numbers.

Historical documents SHALL retain their assigned numbers.

## Effect on New Documents

New documents SHALL follow the current policy.

The sequence counter SHALL continue from the last used value unless a reset policy dictates otherwise.

---

# Failure Cases

## FC-DN-001 — Sequence Exhausted

If the sequence counter overflows its configured width, the Application SHALL return a Domain Error.

Manual intervention SHALL be required.

## FC-DN-002 — Conflict Persists

If the Application retries exhaust without success, a Domain Error SHALL be returned.

This indicates a persistence-layer integrity issue, not a business failure.

## FC-DN-003 — Missing Sequence Configuration

If the Business has no numbering policy configured, a Domain Error SHALL be returned.

Business configuration SHALL be completed before Invoices are issued.

---

# Related Requirements

- [[01-Requirements/billing/Invoice#BR-INV-005|BR-INV-005]]
- [[01-Requirements/billing/Invoice#BR-INV-006|BR-INV-006]]
- [[01-Requirements/billing/Receipt#BR-REC-007|BR-REC-007]]
- [[01-Requirements/billing/Receipt#BR-REC-008|BR-REC-008]]
- [[01-Requirements/billing/Document#BR-DOC-002|BR-DOC-002]]
- [[01-Requirements/billing/Document#BR-DOC-004|BR-DOC-004]]

---

# Related Policies

- [[Billing-Policies#BP-NUM-001|BP-NUM-001]]
- [[Billing-Policies#BP-NUM-002|BP-NUM-002]]
- [[Billing-Policies#BP-NUM-003|BP-NUM-003]]
- [[Billing-Policies#BP-NUM-004|BP-NUM-004]]

---

# Related Documents

- [[01-Requirements/common/shared/Document-Number|Document Number]]
- [[03-domain/billing/value objects/Document-Number|Document Number Value Object]]
- [[02-architecture/Persistence-Strategy|Persistence Strategy]]