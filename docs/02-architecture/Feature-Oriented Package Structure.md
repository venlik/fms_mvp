# Feature-Oriented Package Structure

## Principle

The Finance Management System SHALL organize source code primarily by business feature (module), rather than by technical type.

The package structure SHALL reflect the business domain.

---

# Rationale

Feature-oriented organization provides:

- Higher cohesion.
- Lower coupling.
- Easier navigation.
- Simpler maintenance.
- Better scalability.

Related concepts remain physically close together.

---

# Preferred Structure

lib/

domain/
    shared/
    billing/

application/
    common/
    billing/

persistence/
    common/
    billing/

ui/
    common/
    billing/

---

# Module Organization

Each business module owns its internal structure.

Example

billing/

business/

customer/

invoice/

receipt/

payment/

Each module contains only concepts belonging to that business capability.

---

# Example

billing/

invoice/

    Invoice

    InvoiceRepository

    InvoiceValidator

    InvoiceMapper

    InvoiceService

    InvoiceController

All Invoice-related concepts remain together.

---

# Discouraged Structure

The following organization SHOULD be avoided.

domain/

entities/

repositories/

services/

value_objects/

validators/

This structure separates closely related concepts across multiple directories.

---

# Benefits

Feature-oriented organization:

- Reduces navigation effort.
- Improves module cohesion.
- Simplifies refactoring.
- Supports independent module evolution.
- Mirrors business terminology.

---

# Future Evolution

As new business modules are introduced, each SHALL follow the same organizational principles.

Examples include:

- Inventory
- Accounting
- Expenses
- Payroll