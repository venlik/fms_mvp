# UC-INV-001 — Create Invoice

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-INV-001|UC-INV-001]]

## Application Service

`CreateInvoiceService`

## Purpose

Create a new Draft Invoice for a Customer.

---

# Preconditions

- The active Business exists.
    
- The Customer exists and belongs to the active Business.
    

---

# Postconditions

- A new Draft Invoice exists.
    
- The Invoice has no Document Number.
    
- The Invoice is editable.
    

---

# Aggregates Involved

- Invoice (creation)
    
- Customer (referenced)
    

---

# Transaction Required?

No.

The Invoice Aggregate maintains its own consistency.

---

# Domain Operations Invoked

- `Invoice.Create(business, customer)` — construction validates invariants
    
- `InvoiceRepository.save(invoice)`
    

---

# Cross-Aggregate Conditions

- The Customer must exist.
    
- The Customer must belong to the active Business.
    

These are validated by the Application layer before creating the Invoice.

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Customer not found|Resource Not Found|
|Customer does not belong to active Business|Conflict|

---

# References

- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
    
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]
    
- [[01-Requirements/billing/InvoiceStatus|Invoice Status]]