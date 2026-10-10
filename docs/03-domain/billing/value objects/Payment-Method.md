# Payment Method

## Purpose

Payment Method represents the business mechanism through which a Payment is made.

It standardizes payment channels within the Billing module and provides a consistent representation of accepted payment methods.

Payment Method SHALL serve as the standard representation of payment mechanisms throughout the Billing Domain.

---

# Responsibilities

Payment Method SHALL be responsible for:

- Identifying a payment mechanism.
- Supporting payment method validation.
- Providing payment method identity.
- Standardizing payment method usage across the Billing module.

Payment Method SHALL NOT be responsible for:

- Processing payments.
- Verifying payment transactions.
- Communicating with external payment providers.
- Storing provider-specific transaction data.

---

# System-Defined Methods

The following Payment Methods are defined by the system:

- Cash
- Bank Transfer
- Card
- Mobile Money
- Cheque
- **Customer Credit** — applied from the Customer's credit balance

Business configuration MAY enable or disable individual methods.

---

# Business Rules

Payment Method SHALL enforce the following Business Rules:

- Every Payment SHALL specify exactly one Payment Method.
- Payment Methods SHALL be immutable.
- Payment Method equality SHALL be determined by identity.
- Only supported Payment Methods MAY be used when recording a Payment.

---

# State

Payment Method maintains:

- Its identity.
- A display name.
- An optional description.

The implementation MAY maintain additional metadata where appropriate.

The `Customer Credit` method is a system-defined method. Payments using this method are automatically sourced from the Customer's Customer Credit balance.

---

# Operations

Payment Method supports:

- Identity comparison.
- Equality evaluation.

Payment Method SHALL NOT perform payment processing.

---

# Invariants

The following conditions SHALL always hold:

- Payment Method identity SHALL remain immutable.
- Every Payment Method has a valid identity.
- Display information remains consistent throughout its lifetime.

---

# Collaborators

Payment Method collaborates with:

- Payment

---

# Dependencies

Payment Method SHALL NOT depend upon:

- Payment providers.
- Banking systems.
- Mobile money platforms.
- Infrastructure components.

---

# Validation

Payment Method validates:

- Construction invariants.
- Supported payment method identity.

Validation of business availability belongs to the Business configuration.

---

# Failure Cases

Expected business failures include:

- Invalid Payment Method.
- Unsupported Payment Method.

Expected failures SHALL be represented using the Result model.

Unexpected system failures remain outside the responsibility of Payment Method.

---

# Related Requirements

Functional Requirements

- Payment Recording

Business Rules

- [[01-Requirements/billing/Payment#BR-PAY-001|BR-PAY-001]]
- [[01-Requirements/billing/Payment#BR-PAY-002|BR-PAY-002]]
- [[01-Requirements/billing/Customer-Credit#BR-CC-010|BR-CC-010]]

Business Policies

Future payment policies MAY define which methods are permitted for a Business.

---

# Design Rationale

Payment Method is modeled as a Value Object because it represents a business concept rather than a financial event.

Separating Payment Method from Payment allows new payment mechanisms to be introduced without changing the Payment entity.

---

# Future Considerations

Future versions MAY introduce:

- Business-specific supported methods.
- Default payment methods.
- Method-specific validation rules.
- Integration metadata.

Such additions SHALL preserve Payment Method as a technology-independent Value Object.