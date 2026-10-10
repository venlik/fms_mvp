# Billing Business Rules

## Purpose

This document defines business rules that apply to the Billing module as a whole.

These rules govern interactions between Billing aggregates and establish module-wide policies.

---

## Scope

These rules apply to:

- Business
- Customer
- Invoice
- Invoice Item
- Receipt
- Payment

---

## Rules

### BR-BIL-001

Every Invoice SHALL belong to exactly one Business.

---

### BR-BIL-002

Every Receipt SHALL be issued by exactly one Business.

---

### BR-BIL-003

Every Customer SHALL belong to exactly one Business.

---

### BR-BIL-004

Business data SHALL be configurable without affecting historical financial documents unless explicitly permitted by business policy.

---

### BR-BIL-005

All financial documents SHALL use the Business's configured document numbering policies.

---

### BR-BIL-006

All monetary values SHALL use the Business's configured default currency unless explicitly overridden by future business policies.

In Version 1, no override is permitted.

Currency enforcement is detailed in [[01-Requirements/billing/Currency-Enforcement|Currency Enforcement Business Rules]].

---

### BR-BIL-007

The Billing module SHALL preserve historical financial records.
Historical documents SHALL NOT be modified in ways that alter their financial meaning.

---

## Related Documents

- [[01-Requirements/billing/Business|Business]]
- [[01-Requirements/billing/Customer|Customer]]
- [[01-Requirements/billing/Invoice|Invoice]]
- [[01-Requirements/billing/Receipt|Receipt]]
- [[01-Requirements/billing/Payment|Payment]]