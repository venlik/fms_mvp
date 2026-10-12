## Invoices and Historical Accuracy

- [ ] **Edit an item's price after issuing an invoice**
      _Expect:_ the stored invoice still shows the original price in its
                saved PDF, but re-rendering the PDF (if the saved one is
                missing) will show the new price.
      _Why manual:_ this is a known limitation, not a bug. Verify the
                behavior matches the documented policy.