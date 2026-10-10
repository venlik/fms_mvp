# Currency Enforcement Business Rules

## Purpose

Defines business rules that enforce single-currency operation in Version 1.

These rules supplement the shared Money and Currency rules by specifying where single-currency is enforced across the Billing module.

See [[02-architecture/Multi-Currency-Transition|Multi-Currency Transition]].

---

## Rules

### BR-CUR-001

Every financial document SHALL use the Business default currency at the time the document is created.

---

### BR-CUR-002

Every Payment SHALL use the same currency as its owning Invoice.

---

### BR-CUR-003

Every Receipt SHALL use the same currency as its recorded Payment.

---

### BR-CUR-004

Every Customer Credit balance SHALL use the Business default currency.

---

### BR-CUR-005

Every Credit Movement SHALL use the Business default currency at the time the movement is recorded.

---
### BR-CUR-006

Changing the Business default currency SHALL NOT alter the currency of existing Invoices, Payments, Receipts, Customer Credit, or Credit Movements.

A Business SHALL NOT change its default currency while any Customer Credit balance is non-zero.

If a Customer Credit balance exists, the Business SHALL settle or clear all Customer Credit balances before changing the default currency.

See [[02-architecture/Multi-Currency-Transition#Currency Change Behavior (Version 1)|Multi-Currency Transition]].

---

### BR-CUR-007

Historical financial documents SHALL retain the currency they were issued with, regardless of later changes to the Business default currency.

---

### BR-CUR-008

Currency conversion SHALL remain outside the scope of Version 1.

See [[01-Requirements/common/shared/Money#BR-MON-004|BR-MON-004]].

---

## Related Documents

- [[01-Requirements/common/shared/Money|Money Business Rules]]
- [[01-Requirements/billing/Business-Rules|Billing Business Rules]]
- [[Billing-Policies#BP-CUR-001|BP-CUR-001]]
- [[02-architecture/Multi-Currency-Transition|Multi-Currency Transition]]