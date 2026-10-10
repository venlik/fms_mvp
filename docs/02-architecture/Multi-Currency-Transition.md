# Multi-Currency Transition

## Purpose

This document defines how the Finance Management System enforces single-currency operation in Version 1, and how the system will transition to multi-currency support in a future version.

It exists to:

- Make single-currency enforcement explicit.
- Prevent accidental introduction of multi-currency in Version 1.
- Preserve a clean evolution path when multi-currency is introduced.

It does NOT introduce multi-currency support into Version 1.

---

# Version 1 Constraint

Version 1 SHALL operate using a single configured Business Currency.

See [[01-Requirements/common/Constraints#CON-PRO-005|CON-PRO-005]] and [[01-Requirements/common/shared/Currency#Constraints|Currency Constraints]].

Multi-currency support is out of scope for Version 1.

---

# Why Single-Currency Enforcement Is Needed

The Domain model already supports currency-aware Money.

`Money` combines an amount with a `Currency`.

This is intentional: it future-proofs the model without requiring multi-currency behavior in Version 1.

However, without explicit enforcement, a developer might:

- Allow Money with different currencies on the same Invoice.
- Allow Payments with a currency different from their Invoice.
- Bypass the Business default currency.

Therefore, single-currency SHALL be enforced by Business Rules, not by the Money Value Object.

---

# Enforcement Rules

## Currency Source of Truth

The Business Aggregate owns the default operating currency.

Every financial document SHALL use the Business default currency.

Historical documents SHALL retain the currency they were issued with, even if the Business default later changes.

## Enforcement Points

| Concept | Rule |
|---------|------|
| Invoice | All Invoice Items SHALL use the Business default currency at time of Invoice creation |
| Payment | Payment currency SHALL match the owning Invoice currency |
| Receipt | Receipt currency SHALL match the recorded Payment currency |
| Customer Credit | Customer Credit currency SHALL match the Business default currency |
| Credit Movement | Credit Movement currency SHALL match the Business default currency at time of recording |

## What Is NOT Enforced

The Money Value Object SHALL remain currency-agnostic.

Money SHALL allow construction with any valid Currency.

Money SHALL allow arithmetic between matching currencies only.

Enforcement of a specific currency is a Business Rule concern, not a Money concern.

This separation allows Money to be reused unchanged when multi-currency is introduced.

---

# Currency Change Behavior (Version 1)

A Business MAY change its default operating currency.

## Preconditions

A Business SHALL NOT change its default currency while any Customer Credit balance is non-zero.

Before changing the default currency:

- All Customer Credit balances SHALL be zero.
- Any outstanding Customer Credit SHALL be settled first.

See [[01-Requirements/billing/Currency-Enforcement#BR-CUR-006|BR-CUR-006]].

## Effect of the Change

When the default currency changes:

- Existing Invoices SHALL NOT be re-expressed in the new currency.
- Existing Payments SHALL NOT be re-expressed.
- Existing Receipts SHALL NOT be re-expressed.
- New Invoices SHALL use the new currency.
- Payments SHALL use the currency of their owning Invoice.
- New Customer Credit SHALL use the new currency.

The Business default currency change SHALL be recorded in the Business Aggregate state.

## Rationale

Preventing the currency change while Customer Credit is non-zero avoids an ambiguous state where Customer Credit is denominated in a currency that is no longer the Business default.

---

# Future Multi-Currency Transition

When multi-currency support is introduced, the following transition is anticipated.

## Anticipated Concepts

Future versions MAY introduce:

- Exchange Rate
- Currency Conversion
- Multi-currency Business configuration
- Per-Invoice currency selection
- Reporting across currencies

## Anticipated Rules

Future versions MAY allow:

- Each Customer to have a preferred currency.
- Each Invoice to be issued in a currency different from the Business default.
- Payments to be recorded in a currency different from the Invoice currency, with conversion applied.
- Customer Credit to be held in multiple currencies.

## What Stays Unchanged

The following SHALL remain unchanged during the transition:

- Money continues to combine amount + Currency.
- Money continues to reject arithmetic between incompatible currencies.
- Currency remains an immutable Value Object.
- Identifier remains unchanged.
- Business remains the source of the default currency.

## Migration Path (Anticipated)

When multi-currency is introduced:

1. Existing documents retain their original currency.
2. New documents may choose a currency.
3. Currency conversion is introduced as a new Domain Service.
4. Exchange Rates are configured by the Business.
5. Reporting groups by currency or converts to a reporting currency.

The transition SHALL NOT require rewriting existing documents.

Existing `Money` instances are already currency-aware and require no migration.

---

# Why This Design Is Future-Proof

| Concern | Addressed By |
|---------|--------------|
| Money already stores Currency | No data model change needed |
| Currency is a first-class Value Object | No new concept needed |
| Business owns default currency | Single source of truth |
| Enforcement is by Business Rule | Not baked into Money |
| Historical documents preserve currency | No re-expression |
| Multi-currency can be added per Business Policy | Configurable, not hard-coded |

---

# Related Constraints

- [[01-Requirements/common/Constraints#CON-PRO-005|CON-PRO-005]] — Multi-currency out of scope for Version 1
- [[01-Requirements/common/Constraints#CON-DAT-004|CON-DAT-004]] — Money values always have a Currency
- [[01-Requirements/common/Constraints#CON-DAT-003|CON-DAT-003]] — Persisted financial data internally consistent

---

# Related Business Rules

- [[01-Requirements/billing/Business-Rules#BR-BIL-006|BR-BIL-006]] — Business default currency
- [[01-Requirements/common/shared/Money#BR-MON-001|BR-MON-001]] — Money always has a Currency
- [[01-Requirements/common/shared/Money#BR-MON-002|BR-MON-002]] — Money arithmetic between matching currencies only
- [[01-Requirements/common/shared/Money#BR-MON-004|BR-MON-004]] — Currency conversion out of scope
- [[01-Requirements/common/shared/Money#BR-MON-005|BR-MON-005]] — Single configured Business Currency

---

# Related Documents

- [[01-Requirements/common/shared/Currency|Currency Requirements]]
- [[03-domain/shared/Currency|Currency Domain]]
- [[03-domain/shared/Money|Money Domain]]
- [[Billing-Policies#BP-CUR-001|BP-CUR-001]]
- [[Billing-Policies#BP-CUR-002|BP-CUR-002]]

---

# Evolution

Multi-currency SHALL be introduced only when justified by demonstrated business need.

The introduction of multi-currency SHALL be documented through an Architecture Decision Record.

Enforcement of single-currency in Version 1 SHALL NOT depend on infrastructure or framework behavior.

It SHALL be enforced by the Business Rules documented in this file.