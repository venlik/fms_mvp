# UC-CUS-003 — Archive Customer

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-CUS-003|UC-CUS-003]]

## Application Service

`ArchiveCustomerService`

## Purpose

Prevent further business operations on a Customer while preserving historical records.

---

# Preconditions

- The Customer exists.
    
- The Customer belongs to the active Business.
    

---

# Postconditions

- The Customer is archived.
    
- Historical Invoices, Receipts, and Payments remain valid.
    
- The Customer remains available for historical reference.
    

---

# Aggregates Involved

- Customer (modification)
    

---

# Transaction Required?

No.

The Customer Aggregate maintains its own consistency.

---

# Domain Operations Invoked

- `Customer.Archive()` — Domain validates the transition
    
- `CustomerRepository.save(customer)`
    

---

# Cross-Aggregate Conditions

None.

Archived Customers remain valid for historical financial documents.

See [[01-Requirements/billing/Customer#BR-CUS-003|BR-CUS-003]].

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Customer not found|Resource Not Found|
|Customer already archived|Conflict|

---

# References

- [[01-Requirements/billing/Customer|Customer Business Rules]]
    
- [[03-domain/billing/aggregates/Customer|Customer Aggregate]]