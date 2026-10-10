# UC-REC-002 — Generate Receipt

## Use Case Reference

[[01-Requirements/common/Use-Cases#UC-REC-002|UC-REC-002]]

## Application Service

`GenerateReceiptService`

## Purpose

Generate a Receipt as documentary evidence of a successfully recorded Payment.

---

# Preconditions

- A successfully recorded Payment exists.
    
- The Payment has not already been receipted.
    

---

# Postconditions

- A Receipt exists.
    
- The Receipt references the Payment and the Invoice.
    
- A Receipt Document Number is assigned.
    

---

# Aggregates Involved

- Receipt (creation)
    
- Document Number Sequence (modification for Receipt Document Number)
    

---

# Transaction Required?

Yes.

Receipt creation and Receipt Document Number assignment must commit together.

---

# Domain Operations Invoked

- `Receipt.Generate(payment, invoice)` — construction validates invariants
    
- `ReceiptRepository.save(receipt)`
    

---

# Application-Owned Logic

The Application Service assigns the Receipt Document Number.

See [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]].

---

# Cross-Aggregate Conditions

- The Payment must exist and be successfully recorded.
    
- The associated Invoice must exist.
    

---

# Failure Modes

|Failure|Domain Error|
|---|---|
|Payment not found|Resource Not Found|
|Payment not successfully recorded|Business Rule Violation|
|Duplicate Receipt Document Number|Conflict|
|Sequence configuration missing|Configuration Error|

---

# References

- [[01-Requirements/billing/Receipt|Receipt Business Rules]]
    
- [[03-domain/billing/aggregates/Receipt|Receipt Aggregate]]
    
- [[03-domain/billing/Credit-Movement|Credit Movement]]
    
- [[04-Application/billing/Document-Number-Assignment|Document Number Assignment]]