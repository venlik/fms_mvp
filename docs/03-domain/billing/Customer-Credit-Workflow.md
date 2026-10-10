# Customer Credit Workflow

## Purpose

Defines the business operations that change a Customer's credit balance.

Each operation atomically:

- Replaces the Customer's Customer Credit Value Object.
- Persists a Credit Movement record.

---

# Operations

# Version 1 Creation Paths

Only two paths create Credit Movements in Version 1.

## Path A — Grant via Overpayment

**Trigger**  
A Payment exceeds the outstanding Invoice Balance **and** the Business overpayment policy (BP-PAY-002) is set to “Accept and record Customer Credit”.

**Atomic steps**
1. Invoice records the Payment and settles its Balance to zero (status → Paid).
2. Excess amount is calculated.
3. Customer’s Customer Credit Value Object is replaced with a new instance (amount increased by the excess).
4. A Credit Movement is recorded:
   - Direction: `Granted`
   - Reason: `Overpayment`
   - Source: Invoice Identifier
   - Amount: excess amount
5. A Receipt is generated for the Payment (standard flow).

## Path B — Apply Customer Credit to Invoice

**Trigger**  
User explicitly applies available Customer Credit to an Invoice that is in Issued or Partially Paid status.

**Atomic steps**
1. System verifies:
   - Available Customer Credit ≥ requested amount
   - Invoice belongs to the same Customer
   - Invoice status permits payment
2. Invoice records a Payment with Payment Method = `Customer Credit`.
3. Invoice Balance is reduced (status transitions to Partially Paid or Paid as appropriate).
4. Customer’s Customer Credit Value Object is replaced with a new instance (amount reduced).
5. A Credit Movement is recorded:
   - Direction: `Applied`
   - Target: Invoice Identifier
   - Amount: applied amount
6. A Receipt is generated through the standard payment flow.

Both paths SHALL satisfy the atomicity requirement defined in BR-CC-007.

---

# Atomicity

Grant and Apply operations SHALL be atomic.

The Customer's Customer Credit VO update and the Credit Movement record SHALL commit or roll back together.

### Atomicity Requirement

The following three changes SHALL be committed in a single Application-layer transaction:

1. Update of the Customer’s Customer Credit Value Object
2. Persistence of the corresponding Credit Movement record
3. (When applicable) the related Invoice Payment / Balance / Status change

If any of the three fails, the entire transaction SHALL be rolled back.
No partial state (Customer Credit updated without a matching Credit Movement, or vice versa) SHALL ever be visible.


---

# Cross-Aggregate Coordination

Applying Credit touches two Aggregates:

- Invoice (records Payment, updates Balance and Status)
- Customer (updates Customer Credit VO)

The Application layer coordinates both and persists them in a single transaction.

---

# Related Requirements

Business Rules

- [[01-Requirements/billing/Customer-Credit|Customer Credit Business Rules]]

Business Policies

- [[Billing-Policies#BP-PAY-002|BP-PAY-002]]

Use Cases

- [[01-Requirements/common/Use-Cases#UC-INV-006|UC-INV-006 Apply Customer Credit]]
- [[01-Requirements/common/Use-Cases#UC-CUS-005|UC-CUS-005 View Customer Credit]]
- [[01-Requirements/common/Use-Cases#UC-CUS-006|UC-CUS-006 View Customer Credit History]]

---

# Future Considerations

Future versions MAY introduce:

- Automatic credit application on Invoice Issuance (policy-driven).
- Partial credit application workflows.
- Credit expiration on movement grants.
- Prepaid deposits (standalone credit grants).
- Credit transfer between Customers.