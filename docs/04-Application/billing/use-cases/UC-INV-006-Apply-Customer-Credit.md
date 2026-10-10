# UC-INV-006 — Apply Customer Credit

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-INV-006|UC-INV-006]]

## Application Service

`ApplyCustomerCreditService`

## Purpose

Apply available Customer Credit to reduce an Invoice's outstanding balance.

---

# Preconditions

- The Customer has available Customer Credit.
    
- The Invoice belongs to the same Customer.
    
- The Invoice is in Issued or Partially Paid status.
    
- The Business's Customer Credit application policy permits it.
    

See [[01-Requirements/billing/Billing-Policies#BP-PAY-004|BP-PAY-004]].

---

# Postconditions

- A Payment is recorded with Payment Method = `Customer Credit`.
    
- The Invoice Balance is reduced.
    
- The Invoice status transitions appropriately (Partially Paid or Paid).
    
- The Customer Credit Value Object is reduced.
    
- A Credit Movement is recorded with direction `Applied`.
    
- A Receipt is generated through the standard payment flow.
    

---

# Aggregates Involved

- Invoice (modification)
    
- Customer (modification)
    
- Credit Movement (creation)
    

---

# Transaction Required?

Yes.

This is a canonical cross-Aggregate operation.

See [[04-Application/shared/Transaction-Management|Transaction Management]].

---

# Domain Operations Invoked

- `Invoice.RecordPayment(payment)` — Domain records the Payment with the Customer Credit method
    
- `Customer.ApplyCredit(amount)` — Domain updates Customer Credit Value Object
    
- `CreditMovementRepository.save(movement)`
    

---

# Application-Owned Logic

Steps:

1. Open a transaction
    
2. Load the Invoice and Customer
    
3. Verify cross-Aggregate conditions:
    
    - Invoice belongs to Customer
        
    - Customer has sufficient Credit
        
    - Invoice is in Issued or Partially Paid status
        
4. Determine the applied amount:
    
    - Applied amount SHALL NOT exceed available Customer Credit
        
    - Applied amount SHALL NOT exceed Invoice outstanding Balance
        
5. Invoke `Invoice.RecordPayment(...)` with method Customer Credit
    
6. Invoke `Customer.ApplyCredit(amount)`
    
7. Persist a Credit Movement record with direction `Applied`
    
8. Persist Invoice and Customer
    
9. Generate a Receipt through the standard payment flow
    
10. Commit
    

If any step fails, roll back.

See [[03-domain/billing/Customer-Credit-Workflow|Customer Credit Workflow]].

---

# Cross-Aggregate Conditions

- Same Customer for Invoice and Credit
    
- Sufficient Credit available
    
- Invoice status permits payment
    

These are checked by the Application layer.

The Domain does NOT enforce cross-Aggregate invariants.

See [[03-domain/Aggregate-Map#Rule 4 — No Cross-Aggregate Invariants|Aggregate Map — Rule 4]].

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Customer has insufficient Credit|Business Rule Violation|
|Invoice does not belong to Customer|Conflict|
|Invoice status does not permit payment|Business Rule Violation|
|Applied amount exceeds Invoice Balance|Business Rule Violation|
|Credit application policy forbids operation|Configuration Error|

---

# Atomicity

The following SHALL commit together:

- Invoice Payment / Balance / Status change
    
- Customer Credit Value Object update
    
- Credit Movement record
    

See [[01-Requirements/billing/Customer-Credit#BR-CC-007|BR-CC-007]].

---

# References

- [[01-Requirements/billing/Customer-Credit|Customer Credit Business Rules]]
    
- [[01-Requirements/billing/Customer-Credit#BR-CC-014|BR-CC-014]]
    
- [[03-domain/billing/Customer-Credit-Workflow|Customer Credit Workflow]]
    
- [[03-domain/billing/Credit-Movement|Credit Movement]]
    
- [[04-Application/shared/Cross-Aggregate-Coordination|Cross-Aggregate Coordination]]
    
- [[04-Application/shared/Transaction-Management|Transaction Management]]