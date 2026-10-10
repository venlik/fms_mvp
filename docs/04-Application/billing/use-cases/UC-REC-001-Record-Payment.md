# UC-REC-001 — Record Payment

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-REC-001|UC-REC-001]]

## Application Service

`RecordPaymentService`

## Purpose

Record a payment received from a Customer against an Invoice.

---

# Preconditions

- The Invoice exists.
    
- The Invoice is in Issued or Partially Paid status.
    
- The payment amount is positive.
    
- The payment currency matches the Invoice currency.
    

---

# Postconditions

- The Payment is recorded against the Invoice.
    
- The Invoice Balance is reduced.
    
- The Invoice status is updated (Partially Paid or Paid).
    
- If overpayment policy permits, excess is recorded as Customer Credit.
    
- A Receipt is generated for the Payment.
    

---

# Aggregates Involved

- Invoice (modification)
    

Optionally, when overpayment is accepted:

- Customer (modification)
    
- Credit Movement (creation)
    

---

# Transaction Required?

- Single-Aggregate path (no overpayment): No
    
- Overpayment path: Yes (Invoice + Customer + Credit Movement)
    

---

# Domain Operations Invoked

- `Invoice.RecordPayment(payment)` — Domain validates the payment
    
- `InvoiceRepository.save(invoice)`
    

Overpayment path also invokes:

- `Customer.GrantCredit(...)` — updates Customer Credit Value Object
    
- `CreditMovementRepository.save(movement)`
    

---

# Application-Owned Logic

If overpayment is accepted:

1. Open a transaction
    
2. Load the Invoice and Customer
    
3. Verify overpayment policy permits acceptance
    
4. Invoke `Invoice.RecordPayment()`
    
5. Compute excess and invoke `Customer.GrantCredit(...)`
    
6. Persist a Credit Movement record
    
7. Persist Invoice and Customer
    
8. Commit
    

See [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]].

---

# Receipt Generation

A Receipt is generated as part of the standard payment flow.

See [[03-domain/billing/aggregates/Receipt|Receipt Aggregate]].

---

# Cross-Aggregate Conditions

- If overpayment accepted, the excess MUST be recorded as Customer Credit on the same Customer.
    
- The Customer Credit and Credit Movement MUST commit with the Invoice change.
    

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Invoice not eligible for payment|Business Rule Violation|
|Payment amount is not positive|Validation Error|
|Currency mismatch|Conflict|
|Overpayment rejected by policy|Business Rule Violation|
|Customer Credit grant failed|Integrity Error|

---

# References

- [[01-Requirements/billing/Payment|Payment Business Rules]]
    
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
    
- [[01-Requirements/billing/Billing-Policies#BP-PAY-002|BP-PAY-002]]
    
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]
    
- [[03-domain/billing/aggregates/Customer|Customer Aggregate]]
    
- [[03-domain/billing/Credit-Movement|Credit Movement]]