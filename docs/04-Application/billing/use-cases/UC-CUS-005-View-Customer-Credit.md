# UC-CUS-005 — View Customer Credit

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-CUS-005|UC-CUS-005]]

## Application Service

`ViewCustomerCreditService`

## Purpose

Return the current Customer Credit balance for a Customer.

---

# Preconditions

- The Customer exists.
    

---

# Postconditions

- The current Customer Credit balance is returned.
    

---

# Aggregates Involved

- Customer (read-only)
    

---

# Transaction Required?

No.

This is a read-only operation.

---

# Domain Operations Invoked

- `Customer.Credit` — reads the current Customer Credit Value Object
    

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Customer not found|Resource Not Found|

---

# References

- [[01-Requirements/billing/Customer-Credit|Customer Credit Business Rules]]
    
- [[03-domain/billing/value objects/Customer-Credit|Customer Credit]]
    
- [[03-domain/billing/aggregates/Customer|Customer Aggregate]]