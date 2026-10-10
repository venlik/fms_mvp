# UC-CUS-001 — Register Customer

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-CUS-001|UC-CUS-001]]

## Application Service

`RegisterCustomerService`

## Purpose

Create a new Customer within the active Business.

---

# Preconditions

- The active Business exists.
    
- The caller has supplied the required customer information.
    

---

# Postconditions

- A new Customer exists.
    
- The Customer belongs to the active Business.
    
- The Customer is available for future financial transactions.
    

---

# Aggregates Involved

- Customer (creation)
    

---

# Transaction Required?

No.

The Customer Aggregate maintains its own consistency.

---

# Domain Operations Invoked

- `Customer.Create(...)` — construction validates invariants
    
- `CustomerRepository.save(customer)`
    

---

# Cross-Aggregate Conditions

None.

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Missing required customer information|Validation Error|
|Duplicate customer where prohibited|Conflict|
|Business not found|Resource Not Found|

---

# References

- [[01-Requirements/billing/Customer|Customer Business Rules]]
    
- [[03-domain/billing/aggregates/Customer|Customer Aggregate]]
    
- [[04-Application/shared/Application-Services|Application Services]]