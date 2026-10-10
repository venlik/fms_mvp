# UC-INV-005 — Duplicate Invoice

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-INV-005|UC-INV-005]]

## Application Service

`DuplicateInvoiceService`

## Purpose

Create a new Draft Invoice using an existing Invoice as a starting point.

---

# Preconditions

- The source Invoice exists.
    
- The source Invoice belongs to the active Business.
    

---

# Postconditions

- A new Draft Invoice exists.
    
- The source Invoice is unchanged.
    
- The new Invoice references the source via `duplicatedFromId`.
    
- No Document Number is assigned.
    
- No Payments or Receipts are copied.
    

---

# Aggregates Involved

- Invoice (creation of a new Aggregate based on a source)
    

---

# Transaction Required?

No.

Only one new Invoice Aggregate is created. The source is unchanged.

---

# Domain Operations Invoked

- `Invoice.DuplicateFrom(source)` — construction of the new Draft
    
- `InvoiceRepository.save(newInvoice)`
    

---

# Cross-Aggregate Conditions

- The Customer referenced by the source Invoice must be accessible (including archived Customers).
    
- Archived Customers are valid for historical financial documents.
    

See [[01-Requirements/billing/Invoice-Duplication|Invoice Duplication]].

---

# What Is Copied

- Business reference
    
- Customer reference
    
- Invoice Items (description, quantity, unit price)
    
- Discount configuration (business references)
    
- Tax Rate references (business references)
    
- Invoice-level Discount configuration
    
- Invoice notes


---

# What Is NOT Copied

- Identifier
    
- Document Number
    
- Status
    
- Payments
    
- Receipts
    
- Outstanding Balance
    
- Issuance snapshots
    

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Source Invoice not found|Resource Not Found|
|Source Invoice belongs to different Business|Conflict|
|Customer not accessible|Resource Not Found|
|Invoice Item copy failure|Integrity Error|

---

# References

- [[01-Requirements/billing/Invoice-Duplication|Invoice Duplication]]
    
- [[01-Requirements/billing/Invoice|Invoice Business Rules]]
    
- [[03-domain/billing/aggregates/Invoice|Invoice Aggregate]]