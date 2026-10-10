# UC-CUS-006 — View Customer Credit History

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-CUS-006|UC-CUS-006]]

## Application Service

`ViewCustomerCreditHistoryService`

## Purpose

Return the chronological list of Credit Movements for a Customer.

---

# Preconditions

- The Customer exists.
    

---

# Postconditions

- The list of Credit Movements is returned in chronological order.
    

---

# Aggregates Involved

- Customer (read-only reference)
    
- Credit Movement (read-only query)
    

---

# Transaction Required?

No.

Read-only operation.

---

# Domain Operations Invoked

- `CreditMovementRepository.findByCustomer(customerId)` — returns movements chronologically
    

---

# Cross-Aggregate Conditions

None.

Credit Movements are Domain Records queried independently of the Customer Aggregate.

See [[03-domain/billing/Credit-Movement|Credit Movement]].

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Customer not found|Resource Not Found|

---

# References

- [[01-Requirements/billing/Customer-Credit|Customer Credit Business Rules]]
    
- [[03-domain/billing/Credit-Movement|Credit Movement]]
    
- [[03-domain/Aggregate-Map#Rule 5 — Domain Records Are Outside Aggregates|Aggregate Map — Rule 5]]